//
//  PublishStatus.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import Foundation
import CoreData
import PubNub

@objc(PublishStatus)
public class PublishStatus: Status {
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(result: result, entity: entity, context: context)
        guard let publishStatus = result as? PNPublishStatus else {
            fatalError()
        }
        timetoken = publishStatus.data.timetoken.int64Value
        information = publishStatus.data.information
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)\nInformation: \(information)"
    }
    
}
