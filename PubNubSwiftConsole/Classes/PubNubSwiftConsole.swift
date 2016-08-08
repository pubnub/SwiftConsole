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
    let navController = UINavigationController.init()
    navController.pushViewController(rootViewController, animated: false)
    return navController
}

public func modalConsoleViewController(client: PubNub) -> UINavigationController {
    let rootViewController = ConsoleViewController(client: client)
    let navController = UINavigationController.init()
    navController.pushViewController(rootViewController, animated: false)
    return navController
}
