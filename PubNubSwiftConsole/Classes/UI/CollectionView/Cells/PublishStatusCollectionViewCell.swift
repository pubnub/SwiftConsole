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
    var creationDate: Date {get}
    var statusCode: Int {get}
    var information: String {get}
    var timeToken: NSNumber? {get}
    var error: Any? {get}
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
    let creationDate: Date
    let statusCode: Int
    let information: String
    let timeToken: NSNumber?
    let error: Any?
    init(itemType: ItemType, publishStatus: PNPublishStatus) {
        self.itemType = itemType
        self.category = publishStatus.stringifiedCategory()
        self.operation = publishStatus.stringifiedOperation()
        self.creationDate = Date()
        self.statusCode = publishStatus.statusCode
        self.information = publishStatus.data.information
        self.timeToken = publishStatus.data.timetoken
        self.error = publishStatus.errorData.data
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
    private let timeTokenLabel: UILabel
    private let errorLabel: UILabel
    
    override init(frame: CGRect) {
        self.titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/5))
        self.operationLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/5))
        self.creationDateLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/5))
        self.statusCodeLabel = UILabel(frame: CGRect(x: 5, y: 90, width: frame.size.width, height: frame.size.height/5))
        self.informationLabel = UILabel(frame: CGRect(x: 5, y: 120, width: frame.size.width, height: frame.size.height/5))
        self.timeTokenLabel = UILabel(frame: CGRect(x: 5, y: 150, width: frame.size.width, height: frame.size.height/5))
        self.errorLabel = UILabel(frame: CGRect(x: 5, y: 180, width: frame.size.width, height: frame.size.height/5))
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(informationLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.addSubview(errorLabel)
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
        if let publishTimeToken = item.timeToken {
            timeTokenLabel.isHidden = false
            timeTokenLabel.text = "Time token: \(publishTimeToken)"
        } else {
            timeTokenLabel.isHidden = true
        }
        if let publishError = item.error {
            errorLabel.isHidden = false
            errorLabel.text = "Error: \(publishError)"
        } else {
            errorLabel.isHidden = true
        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let publishItem = item as? PublishStatus else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePublishStatus(item: publishItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 220.0)
    }
}
