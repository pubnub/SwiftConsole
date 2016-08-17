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
    
    required init(itemType: ItemType, pubNubResult result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
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
        contentView.addSubview(subscribedChannelsLabel)
        subscribedChannelsLabel.forceAutoLayout()
        contentView.addSubview(subscribedChannelGroupsLabel)
        subscribedChannelGroupsLabel.forceAutoLayout()
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        guard hasConstraints else {
            return
        }
        
    }
    
//    override func layoutSubviews() {
//        categoryLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
//        operationLabel.frame = categoryLabel.frame.offsetBy(dx: 0.0, dy: categoryLabel.frame.size.height)
//        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
//        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
//        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
//        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
//        timetokenLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
//        subscribedChannelsLabel.frame = timetokenLabel.frame.offsetBy(dx: 0.0, dy: timetokenLabel.frame.size.height)
//        subscribedChannelGroupsLabel.frame = subscribedChannelsLabel.frame.offsetBy(dx: 0.0, dy: subscribedChannelsLabel.frame.size.height)
//    }
    
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
