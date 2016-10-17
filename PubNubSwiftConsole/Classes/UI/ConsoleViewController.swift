//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub
import JSQDataSourcesKit

public class ConsoleViewController: ViewController, UICollectionViewDelegate {
    
    struct ClientUpdater: ClientPropertyUpdater {
        internal func update(dataSource: inout StaticDataSource, at indexPath: IndexPath, with item: StaticItemType, isTappable: Bool) -> IndexPath? {
            dataSource[indexPath] = item
            return indexPath
        }

        func indexPath(for clientProperty: ClientProperty) -> IndexPath? {
            switch clientProperty {
            case .pubKey:
                return IndexPath(item: 0, section: 0)
            case .subKey:
                return IndexPath(item: 1, section: 0)
            case .channels:
                return IndexPath(row: 0, section: 1)
            case .channelGroups:
                return IndexPath(item: 1, section: 1)
            case .subscribe:
                return IndexPath(item: 0, section: 3)
            case .unsubscribe:
                return IndexPath(item: 1, section: 3)
            case .streamFilter:
                return IndexPath(item: 0, section: 2)
            case .authKey, .origin, .uuid:
                return nil
            }
        }
    }
    
    let clientUpdater = ClientUpdater()

    var configurationDataSourceProvider: StaticDataSourceProvider!
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    let clientCollectionView: ClientCollectionView
    
    public required init(console: SwiftConsole) {
        self.console = console
        self.consoleCollectionView = ConsoleCollectionView(console: console)
        let bounds = UIScreen.main.bounds
        let layout = StaticItemCollectionViewFlowLayout()
        //layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        self.clientCollectionView = ClientCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init()
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(consoleCollectionView)
        consoleCollectionView.forceAutoLayout()
        consoleCollectionView.backgroundColor = .red
        
        view.addSubview(clientCollectionView)
        clientCollectionView.forceAutoLayout()
        clientCollectionView.backgroundColor = .cyan
        
        let configurationYOffset = (UIApplication.shared.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 5.0
        clientCollectionView.contentInset = UIEdgeInsets(top: configurationYOffset, left: 0.0, bottom: 0.0, right: 0.0)
        //configurationCollectionView.contentOffset = CGPoint(x: 0, y: configurationYOffset)
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
            "clientCollectionView": clientCollectionView,
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[clientCollectionView(300)][consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let configurationHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[clientCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(configurationHorizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        consoleCollectionView.delegate = self
        consoleCollectionView.reloadData()
        
        let pubKeyItemType = ClientProperty.pubKey.generateStaticItemType(client: console.client)
        let subKeyItemType = ClientProperty.subKey.generateStaticItemType(client: console.client)
        let channelsItemType = ClientProperty.channels.generateStaticItemType(client: console.client)
        let channelGroupsItemType = ClientProperty.channelGroups.generateStaticItemType(client: console.client)
        let subscribeItemType = ClientProperty.subscribe.generateStaticItemType(client: console.client, isTappable: true)
        let unsubscribeItemType = ClientProperty.unsubscribe.generateStaticItemType(client: console.client, isTappable: true)
        let streamFilterType = ClientProperty.streamFilter.generateStaticItemType(client: console.client, isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: channelsItemType, channelGroupsItemType)
        let section2 = Section(items: streamFilterType)
        let section3 = Section(items: subscribeItemType, unsubscribeItemType)
        
        let dataSource = DataSource(sections: section0, section1, section2, section3)
        
        configurationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        
        clientCollectionView.delegate = self
        
        clientCollectionView.dataSource = configurationDataSourceProvider.collectionViewDataSource
        
        
        console.client.addListener(self)
        clientCollectionView.reloadData()
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.consoleCollectionView.predicate = ConsoleSegment.messages.consolePredicate
        }
 */
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        clientCollectionView.performBatchUpdates({
            let client = self.console.client
            var updatedIndexPaths = [IndexPath]()
            if let updatedChannelsItemIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channels, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelsItemIndexPath)
            }
            if let updatedChannelGroupsItemIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channelGroups, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelGroupsItemIndexPath)
            }
            self.clientCollectionView.reloadItems(at: updatedIndexPaths)
            })
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case collectionView as ConsoleCollectionView:
            return
            
