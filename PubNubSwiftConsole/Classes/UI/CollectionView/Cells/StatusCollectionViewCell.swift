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
    init(itemType: ItemType, status: PNStatus)
}

class Status: Result, StatusItem {
    let category: String
    let error: Bool
    required init(itemType: ItemType, status: PNStatus) {
        self.category = status.stringifiedCategory()
        self.error = status.isError
        super.init(itemType: itemType, result: status)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
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
        contentView.addSubview(categoryLabel)
        categoryLabel.forceAutoLayout()
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        categoryLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
        operationLabel.frame = categoryLabel.frame.offsetBy(dx: 0.0, dy: categoryLabel.frame.size.height)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let statusItem = item as? StatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        categoryLabel.text = "Category: \(statusItem.category)"
        contentView.setNeedsLayout() // just a flag, can call this with every subclass implementation
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
