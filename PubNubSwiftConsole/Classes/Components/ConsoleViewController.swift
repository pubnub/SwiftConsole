//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit
import PubNub

extension PubNub {
    func channelsString() -> String {
        return self.channels().reduce("", combine: +)
    }
    func channelGroupsString() -> String {
        return self.channelGroups().reduce("", combine: +)
    }
}

public class ConsoleViewController: CollectionViewController, CollectionViewControllerDelegate {
    
    // MARK: - DataSource
    
    struct ConsoleLabelItem: LabelItem {
        let itemType: ItemType
        init(itemType: ConsoleItemType) {
            self.init(itemType: itemType, contents: itemType.defaultValue)
        }
        
        init(itemType: ConsoleItemType, contents: String) {
            self.itemType = itemType
            self.contents = contents
        }
        
        init(itemType: ConsoleItemType, client: PubNub) {
            self.init(itemType: itemType, contents: itemType.contents(client))
        }
        
        var contents: String
        var reuseIdentifier: String {
            return LabelCollectionViewCell.reuseIdentifier
        }
        
    }
    
    struct ConsoleButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: ConsoleItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: ConsoleItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        
        var selected: Bool = false
        var targetSelector: TargetSelector
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
    }
    
    enum ConsoleSectionType: Int, ItemSectionType {
        case Subscribables = 0
        case SubscribeLoopButtons = 1
    }
    
    enum ConsoleItemType: ItemType {
        case Channels
        case ChannelGroups
        case SubscribeButton
        
        func contents(client: PubNub) -> String {
            switch self {
            case .Channels:
                return client.channelsString()
            case .ChannelGroups:
                return client.channelGroupsString()
            default:
                return ""
            }
        }
        
        var title: String {
            switch self {
            case .Channels:
                return "Channels"
            case .ChannelGroups:
                return "Channel Groups"
            case .SubscribeButton:
                return "Subscribe"
            }
        }
        
        var selectedTitle: String? {
            switch self {
            case .SubscribeButton:
                return "Unsubscribe"
            default:
                return nil
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .Channels, .ChannelGroups:
                return ConsoleSectionType.Subscribables
            case .SubscribeButton:
                return ConsoleSectionType.SubscribeLoopButtons
            }
        }
        
        var defaultValue: String {
            switch self {
            default:
                return ""
            }
        }
        
        var item: Int {
            switch self {
            case .Channels:
                return 0
            case .ChannelGroups:
                return 1
            case .SubscribeButton:
                return 0
            }
        }
    }
    
    // MARK: - Constructors
    public required init(client: PubNub) {
        super.init()
        self.client = client
    }
    
    public required init() {
        super.init()
        self.client?.addListener(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // TODO: fix the forced unwrap of the client
        guard let currentClient = self.client else {
            return
        }
        let subscribablesSection = BasicDataSource.BasicSection(items: [ConsoleLabelItem(itemType: .Channels, client: currentClient), ConsoleLabelItem(itemType: .ChannelGroups, client: currentClient)])
        let subscribeButtonItem = ConsoleButtonItem(itemType: .SubscribeButton, targetSelector: (self, #selector(self.subscribeButtonPressed(_:))))
        let subscribeLoopButtonsSection = BasicDataSource.BasicSection(items: [subscribeButtonItem])
        self.dataSource = BasicDataSource(sections: [subscribablesSection, subscribeLoopButtonsSection])
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
        
        // TODO: clean this up later, it's just for debug
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            self.client?.subscribeToChannels(["d"], withPresence: true)
//        }
    }
    
    // MARK: - Actions
    func subscribeButtonPressed(sender: UIButton!) {
        // TODO: clean this up
        if sender.selected {
            client?.unsubscribeFromAll()
            return
        }
        guard let currentDataSource = dataSource, let channelsItem = currentDataSource[ConsoleItemType.Channels.indexPath] as? ConsoleLabelItem else {
            return
        }
        let channels = [channelsItem.contents]
        self.client?.subscribeToChannels(channels, withPresence: true)
        
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?) {
        if let actionTitle = selectedAlertAction.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
            switch (alertDecision) {
            case .OK:
                client?.unsubscribeFromAll() // unsubscribe whenever a subscribable is changed
            default:
                return
            }
        }
    }
    
    // MARK: - Update from Client
    
    public func updateSubscribableLabelCells() {
        guard let currentClient = self.client, let currentDataSource = dataSource else {
            return
        }
        self.dataSource?.updateLabelContentsString(ConsoleItemType.Channels.indexPath, updatedContents: client?.channelsString())
        self.dataSource?.updateLabelContentsString(ConsoleItemType.ChannelGroups.indexPath, updatedContents: client?.channelGroupsString())
        self.collectionView?.reloadItemsAtIndexPaths([ConsoleItemType.Channels.indexPath, ConsoleItemType.ChannelGroups.indexPath])
    }
    
    public func updateSubscribeButtonState() {
        guard let currentClient = self.client else {
            return
        }
        let subscribing = !(currentClient.channels().isEmpty && currentClient.channelGroups().isEmpty)
        let indexPath = ConsoleItemType.SubscribeButton.indexPath
        self.dataSource?.updateSelected(indexPath, selected: subscribing)
        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
        
    }
    
    // MARK: - PNObjectEventListener
    
    public func client(client: PubNub, didReceiveStatus status: PNStatus) {
        print(status.debugDescription)
        if (
            (status.operation == .SubscribeOperation) ||
            (status.operation == .UnsubscribeOperation)
            ){
            updateSubscribableLabelCells() // this ensures we receive updates to available channels and channel groups even if the changes happen outside the scope of this view controller
            updateSubscribeButtonState()
        }
    }
    
    public func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        print(message.debugDescription)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Console"
    }

}
