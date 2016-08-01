//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit

public class NavigationController: UINavigationController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalTransitionStyle = .CoverVertical
        self.modalPresentationStyle = .OverFullScreen
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    public func close(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
