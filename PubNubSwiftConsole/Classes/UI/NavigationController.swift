//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit
import PubNub

public class NavigationController: UINavigationController, UINavigationControllerDelegate {
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public required init(pubNubViewController: ViewController, showsToolbar: Bool = false) {
        super.init(rootViewController: pubNubViewController)
        self.delegate = self
        self.toolbarHidden = (!showsToolbar)
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
        if let viewController = topViewController as? PublishViewControllerDelegate {
            publishViewController.publishDelegate = viewController
        }
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
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        guard let pubNubViewController = viewController as? ViewController else {
            return
        }
        // hide toolbar
        if !pubNubViewController.showsToolbar {
            navigationController.setToolbarHidden(true, animated: true)
        }
    }
    
    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        guard let pubNubViewController = viewController as? ViewController else {
            return
        }
        // show toolbar
        if pubNubViewController.showsToolbar {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
}
