//
//  MessageCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit
import PubNub
import PubNubPersistence

protocol MessageItem: Item {
//    init(itemType: ItemType, message: PNMessageResult)
    var payload: AnyObject? {get}
    var channelData: String? {get}
    var channel: String? {get}
    var timetoken: Int64 {get}
}

//extension MessageItem {
//    public var title: String {
//        guard let currentPayload = payload else {
//            return "Cannot display message"
//        }
//        return "\(currentPayload)"
//    }
//}

struct Message: MessageItem {
    var title: String {
        return "whatever"
    }
    let itemType: ItemType
    let timetoken: Int64
    let payload: AnyObject?
    var channelData: String?
    var channel: String?
    init(itemType: ItemType, message: PNMessageResult) {
        self.timetoken = message.data.timetoken.longLongValue
        self.itemType = itemType
        self.payload = message.data.message
        self.channelData = message.data.subscribedChannel
        self.channel = message.data.actualChannel
    }
    var reuseIdentifier: String {
        return MessageCollectionViewCell.reuseIdentifier
    }
}

extension PNPMessage: MessageItem {
    public var title: String {
        return "whatever"
    }
    public var itemType: ItemType {
        return ConsoleViewController.ConsoleItemType.Message
    }
    var payload: AnyObject? {
        return message
    }
    var channelData: String? {
        return self.actualChannel
    }
    var channel: String? {
        return self.subscribedChannel
    }
}

class MessageCollectionViewCell: CollectionViewCell {
    private let messageLabel: UILabel
    private let channelDataLabel: UILabel
    private let channelLabel: UILabel
    private let timeTokenLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        messageLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        channelDataLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        channelLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        timeTokenLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: 40.0))
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
        messageLabel.text = "Message: \(item.title)"
        timeTokenLabel.text = "Timetoken: \(item.timetoken)"
        if let channelName = item.channel, channelGroupName = item.channelData  {
            channelDataLabel.hidden = false
            channelDataLabel.text = "Channel group: \(channelGroupName)"
            channelLabel.hidden = false
            channelLabel.text = "Channel: \(channelName)"
        } else if let channelName = item.channelData {
            channelDataLabel.hidden = false
            channelDataLabel.text = "Channel: \(channelName)"
            channelLabel.hidden = true
        } else {
            channelDataLabel.hidden = true
            channelLabel.hidden = true
        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let messageItem = item as? MessageItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateMessage(messageItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 150.0)
    }
}
