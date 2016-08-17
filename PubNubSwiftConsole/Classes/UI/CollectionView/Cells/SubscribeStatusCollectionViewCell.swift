//
//  SubscribeStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/1/16.
//
//

import UIKit
import PubNub

protocol SubscriberData {
    var subscribedChannel: String? {get} // do we need these?
    var actualChannel: String? {get} // do we need these?
    var timetoken: NSNumber {get}
}

protocol SubscribeStatusItem: ErrorStatusItem, SubscriberData {
    var currentTimetoken: NSNumber {get}
    var lastTimetoken: NSNumber {get}
    var subscribedChannels: [String] {get}
    var subscribedChannelGroups: [String] {get}
    init(itemType: ItemType, pubNubResult result: PNSubscribeStatus)
    
}

class SubscribeStatus: ErrorStatus, SubscribeStatusItem {
    let subscribedChannel: String?
    let actualChannel: String?
    let timetoken: NSNumber
    let currentTimetoken: NSNumber
    let lastTimetoken: NSNumber
    let subscribedChannels: [String]
    let subscribedChannelGroups: [String]
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNSubscribeStatus)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNSubscribeStatus) {
        self.subscribedChannel = result.data.subscribedChannel
        self.actualChannel = result.data.actualChannel
        self.timetoken = result.data.timetoken
        self.currentTimetoken = result.currentTimetoken
        self.lastTimetoken = result.lastTimeToken
        self.subscribedChannels = result.subscribedChannels
        self.subscribedChannelGroups = result.subscribedChannelGroups
        super.init(itemType: itemType, pubNubResult: result as! PNErrorStatus)
    }
    
    required convenience init(itemType: ItemType, pubNubResult result: PNErrorStatus) {
        self.init(itemType: itemType, pubNubResult: result as! PNSubscribeStatus)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return SubscribeStatus(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return SubscribeStatusCollectionViewCell.reuseIdentifier
    }
}

class SubscribeStatusCollectionViewCell: ErrorStatusCollectionViewCell {
    let timetokenLabel: UILabel
    let subscribedChannelsLabel: UILabel
    let subscribedChannelGroupsLabel: UILabel
    
    override init(frame: CGRect) {
        self.timetokenLabel = UILabel(frame: .zero)
        self.subscribedChannelsLabel = UILabel(frame: .zero)
        self.subscribedChannelGroupsLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(timetokenLabel)
        timetokenLabel.forceAutoLayout()
//        contentView.addSubview(subscribedChannelsLabel)
//        subscribedChannelsLabel.forceAutoLayout()
//        contentView.addSubview(subscribedChannelGroupsLabel)
//        subscribedChannelGroupsLabel.forceAutoLayout()
        setUpInitialConstraints()
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpInitialConstraints() {
        let views = [
            "operation": operationLabel,
            "creationDate": creationDateLabel,
            "statusCode": statusCodeLabel,
            "uuid": uuidLabel,
            "clientRequest": clientRequestLabel,
            "timetoken": timetokenLabel,
            ]
        
        let metrics = [
            "labelHeight": NSNumber(integerLiteral: 30),
            "horizontalPadding": NSNumber(integerLiteral: 5),
            "verticalPadding": NSNumber(integerLiteral: 5),
            ]
        
        let cellConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalPadding-[timetoken(labelHeight)]-[operation(==timetoken)]-verticalPadding-[creationDate(==operation)]-verticalPadding-[statusCode(==operation)]-verticalPadding-[uuid(==operation)]-verticalPadding-[clientRequest(==operation)]", options: .alignAllCenterX, metrics: metrics, views: views)
        NSLayoutConstraint.activate(cellConstraints)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        timetokenLabel.text = "Timetoken: \(subscribeStatusItem.timetoken)"
        if !subscribeStatusItem.subscribedChannels.isEmpty {
            subscribedChannelsLabel.text = "Subscribed channels: \(PubNub.subscribablesToString(subscribables: subscribeStatusItem.subscribedChannels))"
            subscribedChannelsLabel.isHidden = false
        } else {
            subscribedChannelsLabel.isHidden = true
        }
        if !subscribeStatusItem.subscribedChannelGroups.isEmpty {
            subscribedChannelGroupsLabel.text = "Subscribed channel groups: \(PubNub.subscribablesToString(subscribables: subscribeStatusItem.subscribedChannelGroups))"
            subscribedChannelGroupsLabel.isHidden = false
        } else {
            subscribedChannelGroupsLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
