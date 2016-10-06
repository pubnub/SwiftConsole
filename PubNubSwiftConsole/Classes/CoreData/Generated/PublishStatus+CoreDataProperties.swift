//
//  PublishStatus+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import Foundation
import CoreData


extension PublishStatus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublishStatus> {
        return NSFetchRequest<PublishStatus>(entityName: "PublishStatus");
    }

    @NSManaged public var timetoken: Int64
    @NSManaged public var information: String?

}
