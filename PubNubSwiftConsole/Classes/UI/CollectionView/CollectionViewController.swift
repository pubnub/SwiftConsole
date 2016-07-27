//
//  CollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public protocol Item {
    var alertControllerTitle: String? {get}
    var alertControllerTextFieldValue: String? {get}
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

extension UIAlertController {
    enum ItemAction: String {
        case OK, Cancel
    }
    class func itemCellContentsUpdateTextFieldAlertController(selectedItem: Item, completionHandler: ((UIAlertAction, String?) -> ())) -> UIAlertController {
        // TODO: use optionals correctly instead of forced unwrapping
        let alertController = UIAlertController(title: selectedItem.alertControllerTitle!, message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = selectedItem.alertControllerTextFieldValue!
        })
        alertController.addAction(UIAlertAction(title: ItemAction.OK.rawValue, style: .Default, handler: { (action) -> Void in
            var updatedContentsString = alertController.textFields?[0].text
            completionHandler(action, updatedContentsString)
        }))
        alertController.addAction(UIAlertAction(title: ItemAction.Cancel.rawValue, style: .Default, handler: { (action) in
            completionHandler(action, nil)
        }))
        alertController.view.setNeedsLayout() // workaround: https://forums.developer.apple.com/thread/18294
        return alertController
    }
}

@objc public protocol CollectionViewControllerDelegate: UICollectionViewDelegate {
    optional func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?)
}

public class CollectionViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Data Source
    public class BasicSection: ItemSection {
        public var items: [Item]
        public required init(items: [Item]) {
            self.items = items
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
    
    public class BasicDataSource: DataSource {
        public var sections: [ItemSection]
        public required init(sections: [ItemSection]) {
            self.sections = sections
        }
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
    
    // MARK: - Properties
    var collectionView: CollectionView?
    
    weak public var delegate: CollectionViewControllerDelegate?
    
    // start with an empty data source, replace in subclasses
    public var dataSource: DataSource = {
        let sections = [ItemSection]()
        return BasicDataSource(sections: sections)
    }()
    
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
        return dataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let indexedItem = dataSource[indexPath]
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(indexedItem.reuseIdentifier, forIndexPath: indexPath) as? CollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        cell.updateCell(indexedItem)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard var selectedItem = self.dataSource[indexPath] as? LabelItem else {
            return
        }
        
        let alertController = UIAlertController.itemCellContentsUpdateTextFieldAlertController(selectedItem) { (action, updatedTextFieldString) in
            self.delegate?.collectionView!(self.collectionView!, didUpdateItemWithTextFieldAlertControllerAtIndexPath: indexPath, selectedAlertAction: action, updatedTextFieldString: updatedTextFieldString)
        }
        
        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

}
