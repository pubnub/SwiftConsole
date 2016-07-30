//
//  CollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public protocol Item {
    var reuseIdentifier: String {get}
}

public protocol ItemSection {
    init(items: [Item])
    var items: [Item] {get set}
    var count: Int {get}
    subscript(row: Int) -> Item {get set}
}

public protocol DataSource {
    init(sections: [ItemSection])
    var sections: [ItemSection] {get set}
    var count: Int {get}
    subscript(section: Int) -> ItemSection {get set}
    subscript(indexPath: NSIndexPath) -> Item {get set}
}

protocol ItemSectionType {
    var rawValue: Int {get}
}

protocol ItemType {
    var sectionType: ItemSectionType {get}
    var title: String {get}
    var selectedTitle: String? {get}
    var defaultValue: String {get}
    var section: Int {get}
    var item: Int {get}
    var indexPath: NSIndexPath {get}
}

extension ItemType {
    var indexPath: NSIndexPath {
        return NSIndexPath(forItem: item, inSection: section)
    }
    var section: Int {
        return sectionType.rawValue
    }
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
}

@objc public protocol CollectionViewControllerDelegate: UICollectionViewDelegate {
    optional func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?)
}

public class CollectionViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct BasicDataSource: DataSource {
        struct BasicSection: ItemSection {
            var items: [Item]
            init(items: [Item]) {
                self.items = items
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
