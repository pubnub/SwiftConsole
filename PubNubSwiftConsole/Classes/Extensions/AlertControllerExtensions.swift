//
//  AlertControllerExtensions.swift
//  Pods
//
//  Created by Jordan Zucker on 10/16/16.
//
//

import UIKit

extension UIAlertAction {
    static func cancelAlertAction(style: UIAlertActionStyle = .default) -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: style)
    }
}



extension UIAlertController {
    typealias AlertActionHandler = ((UIAlertAction) -> Swift.Void)
    typealias UnsubscribeActionHandler = (UnsubscribeAction, String?) -> (Swift.Void)
    typealias SubscribeActionHandler = (SubscribeAction, String?) -> (Swift.Void)
    typealias StreamFilterActionHandler = (StreamFilterAction, String?) -> (Swift.Void)
    typealias PublishActionHandler = (PublishAction, String?) -> (Swift.Void)
    
    // TODO: This could all be replaced with generics
    
    enum SubscribeAction: String {
        case channels = "Subscribe as channels"
        case channelGroups = "Subscribe as channel groups"
        case cancel = "Cancel"
        
        static func alertActionHandler(action type: SubscribeAction, withInput textField: UITextField, handler: SubscribeActionHandler? = nil) -> AlertActionHandler {
            return { (action) in
                guard let actualTitle = action.title, let actionType = SubscribeAction(rawValue: actualTitle), type == actionType else {
                    fatalError()
                }
                handler?(actionType, textField.text)
            }
        }
        
        func alertAction(withInput textField: UITextField, handler: SubscribeActionHandler? = nil) -> UIAlertAction {
            let subscribeHandler = SubscribeAction.alertActionHandler(action: self, withInput: textField, handler: handler)
            return UIAlertAction(title: rawValue, style: .default, handler: subscribeHandler)
        }
    }
    
    enum PublishAction: String {
        case publish = "Publish"
        case cancel = "Cancel"
        
        static func alertActionHandler(action type: PublishAction, withInput textField: UITextField, handler: PublishActionHandler? = nil) -> AlertActionHandler {
            return { (action) in
                guard let actualTitle = action.title, let actionType = PublishAction(rawValue: actualTitle), type == actionType else {
                    fatalError()
                }
                handler?(actionType, textField.text)
            }
        }
        
        func alertAction(withInput textField: UITextField, handler: PublishActionHandler? = nil) -> UIAlertAction {
            let publishHandler = PublishAction.alertActionHandler(action: self, withInput: textField, handler: handler)
            return UIAlertAction(title: rawValue, style: .default, handler: publishHandler)
        }
    }
    
    enum UnsubscribeAction: String {
        case channels = "Unsubscribe as channels"
        case channelGroups = "Unsubscribe as channel groups"
        case all = "Unsubscribe from all"
        case cancel = "Cancel"
        
        static func alertActionHandler(action type: UnsubscribeAction, withInput textField: UITextField, handler: UnsubscribeActionHandler? = nil) -> AlertActionHandler {
            return { (action) in
                guard let actualTitle = action.title, let actionType = UnsubscribeAction(rawValue: actualTitle), type == actionType else {
                    fatalError()
                }
                handler?(actionType, textField.text)
            }
        }
        
        func alertAction(withInput textField: UITextField, handler: UnsubscribeActionHandler? = nil) -> UIAlertAction {
            let unsubscribeHandler = UnsubscribeAction.alertActionHandler(action: self, withInput: textField, handler: handler)
            return UIAlertAction(title: rawValue, style: .default, handler: unsubscribeHandler)
        }
    }
    
    enum StreamFilterAction: String {
        case setNew = "Set as new stream filter"
        case remove = "Remove filter"
        case cancel = "Cancel"
        
        static func alertActionHandler(action type: StreamFilterAction, withInput textField: UITextField, handler: StreamFilterActionHandler? = nil) -> AlertActionHandler {
            return { (action) in
                guard let actualTitle = action.title, let actionType = StreamFilterAction(rawValue: actualTitle), type == actionType else {
                    fatalError()
                }
                handler?(actionType, textField.text)
            }
        }
        
        func alertAction(withInput textField: UITextField, handler: StreamFilterActionHandler? = nil) -> UIAlertAction {
            let streamFilterHandler = StreamFilterAction.alertActionHandler(action: self, withInput: textField, handler: handler)
            return UIAlertAction(title: rawValue, style: .default, handler: streamFilterHandler)
        }
    }
    
    static func streamFilterAlertController(withCurrent streamFilter: String? = nil, handler: StreamFilterActionHandler? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Stream filter", message: "Enter a string (setting a blank string removes the current stream filter string", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = (streamFilter ?? "Enter stream filter ...")
        })
        guard let inputTextField = alertController.textFields?[0] else {
            fatalError("Didn't find textField")
        }
        let setStreamFilterAction = StreamFilterAction.setNew.alertAction(withInput: inputTextField, handler: handler)
        let removeStreamFilterAction = StreamFilterAction.remove.alertAction(withInput: inputTextField, handler: handler)
        let cancelAction = StreamFilterAction.cancel.alertAction(withInput: inputTextField, handler: handler)
        alertController.addAction(setStreamFilterAction)
        alertController.addAction(removeStreamFilterAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    static func subscribeAlertController(with handler: SubscribeActionHandler? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Subscribe", message: "Enter a value, comma delimited", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Channel or group name ..."
        })
        guard let inputTextField = alertController.textFields?[0] else {
            fatalError("Didn't find textField")
        }
        let subscribeToChannelsAction = SubscribeAction.channels.alertAction(withInput: inputTextField, handler: handler)
        let subscribeToChannelGroupsAction = SubscribeAction.channelGroups.alertAction(withInput: inputTextField, handler: handler)
        let cancelAction = SubscribeAction.cancel.alertAction(withInput: inputTextField, handler: handler)
        alertController.addAction(subscribeToChannelsAction)
        alertController.addAction(subscribeToChannelGroupsAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    static func unsubscribeAlertController(with handler: UnsubscribeActionHandler? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Unsubscribe", message: "Enter a value, comma delimited (Unsubscribe from all ignores input text)", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Channel or group name ..."
        })
        guard let inputTextField = alertController.textFields?[0] else {
            fatalError("Didn't find textField")
        }
        let unsubscribeFromChannelsAction = UnsubscribeAction.channels.alertAction(withInput: inputTextField, handler: handler)
        let unsubscribeFromChannelGroupsAction = UnsubscribeAction.channelGroups.alertAction(withInput: inputTextField, handler: handler)
        let unsubscribeFromAllAction = UnsubscribeAction.all.alertAction(withInput: inputTextField, handler: handler)
        let cancelAction = UnsubscribeAction.cancel.alertAction(withInput: inputTextField, handler: handler)
        alertController.addAction(unsubscribeFromChannelsAction)
        alertController.addAction(unsubscribeFromChannelGroupsAction)
        alertController.addAction(unsubscribeFromAllAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    static func publishAlertController(withCurrent message: String, handler: PublishActionHandler? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Enter a channel", message: "Publish: \(message)", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter channel name ..."
        })
        guard let inputTextField = alertController.textFields?[0] else {
            fatalError("Didn't find textField")
        }
        let publishAction = PublishAction.publish.alertAction(withInput: inputTextField, handler: handler)
        let cancelAction = PublishAction.cancel.alertAction(withInput: inputTextField, handler: handler)
        alertController.addAction(publishAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
}
