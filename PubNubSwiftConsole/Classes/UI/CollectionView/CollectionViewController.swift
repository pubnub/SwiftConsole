//
//  CollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public protocol ItemSectionType {
    var rawValue: Int {get}
    var indexSet: NSIndexSet {get}
}

extension ItemSectionType {
    var indexSet: NSIndexSet {
        return NSIndexSet(index: rawValue)
    }
}

public protocol ItemType {
    var indexSet: NSIndexSet {get}
    var sectionType: ItemSectionType {get}
    var title: String {get}
    var selectedTitle: String? {get}
    var defaultValue: String {get}
    var section: Int {get}
    var item: Int {get}
    var indexPath: NSIndexPath {get}
    var size: CGSize {get}
}

extension ItemType {
    var indexSet: NSIndexSet {
        return sectionType.indexSet
    }
    var indexPath: NSIndexPath {
        return NSIndexPath(forItem: item, inSection: section)
    }
    var section: Int {
        return sectionType.rawValue
    }
    var selectedTitle: String? {
        return title
    }
}

public protocol Item {
    var title: String {get}
    var reuseIdentifier: String {get}
    var itemType: ItemType {get}
}

public protocol ItemSection {
    init(items: [Item])
    var items: [Item] {get set}
    var count: Int {get}
    subscript(index: Int) -> Item {get set}
}

protocol Stack: ItemSection {
    mutating func push(item: Item)
}

extension Stack {
    mutating func push(item: Item) {
        self.items.insert(item, atIndex: 0)
    }
    mutating func clear() {
        self.items.removeAll()
    }
}

public protocol DataSource {
    init(sections: [ItemSection])
    var sections: [ItemSection] {get set}
    var count: Int {get}
    subscript(section: Int) -> ItemSection {get set}
    subscript(indexPath: NSIndexPath) -> Item {get set}
}

extension ItemSection {
    public subscript(index: Int) -> Item {
        get {
            return items[index]
        }
        set {
            items[index] = newValue
        }
    }
    public var count: Int {
        return items.count
    }
}

extension DataSource {
    public subscript(section: Int) -> ItemSection {
        get {
            return sections[section]
        }
        
        set {
            sections[section] = newValue
        }
    }
    public subscript(indexPath: NSIndexPath) -> Item {
        get {
            return self[indexPath.section][indexPath.row]
        }
        set {
            self[indexPath.section][indexPath.row] = newValue
        }
    }
    public var count: Int {
        return sections.count
    }
    public mutating func push(section: Int, item: Item) {
        guard var stackSection = sections[section] as? Stack else {
            return
        }
        stackSection.push(item)
        self[section] = stackSection
    }
    public mutating func clear(section: Int) {
        guard var stackSection = sections[section] as? Stack else {
            return
        }
        stackSection.clear()
        self[section] = stackSection
    }
}

@objc public protocol CollectionViewControllerDelegate: UICollectionViewDelegate {
    optional func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?)
}

public class CollectionViewController: ViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    struct BasicDataSource: DataSource {
        struct BasicSection: ItemSection {
            var items: [Item]
            init(items: [Item]) {
                self.items = items
            }
        }
        struct ScrollingSection: Stack {
            var items: [Item]
            init(items: [Item]) {
                self.items = items
            }
            init() {
                self.init(items: [])
            }
        }
        var sections: [ItemSection]
        init(sections: [ItemSection]) {
            self.sections = sections
        }
    }
    
    // MARK: - Properties
    var collectionView: CollectionView?
    var dataSource: DataSource?
    
    weak public var delegate: CollectionViewControllerDelegate?
    
    // MARK: - Constructors
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        super.init()
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let layout = CollectionViewFlowLayout()
        self.collectionView = CollectionView(frame: self.view.frame, collectionViewLayout: layout)
        guard let pubNubCollectionView = self.collectionView else {
            fatalError("We expected to have a collection view by now. Please contact support@pubnub.com")
        }
        pubNubCollectionView.delegate = self
        pubNubCollectionView.dataSource = self
        self.view.addSubview(pubNubCollectionView)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let currentDataSource = dataSource else {
            return 0
        }
        return currentDataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentDataSource = dataSource else {
            return 0
        }
        return currentDataSource[section].count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard var currentDataSource = dataSource else {
            fatalError()
        }
        let indexedItem = currentDataSource[indexPath]
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(indexedItem.reuseIdentifier, forIndexPath: indexPath) as? CollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        cell.updateCell(indexedItem)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let item = dataSource?[indexPath] else {
            fatalError()
        }
        return item.itemType.size
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let currentCollectionView = self.collectionView else {
            return
        }
        guard var selectedItem = dataSource?[indexPath] as? LabelItem else {
            return
        }
        let alertController = UIAlertController.updateItemWithAlertController(selectedItem) { (action, updatedTextFieldString) in
            if let actionTitle = action.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
                switch (alertDecision) {
                case .OK:
                    self.dataSource?.updateLabelContentsString(indexPath, updatedContents: updatedTextFieldString)
                default:
                    return
                }
            }
            self.delegate?.collectionView?(currentCollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath: indexPath, selectedAlertAction: action, updatedTextFieldString: updatedTextFieldString)
            currentCollectionView.reloadItemsAtIndexPaths([indexPath])
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
