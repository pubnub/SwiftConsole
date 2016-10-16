//
//  ViewController.swift
//  SwiftConsole
//
//  Created by Jordan Zucker on 10/05/2016.
//  Copyright (c) 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import PubNubSwiftConsole
import PubNub

class ViewController: UIViewController, ClientCreationViewControllerDelegate {
    
    @IBOutlet weak var consoleButton: UIButton?
    @IBOutlet weak var clientCreationButton: UIButton?
    
    var createdSwiftConsole: SwiftConsole?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        consoleButton?.addTarget(self, action: #selector(consoleButtonTapped(sender:)), for: .touchUpInside)
        clientCreationButton?.addTarget(self, action: #selector(clientCreationButtonTapped(sender:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func consoleButtonTapped(sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let console = appDelegate.console
        let consoleViewController = console.consoleViewController()
        consoleViewController.modalPresentationStyle = .overFullScreen
        consoleViewController.modalTransitionStyle = .coverVertical
        present(consoleViewController, animated: true)
    }
    
    func clientCreationButtonTapped(sender: UIButton) {
        let clientCreationViewController = SwiftConsole.clientCreationViewController()
        clientCreationViewController.modalPresentationStyle = .overFullScreen
        clientCreationViewController.modalTransitionStyle = .coverVertical
        let clientVC = clientCreationViewController.topViewController as! ClientCreationViewController
        clientVC.delegate = self
        present(clientCreationViewController, animated: true)
    }
    
    // MARK: - ClientCreationViewControllerDelegate
    
    func clientCreation(_ clientCreationViewController: ClientCreationViewController, createdClient: PubNub) {
        let swiftConsole = SwiftConsole(client: createdClient)
        createdSwiftConsole = swiftConsole
        let consoleViewController = ConsoleViewController(console: swiftConsole)
        clientCreationViewController.navigationController?.pushViewController(consoleViewController, animated: true)
    }
    
    func clientCreation(_ clientCreationViewController: ClientCreationViewController, failedWithError: Error) {
        
    }

}

