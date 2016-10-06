//
//  Status.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub

@objc(Status)
public class Status: Result {
    
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(result: result, entity: entity, context: context)
        guard let status = result as? PNStatus else {
            fatalError()
        }
        isError = status.isError
        stringifiedCategory = status.stringifiedCategory()
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nCategory: \(stringifiedCategory!)\nisError: \(isError)"
    }

}
