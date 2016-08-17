//
//  PresenceEventCollectionViewCell.swift
//  Pods
//
//  Created by Keith Martin on 8/10/16.
//
//

import UIKit
import PubNub

protocol PresenceEventItem: ResultItem, SubscriberData {
    var presenceEvent: String {get}
    var presenceTimetoken: NSNumber {get}
    var presenceUUID: String? {get}
    var occupancy: NSNumber {get}
    init(itemType: ItemType, pubNubResult result: PNPresenceEventResult)
}

class PresenceEvent: Result, PresenceEventItem {
    let actualChannel: String?
    let subscribedChannel: String?
    let timetoken: NSNumber
    let presenceEvent: String
    let presenceTimetoken: NSNumber
    let presenceUUID: String?
    let occupancy: NSNumber
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNPresenceEventResult)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNPresenceEventResult) {
        self.subscribedChannel = result.data.subscribedChannel
        self.actualChannel = result.data.actualChannel
        self.timetoken = result.data.timetoken
        self.presenceEvent = result.data.presenceEvent
        self.presenceTimetoken = result.data.presence.timetoken
        self.presenceUUID = result.data.presence.uuid
        self.occupancy = result.data.presence.occupancy
        super.init(itemType: itemType, pubNubResult: result as! PNResult)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return PresenceEvent(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return PresenceEventCollectionViewCell.reuseIdentifier
    }
}

class PresenceEventCollectionViewCell: ResultCollectionViewCell {

    let timetokenLabel: UILabel
    let presenceEventLabel: UILabel
    let presenceTimetokenLabel: UILabel
    let presenceUUIDLabel: UILabel
    
    override init(frame: CGRect) {
        self.timetokenLabel = UILabel(frame: .zero)
        self.presenceUUIDLabel = UILabel(frame: .zero)
        self.presenceEventLabel = UILabel(frame: .zero)
        self.presenceTimetokenLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(presenceTimetokenLabel)
        presenceTimetokenLabel.forceAutoLayout()
        contentView.addSubview(timetokenLabel)
        timetokenLabel.forceAutoLayout()
        contentView.addSubview(presenceEventLabel)
        presenceEventLabel.forceAutoLayout()
        contentView .addSubview(presenceUUIDLabel)
        presenceUUIDLabel.forceAutoLayout()
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        presenceEventLabel.frame = CGRect(x: 5.0, y: 10.0, width: contentView.frame.width, height: 50.0)
        timetokenLabel.frame = presenceEventLabel.frame.offsetBy(dx: 0.0, dy: presenceEventLabel.frame.size.height)
        operationLabel.frame = timetokenLabel.frame.offsetBy(dx: 0.0, dy: timetokenLabel.frame.size.height)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
        presenceTimetokenLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
        presenceUUIDLabel.frame = presenceTimetokenLabel.frame.offsetBy(dx: 0.0, dy: presenceTimetokenLabel.frame.size.height)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let presenceEventItem = item as? PresenceEventItem else {
            fatalError("wrong class")
        }
        presenceEventLabel.text = "Event: \(presenceEventItem.presenceEvent)"
        timetokenLabel.text = "Timetoken: \(presenceEventItem.timetoken)"
        presenceTimetokenLabel.text = "Presence timetoken: \(presenceEventItem.presenceTimetoken)"
        if let presenceUUID = presenceEventItem.presenceUUID {
            presenceUUIDLabel.text = "Presence uuid: \(presenceEventItem.presenceUUID)"
            presenceUUIDLabel.isHidden = false
        } else {
            presenceUUIDLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 300.0)
    }
    
}
