//
//  SubscribeStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/1/16.
//
//

import UIKit
import PubNub

protocol ResultItem: Item {
    init(itemType: ItemType, result: PNResult)
    var statusCode: Int {get}
    var operation: String {get}
    var creationDate: Date {get}
    var uuid: String {get}
    var clientRequest: String? {get}
}

extension ResultItem {
    var title: String {
        return operation
    }
}

class Result: ResultItem {
    let itemType: ItemType
    let statusCode: Int
    let operation: String
    let creationDate: Date
    let uuid: String
    let clientRequest: String?
    required init(itemType: ItemType, result: PNResult) {
        self.itemType = itemType
        self.operation = result.stringifiedOperation()
        self.creationDate = Date()
        self.uuid = result.uuid
        self.statusCode = result.statusCode
        self.clientRequest = result.clientRequest?.url?.absoluteString
    }
}

protocol StatusItem: ResultItem {
    var category: String {get}
    var error: Bool {get}
    init(itemType: ItemType, status: PNStatus)
//    var timeToken: NSNumber? {get}
//    var channels: [String] {get}
//    var channelGroups: [String] {get}
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
    
}

protocol ErrorStatusItem: StatusItem {
    var channels: [String] {get}
    var channelGroups: [String] {get}
    var information: String {get}
    init(itemType: ItemType, errorStatus: PNErrorStatus)
}

class ErrorStatus: Status, ErrorStatusItem {
    let channels: [String]
    let channelGroups: [String]
    let information: String
    required init(itemType: ItemType, errorStatus: PNErrorStatus) {
        self.channels = errorStatus.errorData.channels
        self.channelGroups = errorStatus.errorData.channelGroups
        self.information = errorStatus.errorData.information
        super.init(itemType: itemType, status: errorStatus)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    
    required init(itemType: ItemType, status: PNStatus) {
        fatalError("init(itemType:status:) has not been implemented")
    }
}

protocol SubscriberData {
    var subscribedChannel: String? {get} // do we need these?
    var actualChannel: String? {get} // do we need these?
    var timetoken: NSNumber {get}
}

protocol SubscribeStatusItem: ErrorStatusItem, SubscriberData {
//    var category: String {get}
//    var operation: String {get}
//    var creationDate: Date {get}
//    var statusCode: Int {get}
//    var timeToken: NSNumber? {get}
//    var channels: [String] {get}
//    var channelGroups: [String] {get}
    var currentTimetoken: NSNumber {get}
    var lastTimetoken: NSNumber {get}
    var subscribedChannels: [String] {get}
    var subscribedChannelGroups: [String] {get}
    init(itemType: ItemType, subscribeStatus: PNSubscribeStatus)
    
}

//extension SubscribeStatusItem {
//    var title: String {
//        return category
//    }
//}

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
    
    override init(frame: CGRect) {
        self.categoryLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        self.operationLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        self.timeStampLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        self.statusCodeLabel = UILabel(frame: CGRect(x: 5, y: 90, width: frame.size.width, height: frame.size.height/4))
        self.timeTokenLabel = UILabel(frame: CGRect(x: 5, y: 120, width: frame.size.width, height: frame.size.height/4))
        self.channelLabel = UILabel(frame: CGRect(x: 5, y: 150, width: frame.size.width, height: frame.size.height/4))
        self.channelGroupLabel = UILabel(frame: CGRect(x: 5, y: 180, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(operationLabel)
        contentView.addSubview(timeStampLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.addSubview(channelLabel)
        contentView.addSubview(channelGroupLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: SubscribeStatusItem) {
        categoryLabel.text = "Category: \(item.category)"
        operationLabel.text = "Operation: \(item.operation)"
        timeStampLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        // FIXME: update UI for new object
//        if let timeToken = item.timeToken {
//            timeTokenLabel.isHidden = false
//            timeTokenLabel.text = "Time token: \(timeToken)"
//        } else {
//            timeTokenLabel.isHidden = true
//        }
//        if let channelText = PubNub.subscribablesToString(subscribables: item.channels), !item.channels.isEmpty {
//            channelLabel.isHidden = false
//            channelLabel.text = "Channel(s): \(channelText)"
//        } else {
//            channelLabel.isHidden = true
//        }
//        if let channelGroupText = PubNub.subscribablesToString(subscribables: item.channelGroups), !item.channelGroups.isEmpty {
//            channelGroupLabel.isHidden = false
//            channelGroupLabel.text = "Channel group(s): \(channelGroupText)"
//        } else {
//            channelGroupLabel.isHidden = true
//        }
        setNeedsLayout()
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
