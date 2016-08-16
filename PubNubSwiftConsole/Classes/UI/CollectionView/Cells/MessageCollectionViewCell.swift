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
    init(itemType: ItemType, message: PNMessageResult)
    var payload: Any? {get}
}

class Message: Result, MessageItem {
    let payload: Any?
    let actualChannel: String?
    let subscribedChannel: String?
    let timetoken: NSNumber
    required init(itemType: ItemType, message: PNMessageResult) {
        self.actualChannel = message.data.actualChannel
        self.subscribedChannel = message.data.subscribedChannel
        self.timetoken = message.data.timetoken
        self.payload = message.data.message
        super.init(itemType: itemType, result: message)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    var reuseIdentifier: String {
        return MessageCollectionViewCell.reuseIdentifier
    }
}

class MessageCollectionViewCell: CollectionViewCell {
    private let messageLabel: UILabel
    private let channelDataLabel: UILabel
    private let channelLabel: UILabel
    private let timeTokenLabel: UILabel
    
    override init(frame: CGRect) {
        self.messageLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        self.channelDataLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        self.channelLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        self.timeTokenLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: 40.0))
        super.init(frame: frame)
        contentView.addSubview(messageLabel)
        contentView.addSubview(channelDataLabel)
        contentView.addSubview(channelLabel)
        timeTokenLabel.center = CGPoint(x: channelLabel.center.x, y: channelLabel.center.y + channelLabel.frame.size.height)
        contentView.addSubview(timeTokenLabel)
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMessage(item: MessageItem) {
        // FIXME: update UI for new object
        messageLabel.text = "Message: \(item.payload)"
        timeTokenLabel.text = "Timetoken: \(item.timetoken)"
//        if let channelName = item.channel, let channelGroupName = item.channelData  {
//            channelDataLabel.isHidden = false
//            channelDataLabel.text = "Channel group: \(channelGroupName)"
//            channelLabel.isHidden = false
//            channelLabel.text = "Channel: \(channelName)"
//        } else if let channelName = item.channelData {
//            channelDataLabel.isHidden = false
//            channelDataLabel.text = "Channel: \(channelName)"
//            channelLabel.isHidden = true
//        } else {
//            channelDataLabel.isHidden = true
//            channelLabel.isHidden = true
//        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let messageItem = item as? MessageItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateMessage(item: messageItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 150.0)
    }
}
