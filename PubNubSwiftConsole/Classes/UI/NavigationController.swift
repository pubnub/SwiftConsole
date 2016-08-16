//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit
import PubNubPersistence
import PubNub

@objc(PNCNavigationController)
public class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    // MARK: - Constructors
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
    
    public enum PubNubRootViewControllerType {
        case ClientCreation
        case Console(client: PubNub, persistence: PubNubPersistence)
        case Publish(client: PubNub, persistence: PubNubPersistence)
        func create() -> ViewController {
            switch self {
            case .ClientCreation:
                return ClientCreationViewController()
            case let .Console(client, persistence):
                return ConsoleViewController(client: client, persistence: persistence)
            case let .Publish(client, persistence):
                return PublishViewController(client: client, persistence: persistence)
            }
        }
    }
    
    public convenience init(rootViewControllerType: PubNubRootViewControllerType) {
        self.init(pubNubViewController: rootViewControllerType.create())
    }
    
    public static func clientCreationNavigationController() -> NavigationController {
        return NavigationController(rootViewControllerType: .ClientCreation)
    }
    
    public static func consoleNavigationController(client: PubNub, persistence: PubNubPersistence) -> NavigationController {
        return NavigationController(rootViewControllerType: .Console(client: client, persistence: persistence))
    }
    
    public static func publishNavigationController(client: PubNub, persistence: PubNubPersistence) -> NavigationController {
        return NavigationController(rootViewControllerType: .Publish(client: client, persistence: persistence))
    }
    
    // MARK: - Toolbar Items
    
    public func publishBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Publish", style: .Plain, target: self, action: #selector(self.publishBarButtonItemTapped(_:)))
    }
    
    // MARK: - Actions
    
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
    
    // MARK: - Properties
        
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
