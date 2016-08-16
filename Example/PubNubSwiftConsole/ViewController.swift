//
//  ViewController.swift
//  PubNubSwiftConsole
//
//  Created by Jordan Zucker on 07/13/2016.
//  Copyright (c) 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import PubNubPersistence
import PubNub
import PubNubSwiftConsole

class ViewController: UIViewController {
    
    @IBOutlet weak var clientCreationButton: UIButton!
    @IBOutlet weak var consoleButton: UIButton!
    var client: PubNub?
    var persistence: PubNubPersistence?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clientCreationButton.setTitle("PubNub Client Creation", forState: .Normal)
        clientCreationButton.addTarget(self, action: #selector(self.clientCreationButtonPressed(_:)), forControlEvents: .TouchUpInside)
        consoleButton.setTitle("PubNub Console", forState: .Normal)
        consoleButton.addTarget(self, action: #selector(self.consoleButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clientCreationButtonPressed(sender: UIButton!) {
        let clientCreationViewController = PubNubSwiftConsole.modalClientCreationViewController()
        self.presentViewController(clientCreationViewController, animated: true, completion: nil)
    }
    
    func consoleButtonPressed(sender: UIButton!) {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        client = PubNub.clientWithConfiguration(config)
        
        let persistenceConfig = PNPPersistenceConfiguration(client: client!)
        persistence = PubNubPersistence(configuration: persistenceConfig)
        
        guard let currentClient = client else {
            return
        }
        let consoleViewController = PubNubSwiftConsole.modalConsoleViewController(currentClient, persistence: persistence)
        self.presentViewController(consoleViewController, animated: true, completion: nil)
    }

}

