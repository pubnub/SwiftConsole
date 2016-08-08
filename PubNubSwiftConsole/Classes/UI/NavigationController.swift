//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit
import PubNub

extension UINavigationController {
    public convenience init(pubNubViewController: ViewController, showsToolbar: Bool = false) {
        self.init(rootViewController: pubNubViewController)
        self.toolbarHidden = (!showsToolbar)
    }
    public func close(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    public var client: PubNub? {
        guard let topViewController = topViewController as? ViewController else {
            return nil
        }
        return topViewController.client
    }
    // can use this for the publish?
    public var firstClient: PubNub? {
        for viewController in viewControllers.reverse() {
            guard let pubNubViewController = viewController as? ViewController, let client = pubNubViewController.client else {
                continue
            }
            return client
        }
        return nil
    }
}
