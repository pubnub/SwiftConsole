//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit
import PubNub

public class ConsoleViewController: CollectionViewController, CollectionViewControllerDelegate {
    
    // MARK: - DataSource
    
    enum ConsoleLabelSectionItemType: String {
        case Channels = "Channels"
        case ChannelGroups = "Channel Groups"
        var section: Int {
            return 0
        }
        var row: Int {
            switch self {
            case .Channels:
                return 0
            case .ChannelGroups:
                return 1
            }
        }
        var indexPath: NSIndexPath {
            return NSIndexPath(forItem: row, inSection: section) // this is hardcoded for now
        }
        
        func subscribablesArray(client: PubNub) -> [String] {
            switch self {
            case .Channels:
                return client.channels()
            case .ChannelGroups:
                return client.channelGroups()
            }
        }
        
        func subscribablesString(client: PubNub) -> String {
            return subscribablesArray(client).reduce("", combine: +)
        }
    }
    
    struct ConsoleLabelItem: LabelItem {
        let labelSectionItemType: ConsoleLabelSectionItemType
        init(labelSectionType: ConsoleLabelSectionItemType, contentsString: String) {
            self.labelSectionItemType = labelSectionType
            self.contentsString = contentsString
        }
        
        init(labelSectionType: ConsoleLabelSectionItemType, client: PubNub) {
            self.init(labelSectionType: labelSectionType, contentsString: labelSectionType.subscribablesString(client))
        }
        
        var titleString: String {
            return labelSectionItemType.rawValue
        }
        var contentsString: String
        
        var alertControllerTitle: String? {
            return titleString
        }
        var alertControllerTextFieldValue: String? {
            return contentsString
        }
        
        var reuseIdentifier: String {
            return LabelCollectionViewCell.reuseIdentifier
        }
        
    }
    
    struct ConsoleButtonItem: ButtonItem {
        init(selected: Bool, targetSelector: TargetSelector) {
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(targetSelector: TargetSelector) {
            self.init(selected: false, targetSelector: targetSelector)
        }
        var title: String {
            return "Subscribe"
        }
        
        var selectedTitle: String? {
            return "Unsubscribe"
        }
        
        var selected: Bool = false
        
        var targetSelector: TargetSelector
        var alertControllerTextFieldValue: String? {
            return nil
        }
        var alertControllerTitle: String? {
            return nil
        }
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
        
        static var section: Int {
            return 1
        }
        static var row: Int {
            return 0
        }
        static var indexPath: NSIndexPath {
            return NSIndexPath(forItem: row, inSection: section) // this is hardcoded for now
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
            fatalError()
        }
        let labelSection = BasicSection(items: [ConsoleLabelItem(labelSectionType: .Channels, client: currentClient), ConsoleLabelItem(labelSectionType: .ChannelGroups, client: currentClient)])
        let buttonItem = ConsoleButtonItem(targetSelector: (self, #selector(self.subscribeButtonPressed(_:))))
        let buttonSection = BasicSection(items: [buttonItem])
        self.dataSource = BasicDataSource(sections: [labelSection, buttonSection])
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
//        self.client?.unsubscribeFromAll() // bad idea to stack this?
        // selected means is subscribing
        if sender.selected {
            client?.unsubscribeFromAll()
            return
        }
        // this is hard-coded, need to fix that
        guard let channelsItem = dataSource[0][0] as? ConsoleLabelItem else {
            fatalError()
        }// this is hard-coded, need to fix that
        let channels = [channelsItem.contentsString]
        self.client?.subscribeToChannels(channels, withPresence: true)
        
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?) {
        if let actionTitle = selectedAlertAction.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
            switch (alertDecision) {
            case .OK:
                client?.unsubscribeFromAll() // unsubscribe whenever a subscribable is changed
                guard var selectedLabelItem = self.dataSource[indexPath] as? LabelItem else {
                    fatalError("Please contact support@pubnub.com")
                }
                if let unwrappedUpdatedContentsString = updatedString  {
                    selectedLabelItem.contentsString = unwrappedUpdatedContentsString
                    dataSource[indexPath] = selectedLabelItem
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            default:
                return
            }
        }
    }
    
    // MARK: - Update from Client
    
    public func updateSubscribableLabelCells() {
        guard let currentClient = self.client else {
            return
        }
        dataSource[ConsoleLabelSectionItemType.Channels.indexPath] = ConsoleLabelItem(labelSectionType: .Channels, client: currentClient)
        dataSource[ConsoleLabelSectionItemType.ChannelGroups.indexPath] = ConsoleLabelItem(labelSectionType: .ChannelGroups, client: currentClient)
        self.collectionView?.reloadItemsAtIndexPaths([ConsoleLabelSectionItemType.Channels.indexPath, ConsoleLabelSectionItemType.ChannelGroups.indexPath])
    }
    
    public func updateSubscribeButtonState() {
        guard let currentClient = self.client else {
            return
        }
        let subscribing = !(currentClient.channels().isEmpty && currentClient.channelGroups().isEmpty)
        guard var subscribeButtonItem = dataSource[ConsoleButtonItem.indexPath] as? ConsoleButtonItem else {
            fatalError()
        }
        subscribeButtonItem.selected = subscribing
        dataSource[ConsoleButtonItem.indexPath] = subscribeButtonItem
        self.collectionView?.reloadItemsAtIndexPaths([ConsoleButtonItem.indexPath])
        
        
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
