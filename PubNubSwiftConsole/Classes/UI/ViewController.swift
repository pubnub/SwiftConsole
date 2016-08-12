//
//  ViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub

@objc(PNCViewController)
public class ViewController: UIViewController, PNObjectEventListener {
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        // don't call super for UIViewController direct subclass
        let frame = UIScreen.main.bounds
        self.view = UIView(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var client: PubNub? {
        didSet {
            oldValue?.remove(self)
            client?.add(self)
        }
    }
    
    deinit {
        client?.remove(self) // not really necessary, just to be safe
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        self.navigationItem.title = navBarTitle
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - NavigationController Additions
    
    public func closeButtonPressed(_ sender: UIBarButtonItem!) {
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
