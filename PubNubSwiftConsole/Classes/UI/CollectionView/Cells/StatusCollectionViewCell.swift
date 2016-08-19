//
//  StatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import UIKit
import PubNub

protocol StatusItem: ResultItem {
    var category: String {get}
    var error: Bool {get}
    init(itemType: ItemType, pubNubResult result: PNStatus)
}

class Status: Result, StatusItem {
    let category: String
    let error: Bool
    
    required init(itemType: ItemType, pubNubResult result: PNStatus) {
        self.category = result.stringifiedCategory()
        self.error = result.isError
        super.init(itemType: itemType, pubNubResult: result as! PNResult)
    }
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNStatus)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return Status(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return StatusCollectionViewCell.reuseIdentifier
    }
    
}

class StatusCollectionViewCell: ResultCollectionViewCell {
    let categoryLabel: UILabel
    
    override init(frame: CGRect) {
        self.categoryLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        // let's put it after the operation label
        stackView.insertArrangedSubview(categoryLabel, at: 1)
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let statusItem = item as? StatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        categoryLabel.text = "Category: \(statusItem.category)"
        contentView.setNeedsLayout() // just a flag, can call this with every subclass implementation
    }
}
