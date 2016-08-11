//
//  PubNubSwiftConsole.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub

public func modalClientCreationViewController() -> NavigationController {
    return NavigationController(rootViewControllerType: .ClientCreation)
}

public func modalConsoleViewController(client: PubNub) -> NavigationController {
    return NavigationController(rootViewControllerType: .Console(client: client))
}

public func modalPublishViewController(client: PubNub) -> PublishViewController {
    return PublishViewController(client: client)
}
