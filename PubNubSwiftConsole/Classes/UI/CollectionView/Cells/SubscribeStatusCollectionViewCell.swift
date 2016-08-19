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
        // the first 4 items are important, let's put it after those
        stackView.insertArrangedSubview(subscribedChannelsLabel, at: 4)
        stackView.insertArrangedSubview(subscribedChannelGroupsLabel, at: 5)
        stackView.insertArrangedSubview(timetokenLabel, at: 6)
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        timetokenLabel.text = "Timetoken: \(subscribeStatusItem.timetoken)"
        if !subscribeStatusItem.subscribedChannels.isEmpty, let subscribedChannelsString = PubNub.subscribablesToString(subscribables: subscribeStatusItem.subscribedChannels) {
            subscribedChannelsLabel.text = "Subscribed channels: \(subscribedChannelsString)"
        } else {
            subscribedChannelsLabel.isHidden  = true
        }
        if !subscribeStatusItem.subscribedChannelGroups.isEmpty, let subscribedChannelGroupsString = PubNub.subscribablesToString(subscribables: subscribeStatusItem.subscribedChannelGroups) {
            subscribedChannelGroupsLabel.text = "Subscribed channel groups: \(subscribedChannelGroupsString)"
        } else {
            subscribedChannelGroupsLabel.isHidden  = true
        }
        contentView.setNeedsLayout()
    }
}
