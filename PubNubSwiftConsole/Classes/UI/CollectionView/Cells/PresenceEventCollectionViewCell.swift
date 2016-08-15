//
//  PresenceEventCollectionViewCell.swift
//  Pods
//
//  Created by Keith Martin on 8/10/16.
//
//

import UIKit
import PubNub

protocol PresenceEventItem: Item {
    init(itemType: ItemType, event: PNPresenceEventResult)
    var eventType: String {get}
    var occupancy: NSNumber? {get}
    var timeToken: NSNumber? {get}
}

extension PresenceEventItem {
    var title: String {
        return eventType
    }
}

struct PresenceEvent: PresenceEventItem {
    let itemType: ItemType
    let eventType: String
    let occupancy: NSNumber?
    let timeToken: NSNumber?
    init(itemType: ItemType, event: PNPresenceEventResult) {
        self.itemType = itemType
        self.eventType = event.data.presenceEvent
        self.occupancy = event.data.presence.occupancy
        self.timeToken = event.data.presence.timetoken
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
        eventTypeLabel.text = "Type: \(item.title)"
        if let channelOccupancy = item.occupancy {
            occupancyLabel.isHidden = false
            occupancyLabel.text = "Occupancy: \(channelOccupancy)"
        } else {
            occupancyLabel.isHidden = true
        }
        if let eventTimeToken = item.timeToken {
            timeTokenLabel.isHidden = false
            timeTokenLabel.text = "Time token: \(eventTimeToken)"
        } else {
            timeTokenLabel.isHidden = true
        }
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
