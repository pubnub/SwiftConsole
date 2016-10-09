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
    
}

protocol ThingSection {
    var items: [Thing] {get}
    var count: Int {get}
    var section: Int {get}
    func item(for thing: Thing) -> Int
    func thing(for item: Int) -> Thing
    func indexPath(for thing: Thing) -> IndexPath
    func indexPath(for item: Int) -> IndexPath
    subscript(indexPath: IndexPath) -> Thing {get}
    subscript(item: Int) -> Thing {get}
}

extension ThingSection {
    var count: Int {
        return items.count
    }
    
    func thing(for item: Int) -> Thing {
        return items[item]
    }
    
    func indexPath(for thing: Thing) -> IndexPath {
        let foundItem = item(for: thing)
        return indexPath(for: foundItem)
    }
    
    func indexPath(for item: Int) -> IndexPath {
        return IndexPath(item: item, section: section)
    }
    subscript(indexPath: IndexPath) -> Thing {
        return self[indexPath.item]
    }
    
    subscript(item: Int) -> Thing {
        return thing(for: item)
    }
}

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

public class ConsoleViewController: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    struct ConfigurationSection: StaticItemSection {
        var section: Int {
            return 0
        }
        let items: [StaticCellType] = [.pubKey, .subKey, .channels, .channelGroups]
    }
    let configurationSection = ConfigurationSection()
    
    let console: SwiftConsole
    let collectionView: UICollectionView
    
    lazy var fetchedResultsController: NSFetchedResultsController<Result> = {
        let allResultsFetchRequest: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: allResultsFetchRequest, managedObjectContext: self.console.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        creatingFetchedResultsController.delegate = self
        return creatingFetchedResultsController
    }()
    
    public required init(console: SwiftConsole) {
        let bounds = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.forceAutoLayout()
        collectionView.backgroundColor = UIColor.red
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
        collectionView.register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.reuseIdentifier())
        let views = [
            "collectionView": collectionView,
        ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        console.client.addListener(self)
        updateConfigurationCells(client: console.client)
        updateSubscribablesCells(client: console.client)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateConfigurationCells(client: PubNub) {
        collectionView.performBatchUpdates({
            guard let pubKeyPath = self.configurationSection.indexPath(for: .pubKey), let subKeyPath = self.configurationSection.indexPath(for: .subKey) else {
                fatalError()
            }
            self.collectionView.reloadItems(at: [pubKeyPath, subKeyPath])
        })
    }
    
    func updateSubscribablesCells(client: PubNub) {
        collectionView.performBatchUpdates({
            guard let channelsPath = self.configurationSection.indexPath(for: .channels), let channelGroupsPath = self.configurationSection.indexPath(for: .channelGroups) else {
                fatalError()
            }
            self.collectionView.reloadItems(at: [channelsPath, channelGroupsPath])
        })
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let titleContentsCell = cell as? TitleContentsCollectionViewCell else {
                fatalError()
            }
            let title = configurationSection.title(for: indexPath)
            let contents = configurationSection.contents(for: indexPath, with: console.client)
            titleContentsCell.update(title: title, contents: contents)
        case 1:
            guard let resultCell = cell as? ResultCollectionViewCell else {
                fatalError()
            }
            var adjustedIndexPath = indexPath
            // need to adjust the indexPath section to match the fetched results controller
            adjustedIndexPath.section -= 1
            let result = fetchedResultsController.object(at: adjustedIndexPath)
            // Populate cell from the NSManagedObject instance
            resultCell.update(result: result)
        default:
            fatalError("Not expecting more sections")
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return configurationSection.count
        case 1:
            guard let onlySectionInfo = fetchedResultsController.sections?.first else {
                fatalError("No sections in fetchedResultsController")
            }
            return onlySectionInfo.numberOfObjects
        default:
            fatalError("Can't handle this")
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reuseIdentifier: String
        switch indexPath.section {
        case 0:
            reuseIdentifier = TitleContentsCollectionViewCell.reuseIdentifier()
        case 1:
            reuseIdentifier = ResultCollectionViewCell.reuseIdentifier()
        default:
            fatalError("Can't handle section 3")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return TitleContentsCollectionViewCell.size(collectionViewSize: collectionView.frame.size)
        case 1:
            return ResultCollectionViewCell.size
        default:
            fatalError("Unexpected section number encountered")
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        guard configurationSection.type(for: indexPath).isTappable else {
            return
        }
        let alertController = UIAlertController(title: "Change channel", message: "Enter new channels, or remove some, comma separated", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter channels ..."
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let textFieldText = alertController.textFields?[0].text else {
                return
            }
            self.console.client.subscribeToChannels([textFieldText], withPresence: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
        
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        collectionView.performBatchUpdates({ 
            switch type {
            case .insert:
                var adjustedSectionIndex = sectionIndex
                adjustedSectionIndex += 1
                self.collectionView.insertSections(IndexSet(integer: adjustedSectionIndex))
            case .delete:
                var adjustedSectionIndex = sectionIndex
                adjustedSectionIndex += 1
                self.collectionView.deleteSections(IndexSet(integer: adjustedSectionIndex))
            case .move:
                break
            case .update:
                break
            }
            })
        
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var adjustedIndexPath = indexPath
        adjustedIndexPath?.section += 1
        var adjustedNewIndexPath = newIndexPath
        adjustedNewIndexPath?.section += 1
        collectionView.performBatchUpdates({ 
            switch type {
            case .insert:
                self.collectionView.insertItems(at: [adjustedNewIndexPath!])
            case .delete:
                self.collectionView.deleteItems(at: [adjustedIndexPath!])
            case .update:
                guard let cell = self.collectionView.cellForItem(at: adjustedIndexPath!) else {
                    fatalError()
                }
                self.configureCell(cell: cell, indexPath: adjustedIndexPath!)
            case .move:
                self.collectionView.moveItem(at: adjustedIndexPath!, to: adjustedNewIndexPath!)
            }
            })
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
