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
    var information: String {get}
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
    let information: String
    init(itemType: ItemType, publishStatus: PNPublishStatus) {
        self.itemType = itemType
        self.category = publishStatus.stringifiedCategory()
        self.operation = publishStatus.stringifiedOperation()
        self.creationDate = NSDate()
        self.statusCode = publishStatus.statusCode
        self.information = publishStatus.data.information
    }
    var reuseIdentifier: String {
        return PublishStatusCollectionViewCell.reuseIdentifier
    }
}

class PublishStatusCollectionViewCell: CollectionViewCell {
    private let titleLabel: UILabel
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let informationLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/5))
        operationLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/5))
        creationDateLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/5))
        statusCodeLabel = UILabel(frame: CGRect(x: 5, y: 90, width: frame.size.width, height: frame.size.height/5))
        informationLabel = UILabel(frame: CGRect(x: 5, y: 120, width: frame.size.width, height: frame.size.height/5))
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(informationLabel)
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updatePublishStatus(item: PublishStatus) {
        titleLabel.text = "Publish: \(item.title)"
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        informationLabel.text = "Response message: \(item.information)"
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let publishItem = item as? PublishStatus else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePublishStatus(publishItem)
    }
}
