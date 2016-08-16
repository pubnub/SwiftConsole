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
    init(itemType: ItemType, presenceEvent: PNPresenceEventResult)
}

class PresenceEvent: Result, PresenceEventItem {
    let actualChannel: String?
    let subscribedChannel: String?
    let timetoken: NSNumber
    let presenceEvent: String
    let presenceTimetoken: NSNumber
    let presenceUUID: String?
    let occupancy: NSNumber
    required init(itemType: ItemType, presenceEvent: PNPresenceEventResult) {
        self.subscribedChannel = presenceEvent.data.subscribedChannel
        self.actualChannel = presenceEvent.data.actualChannel
        self.timetoken = presenceEvent.data.timetoken
        self.presenceEvent = presenceEvent.data.presenceEvent
        self.presenceTimetoken = presenceEvent.data.presence.timetoken
        self.presenceUUID = presenceEvent.data.presence.uuid
        self.occupancy = presenceEvent.data.presence.occupancy
        super.init(itemType: itemType, result: presenceEvent)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    
    var reuseIdentifier: String {
        return PresenceEventCollectionViewCell.reuseIdentifier
    }
}

class PresenceEventCollectionViewCell: CollectionViewCell {

    private let eventTypeLabel: UILabel
    private let occupancyLabel: UILabel
    private let timeTokenLabel: UILabel

    override init(frame: CGRect) {
        self.eventTypeLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        self.occupancyLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        self.timeTokenLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        contentView.addSubview(eventTypeLabel)
        contentView.addSubview(occupancyLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updatePresence(item: PresenceEventItem) {
        eventTypeLabel.text = "Type: \(item.presenceEvent)"
        // FIXME: update UI for new object
//        if let channelOccupancy = item.occupancy {
//            occupancyLabel.isHidden = false
//            occupancyLabel.text = "Occupancy: \(channelOccupancy)"
//        } else {
//            occupancyLabel.isHidden = true
//        }
//        if let eventTimeToken = item.timeToken {
//            timeTokenLabel.isHidden = false
//            timeTokenLabel.text = "Time token: \(eventTimeToken)"
//        } else {
//            timeTokenLabel.isHidden = true
//        }
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let presenceEventItem = item as? PresenceEventItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePresence(item: presenceEventItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 150.0)
    }
    
}
