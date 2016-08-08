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
        if showsToolbar {
            let publishItem = UIBarButtonItem(title: "Publish", style: .Plain, target: self, action: #selector(self.publishBarButtonItemTapped(_:)))
            self.toolbar.items = [publishItem]
            self.toolbar.setNeedsLayout()
        }
    }
    public func close(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    public func publishBarButtonItemTapped(sender: UIBarButtonItem!) {
        guard let currentClient = self.client else {
            return
        }
        pushPublishViewController(currentClient)
    }
    public func pushPublishViewController(client: PubNub) {
        let publishViewController = PublishViewController(client: client)
        self.pushViewController(publishViewController, animated: true)
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
