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
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        eventTypeLabel = UILabel(frame: CGRectZero)
        occupancyLabel = UILabel(frame: CGRectZero)
        timeTokenLabel = UILabel(frame: CGRectZero)
        super.init(frame: frame)
        eventTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        occupancyLabel.translatesAutoresizingMaskIntoConstraints = false
        timeTokenLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventTypeLabel)
        contentView.addSubview(occupancyLabel)
        contentView.addSubview(timeTokenLabel)
        contentView.layer.borderWidth = 3
        
        let eventTypeLabelXConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let occupancyLabelXConstraint = NSLayoutConstraint(item: occupancyLabel, attribute: .CenterX, relatedBy: .Equal, toItem: eventTypeLabel, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let timeTokenLabelXConstraint = NSLayoutConstraint(item: timeTokenLabel, attribute: .CenterX, relatedBy: .Equal, toItem: occupancyLabel, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let views = [
            "eventTypeLabel" : eventTypeLabel,
            "occupancyLabel" : occupancyLabel,
            "timeTokenLabel" : timeTokenLabel
        ]
        let metrics = [
            "timeTokenWidth" : NSNumber(integer: 100),
            "spacer" : NSNumber(integer: 5)
        ]
        
        let eventTypeLabelWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[eventTypeLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let occupancyLabelWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[occupancyLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let timeTokenLabelWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[timeTokenLabel]-spacer-|", options: [], metrics: metrics, views: views)
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacer-[eventTypeLabel]-spacer-[occupancyLabel]-spacer-[timeTokenLabel]", options: [], metrics: metrics, views: views)
        
        contentView.addConstraint(eventTypeLabelXConstraint)
        contentView.addConstraint(occupancyLabelXConstraint)
        contentView.addConstraint(timeTokenLabelXConstraint)
        contentView.addConstraints(eventTypeLabelWidthConstraints)
        contentView.addConstraints(occupancyLabelWidthConstraints)
        contentView.addConstraints(timeTokenLabelWidthConstraints)
        contentView.addConstraints(verticalConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updatePresence(item: PresenceEventItem) {
        eventTypeLabel.text = "Type: \(item.title)"
        if let channelOccupancy = item.occupancy {
            occupancyLabel.hidden = false
            occupancyLabel.text = "Occupancy: \(channelOccupancy)"
        } else {
            occupancyLabel.hidden = true
        }
        if let eventTimeToken = item.timeToken {
            timeTokenLabel.hidden = false
            timeTokenLabel.text = "Time token: \(eventTimeToken)"
        } else {
            timeTokenLabel.hidden = true
        }
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let presenceEventItem = item as? PresenceEventItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updatePresence(presenceEventItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 150.0)
    }
    
}
