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
public class ViewController: UIViewController {
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func loadView() {
        // don't call super for UIViewController direct subclass
        let frame = UIScreen.main.bounds
        self.view = UIView(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var client: PubNub? {
        didSet {
            oldValue?.removeListener(self)
            client?.addListener(self)
        }
    }
    
    deinit {
        client?.removeListener(self) // not really necessary, just to be safe
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        self.navigationItem.title = navBarTitle
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - NavigationController Additions
    
    open func closeButtonPressed(_ sender: UIBarButtonItem!) {
        guard let navController = self.navigationController as? NavigationController else {
            return
        }
        navController.close(sender)
    }
    
    open var navBarTitle: String {
        return "PubNub"
    }
    
    // must be in a nav controller
    open var showsToolbar: Bool {
        return false
    }
}

extension ViewController: PNObjectEventListener {}
