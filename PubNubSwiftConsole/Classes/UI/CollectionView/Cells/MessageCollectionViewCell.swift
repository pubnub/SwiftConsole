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
    override var reuseIdentifier: String {
        return MessageCollectionViewCell.reuseIdentifier
    }
}

class MessageCollectionViewCell: CollectionViewCell {

    private let payloadLabel: UILabel
    private let timetokenLabel: UILabel
    private let actualChannelLabel: UILabel
    private let subscribedChannelLabel: UILabel
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let uuidLabel: UILabel
    private let clientRequestLabel: UILabel
    
    override init(frame: CGRect) {
        self.payloadLabel = UILabel(frame: .zero)
        self.timetokenLabel = UILabel(frame: .zero)
        self.actualChannelLabel = UILabel(frame: .zero)
        self.subscribedChannelLabel = UILabel(frame: .zero)
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(clientRequestLabel)
        contentView.addSubview(payloadLabel)
        contentView.addSubview(timetokenLabel)
        contentView.addSubview(actualChannelLabel)
        contentView .addSubview(subscribedChannelLabel)
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        payloadLabel.frame = CGRect(x: 5.0, y: 10.0, width: contentView.frame.width, height: 100.0)
        timetokenLabel.frame = payloadLabel.frame.offsetBy(dx: 0.0, dy: 50.0)
        operationLabel.frame = timetokenLabel.frame.offsetBy(dx: 0.0, dy: timetokenLabel.frame.size.height)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
        actualChannelLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
        subscribedChannelLabel.frame = actualChannelLabel.frame.offsetBy(dx: 0.0, dy: actualChannelLabel.frame.size.height)
    }
    
    func updateMessage(item: MessageItem) {
        payloadLabel.text = "Message: \(item.payload ?? "Cannot display message")"
        timetokenLabel.text = "Timetoken: \(item.timetoken)"
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        uuidLabel.text = "UUID: \(item.uuid)"
        clientRequestLabel.text = "Client request: \(item.clientRequest)"
        if let actualChannel = item.actualChannel {
            actualChannelLabel.text = "Actual channel: \(actualChannel)"
            actualChannelLabel.isHidden = false
        } else {
            actualChannelLabel.isHidden = true
        }
        if let subscribedChannel = item.subscribedChannel {
            subscribedChannelLabel.text = "Subscribed channel: \(subscribedChannel)"
            subscribedChannelLabel.isHidden = false
        } else {
            subscribedChannelLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let messageItem = item as? MessageItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateMessage(item: messageItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 300.0)
    }
}
