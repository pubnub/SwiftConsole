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
    init(itemType: ItemType, subscribeStatus: PNSubscribeStatus)
    
}

class SubscribeStatus: ErrorStatus, SubscribeStatusItem {
    let subscribedChannel: String?
    let actualChannel: String?
    let timetoken: NSNumber
    let currentTimetoken: NSNumber
    let lastTimetoken: NSNumber
    let subscribedChannels: [String]
    let subscribedChannelGroups: [String]
    required init(itemType: ItemType, subscribeStatus: PNSubscribeStatus) {
        self.subscribedChannel = subscribeStatus.data.subscribedChannel
        self.actualChannel = subscribeStatus.data.actualChannel
        self.timetoken = subscribeStatus.data.timetoken
        self.currentTimetoken = subscribeStatus.currentTimetoken
        self.lastTimetoken = subscribeStatus.lastTimeToken
        self.subscribedChannels = subscribeStatus.subscribedChannels
        self.subscribedChannelGroups = subscribeStatus.subscribedChannelGroups
        super.init(itemType: itemType, errorStatus: subscribeStatus)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    
    required init(itemType: ItemType, errorStatus: PNErrorStatus) {
        fatalError("init(itemType:errorStatus:) has not been implemented")
    }
    
    required init(itemType: ItemType, status: PNStatus) {
        fatalError("init(itemType:status:) has not been implemented")
    }
    
    override var reuseIdentifier: String {
        return SubscribeStatusCollectionViewCell.reuseIdentifier
    }
}

class SubscribeStatusCollectionViewCell: CollectionViewCell {
    private let timetokenLabel: UILabel
    private let subscribedChannelsLabel: UILabel
    private let subscribedChannelGroupsLabel: UILabel
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let uuidLabel: UILabel
    private let clientRequestLabel: UILabel
    private let categoryLabel: UILabel
    
    override init(frame: CGRect) {
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        self.categoryLabel = UILabel(frame: .zero)
        self.timetokenLabel = UILabel(frame: .zero)
        self.subscribedChannelsLabel = UILabel(frame: .zero)
        self.subscribedChannelGroupsLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(clientRequestLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(timetokenLabel)
        contentView.addSubview(subscribedChannelsLabel)
        contentView.addSubview(subscribedChannelGroupsLabel)
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
        timetokenLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
        subscribedChannelsLabel.frame = timetokenLabel.frame.offsetBy(dx: 0.0, dy: timetokenLabel.frame.size.height)
        subscribedChannelGroupsLabel.frame = subscribedChannelsLabel.frame.offsetBy(dx: 0.0, dy: subscribedChannelsLabel.frame.size.height)
    }
    
    func updateStatus(item: SubscribeStatusItem) {
        categoryLabel.text = "Category: \(item.category)"
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        uuidLabel.text = "UUID: \(item.uuid)"
        clientRequestLabel.text = "Client request: \(item.clientRequest)"
        timetokenLabel.text = "Timetoken: \(item.timetoken)"
        if !item.subscribedChannels.isEmpty {
            subscribedChannelsLabel.text = "Subscribed channels: \(PubNub.subscribablesToString(subscribables: item.subscribedChannels))"
            subscribedChannelsLabel.isHidden = false
        } else {
            subscribedChannelsLabel.isHidden = true
        }
        if !item.subscribedChannelGroups.isEmpty {
            subscribedChannelGroupsLabel.text = "Subscribed channel groups: \(PubNub.subscribablesToString(subscribables: item.subscribedChannelGroups))"
            subscribedChannelGroupsLabel.isHidden = false
        } else {
            subscribedChannelGroupsLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(item: subscribeStatusItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
