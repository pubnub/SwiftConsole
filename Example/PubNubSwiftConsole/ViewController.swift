//
//  ViewController.swift
//  PubNubSwiftConsole
//
//  Created by Jordan Zucker on 07/13/2016.
//  Copyright (c) 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import PubNubSwiftConsole

class ViewController: UIViewController {
    
    @IBOutlet weak var pubNubDebugViewButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pubNubDebugViewButton.setTitle("PubNub Debug", forState: .Normal)
        pubNubDebugViewButton.addTarget(self, action: #selector(self.pubNubDebugViewButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pubNubDebugViewButtonPressed(sender: UIButton!) {
        let pubNubViewController = PubNubSwiftConsole.ClientCreationViewController()
        self.presentViewController(pubNubViewController, animated: true, completion: nil)
    }

}

