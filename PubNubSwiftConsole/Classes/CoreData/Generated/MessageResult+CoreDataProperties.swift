//
//  MessageResult+CoreDataProperties.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MessageResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageResult> {
        return NSFetchRequest<MessageResult>(entityName: "MessageResult");
    }

    @NSManaged public var data: String?

}
