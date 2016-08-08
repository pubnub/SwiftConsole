//
//  PubNubSwiftConsole.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub

public func modalClientCreationViewController() -> UINavigationController {
    let rootViewController = ClientCreationViewController()
    return UINavigationController.init(pubNubViewController: rootViewController)
}

public func modalConsoleViewController(client: PubNub) -> UINavigationController {
    let rootViewController = ConsoleViewController(client: client)
    return UINavigationController.init(pubNubViewController: rootViewController)
}
