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

struct EmptySectionType: ItemSectionType {
    var rawValue: Int {
        return 0
    }
    var indexSet: NSIndexSet {
        return NSIndexSet(index: 0)
    }
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

struct EmptySectionItemType: ItemType {
    var size: CGSize {
        return CGSizeZero
    }
    var title: String {
        return ""
    }
    var defaultValue: String {
        return ""
    }
    var sectionType: ItemSectionType {
        return EmptySectionType()
    }
    var item: Int {
        return 0
    }
}

public protocol Item {
    var title: String {get}
    var reuseIdentifier: String {get}
    var itemType: ItemType {get}
}

public protocol ItemSection: Item {
    init(items: [Item])
    var items: [Item] {get set}
    var count: Int {get}
    subscript(index: Int) -> Item {get set}
}

extension ItemSection {
    var title: String {
        return itemType.title
    }
    var reuseIdentifier: String {
        return ""
    }
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

protocol StackItemSection: ItemSection {
    mutating func push(item: Item)
}

extension StackItemSection {
    mutating func push(item: Item) {
        self.items.insert(item, atIndex: 0)
    }
    mutating func clear() {
        self.items.removeAll()
    }
}

protocol SelectableItemSection: ItemSection {
//    init(selectableItemSections: [ItemSection])
    var selectedSectionIndex: Int {get set}
    var selectedSection: ItemSection {get}
    var itemSections: [ItemSection] {get}
    subscript(indexPath: NSIndexPath) -> Item { get set }
    subscript(section: Int) -> ItemSection {get set}
    subscript(section: Int, item: Int) -> Item {get set}
    mutating func push(section: Int, item: Item)
    mutating func clear(section: Int)
    mutating func clearAllSections()
}

extension SelectableItemSection {
    var selectedSection: ItemSection {
        return itemSections[selectedSectionIndex]
    }
    var itemSections: [ItemSection] {
        get {
//            return items as! [ItemSection]
            var castedItems = [ItemSection]()
            for item in items {
                guard let castedItem = item as? ItemSection else {
                    fatalError()
                }
                castedItems.append(castedItem)
            }
            return castedItems
        }
        set {
            var updatedItems = [Item]()
            for item in newValue {
                guard let newItem = item as? Item else {
                    fatalError()
                }
                updatedItems.append(newItem)
            }
            self.items = updatedItems
        }
    }
    public var count: Int {
        return selectedSection.count
    }
    public subscript(section: Int) -> ItemSection {
        get {
            return itemSections[section]
        }
        set {
            itemSections[section] = newValue
        }
    }
    public subscript(index: Int) -> Item {
        get {
            return selectedSection[index]
        }
        set {
            items[index] = newValue
        }
    }
    subscript(indexPath: NSIndexPath) -> Item {
        get {
            return self[indexPath.section, indexPath.item]
        }
        set {
            self[indexPath.section, indexPath.item] = newValue
        }
    }
    subscript(section: Int, item: Int) -> Item {
        get {
            return itemSections[section][item]
        }
        set {
            var itemSection = self[section]
            itemSection[item] = newValue
            self[section] = itemSection
        }
    }
    mutating func push(section: Int, item: Item) {
        guard var stackSection = itemSections[section] as? StackItemSection else {
            fatalError()
        }
        stackSection.push(item)
        self[section] = stackSection
    }
    mutating func clear(section: Int) {
        guard var stackSection = itemSections[section] as? StackItemSection else {
            fatalError()
        }
        stackSection.clear()
        self[section] = stackSection
        
    }
    mutating func clearAllSections() {
        for sectionIndex in 0..<itemSections.count {
            self.clear(sectionIndex)
        }
    }
}

public protocol DataSource {
    init(sections: [ItemSection])
    var sections: [ItemSection] {get set}
    var count: Int {get}
    subscript(section: Int) -> ItemSection {get set}
    subscript(indexPath: NSIndexPath) -> Item {get set}
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
        guard var stackSection = sections[section] as? StackItemSection else {
            return
        }
        stackSection.push(item)
        self[section] = stackSection
    }
    public mutating func clear(section: Int) {
        guard var stackSection = sections[section] as? StackItemSection else {
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
            let itemType: ItemType
            init(items: [Item]) {
                self.init(items: items, sectionItemType: EmptySectionItemType())
            }
            init(items: [Item], sectionItemType: ItemType) {
                self.itemType = sectionItemType
                self.items = items
            }
        }
        struct ScrollingSection: StackItemSection {
            var items: [Item]
            let itemType: ItemType
            init(items: [Item]) {
                self.init(items: items, sectionItemType: EmptySectionItemType())
            }
            init(items: [Item], sectionItemType: ItemType) {
                self.itemType = sectionItemType
                self.items = items
            }
            init() {
                self.init(items: [])
            }
        }
        struct SingleSegmentedControlSection: SingleSegementedControlItemSection {
            var items: [Item]
            let itemType: ItemType
            init(items: [Item]) {
                self.init(items: items, sectionItemType: EmptySectionItemType())
            }
            init(items: [Item], sectionItemType: ItemType) {
                self.itemType = sectionItemType
                self.items = items
            }
            init(segmentedControl: SegmentedControlItem) {
                self.init(items: [segmentedControl])
            }
        }
        struct SelectableSection: SelectableItemSection {
            var items: [Item]
            let itemType: ItemType
            var selectedSectionIndex: Int
            init(items: [Item]) {
                self.init(items: items, sectionItemType: EmptySectionItemType())
            }
            init(items: [Item], sectionItemType: ItemType) {
                self.itemType = sectionItemType
                self.items = items
                self.selectedSectionIndex = 0
            }
//            init(selectableItemSections: [ItemSection]) {
//                self.init(items: (selectableItemSections as! [Item]))
//            }
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
