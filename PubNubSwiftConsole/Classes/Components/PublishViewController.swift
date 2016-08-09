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
        case Configuration = 0, PayloadInput, PublishStatusConsole
    }
    
    enum PublishItemType: ItemType {
        case ChannelLabel
        case PayloadInput
        case PublishButton
        case PublishStatus
        
        func size(collectionViewSize: CGSize) -> CGSize {
            switch self {
            case .ChannelLabel:
                return CGSize(width: 100.0, height: 100.0)
            case .PayloadInput:
                return CGSize(width: 300.0, height: 300.0)
            case .PublishButton:
                return CGSize(width: 125.0, height: 100.0)
            case .PublishStatus:
                return CGSize(width: collectionViewSize.width, height: 150.0)
            }
        }
        
        var selectedTitle: String? {
            return nil
        }
        
        var title: String {
            switch self {
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
        
        var sectionType: ItemSectionType {
            switch self {
            case .ChannelLabel:
                return PublishSectionType.Configuration
            case .PayloadInput:
                return PublishSectionType.PayloadInput
            case .PublishButton:
                return PublishSectionType.Configuration
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
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
    }
    
    struct PublishUpdateableLabelItem: UpdatableTitleContentsItem {
        init(itemType: PublishItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: PublishItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
        var reuseIdentifier: String {
            return TitleContentsCollectionViewCell.reuseIdentifier
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
        var reuseIdentifier: String {
            return TextViewCollectionViewCell.reuseIdentifier
        }
    }
    
    final class PublishDataSource: BasicDataSource {
        required override init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(publishButton: TargetSelector) {
            let publishButtonItem = PublishButtonItem(itemType: .PublishButton, targetSelector: publishButton)
            let channelLabelItem = PublishUpdateableLabelItem(itemType: .ChannelLabel)
            let textViewItem = PublishTextViewItem(itemType: .PayloadInput)
            let configSection = BasicSection(items: [channelLabelItem, publishButtonItem])
            let payloadSection = BasicSection(items: [textViewItem])
            let publishStatusSection = ScrollingSection()
            self.init(sections: [configSection, payloadSection, publishStatusSection])
        }
        var message: String {
            guard let payloadItem = self[PublishItemType.PayloadInput.indexPath] as? PublishTextViewItem else {
                fatalError()
            }
            return payloadItem.contents
        }
        var channel: String {
            guard let channelItem = self[PublishItemType.ChannelLabel.indexPath] as? PublishUpdateableLabelItem else {
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
        self.delegate = self
        let publishButton: TargetSelector = (self, #selector(self.publishButtonTapped(_:)))
        dataSource = PublishDataSource(publishButton: publishButton)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    public func publishButtonTapped(sender: UIButton!) {
        print(#function)
        publish()
    }
    
    func publish() {
        guard let currentDataSource = dataSource as? PublishDataSource else {
            return
        }
        let message = currentDataSource.message // eventually throw errors for feedback
        let channel = currentDataSource.channel
        // we may exit the view controller before the completion handler occurs, so let's keep that in mind
        // in this case, we need it to stick around, so that we can log the response (if we were using Realm we could let the underlying view controller handle the completion and then this view controller could be weak instead of unowned)
        self.client?.publish(message, toChannel: channel, withCompletion: { [unowned self] (publishStatus) in
            print(publishStatus.debugDescription)
            guard var completionDataSource = self.dataSource as? PublishDataSource else {
                return
            }
            self.collectionView?.performBatchUpdates({ 
                let insertedPublishCell = completionDataSource.push(publishStatus)
                self.collectionView?.insertItemsAtIndexPaths([insertedPublishCell])
                }, completion: nil)
            // now try to send this publish status to the console view controller
            self.publishDelegate?.publishView?(self, receivedPublishStatus: publishStatus)
//            if let publishDelegate = self.delegate as? PublishViewControllerDelegate {
//                publishDelegate.publishView?(self, receivedPublishStatus: publishStatus)
//            }
        })
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextViewAtIndexPath indexPath: NSIndexPath, textView: UITextView, updatedTextFieldString updatedString: String?) {
        print(#file)
        print(#line)
        print(#function)
        print(updatedString)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Publish"
    }
}
