//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation
import PubNub

public class ClientCreationViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - DataSource
    
    struct ClientCreationLabelItem: LabelItem {
        init(itemType: ClientCreationItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: ClientCreationItemType, contentsString: String) {
            self.itemType = itemType
            self.contentsString = contentsString
        }
        
        let itemType: ItemType
        var contentsString: String
        var reuseIdentifier: String {
            return LabelCollectionViewCell.reuseIdentifier
        }
        
    }
    
    struct ClientCreationButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: ClientCreationItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: ClientCreationItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        var selected: Bool = false
        var targetSelector: TargetSelector
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
        
        
    }
    
    enum ClientCreationSectionType: Int, ItemSectionType {
        case ConfigurationLabels = 0
        case ClientCreationButton = 1
    }
    
    enum ClientCreationItemType: ItemType {
        case PublishKey
        case SubscribeKey
        case Origin
        case ClientCreationButton
        
        var selectedTitle: String? {
            return nil
        }
        
        var title: String {
            switch self {
            case .PublishKey:
                return "Publish Key"
            case .SubscribeKey:
                return "Subscribe Key"
            case .Origin:
                return "Origin"
            case .ClientCreationButton:
                return "Create Client"
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .PublishKey, .SubscribeKey, .Origin:
                return ClientCreationSectionType.ConfigurationLabels
            case .ClientCreationButton:
                return ClientCreationSectionType.ClientCreationButton
            }
        }
        
        var defaultValue: String {
            switch self {
            case .PublishKey, .SubscribeKey:
                return "demo-36"
            case .Origin:
                return "pubsub.pubnub.com"
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
            case .Origin:
                return 2
            case .ClientCreationButton:
                return 0
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let creationButtonItem = ClientCreationButtonItem(itemType: .ClientCreationButton, targetSelector: (self, #selector(self.clientCreationButtonPressed(_:))))
        let creationSection = BasicDataSource.BasicSection(items: [creationButtonItem])
        let configSection = BasicDataSource.BasicSection(items: [ClientCreationLabelItem(itemType: .PublishKey), ClientCreationLabelItem(itemType: .SubscribeKey), ClientCreationLabelItem(itemType: .Origin)])
        let clientCreationDataSource = BasicDataSource(sections: [configSection, creationSection])
        self.dataSource = clientCreationDataSource
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    
    func clientCreationButtonPressed(sender: UIButton!) {
        guard let client = createPubNubClient() else {
            return
        }
        let consoleViewController = ConsoleViewController(client: client)
        self.navigationController?.pushViewController(consoleViewController, animated: true)
    }
    
    // TODO: add error handling, resetting state?
    func createPubNubClient() -> PubNub? {

        func stringForItem(itemType: ClientCreationItemType) -> String {
            guard let item = dataSource?[itemType.indexPath] as? ClientCreationLabelItem where item.titleString == itemType.title else {
                fatalError("oops, dataSourceIndex is probably out of whack")
            }
            return item.contentsString
        }

        let pubKey = stringForItem(.PublishKey)
        let subKey = stringForItem(.SubscribeKey)
        let origin = stringForItem(.Origin)
        let config = PNConfiguration(publishKey: pubKey, subscribeKey: subKey)
        config.origin = origin
        return PubNub.clientWithConfiguration(config)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Client Creation"
    }
}
