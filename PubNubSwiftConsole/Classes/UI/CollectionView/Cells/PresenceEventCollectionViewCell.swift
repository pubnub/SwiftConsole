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
    let occupancyLabel: UILabel
    
    override init(frame: CGRect) {
        self.timetokenLabel = UILabel(frame: .zero)
        self.presenceUUIDLabel = UILabel(frame: .zero)
        self.presenceEventLabel = UILabel(frame: .zero)
        self.presenceTimetokenLabel = UILabel(frame: .zero)
        self.occupancyLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        stackView.insertArrangedSubview(presenceEventLabel, at: 0)
        stackView.insertArrangedSubview(presenceTimetokenLabel, at: 1)
        stackView.insertArrangedSubview(presenceUUIDLabel, at: 2)
        stackView.insertArrangedSubview(occupancyLabel, at: 3)
        stackView.insertArrangedSubview(timetokenLabel, at: 4)
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let presenceEventItem = item as? PresenceEventItem else {
            fatalError("wrong class")
        }
        presenceEventLabel.text = "Event: \(presenceEventItem.presenceEvent)"
        timetokenLabel.text = "Timetoken: \(presenceEventItem.timetoken)"
        presenceTimetokenLabel.text = "Presence timetoken: \(presenceEventItem.presenceTimetoken)"
        occupancyLabel.text = "Occupancy: \(presenceEventItem.occupancy)"
        if let presenceUUID = presenceEventItem.presenceUUID {
            presenceUUIDLabel.text = "Presence uuid: \(presenceUUID)"
            presenceUUIDLabel.isHidden = false
        } else {
            presenceUUIDLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
}
