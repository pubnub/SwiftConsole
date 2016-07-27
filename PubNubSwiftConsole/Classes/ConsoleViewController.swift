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
    
    enum ConsoleItemType: String {
        case Channels = "Channels"
        case ChannelGroups = "Channel Groups"
        var dataSourceIndex: Int {
            switch self {
            case .Channels:
                return 0
            case .ChannelGroups:
                return 1
            }
        }
        var indexPath: NSIndexPath {
            return NSIndexPath(forItem: dataSourceIndex, inSection: 0) // this is hardcoded for now
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
        let consoleType: ConsoleItemType
        init(consoleType: ConsoleItemType, contentsString: String) {
            self.consoleType = consoleType
            self.contentsString = contentsString
        }
        
        init(consoleType: ConsoleItemType, client: PubNub) {
            self.init(consoleType: consoleType, contentsString: consoleType.subscribablesString(client))
        }
        
        var titleString: String {
            return consoleType.rawValue
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
        var title: String {
            return "Subscribe"
        }
        
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
        let labelSection = BasicSection(items: [ConsoleLabelItem(consoleType: .Channels, client: currentClient), ConsoleLabelItem(consoleType: .ChannelGroups, client: currentClient)])
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
    
    public func updateSubscribables() {
        guard let currentClient = self.client else {
            return
        }
        dataSource[ConsoleItemType.Channels.indexPath] = ConsoleLabelItem(consoleType: .Channels, client: currentClient)
        dataSource[ConsoleItemType.ChannelGroups.indexPath] = ConsoleLabelItem(consoleType: .ChannelGroups, client: currentClient)
        self.collectionView?.reloadItemsAtIndexPaths([ConsoleItemType.Channels.indexPath, ConsoleItemType.ChannelGroups.indexPath])
    }
    
    // MARK: - PNObjectEventListener
    
    public func client(client: PubNub, didReceiveStatus status: PNStatus) {
        if (
            (status.operation == .SubscribeOperation) ||
            (status.operation == .UnsubscribeOperation)
            ){
            updateSubscribables() // this ensures we receive updates to available channels and channel groups even if the changes happen outside the scope of this view controller
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