        case collectionView as ClientCollectionView:
            print("console collection view tapped")
            let selectedItem = clientUpdater.staticItem(from: configurationDataSourceProvider.dataSource, at: indexPath)
            guard selectedItem.isTappable == true else {
                return
            }
            guard let clientProperty = ClientProperty(staticItem: selectedItem) else {
                return
            }
            switch clientProperty {
            case .subscribe:
                let alertController = UIAlertController.subscribeAlertController(with: { (action, input) -> (Void) in
                    do {
                        guard let subscribablesArray = try PubNub.stringToSubscribablesArray(input) else {
                            return
                        }
                        switch action {
                        case .channels:
                            self.console.client.subscribeToChannels(subscribablesArray, withPresence: true)
                        case .channelGroups:
                            self.console.client.subscribeToChannelGroups(subscribablesArray, withPresence: true)
                        }
                    } catch let userError as AlertControllerError {
                        // TODO: Implement error handling
                        let errorAlertController = UIAlertController.alertController(error: userError)
                        self.present(errorAlertController, animated: true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                })
                present(alertController, animated: true)
            case .unsubscribe:
                let alertController = UIAlertController.unsubscribeAlertController(with: { (action, input) -> (Void) in
                    
                    guard action != .all else {
                        self.console.client.unsubscribeFromAll()
                        return
                    }
                    do {
                        guard let subscribablesArray = try PubNub.stringToSubscribablesArray(input) else {
                            return
                        }
                        switch action {
                        case .channels:
                            self.console.client.unsubscribeFromChannels(subscribablesArray, withPresence: true)
                        case .channelGroups:
                            self.console.client.unsubscribeFromChannelGroups(subscribablesArray, withPresence: true)
                        default:
                            fatalError("Not expecting this kind of action")
                        }
                    } catch let userError as AlertControllerError {
                        // TODO: Implement error handling
                        let errorAlertController = UIAlertController.alertController(error: userError)
                        self.present(errorAlertController, animated: true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                })
                present(alertController, animated: true)
            case .streamFilter:
                let alertController = UIAlertController.streamFilterAlertController(withCurrent: console.client.filterExpression, handler: { (action, input) -> (Void) in
                    defer {
                        print("ran defer \(#function)")
                        self.clientCollectionView.performBatchUpdates({ 
                            guard let updatedIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .streamFilter, with: self.console.client, isTappable: true) else {
                                return
                            }
                            self.clientCollectionView.reloadItems(at: [updatedIndexPath])
                            })
                    }
                    guard let actualInput = input else {
                        self.console.client.filterExpression = nil
                        return
                    }
                    self.console.client.filterExpression = actualInput
                })
                present(alertController, animated: true)
            default:
                return
            }
        default:
            print("other collection view tapped")
        }
    }
    /*
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        cell.contentView.backgroundColor = .blue
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        cell.contentView.backgroundColor = nil
    }
 */

    
    // MARK: - PNObjectEventListener
    
    @objc(client:didReceiveStatus:)
    public func client(_ client: PubNub, didReceive status: PNStatus) {
        guard (status.operation == .subscribeOperation) || (status.operation == .unsubscribeOperation) else {
            return
        }
        updateSubscribablesCells(client: client)
    }
    
}

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
        let cancelAction = UIAlertAction.cancelAlertAction()
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
        let cancelAction = UIAlertAction.cancelAlertAction()
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
        let cancelAction = UIAlertAction.cancelAlertAction()
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
        let cancelAction = UIAlertAction.cancelAlertAction()
        alertController.addAction(publishAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
}
