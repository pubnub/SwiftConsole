//
//  UtilityExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import Foundation
import UIKit
import CoreData

extension UIImage {
    static func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
    }
    func resizedImage(newHeight: CGFloat) -> UIImage {
        return UIImage.resizeImage(image: self, newHeight: newHeight)
    }
}

extension UINavigationItem {
    func setPrompt(with message: String, for duration: Double = 3.0) {
        assert(duration > 0.0)
        assert(duration < 10.0)
        self.prompt = message
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.prompt = nil
        }
    }
    
    func setPrompt(with error: PromptError, for duration: Double = 3.0) {
        setPrompt(with: error.prompt, for: duration)
    }
}

extension UIControl {
    func removeAllTargets() {
        self.allTargets.forEach { (target) in
            self.removeTarget(target, action: nil, for: .allEvents)
        }
    }
}

extension UIView {
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

extension UIView {
    
    var hasConstraints: Bool {
        let hasHorizontalConstraints = !self.constraintsAffectingLayout(for: .horizontal).isEmpty
        let hasVerticalConstraints = !self.constraintsAffectingLayout(for: .vertical).isEmpty
        return hasHorizontalConstraints || hasVerticalConstraints
    }
    
    func forceAutoLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

protocol AlertControllerError: Error {
    /// Title for the UIAlertController
    var alertTitle: String { get }
    var alertMessage: String { get }
}

protocol PromptError: Error {
    var prompt: String { get }
}

extension PromptError {
    /*
    public static var errorDomain: String {
        return "CookingBrowser"
    }
    public var errorCode: Int {
        return 100
    }
    public var errorUserInfo: [String : Any] {
        return ["description": errorDescription!]
    }
    
    public var errorDescription: String? {
        return prompt
    }
 */
}

extension AlertControllerError {
    /*
    public static var errorDomain: String {
        return "CookingBrowser"
    }
    public var errorCode: Int {
        return 100
    }
    public var errorUserInfo: [String : Any] {
        return ["description": errorDescription!]
    }
    
    public var errorDescription: String? {
        return alertMessage
    }
 */
}

extension UIAlertController {
    static func alertController(error: AlertControllerError, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let title = error.alertTitle
        let message = error.alertMessage
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        return alertController
    }
}
