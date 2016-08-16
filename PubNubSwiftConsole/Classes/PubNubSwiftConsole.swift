//
//  PubNubSwiftConsole.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub
import PubNubPersistence

public func modalClientCreationViewController() -> NavigationController {
    return NavigationController(rootViewControllerType: .ClientCreation)
}

public func modalConsoleViewController(client: PubNub, persistence: PubNubPersistence? = nil) -> NavigationController {
    // FIXME: this needs updating
    return NavigationController(rootViewControllerType: .Console(client: client, persistence: persistence!))
}

public func modalPublishViewController(client: PubNub, persistence: PubNubPersistence? = nil) -> PublishViewController {
    return PublishViewController(client: client, persistence: persistence)
}
