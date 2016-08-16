//
//  CollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation
import PubNub
import PubNubPersistence

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
    var cellClass: CollectionViewCell.Type {get}
    func size(collectionViewFrame: CGSize) -> CGSize
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
    func size(collectionViewSize: CGSize) -> CGSize {
        return cellClass.size(collectionViewSize)
    }
}

struct EmptySectionItemType: ItemType {
    func size(collectionViewSize: CGSize) -> CGSize {
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
    var cellClass: CollectionViewCell.Type {
        return CollectionViewCell.self
    }
}

public protocol Item {
    var title: String {get}
    var reuseIdentifier: String {get}
    var itemType: ItemType {get}
    func size(collectionViewSize: CGSize) -> CGSize
}

extension Item {
    public func size(collectionViewSize: CGSize) -> CGSize {
        return itemType.size(collectionViewSize)
    }
    public var reuseIdentifier: String {
        return itemType.cellClass.reuseIdentifier
    }
}

public protocol ItemSection: Item {
    init(items: [Item])
    var items: [Item] {get set}
    var count: Int {get}
    subscript(item: Int) -> Item {get set}
}

extension ItemSection {
    var title: String {
        return itemType.title
    }
    var reuseIdentifier: String {
        return ""
    }
    public subscript(item: Int) -> Item {
        get {
            return items[item]
        }
        set {
            items[item] = newValue
        }
    }
    public subscript(itemType: ItemType) -> Item {
        get {
            return items[itemType.item]
        }
        set {
            items[itemType.item] = newValue
        }
    }
    public var count: Int {
        return items.count
    }
}

// should there be a protocol for pushable items?
protocol StackItemSection: ItemSection {
    mutating func push(item: Item) -> Int
    mutating func clear()
}

extension StackItemSection {
    mutating func push(item: Item) -> Int {
        self.items.insert(item, atIndex: 0)
        return 0
    }
    mutating func clear() {
        self.items.removeAll()
    }
}

protocol SelectableItemSection: ItemSection {
    init(selectableItemSections: [ItemSection])
    var selectedSectionIndex: Int {get set}
    var selectedSection: ItemSection {get}
    var itemSections: [ItemSection] {get set}
    subscript(indexPath: NSIndexPath) -> Item { get set }
    subscript(section: Int) -> ItemSection {get set}
    subscript(section: Int, item: Int) -> Item {get set}
    mutating func updateSelectedSection(index: Int)
}

extension SelectableItemSection {
    var selectedSection: ItemSection {
        return itemSections[selectedSectionIndex]
    }
    var itemSections: [ItemSection] {
        get {
            return items.map({ (item) -> ItemSection in
                guard let castedItem = item as? ItemSection else {
                    fatalError()
                }
                return castedItem
            })
        }
        set {
            self.items = newValue.map {
                $0 as Item // always succeeds (ItemSection extends Item)
            }
        }
    }
    var count: Int {
        return selectedSection.count
    }
    subscript(section: Int) -> ItemSection {
        get {
            return itemSections[section]
        }
        set {
            itemSections[section] = newValue
        }
    }
    // FIXME: this seems wrong
    subscript(item: Int) -> Item {
        get {
            return selectedSection[item]
        }
        set {
            // FIXME: this seems wrong
            self[selectedSectionIndex][item] = newValue
        }
    }
    subscript(itemType: ItemType) -> Item {
        get {
            return self[itemType.indexPath]
        }
        set {
            self[itemType.indexPath] = newValue
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
    mutating func updateSelectedSection(index: Int) {
        self.selectedSectionIndex = index
    }
}

public protocol DataSource: class {
    init(sections: [ItemSection])
    var sections: [ItemSection] {get set}
    var count: Int {get}
    subscript(section: Int) -> ItemSection {get set}
    subscript(indexPath: NSIndexPath) -> Item {get set}
    subscript(itemType: ItemType) -> Item {get set}
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
    public subscript(itemType: ItemType) -> Item {
        get {
            return self[itemType.indexPath]
        }
        set {
            self[itemType.indexPath] = newValue
        }
    }
    public var count: Int {
        return sections.count
    }
    public func push(section: Int, item: Item) -> NSIndexPath {
        guard var stackSection = sections[section] as? StackItemSection else {
            fatalError()
        }
        let pushedItemIndex = stackSection.push(item)
        sections[section] = stackSection
        return NSIndexPath(forItem: pushedItemIndex, inSection: section)
    }
    public func push(section: Int, subSection: Int, item: Item) -> NSIndexPath {
        guard var selectableSection = sections[section] as? SelectableItemSection, var stackSection = selectableSection[subSection] as? StackItemSection else {
            fatalError()
        }
        let index = stackSection.push(item)
        selectableSection[subSection] = stackSection
        sections[section] = selectableSection
        return NSIndexPath(forItem: index, inSection: section) // we need to alter this value because we want to return the major section for use in collection view cell reloading and not the sub section value used by the data store
    }
    public func clear(section: Int) {
        guard var stackSection = sections[section] as? StackItemSection else {
            return
        }
        stackSection.clear()
        self[section] = stackSection
    }
    public func updateSelectedSection(section: Int, selectedSubSection: Int) {
        guard var selectableSection = sections[section] as? SelectableItemSection else {
            fatalError()
        }
        selectableSection.updateSelectedSection(selectedSubSection)
        sections[section] = selectableSection
    }
    public func selectedSectionIndex(section: Int) -> Int {
        guard let selectableSection = sections[section] as? SelectableItemSection else {
            fatalError()
        }
        return selectableSection.selectedSectionIndex
    }
}

@objc(PNCCollectionViewControllerDelegate)
public protocol CollectionViewControllerDelegate: UICollectionViewDelegate {
    optional func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?)
    optional func collectionView(collectionView: UICollectionView, didUpdateItemWithTextViewAtIndexPath indexPath: NSIndexPath, textView: UITextView, updatedTextFieldString updatedString: String?)
}

@objc(PNCCollectionViewController)
public class CollectionViewController: ViewController, TextViewCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // this is a class so that it can be subclassed and modified by subclasses of CollectionViewController
    class BasicDataSource: DataSource {
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
            init(selectableItemSections: [ItemSection]) {
                let items = selectableItemSections.map {
                    $0 as Item // always succeeds (ItemSection extends Item)
                }
                self.init(items: items)
            }
        }
        var sections: [ItemSection]
        required init(sections: [ItemSection]) {
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
    
    public convenience init() {
        self.init(persistence: nil)
    }
    
    public required init(persistence: PubNubPersistence?) {
        super.init(persistence: persistence)
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
        guard let currentDataSource = dataSource else {
            fatalError()
        }
        let indexedItem = currentDataSource[indexPath]
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(indexedItem.reuseIdentifier, forIndexPath: indexPath) as? CollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        cell.updateCell(indexedItem)
        if let textViewCell = cell as? TextViewCollectionViewCell {
            textViewCell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // TODO: eventually we can probably drop this in favor of a better layout object
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let item = dataSource?[indexPath] else {
            fatalError()
        }
        return item.size(collectionView.frame.size)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let currentCollectionView = self.collectionView else {
            return
        }
        // We don't have any special behavior for text views as of now, this is really just a check
        // to make sure that we don't treat UpdatableTitleContentsItem types as a TextViewItem because
        // TextViewItem protocol does inherit from UpdatableTitleContentsItem
        if let _ = dataSource?[indexPath] as? TextViewItem {
            // are we going to handle text view differently?
            // make sure we at least don't apply the alert controller to this type, because it only applies to the one below
        } else if let selectedUpdatableLabelItem = dataSource?[indexPath] as? UpdatableTitleContentsItem {
            let alertController = UIAlertController.updateItemWithAlertController(selectedUpdatableLabelItem) { (action, updatedTextFieldString) in
                if let actionTitle = action.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
                    switch (alertDecision) {
                    case .OK:
                        self.collectionView?.performBatchUpdates({
                            self.dataSource?.updateTitleContents(indexPath, updatedContents: updatedTextFieldString)
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            self.delegate?.collectionView?(currentCollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath: indexPath, selectedAlertAction: action, updatedTextFieldString: updatedTextFieldString)
                            }, completion: nil)
                    default:
                        return
                    }
                }
            }
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - TextViewCollectionViewCellDelegate
    
    public func textViewCell(cell: TextViewCollectionViewCell, textViewDidEndEditing textView: UITextView) {
        guard let currentCollectionView = self.collectionView else {
            return
        }
        guard let textViewCellIndexPath = currentCollectionView.indexPathForCell(cell) else {
            fatalError()
        }
        self.collectionView?.performBatchUpdates({
            self.dataSource?.updateTitleContents(textViewCellIndexPath, updatedContents: textView.text)
            self.delegate?.collectionView?(self.collectionView!, didUpdateItemWithTextViewAtIndexPath: textViewCellIndexPath, textView: textView, updatedTextFieldString: textView.text)
            }, completion: nil)
    }
    
}
