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
    
    var client: PubNub? {
        didSet {
            oldValue?.removeListener(self)
            client?.addListener(self)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
    }
    
    // MARK: - UINavigationItem
    
    func closeButtonPressed(sender: UIBarButtonItem!) {
        var navController = self.navigationController as? NavigationController
        navController?.close(sender)
    }
    
    public var navBarTitle: String {
        return "PubNub"
    }
    
    public override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem(title: self.navBarTitle)
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
        return navigationItem
    }
}
