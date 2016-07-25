//
//  PubNubSwiftConsole.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

public func modalClientCreationViewController() -> NavigationController {
    let rootViewController = ClientCreationViewController()
    return NavigationController(rootViewController: rootViewController)
}
