//
//  MessageCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit
import PubNub

protocol MessageItem: ResultItem, SubscriberData {
    init(itemType: ItemType, pubNubResult result: PNMessageResult)
    var payload: Any? {get}
}

class Message: Result, MessageItem {
    let payload: Any?
    let actualChannel: String?
    let subscribedChannel: String?
    let timetoken: NSNumber
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNMessageResult)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNMessageResult) {
        self.actualChannel = result.data.actualChannel
        self.subscribedChannel = result.data.subscribedChannel
        self.timetoken = result.data.timetoken
        self.payload = result.data.message
        super.init(itemType: itemType, pubNubResult: result as! PNResult)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return Message(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return MessageCollectionViewCell.reuseIdentifier
    }
}

class MessageCollectionViewCell: ResultCollectionViewCell {

    let payloadLabel: UILabel
    let timetokenLabel: UILabel
    let actualChannelLabel: UILabel
    let subscribedChannelLabel: UILabel

    override init(frame: CGRect) {
        self.payloadLabel = UILabel(frame: .zero)
        self.timetokenLabel = UILabel(frame: .zero)
        self.actualChannelLabel = UILabel(frame: .zero)
        self.subscribedChannelLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        stackView.insertArrangedSubview(payloadLabel, at: 0)
        stackView.insertArrangedSubview(timetokenLabel, at: 1)
        stackView.insertArrangedSubview(actualChannelLabel, at: 2)
        stackView.insertArrangedSubview(subscribedChannelLabel, at: 3)
        // FIXME: // let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let messageItem = item as? MessageItem else {
            fatalError("wrong class")
        }
        payloadLabel.text = "Message: \(messageItem.payload ?? "Cannot display message")"
        timetokenLabel.text = "Timetoken: \(messageItem.timetoken)"
        if let actualChannel = messageItem.actualChannel {
            actualChannelLabel.text = "Actual channel: \(actualChannel)"
            actualChannelLabel.isHidden = false
        } else {
            actualChannelLabel.isHidden = true
        }
        if let subscribedChannel = messageItem.subscribedChannel {
            subscribedChannelLabel.text = "Subscribed channel: \(subscribedChannel)"
            subscribedChannelLabel.isHidden = false
        } else {
            subscribedChannelLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
}
