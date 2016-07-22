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
        print("viewDidLoad")
        self.view.backgroundColor = UIColor.redColor()
    }
    
    public func client(client: PubNub, didReceiveStatus status: PNStatus) {
        print("status")
    }
    
    public func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("message")
    }
    
    public func client(client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        print("presence")
    }
}
