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
    let payload: AnyObject?
    var channelData: String?
    var channel: String?
    init(itemType: ItemType, message: PNMessageResult) {
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
    private let titleLabel: UILabel
    private let channelDataLabel: UILabel
    private let channelLabel: UILabel
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        channelDataLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        channelLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelDataLabel)
        contentView.addSubview(channelLabel)
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStatus(item: MessageItem) {
        titleLabel.text = "Message: \(item.title)"
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
        updateStatus(messageItem)
    }
}
