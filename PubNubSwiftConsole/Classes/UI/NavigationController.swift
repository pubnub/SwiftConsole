//
//  NavigationController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/25/16.
//
//

import UIKit

extension UINavigationController {
    public func close(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
