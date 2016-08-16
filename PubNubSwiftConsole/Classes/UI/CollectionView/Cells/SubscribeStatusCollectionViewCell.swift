//
//  SubscribeStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/1/16.
//
//

import UIKit
import PubNub

protocol SubscribeStatusItem: Item {
    var category: String {get}
    var operation: String {get}
    var creationDate: NSDate {get}
    var statusCode: Int {get}
    var timeToken: NSNumber? {get}
    var channels: [String] {get}
    var channelGroups: [String] {get}
}

extension SubscribeStatusItem {
    var title: String {
        return category
    }
}

struct SubscribeStatus: SubscribeStatusItem {
    let itemType: ItemType
    let category: String
    let operation: String
    let creationDate: NSDate
    let statusCode: Int
    var timeToken: NSNumber?
    var channels: [String] = []
    var channelGroups: [String] = []
    init(itemType: ItemType, status: PNStatus) {
        self.itemType = itemType
        self.category = status.stringifiedCategory()
        self.operation = status.stringifiedOperation()
        self.creationDate = NSDate()
        self.statusCode = status.statusCode
        if let subscribeStatus = status as? PNSubscribeStatus {
            self.timeToken = subscribeStatus.data.timetoken
            self.channels = subscribeStatus.subscribedChannels
            self.channelGroups = subscribeStatus.subscribedChannelGroups
        }
    }
    var reuseIdentifier: String {
        return SubscribeStatusCollectionViewCell.reuseIdentifier
    }
}

class SubscribeStatusCollectionViewCell: CollectionViewCell {
    
    private let categoryLabel: UILabel
    private let operationLabel: UILabel
    private let timeStampLabel: UILabel
    private let statusCodeLabel: UILabel
    private let timeTokenLabel: UILabel
    private let channelLabel: UILabel
    private let channelGroupLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        categoryLabel = UILabel(frame: CGRectZero)
        operationLabel = UILabel(frame: CGRectZero)
        timeStampLabel = UILabel(frame: CGRectZero)
        statusCodeLabel = UILabel(frame: CGRectZero)
        timeTokenLabel = UILabel(frame: CGRectZero)
        channelLabel = UILabel(frame: CGRectZero)
        channelGroupLabel = UILabel(frame: CGRectZero)
        super.init(frame: frame)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        operationLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStampLabel.translatesAutoresizingMaskIntoConstraints = false
        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        channelLabel.translatesAutoresizingMaskIntoConstraints = false
        channelGroupLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        contentView.addSubview(operationLabel)
        contentView.addSubview(timeStampLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.addSubview(channelLabel)
        contentView.addSubview(channelGroupLabel)
        contentView.layer.borderWidth = 3
        
        
        let views = [
            "categoryLabel": categoryLabel,
            "operationLabel": operationLabel,
            "timeStampLabel": timeStampLabel,
            "statusCodeLabel" : statusCodeLabel,
            "timeTokenLabel" : timeTokenLabel,
            "channelLabel": channelLabel,
            "channelGroupLabel" : channelGroupLabel
        ]
        
        let metrics = [
            "spacer": NSNumber(integer: 15)
        ]
        
        let categoryLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[categoryLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let operationLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[operationLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let timeStampLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[timeStampLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let statusCodeLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[statusCodeLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let timeTokenLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[timeTokenLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let channelLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[channelLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let channelGroupLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[channelGroupLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacer-[categoryLabel]-spacer-[operationLabel]-spacer-[timeStampLabel]-spacer-[statusCodeLabel]-spacer-[timeTokenLabel]-spacer-[channelLabel]-spacer-[channelGroupLabel]-spacer-|", options: [], metrics: metrics, views: views)
        contentView.addConstraints(categoryLabelXConstraints)
        contentView.addConstraints(operationLabelXConstraints)
        contentView.addConstraints(timeStampLabelXConstraints)
        contentView.addConstraints(statusCodeLabelXConstraints)
        contentView.addConstraints(timeTokenLabelXConstraints)
        contentView.addConstraints(channelLabelXConstraints)
        contentView.addConstraints(channelGroupLabelXConstraints)
        contentView.addConstraints(verticalConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: SubscribeStatusItem) {
        categoryLabel.text = "Category: \(item.title)"
        operationLabel.text = "Operation: \(item.operation)"
        timeStampLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        if let timeToken = item.timeToken {
            timeTokenLabel.hidden = false
            timeTokenLabel.text = "Time token: \(timeToken)"
        } else {
            timeTokenLabel.hidden = true
        }
        if let channelText = PubNub.subscribablesToString(item.channels) where !item.channels.isEmpty {
            channelLabel.hidden = false
            channelLabel.text = "Channel(s): \(channelText)"
        } else {
            channelLabel.hidden = true
        }
        if let channelGroupText = PubNub.subscribablesToString(item.channelGroups) where !item.channelGroups.isEmpty {
            channelGroupLabel.hidden = false
            channelGroupLabel.text = "Channel group(s): \(channelGroupText)"
        } else {
            channelGroupLabel.hidden = true
        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(subscribeStatusItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
