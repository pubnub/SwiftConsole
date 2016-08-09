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
    let rootViewController = ClientCreationViewController()
    return NavigationController(pubNubViewController: rootViewController)
}

public func modalConsoleViewController(client: PubNub) -> NavigationController {
    let rootViewController = ConsoleViewController(client: client)
    return NavigationController(pubNubViewController: rootViewController)
}

public func modalPublishViewController(client: PubNub) -> PublishViewController {
    return PublishViewController(client: client)
}
