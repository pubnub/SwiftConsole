//
//  PresenceEventResult.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import Foundation
import CoreData
import PubNub

@objc(PresenceEventResult)
public class PresenceEventResult: Result {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(result: result, entity: entity, context: context)
        guard let presenceEventResult = result as? PNPresenceEventResult else {
            fatalError()
        }
        presenceEvent = presenceEventResult.data.presenceEvent
        occupancy = presenceEventResult.data.presence.occupancy.int16Value
        presenceUUID = presenceEventResult.data.presence.uuid
        presenceTimetoken = presenceEventResult.data.presence.timetoken.int64Value
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nPresence Event: \(presenceEvent!)\nPresence Timetoken: \(presenceTimetoken)\nPresence UUID: \(presenceUUID)\nOccupancy: \(occupancy)"
    }
    
}
