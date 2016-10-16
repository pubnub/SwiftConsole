//
//  ViewController.swift
//  SwiftConsole
//
//  Created by Jordan Zucker on 10/05/2016.
//  Copyright (c) 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import PubNubSwiftConsole

class ViewController: UIViewController {
    
    @IBOutlet weak var consoleButton: UIButton?
    @IBOutlet weak var clientCreationButton: UIButton?
    
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let console = appDelegate.console
        let clientCreationViewController = console.clientCreationViewController()
        clientCreationViewController.modalPresentationStyle = .overFullScreen
        clientCreationViewController.modalTransitionStyle = .coverVertical
        present(clientCreationViewController, animated: true)
    }

}

