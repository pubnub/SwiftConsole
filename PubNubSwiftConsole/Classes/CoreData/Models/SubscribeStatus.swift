//
//  SubscribeStatus.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub

@objc(SubscribeStatus)
public class SubscribeStatus: Status {
    
    public required init(result: PNResult, entity: NSEntityDescription, context: NSManagedObjectContext) {
        super.init(result: result, entity: entity, context: context)
        guard let subscribeStatus = result as? PNSubscribeStatus else {
            fatalError()
        }
        timetoken = subscribeStatus.data.timetoken.int64Value
    }
    
    public override var textViewDisplayText: String {
        let superText = super.textViewDisplayText
        return superText + "\nTimetoken: \(timetoken)"
    }

}
