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
    init(message: PNMessageResult)
    var payload: AnyObject? {get}
    var channel: String? {get}
    var channelGroup: String? {get}
}

extension MessageItem {
    var title: String {
        guard let currentPayload = payload else {
            return "Cannot display message"
        }
        return "\(currentPayload)"
    }
}

class MessageCollectionViewCell: CollectionViewCell {
    private let titleLabel: UILabel
    private let channelLabel: UILabel
    private let channelGroupLabel: UILabel
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        channelLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        channelGroupLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelLabel)
        contentView.addSubview(channelGroupLabel)
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: MessageItem) {
        titleLabel.text = "Message: \(item.title)"
        if let channel = item.channel {
            channelLabel.hidden = false
            channelLabel.text = "Channel(s): \(channel)"
        } else {
            channelLabel.hidden = true
        }
        if let channelGroup = item.channelGroup {
            channelGroupLabel.hidden = false
            channelGroupLabel.text = "Channel group: \(channelGroup)"
        } else {
            channelGroupLabel.hidden = true
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
