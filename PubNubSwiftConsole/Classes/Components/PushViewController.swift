//
//  PushViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import UIKit
import PubNub

@objc(PNCPushViewControllerDelegate)
public protocol PushViewControllerDelegate {
//    @objc optional func publishView(publishView: PublishViewController, receivedPublishStatus status: PNPublishStatus)
}

// Intended to launch from the toolbar
@objc(PNCPushViewController)
class PushViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - Properties
    var pushDelegate: PushViewControllerDelegate?
    
    // MARK: - DataSource
    
    enum PushSectionType: Int, ItemSectionType {
        case clientConfiguration = 0, publishConfiguration, payloadInput, publishStatusConsole
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
        case pushNotificationsForChannelsButton
        
        case publishStatus
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return TitleContentsCollectionViewCell.self
            case .channelsLabel:
                return TitleContentsCollectionViewCell.self
            case .devicePushTokenLabel:
                return TitleContentsCollectionViewCell.self
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
            case .channelLabel:
                return "Channel"
            case .publishButton:
                return "Publish"
            case .payloadInput:
                return "Payload"
            case .publishStatus:
                return "Publish Statuses"
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
            case .channelLabel:
                return PushSectionType.publishConfiguration
            case .payloadInput:
                return PushSectionType.payloadInput
            case .publishButton:
                return PushSectionType.publishConfiguration
            case .publishStatus:
                return PushSectionType.publishStatusConsole
            }
        }
        
        var defaultValue: String {
            switch self {
            case .channelLabel:
                return ""
            case .payloadInput:
                return "Hello, world!"
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
            case .channelLabel:
                return 0
            case .payloadInput:
                return 0
            case .publishButton:
                return 1
            case .publishStatus:
                return 0
            }
        }
    }
    
    struct PublishButtonItem: ButtonItem {
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
    
    struct PublishUpdatableLabelItem: UpdatableTitleContentsItem {
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
    
    struct PublishLabelItem: TitleContentsItem {
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
    
    struct PublishTextViewItem: TextViewItem {
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
    
    final class PublishDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(client: PubNub, publishButton: TargetSelector) {
            let subscribeLabelItem = PublishLabelItem(itemType: .subscribeKey, client: client)
            let publishLabelItem = PublishLabelItem(itemType: .publishKey, client: client)
            let uuidLabelItem = PublishLabelItem(itemType: .uuid, client: client)
            let publishButtonItem = PublishButtonItem(itemType: .publishButton, targetSelector: publishButton)
            let channelLabelItem = PublishUpdatableLabelItem(itemType: .channelLabel)
            let textViewItem = PublishTextViewItem(itemType: .payloadInput)
            let publishConfigSection = BasicSection(items: [channelLabelItem, publishButtonItem])
            let payloadSection = BasicSection(items: [textViewItem])
            let publishStatusSection = ScrollingSection()
            let clientConfigSection = BasicSection(items: [publishLabelItem, subscribeLabelItem, uuidLabelItem])
            self.init(sections: [clientConfigSection, publishConfigSection, payloadSection, publishStatusSection])
        }
        var message: String {
            guard let payloadItem = self[PublishItemType.payloadInput.indexPath] as? PublishTextViewItem else {
                fatalError()
            }
            return payloadItem.contents
        }
        var channel: String {
            guard let channelItem = self[PublishItemType.channelLabel.indexPath] as? PublishUpdatableLabelItem else {
                fatalError()
            }
            return channelItem.contents
        }
        func push(publishStatus: PNPublishStatus) -> IndexPath {
            let publishStatusItem = publishStatus.createItem(itemType: PublishItemType.publishStatus)
            return push(section: PublishItemType.publishStatus.section, item: publishStatusItem)
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
        let publishButton: TargetSelector = (self, #selector(self.publishButtonTapped(sender:)))
        dataSource = PublishDataSource(client: currentClient, publishButton: publishButton)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.register(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.register(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
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
        // do i really need unowned here? re-examine with swift 3 rules
        do {
            try self.client?.safePublish(message: message, toChannel: channel, withCompletion: { [unowned self] (publishStatus) in
                guard let completionDataSource = self.dataSource as? PublishDataSource else {
                    return
                }
                self.collectionView?.performBatchUpdates({
                    let insertedPublishCell = completionDataSource.push(publishStatus: publishStatus)
                    self.collectionView?.insertItems(at: [insertedPublishCell])
                    }, completion: nil)
                // now try to send this publish status to the console view controller
                self.publishDelegate?.publishView?(publishView: self, receivedPublishStatus: publishStatus)
                //if let publishDelegate = self.delegate as? PublishViewControllerDelegate {
                //    publishDelegate.publishView?(self, receivedPublishStatus: publishStatus)
                //}
                })
        } catch let channelParsingError as PubNubSubscribableStringParsingError {
            let alertController = UIAlertController.alertController(error: channelParsingError)
            present(alertController, animated: true)
        } catch let publishError as PubNubPublishError {
            let alertController = UIAlertController.alertController(error: publishError)
            present(alertController, animated: true)
        } catch {
            fatalError()
        }
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didUpdateItemWithTextViewAtIndexPath indexPath: IndexPath, textView: UITextView, updatedTextFieldString updatedString: String?) {
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Publish"
    }
}
