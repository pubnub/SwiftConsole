//
//  ControlExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
//
//

import Foundation

typealias TargetSelector = (target: AnyObject?, selector: Selector)

extension UIControl {
    func removeAllTargets() {
        self.allTargets.forEach { (target) in
            self.removeTarget(target, action: nil, for: .allEvents)
        }
    }
}
