//
//  PushViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import Foundation
import PubNub

@objc(PNCPushOperation)
public enum PushOperation: Int {
    case addPushNotificationsForChannels
    case removePushNotifitcationsFromChannels
    case removeAllPushNotifications
    case pushChannelsForDeviceToken
}

@objc(PNCPushViewControllerDelegate)
public protocol PushViewControllerDelegate {
    @objc optional func pushView(pushView: PushViewController, action: PushOperation, receivedResult: PNResult)
}

//// Intended to launch from the toolbar
@objc(PNCPushViewController)
public class PushViewController: CollectionViewController, CollectionViewControllerDelegate {
    
    // MARK: - Properties
    var pushDelegate: PushViewControllerDelegate?

    // MARK: - DataSource

    enum PushSectionType: Int, ItemSectionType {
        case clientConfiguration = 0, pushConfiguration, pushActions, pushConsole
    }
    
    enum PushItemType: ItemType {
        case publishKey
        case subscribeKey
        case uuid
        case channelsLabel
        case devicePushTokenLabel
        case addPushNotificationsButton
        case removePushNotificationsButton
        case removeAllPushNotificationsButton
        case pushChannelsForDeviceToken
        case pushResult

        var cellClass: CollectionViewCell.Type {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return TitleContentsCollectionViewCell.self
            case .channelsLabel, .devicePushTokenLabel:
                return TitleContentsCollectionViewCell.self
            case .addPushNotificationsButton, .removeAllPushNotificationsButton, .removePushNotificationsButton, .pushChannelsForDeviceToken:
                return ButtonCollectionViewCell.self
            case .pushResult:
                return ResultCollectionViewCell.self
            }
        }
        
        var selectedTitle: String? {
            return nil
        }
        
        var title: String {
            switch self {
            case .publishKey:
                return "Publish Key"
            case .subscribeKey:
                return "Subscribe Key"
            case .uuid:
                return "UUID"
            case .channelsLabel:
                return "Channels"
            case .devicePushTokenLabel:
                return "Device Push Token"
            case .addPushNotificationsButton:
                return "Add Push Notifications"
            case .removePushNotificationsButton:
                return "Remove Push Notifications"
            case .removeAllPushNotificationsButton:
                return "Remove All Push Notifications"
            case .pushChannelsForDeviceToken:
                return "Push Notification Channels for Device Token"
            case .pushResult:
                return "Push Result"
            }
        }
        
        func contents(client: PubNub) -> String {
            switch self {
            case .publishKey:
                return client.currentConfiguration().publishKey
            case .subscribeKey:
                return client.currentConfiguration().subscribeKey
            case .uuid:
                return client.currentConfiguration().uuid
            default:
                return ""
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return PushSectionType.clientConfiguration
            case .channelsLabel:
                return PushSectionType.pushConfiguration
            case .channelsLabel, .devicePushTokenLabel:
                return PushSectionType.pushConfiguration
            case .addPushNotificationsButton, .removePushNotificationsButton, .removeAllPushNotificationsButton, .pushChannelsForDeviceToken:
                return PushSectionType.pushActions
            case .pushResult:
                return PushSectionType.pushConsole
            }
        }
        
        var defaultValue: String {
            switch self {
            case .channelsLabel:
                return ""
            case .devicePushTokenLabel:
                return ""
            default:
                return ""
            }
        }
        
