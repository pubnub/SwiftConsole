//
//  Status+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Status {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: "Status");
    }

    @NSManaged public var isError: Bool
    @NSManaged public var stringifiedCategory: String?

}
