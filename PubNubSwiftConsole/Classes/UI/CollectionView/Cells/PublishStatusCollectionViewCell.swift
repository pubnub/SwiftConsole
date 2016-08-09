//
//  PublishStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import UIKit
import PubNub

protocol PublishStatusItem: Item {
    init(itemType: ItemType, publishStatus: PNPublishStatus)
    var category: String {get}
    var operation: String {get}
    var creationDate: NSDate {get}
    var statusCode: Int {get}
}

extension PublishStatusItem {
    var title: String {
        return category
    }
}

struct PublishStatus: PublishStatusItem {
    let itemType: ItemType
    let category: String
    let operation: String
    let creationDate: NSDate
    let statusCode: Int
    init(itemType: ItemType, publishStatus: PNPublishStatus) {
        self.itemType = itemType
        self.category = publishStatus.stringifiedCategory()
        self.operation = publishStatus.stringifiedOperation()
        self.creationDate = NSDate()
        self.statusCode = publishStatus.statusCode
    }
    var reuseIdentifier: String {
        return PublishStatusCollectionViewCell.reuseIdentifier
    }
}

class PublishStatusCollectionViewCell: CollectionViewCell {
    private let titleLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/3))
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updatePublishStatus(item: PublishStatus) {
        titleLabel.text = "Publish: \(item.title)"
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let publishItem = item as? PublishStatus else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePublishStatus(publishItem)
    }
}
