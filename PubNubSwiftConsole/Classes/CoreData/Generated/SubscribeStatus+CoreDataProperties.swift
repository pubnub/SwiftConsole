//
//  SubscribeStatus+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension SubscribeStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscribeStatus> {
        return NSFetchRequest<SubscribeStatus>(entityName: "SubscribeStatus");
    }

    @NSManaged public var channel: String?
    @NSManaged public var currentTimetoken: Int64
    @NSManaged public var lastTimetoken: Int64
    @NSManaged public var subscribedChannelGroups: String?
    @NSManaged public var subscribedChannels: String?
    @NSManaged public var timetoken: Int64

}
