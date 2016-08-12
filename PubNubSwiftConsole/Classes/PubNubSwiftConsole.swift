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
    return NavigationController(rootViewControllerType: .clientCreation)
}

public func modalConsoleViewController(_ client: PubNub) -> NavigationController {
    return NavigationController(rootViewControllerType: .console(client: client))
}

public func modalPublishViewController(_ client: PubNub) -> PublishViewController {
    return PublishViewController(client: client)
}
