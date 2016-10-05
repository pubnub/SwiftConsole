//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit
import PubNub

@objc(PNCNavigationController)
open class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    // MARK: - Constructors
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init(pubNubViewController: ViewController, showsToolbar: Bool = false) {
        super.init(rootViewController: pubNubViewController)
        self.delegate = self
        self.isToolbarHidden = (!showsToolbar)
    }
    
    /*
    public enum PubNubRootViewControllerType {
        case clientCreation
        case console(client: PubNub)
        case publish(client: PubNub)
        func create() -> ViewController {
            switch self {
            case .clientCreation:
                return ClientCreationViewController()
            case .console(let client):
                return ConsoleViewController(client: client)
            case .publish(let client):
                return PublishViewController(client: client)
            }
        }
    }
 */
    
    /*
    public convenience init(rootViewControllerType: PubNubRootViewControllerType) {
        self.init(pubNubViewController: rootViewControllerType.create())
    }
    
    open static func clientCreationNavigationController() -> NavigationController {
        return NavigationController(rootViewControllerType: .clientCreation)
    }
    
    open static func consoleNavigationController(_ client: PubNub) -> NavigationController {
        return NavigationController(rootViewControllerType: .console(client: client))
    }
    
    open static func publishNavigationController(_ client: PubNub) -> NavigationController {
        return NavigationController(rootViewControllerType: .publish(client: client))
    }
 */
    
    // MARK: - Toolbar Items
    
    open func publishBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Publish", style: .plain, target: self, action: #selector(self.publishBarButtonItemTapped(_:)))
    }
    
    // MARK: - Actions
    
    open func close(_ sender: UIBarButtonItem!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    open func publishBarButtonItemTapped(_ sender: UIBarButtonItem!) {
        guard let currentClient = self.client else {
            return
        }
        print(currentClient)
        //pushPublishViewController(currentClient)
    }
    
    /*
    open func pushPublishViewController(_ client: PubNub) {
        let publishViewController = PublishViewController(client: client)
        if let viewController = topViewController as? PublishViewControllerDelegate {
            publishViewController.publishDelegate = viewController
        }
        self.pushViewController(publishViewController, animated: true)
    }
 */
    
    // MARK: - Properties
        
    open var client: PubNub? {
        guard let topViewController = topViewController as? ViewController else {
            return nil
        }
        return topViewController.client
    }
    // can use this for the publish?
    open var firstClient: PubNub? {
        for viewController in viewControllers.reversed() {
            guard let pubNubViewController = viewController as? ViewController, let client = pubNubViewController.client else {
                continue
            }
            return client
        }
        return nil
    }
    
    // MARK: - UINavigationControllerDelegate
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let pubNubViewController = viewController as? ViewController else {
            return
        }
        // hide toolbar
        if !pubNubViewController.showsToolbar {
            navigationController.setToolbarHidden(true, animated: true)
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let pubNubViewController = viewController as? ViewController else {
            return
        }
        // show toolbar
        if pubNubViewController.showsToolbar {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
}
