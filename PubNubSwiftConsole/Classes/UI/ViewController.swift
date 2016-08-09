//
//  ViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub

public class ViewController: UIViewController, PNObjectEventListener {
    
    public required init() {
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
        self.navigationItem.title = navBarTitle
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - UINavigationItem
    
    func closeButtonPressed(sender: UIBarButtonItem!) {
        guard let navController = self.navigationController as? NavigationController else {
            return
        }
        navController.close(sender)
    }
    
    public var navBarTitle: String {
        return "PubNub"
    }
    
    public var showsToolbar: Bool {
        return false
    }
}
