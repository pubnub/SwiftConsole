//
//  PubNubSwiftConsole.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub
import CoreData

/*
public func modalClientCreationViewController() -> NavigationController {
    return NavigationController(rootViewControllerType: .clientCreation)
}

public func modalConsoleViewController(client: PubNub) -> NavigationController {
    return NavigationController(rootViewControllerType: .console(client: client))
}

public func modalPublishViewController(client: PubNub) -> PublishViewController {
    return PublishViewController(client: client)
}
 */

class SwiftConsole: NSObject, PNObjectEventListener {
    var client: PubNub? {
        willSet {
            client?.removeListener(self)
        }
        didSet {
            client?.addListener(self)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Spotella")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - PNObjectEventListener
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        persistentContainer.performBackgroundTask { (context) in
            var object: NSManagedObject?
            switch status {
            case let subscribeStatus as PNSubscribeStatus:
                let createdStatus = SubscribeStatus(context: context)
                createdStatus.timetoken = subscribeStatus.data.timetoken.int64Value
                createdStatus.isError = subscribeStatus.isError
                createdStatus.stringifiedCategory = subscribeStatus.stringifiedCategory()
                createdStatus.clientRequest = subscribeStatus.clientRequest?.url?.absoluteString
                createdStatus.isTLSEnabled = subscribeStatus.isTLSEnabled
                createdStatus.origin = subscribeStatus.origin
                createdStatus.stringifiedOperation = subscribeStatus.stringifiedOperation()
                createdStatus.statusCode = Int16(subscribeStatus.statusCode)
                object = createdStatus
            case let basicStatus as PNStatus:
                let createdStatus = Status(context: context)
                createdStatus.isError = basicStatus.isError
                createdStatus.stringifiedCategory = basicStatus.stringifiedCategory()
                object = createdStatus
            default:
                guard let result = status as? PNResult else {
                    fatalError()
                }
                let createdResult = Result(context: context)
                createdResult.stringifiedOperation = result.stringifiedOperation()
                createdResult.clientRequest = result.clientRequest?.url?.absoluteString
                createdResult.isTLSEnabled = result.isTLSEnabled
                createdResult.origin = result.origin
                createdResult.statusCode = Int16(result.statusCode)
                object = createdResult
            }
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        persistentContainer.performBackgroundTask { (context) in
            let createdMessage = MessageResult(context: context)
            createdMessage.stringifiedOperation = message.stringifiedOperation()
            createdMessage.clientRequest = message.clientRequest?.url?.absoluteString
            createdMessage.isTLSEnabled = message.isTLSEnabled
            createdMessage.origin = message.origin
            createdMessage.statusCode = Int16(message.statusCode)
            createdMessage.data = "\(message.data.message)"
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
