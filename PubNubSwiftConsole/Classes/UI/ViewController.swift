//
//  ViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub
import PubNubPersistence

@objc(PNCViewController)
public class ViewController: UIViewController, PNObjectEventListener {
    
    public convenience init() {
        self.init(persistence: nil)
    }
    
    public required init(persistence: PubNubPersistence?) {
        self.persistence = persistence
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        // don't call super for UIViewController direct subclass
        let frame = UIScreen.mainScreen().bounds
        self.view = UIView(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var client: PubNub? {
        didSet {
            oldValue?.removeListener(self)
            client?.addListener(self)
        }
    }
    
    public let persistence: PubNubPersistence?
    
    deinit {
        client?.removeListener(self) // not really necessary, just to be safe
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
        self.navigationItem.title = navBarTitle
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - NavigationController Additions
    
    public func closeButtonPressed(sender: UIBarButtonItem!) {
        guard let navController = self.navigationController as? NavigationController else {
            return
        }
        navController.close(sender)
    }
    
    public var navBarTitle: String {
        return "PubNub"
    }
    
    // must be in a nav controller
    public var showsToolbar: Bool {
        return false
    }
}
