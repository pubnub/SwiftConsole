//
//  MessageCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit
import PubNub

protocol MessageItem: Item {
    init(itemType: ItemType, message: PNMessageResult)
    var payload: AnyObject? {get}
    var channelData: String? {get}
    var channel: String? {get}
    var timetoken: NSNumber {get}
}

extension MessageItem {
    var title: String {
        guard let currentPayload = payload else {
            return "Cannot display message"
        }
        return "\(currentPayload)"
    }
}

struct Message: MessageItem {
    let itemType: ItemType
    let timetoken: NSNumber
    let payload: AnyObject?
    var channelData: String?
    var channel: String?
    init(itemType: ItemType, message: PNMessageResult) {
        self.timetoken = message.data.timetoken
        self.itemType = itemType
        self.payload = message.data.message
        self.channelData = message.data.subscribedChannel
        self.channel = message.data.actualChannel
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
    
    func updateMessage(_ item: MessageItem) {
        messageLabel.text = "Message: \(item.title)"
        timeTokenLabel.text = "Timetoken: \(item.timetoken)"
        if let channelName = item.channel, let channelGroupName = item.channelData  {
            channelDataLabel.isHidden = false
            channelDataLabel.text = "Channel group: \(channelGroupName)"
            channelLabel.isHidden = false
            channelLabel.text = "Channel: \(channelName)"
        } else if let channelName = item.channelData {
            channelDataLabel.isHidden = false
            channelDataLabel.text = "Channel: \(channelName)"
            channelLabel.isHidden = true
        } else {
            channelDataLabel.isHidden = true
            channelLabel.isHidden = true
        }
        setNeedsLayout()
    }
    
    override func updateCell(_ item: Item) {
        guard let messageItem = item as? MessageItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateMessage(messageItem)
    }
    
    class override func size(_ collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 150.0)
    }
}
