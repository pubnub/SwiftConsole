//
//  ViewController.swift
//  PubNubSwiftConsole
//
//  Created by Jordan Zucker on 07/13/2016.
//  Copyright (c) 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import PubNub
import PubNubSwiftConsole

class ViewController: UIViewController {
    
    @IBOutlet weak var clientCreationButton: UIButton!
    @IBOutlet weak var consoleButton: UIButton!
    var client: PubNub?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clientCreationButton.setTitle("PubNub Client Creation", for: UIControlState())
        clientCreationButton.addTarget(self, action: #selector(self.clientCreationButtonPressed(_:)), for: .touchUpInside)
        consoleButton.setTitle("PubNub Console", for: UIControlState())
        consoleButton.addTarget(self, action: #selector(self.consoleButtonPressed(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clientCreationButtonPressed(_ sender: UIButton!) {
        let clientCreationViewController = PubNubSwiftConsole.modalClientCreationViewController()
        self.present(clientCreationViewController, animated: true, completion: nil)
    }
    
    func consoleButtonPressed(_ sender: UIButton!) {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        client = PubNub.client(with: config)
        guard let currentClient = client else {
            return
        }
        let consoleViewController = PubNubSwiftConsole.modalConsoleViewController(currentClient)
        self.present(consoleViewController, animated: true, completion: nil)
    }

}

