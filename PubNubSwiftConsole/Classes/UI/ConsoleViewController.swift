//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub

enum StaticCellType: String {
    case pubKey = "Publish Key"
    case subKey = "Subscribe Key"
    case channels = "Channels"
    case channelGroups = "Channel Groups"
    
    func contents(client: PubNub) -> String? {
        switch self {
        case .pubKey:
            return client.currentConfiguration().publishKey
        case .subKey:
            return client.currentConfiguration().subscribeKey
        case .channels:
            return client.channelsString()
        case .channelGroups:
            return client.channelGroupsString()
        }
    }
    
    var isTappable: Bool {
        switch self {
        case .channels, .channelGroups:
            return true
        default:
            return false
        }
    }
}

protocol StaticItemSection {
    var items: [StaticCellType] {get}
    var count: Int {get}
    func item(for type: StaticCellType) -> Int?
    var section: Int {get}
    func title(for type: StaticCellType) -> String
    func title(for indexPath: IndexPath) -> String
    func contents(for indexPath: IndexPath, with client: PubNub) -> String?
    func contents(for type: StaticCellType, with client: PubNub) -> String?
    func indexPath(for type: StaticCellType) -> IndexPath?
    func type(for indexPath: IndexPath) -> StaticCellType
}

extension StaticItemSection {
    var count: Int {
        return items.count
    }
    func item(for type: StaticCellType) -> Int? {
        return items.index(of: type)
    }
    
    func title(for type: StaticCellType) -> String {
        return type.rawValue
    }
    
    func contents(for type: StaticCellType, with client: PubNub) -> String? {
        return type.contents(client: client)
    }
    
    func type(for indexPath: IndexPath) -> StaticCellType {
        guard indexPath.section == section else {
            fatalError("Wrong section")
        }
        guard indexPath.item >= 0 else {
            fatalError("Must be positive or 0 index")
        }
        guard indexPath.item < count else {
            fatalError("Can't index past array")
        }
        return items[indexPath.row]
    }
    
    func title(for indexPath: IndexPath) -> String {
        return type(for: indexPath).rawValue
    }
    
    func contents(for indexPath: IndexPath, with client: PubNub) -> String? {
        return type(for: indexPath).contents(client: client)
    }
    
    func indexPath(for type: StaticCellType) -> IndexPath? {
        guard let item = item(for: type) else {
            return nil
        }
        return IndexPath(item: item, section: section)
    }
}

public class ConsoleViewController: ViewController, ConsoleLayoutDelegate, ConsoleDelegate, ConsoleDataSource, NSFetchedResultsControllerDelegate {
    
    struct ConfigurationSection: StaticItemSection {
        var section: Int {
            return 0
        }
        let items: [StaticCellType] = [.pubKey, .subKey, .channels, .channelGroups]
    }
    let configurationSection = ConfigurationSection()
    
    let console: SwiftConsole
    let collectionView: ConsoleCollectionView
    
    public required init(console: SwiftConsole) {
        let bounds = UIScreen.main.bounds
        let layout = ConsoleLayout()
        self.collectionView = ConsoleCollectionView(frame: .zero, collectionViewLayout: layout)
        self.console = console
        super.init()
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        collectionView.consoleDelegate = self
        collectionView.viewContext = console.viewContext
        collectionView.consoleDataSource = self
        collectionView.forceAutoLayout()
        collectionView.backgroundColor = UIColor.red
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())

        let views = [
            "collectionView": collectionView,
        ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        
        collectionView.reloadData()
        console.client.addListener(self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        let channelsIndexPath = configurationSection.indexPath(for: .channels)
        let channelGroupsIndexPath = configurationSection.indexPath(for: .channelGroups)
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [channelsIndexPath!, channelGroupsIndexPath!])
        })
    }
    
    // MARK: - ConsoleDataSource
    
    func consoleView(_ consoleView: ConsoleCollectionView, numberOfItemsInConfigurationSection subSection: Int) -> Int {
        return configurationSection.count
    }
    
    func numberOfSectionsInConfigurationSection(in consoleView: ConsoleCollectionView) -> Int {
        return 1
    }
    
    func consoleView(_ consoleView: ConsoleCollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let titleContentsCell = cell as? TitleContentsCollectionViewCell else {
            fatalError()
        }
        let title = configurationSection.title(for: indexPath)
        let contents = configurationSection.contents(for: indexPath, with: console.client)
        titleContentsCell.update(title: title, contents: contents)
    }
    
    var coreDataSection: Int? {
        return 1
    }
    
    func consoleView(_ consoleView: ConsoleCollectionView, reuseIdentifierForConfigurationItemAt indexPath: IndexPath) -> String {
        return TitleContentsCollectionViewCell.reuseIdentifier()
    }
    
    // MARK: - UIConsoleDelegate
    
    func consoleView(_ consoleView: ConsoleCollectionView, didSelect result: Result) {
        print("\(#function) result: \(result.debugDescription)")
    }
    
    func consoleView(_ consoleView: ConsoleCollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function) indexPath: \(indexPath.debugDescription)")
    }
    
    // MARK: - PNObjectEventListener
    
    @objc(client:didReceiveStatus:)
    public func client(_ client: PubNub, didReceive status: PNStatus) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! \(#function)")
        guard (status.operation == .subscribeOperation) || (status.operation == .unsubscribeOperation) else {
            return
        }
        updateSubscribablesCells(client: client)
    }
    
}
