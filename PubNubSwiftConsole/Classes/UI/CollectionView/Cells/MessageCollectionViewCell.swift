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
    
    private var channelLabelConstraints: [NSLayoutConstraint]?
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        messageLabel = UILabel(frame: CGRectZero)
        channelDataLabel = UILabel(frame: CGRectZero)
        channelLabel = UILabel(frame: CGRectZero)
        timeTokenLabel = UILabel(frame: CGRectZero)
        super.init(frame: frame)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        channelDataLabel.translatesAutoresizingMaskIntoConstraints = false
        channelLabel.translatesAutoresizingMaskIntoConstraints = false
        timeTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        contentView.addSubview(channelDataLabel)
        contentView.addSubview(channelLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.layer.borderWidth = 1
        
        let messageLabelXConstraint = NSLayoutConstraint(item: messageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let timetokenXConstraint = NSLayoutConstraint(item: timeTokenLabel, attribute: .CenterX, relatedBy: .Equal, toItem: messageLabel, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let views = [
            "messageLabel": messageLabel,
            "channelDataLabel": channelDataLabel,
            "channelLabel": channelLabel,
            "timeTokenLabel": timeTokenLabel,
        ]
        
        let metrics = [
            "timeTokenWidth": NSNumber(integer: 100),
            "spacer": NSNumber(integer: 5),
        ]
        
        let messageLabelXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[messageLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let timeTokenWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[timeTokenLabel(timeTokenWidth)]", options: [], metrics: metrics, views: views)
        let channelDataWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[channelDataLabel]", options: [], metrics: metrics, views: views)
        channelLabelConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[channelLabel]-spacer-|", options: [], metrics: metrics, views: views)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacer-[messageLabel]-spacer-[timeTokenLabel]-spacer-[channelDataLabel]", options: [], metrics: metrics, views: views)
        
        NSLayoutConstraint.activateConstraints([messageLabelXConstraint, timetokenXConstraint])
        NSLayoutConstraint.activateConstraints(messageLabelXConstraints)
        NSLayoutConstraint.activateConstraints(timeTokenWidthConstraints)
        NSLayoutConstraint.activateConstraints(channelDataWidthConstraints)
        NSLayoutConstraint.activateConstraints(verticalConstraints)
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
            NSLayoutConstraint.activateConstraints(channelLabelConstraints!)
            channelLabel.text = "Channel: \(channelName)"
        } else if let channelName = item.channelData {
            channelDataLabel.hidden = false
            channelDataLabel.text = "Channel: \(channelName)"
            channelLabel.hidden = true
            NSLayoutConstraint.deactivateConstraints(channelLabelConstraints!)
        } else {
            fatalError()
        }
        contentView.setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NSLayoutConstraint.deactivateConstraints(channelLabelConstraints!)
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
