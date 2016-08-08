//
//  PublishViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import Foundation
import PubNub

public class PublishViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - DataSource
    
    enum PublishSectionType: Int, ItemSectionType {
        case Channel = 0, PayloadInput, PublishButton
    }
    
    enum PublishItemType: ItemType {
        case ChannelLabel
        case PayloadInput
        case PublishButton
        
        func size(collectionViewSize: CGSize) -> CGSize {
            switch self {
            case .ChannelLabel:
                return CGSize(width: 100.0, height: 100.0)
            case .PayloadInput:
                return CGSize(width: 300.0, height: 300.0)
            case .PublishButton:
                return CGSize(width: 200.0, height: 100.0)
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
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .ChannelLabel:
                return PublishSectionType.Channel
            case .PayloadInput:
                return PublishSectionType.PayloadInput
            case .PublishButton:
                return PublishSectionType.PublishButton
            }
        }
        
        var defaultValue: String {
            switch self {
            case .ChannelLabel:
                return ""
            case .PayloadInput:
                return ""
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
    
    struct PublishUpdateableLabelItem: UpdateableLabelItem {
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
            return UpdateableLabelCollectionViewCell.reuseIdentifier
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
            let channelLabelSection = BasicSection(items: [channelLabelItem])
            let payloadSection = BasicSection(items: [textViewItem])
            let publishButtonSection = BasicSection(items: [publishButtonItem])
            self.init(sections: [channelLabelSection, payloadSection, publishButtonSection])
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
        collectionView.registerClass(UpdateableLabelCollectionViewCell.self, forCellWithReuseIdentifier: UpdateableLabelCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(TextViewCollectionViewCell.self, forCellWithReuseIdentifier: TextViewCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    public func publishButtonTapped(sender: UIButton!) {
        print(#function)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Publish"
    }
}
