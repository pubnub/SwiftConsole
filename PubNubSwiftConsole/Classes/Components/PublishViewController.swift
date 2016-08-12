//
//  PublishViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import Foundation
import PubNub

@objc(PNCPublishViewControllerDelegate)
public protocol PublishViewControllerDelegate {
    @objc optional func publishView(publishView: PublishViewController, receivedPublishStatus status: PNPublishStatus)
}

// Intended to launch from the toolbar
@objc(PNCPublishViewController)
public class PublishViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - Properties
    var publishDelegate: PublishViewControllerDelegate?
    
    // MARK: - DataSource
    
    enum PublishSectionType: Int, ItemSectionType {
        case clientConfiguration = 0, publishConfiguration, payloadInput, publishStatusConsole
    }
    
    enum PublishItemType: ItemType {
        case publishKey
        case subscribeKey
        case uuid
        case channelLabel
        case payloadInput
        case publishButton
        case publishStatus
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return TitleContentsCollectionViewCell.self
            case .channelLabel:
                return TitleContentsCollectionViewCell.self
            case .payloadInput:
                return TextViewCollectionViewCell.self
            case .publishButton:
                return ButtonCollectionViewCell.self
            case .publishStatus:
                return PublishStatusCollectionViewCell.self
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
        
        func contents(_ client: PubNub) -> String {
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
                return PublishSectionType.clientConfiguration
            case .channelLabel:
                return PublishSectionType.publishConfiguration
            case .payloadInput:
                return PublishSectionType.payloadInput
            case .publishButton:
                return PublishSectionType.publishConfiguration
            case .publishStatus:
                return PublishSectionType.publishStatusConsole
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
            let publishItem = PublishStatus(itemType: PublishItemType.publishStatus, publishStatus: publishStatus)
            return push(section: PublishItemType.publishStatus.section, item: publishItem)
        }
    }
    
    // MARK: - Constructors
    public required init(client: PubNub) {
        super.init()
        self.client = client
    }
    
    public required init() {
        super.init()
        self.client?.add(self)
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
        let publishButton: TargetSelector = (self, #selector(self.publishButtonTapped(_:)))
        dataSource = PublishDataSource(client: currentClient, publishButton: publishButton)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.register(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.register(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    public func publishButtonTapped(_ sender: UIButton!) {
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
            try self.client?.safePublish(message, toChannel: channel, withCompletion: { [unowned self] (publishStatus) in
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
