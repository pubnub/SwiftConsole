//
//  Result.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub

@objc(Result)
public class Result: NSManagedObject {
        
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(entity: entity, insertInto: context)
        stringifiedOperation = result.stringifiedOperation()
        clientRequest = result.clientRequest?.url?.absoluteString
        isTLSEnabled = result.isTLSEnabled
        origin = result.origin
        statusCode = Int16(result.statusCode)
    }
    
    public convenience init(result: PNResult, context: NSManagedObjectContext) {
        let entity = type(of: self).entity()
        self.init(result: result, entity: entity, context: context)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
    }
    
    public var textViewDisplayText: String {
        //return "Type: PNResult\nOperation: \(stringifiedOperation)\nStatus Code: \(statusCode)\nLocal Time: \(creationDate)"
        return "Operation: \(stringifiedOperation!)\nStatus Code: \(statusCode)\nLocal Time: \(creationDate!)"
    }

}
