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

protocol Thing {
    var isTappable: Bool { get }
}

extension Thing {
    var isTappable: Bool {
        return false
    }
}

struct TitleContentsThing: Thing {
    let title: String
    let contents: String?
}

enum ClientCellType: String {
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
    
    func updateThing(client: PubNub) -> TitleContentsThing {
        let title = rawValue
        let possibleContents = contents(client: client)
        return TitleContentsThing(title: title, contents: possibleContents)
    }
}

extension ClientCellType: Thing {}

protocol ThingSection {

    // MARK: Must define
    init(items: [Thing])
    var items: [Thing] {get}
    func item(for thing: Thing) -> Int?
    
    // MARK: Extended
    subscript(item: Int) -> Thing { get }
    func thing(for item: Int) -> Thing
    func isTappable(at item: Int) -> Bool
    var count: Int {get}
    
    
}

extension ThingSection {
    
    var count: Int {
        return items.count
    }
    
    func thing(for item: Int) -> Thing {
        return items[item]
    }
    
    func isTappable(at item: Int) -> Bool {
        return thing(for: item).isTappable
    }
    
    subscript(item: Int) -> Thing {
        return thing(for: item)
    }
}

struct ClientSection: ThingSection {
    var items: [Thing]
    init(items: [Thing]) {
        assert(items is [ClientCellType])
        self.items = items
    }
    
    func item(for thing: Thing) -> Int? {
        guard let staticCell = thing as? ClientCellType else {
            return nil
        }
        guard let castedItems = items as? [ClientCellType] else {
            return nil
        }
        return castedItems.index(of: staticCell)
    }
    
    
}

/*
protocol ClientSection: ThingSection {
    func item(for type: StaticCellType) -> Int?
    func title(for type: StaticCellType) -> String
    func title(for indexPath: IndexPath) -> String
    func contents(for indexPath: IndexPath, with client: PubNub) -> String?
    func contents(for type: StaticCellType, with client: PubNub) -> String?
    func indexPath(for type: StaticCellType) -> IndexPath?
    func type(for indexPath: IndexPath) -> StaticCellType
    subscript(indexPath: IndexPath) -> StaticCellType { get }
    subscript(item: Int) -> StaticCellType { get }
}
 */

/*
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
    func isTappable(at indexPath: IndexPath) -> Bool
}

extension StaticItemSection {
    
    func isTappable(at indexPath: IndexPath) -> Bool {
        return type(for: indexPath).isTappable
    }
    
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
 */

protocol ConfigurationDataSource {
    
    // Must define
    init(sections: [ThingSection])
    var sections: [ThingSection] { get }
    
    // Extended
    func thingSection(for section: Int) -> ThingSection
    subscript(section: Int) -> ThingSection { get }
    subscript(indexPath: IndexPath) -> Thing { get }
    func thing(for indexPath: IndexPath) -> Thing
    func isTappable(at indexPath: IndexPath) -> Bool
}

extension ConfigurationDataSource {
    
    func thingSection(for section: Int) -> ThingSection {
        return sections[section]
    }
    
    subscript(section: Int) -> ThingSection {
        return thingSection(for: section)
    }
    subscript(indexPath: IndexPath) -> Thing {
        return thing(for: indexPath)
    }
    func thing(for indexPath: IndexPath) -> Thing {
        return thingSection(for: indexPath.section).thing(for: indexPath.item)
    }
    func isTappable(at indexPath: IndexPath) -> Bool {
        return thing(for: indexPath).isTappable
    }
}


public class ConsoleViewController: ViewController, ConsoleLayoutDelegate, ConsoleDelegate, ConsoleDataSource, NSFetchedResultsControllerDelegate {
    
    /*
    struct ConfigurationSection: StaticItemSection {
        var section: Int {
            return 0
        }
        let items: [StaticCellType] = [.pubKey, .subKey, .channels, .channelGroups]
    }
    
    let configurationSection = ConfigurationSection()
 */
    struct MainConsoleDataSource: ConfigurationDataSource {
        var sections: [ThingSection]
        
        init(sections: [ThingSection]) {
            self.sections = sections
        }
        
        init() {
            let configurationSection = ClientSection(items: [ClientCellType.pubKey, ClientCellType.subKey])
            let subscribeSection = ClientSection(items: [ClientCellType.channels, ClientCellType.channelGroups])
            self.init(sections: [configurationSection, subscribeSection])
        }
        
        var subscribableIndexSet: IndexSet {
            return IndexSet(integer: 1)
        }
    }
    
    
    let configurationDataSource: MainConsoleDataSource = {
        print("configurationDataSource: \(#function)")
        //let configurationSection = ClientSection(items: [ClientCellType.pubKey, ClientCellType.subKey])
        //let subscribeSection = ClientSection(items: [ClientCellType.channels, ClientCellType.channelGroups])
        //return MainConsoleDataSource(sections: [configurationSection, subscribeSection])
        
        let section = ClientSection(items: [ClientCellType.pubKey, ClientCellType.subKey, ClientCellType.channels, ClientCellType.channels])
        return MainConsoleDataSource(sections: [section])
    }()
    
    //let configurationDataSource = MainConsoleDataSource()
    
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
        
        /*
        let channelsIndexPath = configurationSection.indexPath(for: .channels)
        let channelGroupsIndexPath = configurationSection.indexPath(for: .channelGroups)
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [channelsIndexPath!, channelGroupsIndexPath!])
        })
 */
        /*
        collectionView.performBatchUpdates({
            self.collectionView.reloadSections(self.configurationDataSource.subscribableIndexSet)
            })
 */
    }
    
    // MARK: - ConsoleDataSource
    
    func consoleView(_ consoleView: ConsoleCollectionView, numberOfItemsInConfigurationSection subSection: Int) -> Int {
        return configurationDataSource.sections[subSection].count
    }
    
    func numberOfSectionsInConfigurationSection(in consoleView: ConsoleCollectionView) -> Int {
        return configurationDataSource.sections.count
    }
    
    func consoleView(_ consoleView: ConsoleCollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let titleContentsCell = cell as? TitleContentsCollectionViewCell, let clientThing = configurationDataSource[indexPath] as? ClientCellType else {
            fatalError()
        }
        let updateThing = clientThing.updateThing(client: console.client)
        titleContentsCell.update(thing: updateThing)
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
    
    func consoleView(_ consoleView: ConsoleCollectionView, didSelectConfigurationItemAt indexPath: IndexPath) {
        guard configurationDataSource.isTappable(at: indexPath) else {
            return
        }
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
