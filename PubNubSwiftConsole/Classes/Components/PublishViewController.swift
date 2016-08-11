//
//  PublishViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import Foundation
import PubNub

@objc public protocol PublishViewControllerDelegate {
    optional func publishView(publishView: PublishViewController, receivedPublishStatus status: PNPublishStatus)
}

public class PublishViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - Properties
    var publishDelegate: PublishViewControllerDelegate?
    
    // MARK: - DataSource
    
    enum PublishSectionType: Int, ItemSectionType {
        case ClientConfiguration = 0, PublishConfiguration, PayloadInput, PublishStatusConsole
    }
    
    enum PublishItemType: ItemType {
        case PublishKey
        case SubscribeKey
        case ChannelLabel
        case PayloadInput
        case PublishButton
        case PublishStatus
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .PublishKey, .SubscribeKey:
                return TitleContentsCollectionViewCell.self
            case .ChannelLabel:
                return TitleContentsCollectionViewCell.self
            case .PayloadInput:
                return TextViewCollectionViewCell.self
            case .PublishButton:
                return ButtonCollectionViewCell.self
            case .PublishStatus:
                return PublishStatusCollectionViewCell.self
            }
        }
        
        var selectedTitle: String? {
            return nil
        }
        
        var title: String {
            switch self {
            case .PublishKey:
                return "Publish Key"
            case .SubscribeKey:
                return "Subscribe Key"
            case .ChannelLabel:
                return "Channel"
            case .PublishButton:
                return "Publish"
            case .PayloadInput:
                return "Payload"
            case .PublishStatus:
                return "Publish Statuses"
            }
        }
        
        func contents(client: PubNub) -> String {
            switch self {
            case .PublishKey:
                return client.currentConfiguration().publishKey
            case .SubscribeKey:
                return client.currentConfiguration().subscribeKey
            default:
                return ""
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .PublishKey, .SubscribeKey:
                return PublishSectionType.ClientConfiguration
            case .ChannelLabel:
                return PublishSectionType.PublishConfiguration
            case .PayloadInput:
                return PublishSectionType.PayloadInput
            case .PublishButton:
                return PublishSectionType.PublishConfiguration
            case .PublishStatus:
                return PublishSectionType.PublishStatusConsole
            }
        }
        
        var defaultValue: String {
            switch self {
            case .ChannelLabel:
                return ""
            case .PayloadInput:
                return "Hello, world!"
            default:
                return ""
            }
        }
        
        var item: Int {
            switch self {
            case .PublishKey:
                return 0
            case .SubscribeKey:
                return 1
            case .ChannelLabel:
                return 0
            case .PayloadInput:
                return 0
            case .PublishButton:
                return 1
            case .PublishStatus:
                return 0
            }
        }
    }
    
    struct PublishButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: PublishItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: PublishItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        var selected: Bool = false
        var targetSelector: TargetSelector
    }
    
    struct PublishUpdatableLabelItem: UpdatableTitleContentsItem {
        init(itemType: PublishItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: PublishItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
    }
    
    struct PublishLabelItem: TitleContentsItem {
        let itemType: ItemType
        var contents: String
        init(itemType: PublishItemType, contents: String) {
            self.itemType = itemType
            self.contents = contents
        }
        init(itemType: PublishItemType, client: PubNub) {
            self.init(itemType: itemType, contents: itemType.contents(client))
        }
    }
    
    struct PublishTextViewItem: TextViewItem {
        init(itemType: PublishItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: PublishItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
    }
    
    final class PublishDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(client: PubNub, publishButton: TargetSelector) {
            let subscribeLabelItem = PublishLabelItem(itemType: .SubscribeKey, client: client)
            let publishLabelItem = PublishLabelItem(itemType: .PublishKey, client: client)
            let publishButtonItem = PublishButtonItem(itemType: .PublishButton, targetSelector: publishButton)
            let channelLabelItem = PublishUpdatableLabelItem(itemType: .ChannelLabel)
            let textViewItem = PublishTextViewItem(itemType: .PayloadInput)
            let publishConfigSection = BasicSection(items: [channelLabelItem, publishButtonItem])
            let payloadSection = BasicSection(items: [textViewItem])
            let publishStatusSection = ScrollingSection()
            let clientConfigSection = BasicSection(items: [publishLabelItem, subscribeLabelItem])
            self.init(sections: [clientConfigSection, publishConfigSection, payloadSection, publishStatusSection])
        }
        var message: String {
            guard let payloadItem = self[PublishItemType.PayloadInput.indexPath] as? PublishTextViewItem else {
                fatalError()
            }
            return payloadItem.contents
        }
        var channel: String {
            guard let channelItem = self[PublishItemType.ChannelLabel.indexPath] as? PublishUpdatableLabelItem else {
                fatalError()
            }
            return channelItem.contents
        }
        func push(publishStatus: PNPublishStatus) -> NSIndexPath {
            let publishItem = PublishStatus(itemType: PublishItemType.PublishStatus, publishStatus: publishStatus)
            return push(PublishItemType.PublishStatus.section, item: publishItem)
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
    
    deinit {
        self.client?.removeListener(self)
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentClient = self.client else {
            fatalError()
        }
        self.delegate = self
        let publishButton: TargetSelector = (self, #selector(self.publishButtonTapped(_:)))
        dataSource = PublishDataSource(client: currentClient, publishButton: publishButton)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    public func publishButtonTapped(sender: UIButton!) {
        publish()
    }
    
    func publish() {
        guard let currentDataSource = dataSource as? PublishDataSource else {
            return
        }
        view.endEditing(true) // make sure the message value is updated before sending the publish (this may be a race?)
        let message = currentDataSource.message // eventually throw errors for feedback
        let channel = currentDataSource.channel
        // we may exit the view controller before the completion handler occurs, so let's keep that in mind
        // in this case, we need it to stick around, so that we can log the response (if we were using Realm we could let the underlying view controller handle the completion and then this view controller could be weak instead of unowned)
        do {
            try self.client?.safePublish(message, toChannel: channel, withCompletion: { [unowned self](publishStatus) in
                guard let completionDataSource = self.dataSource as? PublishDataSource else {
                    return
                }
                self.collectionView?.performBatchUpdates({
                    let insertedPublishCell = completionDataSource.push(publishStatus)
                    self.collectionView?.insertItemsAtIndexPaths([insertedPublishCell])
                    }, completion: nil)
                // now try to send this publish status to the console view controller
                self.publishDelegate?.publishView?(self, receivedPublishStatus: publishStatus)
                //if let publishDelegate = self.delegate as? PublishViewControllerDelegate {
                //    publishDelegate.publishView?(self, receivedPublishStatus: publishStatus)
                //}
            })
        } catch let channelParsingError as PubNubSubscribableStringParsingError {
            let alertController = UIAlertController.alertControllerForPubNubStringParsingIntoSubscribablesArrayError("channel", error: channelParsingError, handler: nil)
            presentViewController(alertController, animated: true, completion: nil)
        } catch let publishError as PubNubPublishError {
            let alertController = UIAlertController.alertControllerForPubNubPublishingError(publishError, handler: nil)
            presentViewController(alertController, animated: true, completion: nil)
        } catch {
            fatalError()
        }
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextViewAtIndexPath indexPath: NSIndexPath, textView: UITextView, updatedTextFieldString updatedString: String?) {
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Publish"
    }
}
