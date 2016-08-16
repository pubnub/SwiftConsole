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
    var timeToken: NSNumber? {get}
    var error: AnyObject? {get}
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
    let timeToken: NSNumber?
    let error: AnyObject?
    init(itemType: ItemType, publishStatus: PNPublishStatus) {
        self.itemType = itemType
        self.category = publishStatus.stringifiedCategory()
        self.operation = publishStatus.stringifiedOperation()
        self.creationDate = NSDate()
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
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRectZero)
        operationLabel = UILabel(frame: CGRectZero)
        creationDateLabel = UILabel(frame: CGRectZero)
        statusCodeLabel = UILabel(frame: CGRectZero)
        informationLabel = UILabel(frame: CGRectZero)
        timeTokenLabel = UILabel(frame: CGRectZero)
        errorLabel = UILabel(frame: CGRectZero)
        super.init(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        operationLabel.translatesAutoresizingMaskIntoConstraints = false
        creationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        creationDateLabel.numberOfLines = 2
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        timeTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(informationLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.addSubview(errorLabel)
        contentView.layer.borderWidth = 1
        
        let views = [
            "titleLabel": titleLabel,
            "operationLabel": operationLabel,
            "creationDateLabel": creationDateLabel,
            "statusCodeLabel" : statusCodeLabel,
            "informationLabel" : informationLabel,
            "timeTokenLabel": timeTokenLabel,
            "errorLabel" : errorLabel
            ]
        
        let metrics = [
            "spacer": NSNumber(integer: 10)
            ]
        
        let titleLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[titleLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let operationLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[operationLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let creationDateXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[creationDateLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let statusCodeLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[statusCodeLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let informationLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[informationLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let timeTokenLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[timeTokenLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let errorLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[errorLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacer-[titleLabel]-spacer-[operationLabel]-spacer-[creationDateLabel]-spacer-[statusCodeLabel]-spacer-[informationLabel]-spacer-[timeTokenLabel]-spacer-[errorLabel]-spacer-|", options: [], metrics: metrics, views: views)
        contentView.addConstraints(titleLabelXConstraints)
        contentView.addConstraints(operationLabelXConstraints)
        contentView.addConstraints(creationDateXConstraints)
        contentView.addConstraints(statusCodeLabelXConstraints)
        contentView.addConstraints(informationLabelXConstraints)
        contentView.addConstraints(timeTokenLabelXConstraints)
        contentView.addConstraints(errorLabelXConstraints)
        contentView.addConstraints(verticalConstraints)
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
            timeTokenLabel.hidden = false
            timeTokenLabel.text = "Time token: \(publishTimeToken)"
        } else {
            timeTokenLabel.hidden = true
        }
        if let publishError = item.error {
            errorLabel.hidden = false
            errorLabel.text = "Error: \(publishError)"
        } else {
            errorLabel.hidden = true
        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let publishItem = item as? PublishStatus else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePublishStatus(publishItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 220.0)
    }
}
