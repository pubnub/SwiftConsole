//
//  PresenceEventResult+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import Foundation
import CoreData


extension PresenceEventResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PresenceEventResult> {
        return NSFetchRequest<PresenceEventResult>(entityName: "PresenceEventResult");
    }

    @NSManaged public var presenceEvent: String?
    @NSManaged public var presenceTimetoken: Int64
    @NSManaged public var presenceUUID: String?
    @NSManaged public var occupancy: Int16

}
