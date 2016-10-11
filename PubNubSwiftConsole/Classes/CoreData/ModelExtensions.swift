//
//  ModelExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import Foundation
import CoreData
import PubNub

enum ResultType {
    case result
    case status
    case subscribeStatus
    case messageResult
    case presenceEventResult
    case publishStatus
    
    var resultType: Result.Type {
        switch self {
        case .publishStatus:
            return PublishStatus.self
        case .subscribeStatus:
            return SubscribeStatus.self
        case .presenceEventResult:
            return PresenceEventResult.self
        case .messageResult:
            return MessageResult.self
        case .status:
            return Status.self
        case .result:
            return Result.self
        }
    }
    
    init?(result: PNResult?) {
        guard let actualResult = result else {
            return nil
        }
        switch actualResult {
        case let publishStatus as PNPublishStatus:
            self = ResultType.publishStatus
        case let subscribeStatus as PNSubscribeStatus:
            self = ResultType.subscribeStatus
        case let presenceEventResult as PNPresenceEventResult:
            self = ResultType.presenceEventResult
        case let messageResult as PNMessageResult:
            self = ResultType.messageResult
        case let status as PNStatus:
            self = ResultType.status
        default:
            self = ResultType.result
        }
    }
    
    static func createCoreDataObject(result: PNResult?, in context: NSManagedObjectContext) -> Result? {
        guard let actualResult = result else {
            return nil
        }
        guard let resultType = ResultType(result: actualResult) else {
            return nil
        }
        let actualResultType = resultType.resultType
        let entity = actualResultType.entity()
        return actualResultType.init(result: actualResult, entity: entity, context: context)
    }
    
}

//extension Result: Thing { }
