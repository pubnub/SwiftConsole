//
//  PNCViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation
import PubNub

public class PNCViewController: UIViewController, PNObjectEventListener {
    
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
