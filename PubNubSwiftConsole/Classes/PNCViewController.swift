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
//    required public init?(coder aDecoder: NSCoder) {
//        self.collectionView = PNCCollectionView()
//        super.init(coder: aDecoder)
//    }
//    
//    convenience init() {
//        self.init()
//        
//        // ... store or user your objectId
//    }
    
    var client: PubNub? {
        didSet {
            oldValue?.removeListener(self)
            client?.addListener(self)
        }
    }
    
    var collectionView: PNCCollectionView?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.view.backgroundColor = UIColor.redColor()
        self.collectionView = PNCCollectionView()
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
