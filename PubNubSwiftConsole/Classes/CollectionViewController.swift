//
//  CollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public protocol Item {
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
    
    // start with an empty data source, replace in subclasses
    public var dataSource: BasicDataSource = {
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
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LabelCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as? CollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        let indexedItem = dataSource[indexPath]
        cell.updateCell(indexedItem)
        return cell
    }

}