        var item: Int {
            switch self {
            case .publishKey:
                return 0
            case .subscribeKey:
                return 1
            case .uuid:
                return 2
            case .channelsLabel:
                return 0
            case .devicePushTokenLabel:
                return 1
            case .addPushNotificationsButton:
                return 0
            case .pushChannelsForDeviceToken:
                return 1
            case .removePushNotificationsButton:
                return 2
            case .removeAllPushNotificationsButton:
                return 3
            case .pushResult:
                return 0
            }
        }
    }
    
    struct PushButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: PushItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: PushItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        var selected: Bool = false
        var targetSelector: TargetSelector
    }
    
    struct PushUpdatableLabelItem: UpdatableTitleContentsItem {
        init(itemType: PushItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: PushItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
    }
    
    struct PushLabelItem: TitleContentsItem {
        let itemType: ItemType
        var contents: String
        init(itemType: PushItemType, contents: String) {
            self.itemType = itemType
            self.contents = contents
        }
        init(itemType: PushItemType, client: PubNub) {
            self.init(itemType: itemType, contents: itemType.contents(client: client))
        }
    }
    
    struct PushTextViewItem: TextViewItem {
        init(itemType: PushItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: PushItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
    }
    
    final class PushDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(client: PubNub, addChannelsButton: TargetSelector, channelsForDeviceTokenButton: TargetSelector, removeChannelsButton: TargetSelector, removeAllButton: TargetSelector) {
            let subscribeLabelItem = PushLabelItem(itemType: .subscribeKey, client: client)
            let publishLabelItem = PushLabelItem(itemType: .publishKey, client: client)
            let uuidLabelItem = PushLabelItem(itemType: .uuid, client: client)
            let channelsLabelItem = PushUpdatableLabelItem(itemType: .channelsLabel)
            let pushTokenLabelItem = PushUpdatableLabelItem(itemType: .devicePushTokenLabel)
            let addPushChannelsButtonItem = PushButtonItem(itemType: .addPushNotificationsButton, targetSelector: addChannelsButton)
            let channelsForDeviceTokenButtonItem = PushButtonItem(itemType: .pushChannelsForDeviceToken, targetSelector: channelsForDeviceTokenButton)
            let removeChannelsButtonItem = PushButtonItem(itemType: .removePushNotificationsButton, targetSelector: removeChannelsButton)
            let removeAllButtonItem = PushButtonItem(itemType: .removeAllPushNotificationsButton, targetSelector: removeAllButton)
            let clientConfigSection = BasicSection(items: [publishLabelItem, subscribeLabelItem, uuidLabelItem])
            let pushConfigurationSection = BasicSection(items: [channelsLabelItem, pushTokenLabelItem])
            let pushActionsSection = BasicSection(items: [addPushChannelsButtonItem, channelsForDeviceTokenButtonItem, removeChannelsButtonItem, removeAllButtonItem])
            let pushConsoleSection = ScrollingSection()
            self.init(sections: [clientConfigSection, pushConfigurationSection, pushActionsSection, pushConsoleSection])
            
        }
        
        // add helper method for extracting channels and device token from fields
        var deviceToken: Data {
            guard let deviceTokenItem = self[PushItemType.devicePushTokenLabel.indexPath] as? PushUpdatableLabelItem else {
                fatalError()
            }
            // fixme: better to use internal pubnub logic?
            return Data(base64Encoded: deviceTokenItem.contents)!
        }
        
        // TODO: maybe make this `private`
        var channels: String {
            guard let channelsItem = self[PushItemType.channelsLabel.indexPath] as? PushUpdatableLabelItem else {
                fatalError()
            }
            return channelsItem.contents
        }
        
//        func pushChannels() throws -> [String] {
//            do {
//                let channels = try PubNub.stringToSubscribablesArray(channels: self.channels)
//                
//            } catch let pubNubError as PubNubSubscribableStringParsingError {
//                let alertController = UIAlertController.alertController(error: pubNubError)
//                // TODO: investigate the scope of this return (will it prevent the code after the error block from running)
//                return
//            } catch {
//                fatalError()
//            }
//        }
        
        
        func push(result: PNResult) -> IndexPath {
            let pushResultItem = result.createItem(itemType: PushItemType.pushResult)
            return push(section: PushItemType.pushResult.section, item: pushResultItem)
        }
    }
    
    // MARK: - Constructors
    public required init(client: PubNub) {
        super.init()
        self.client = client
    }
    
    public required init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.client?.remove(self)
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentClient = self.client else {
            fatalError()
        }
        self.delegate = self
        let addChannelsButton: TargetSelector = (self, #selector(self.addChannelsButtonPressed(sender:)))
        let removeChannelsButton: TargetSelector = (self, #selector(self.removeChannelsButtonPressed(sender:)))
        let channelsForDeviceTokenButton: TargetSelector = (self, #selector(self.channelsForDeviceTokenPressed(sender:)))
        let removeAllButton: TargetSelector = (self, #selector(self.removeAllButtonPressed(sender:)))
        dataSource = PushDataSource(client: currentClient, addChannelsButton: addChannelsButton, channelsForDeviceTokenButton: channelsForDeviceTokenButton, removeChannelsButton: removeChannelsButton, removeAllButton: removeAllButton)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Helpers
    
    // MARK: - Actions
    
    public func addChannelsButtonPressed(sender: UIButton) {
        guard let currentDataSource = dataSource as? PushDataSource else {
            fatalError()
        }
        var channelsString: [String]
        do {
            channelsString = try PubNub.stringToSubscribablesArray(channels: currentDataSource.channels)
        } catch let userFacingError as UserFacingError {
            let alertController = UIAlertController.alertController(error: userFacingError)
            present(alertController, animated: true)
            // TODO: investigate the scope of this return (will it prevent the code after the error block from running)
            return
        } catch {
            fatalError()
        }
        
        let deviceToken = currentDataSource.deviceToken
        
        self.client?.addPushNotifications(onChannels: channelsString, withDevicePushToken: deviceToken, andCompletion: { (status) in
            self.collectionView?.performBatchUpdates({
                let indexPath = currentDataSource.push(result: status)
                self.collectionView?.insertItems(at: [indexPath])
                })
            self.pushDelegate?.pushView?(pushView: self, action: .addPushNotificationsForChannels, receivedResult: status)
        })
    }
    
    public func removeChannelsButtonPressed(sender: UIButton) {
        guard let currentDataSource = dataSource as? PushDataSource else {
            fatalError()
        }
        var channelsString: [String]
        do {
            channelsString = try PubNub.stringToSubscribablesArray(channels: currentDataSource.channels)
        } catch let userFacingError as UserFacingError {
            let alertController = UIAlertController.alertController(error: userFacingError)
            present(alertController, animated: true)
            // TODO: investigate the scope of this return (will it prevent the code after the error block from running)
            return
        } catch {
            fatalError()
        }
        
        let deviceToken = currentDataSource.deviceToken
        
        self.client?.removePushNotifications(fromChannels: channelsString, withDevicePushToken: deviceToken, andCompletion: { (status) in
            self.collectionView?.performBatchUpdates({
                let indexPath = currentDataSource.push(result: status)
                self.collectionView?.insertItems(at: [indexPath])
            })
            self.pushDelegate?.pushView?(pushView: self, action: .removePushNotifitcationsFromChannels, receivedResult: status)
        })
    }
    
    public func removeAllButtonPressed(sender: UIButton) {
        guard let currentDataSource = dataSource as? PushDataSource else {
            fatalError()
        }
        let deviceToken = currentDataSource.deviceToken
        self.client?.removeAllPushNotificationsFromDevice(withPushToken: deviceToken, andCompletion: { (status) in
            self.collectionView?.performBatchUpdates({
                let indexPath = currentDataSource.push(result: status)
                self.collectionView?.insertItems(at: [indexPath])
            })
            self.pushDelegate?.pushView?(pushView: self, action: .removeAllPushNotifications, receivedResult: status)
        })
    }
    
    public func channelsForDeviceTokenPressed(sender: UIButton) {
        guard let currentDataSource = dataSource as? PushDataSource else {
            fatalError()
        }
        let deviceToken = currentDataSource.deviceToken
        self.client?.pushNotificationEnabledChannelsForDevice(withPushToken: deviceToken, andCompletion: { (result, errorStatus) in
            var finalResult: PNResult
            switch (result, errorStatus) {
            case let (validResult, nil) where validResult != nil:
                finalResult = validResult!
            case let (nil, validErrorStatus) where validErrorStatus != nil:
                finalResult = validErrorStatus!
            default:
                fatalError()
            }
            
            self.collectionView?.performBatchUpdates({
                let indexPath = currentDataSource.push(result: finalResult)
                self.collectionView?.insertItems(at: [indexPath])
            })
            self.pushDelegate?.pushView?(pushView: self, action: .pushChannelsForDeviceToken, receivedResult: finalResult)
        })
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Push"
    }
}
