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

public class SwiftConsole: NSObject, PNObjectEventListener {
    
    let client: PubNub
    
    public required init(client: PubNub) {
        self.client = client
        super.init()
        client.addListener(self)
    }
    
    // MARK: - Views
    
    public func consoleViewController() -> NavigationController {
        return NavigationController(pubNubViewController: ConsoleViewController(console: self))
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
        NSBundle *podBundle = [NSBundle bundleForClass:self.classForCoder];
        NSURL *dataModelBundleURL = [podBundle URLForResource:@"DataModel" withExtension:@"bundle"];
        NSBundle *dataModelBundle = [NSBundle bundleWithURL:dataModelBundleURL];
        //NSURL *dataModelURL = [dataModelBundle URLForResource:@"PubNubPersistence" withExtension:@"xcdatamodeld"];
        //NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"bundle"];
        //NSBundle *podBundle = [NSBundle bundleWithPath:bundlePath];
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[dataModelBundle]];
        
        //NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:dataModelURL];
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PubNubPersistence" managedObjectModel:model];
         */
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let podBundle = Bundle(for: self.classForCoder)
        guard let dataModelBundleURL = podBundle.url(forResource: "PubNubSwiftConsole", withExtension: "bundle") else {
            fatalError("no pod bundle URL")
        }
        guard let dataModelBundle = Bundle(url: dataModelBundleURL) else {
            fatalError("no pod bundle")
        }
        guard let model = NSManagedObjectModel.mergedModel(from: [dataModelBundle]) else {
            fatalError("no managed object model")
        }
        let container = NSPersistentContainer(name: "SwiftConsole", managedObjectModel: model)
        //let container = NSPersistentContainer(name: "SwiftConsole")
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
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
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
    
    public func client(_ client: PubNub, didReceive status: PNStatus) {
        persistentContainer.performBackgroundTask { (context) in
            let _ = ResultType.createCoreDataObject(result: status, in: context)
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        persistentContainer.performBackgroundTask { (context) in
            let _ = ResultType.createCoreDataObject(result: message, in: context)
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        persistentContainer.performBackgroundTask { (context) in
            let _ = ResultType.createCoreDataObject(result: event, in: context)
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
