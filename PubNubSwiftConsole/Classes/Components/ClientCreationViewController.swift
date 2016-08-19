//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation
import PubNub

@objc(PNCClientCreationViewController)
public class ClientCreationViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - DataSource

    class ClientCreationDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(clientCreationButton: TargetSelector) {
            let creationButtonItem = ClientCreationButtonItem(itemType: .clientCreationButton, targetSelector: clientCreationButton)
            let creationSection = BasicSection(items: [creationButtonItem])
            let configSection = BasicSection(items: [ClientCreationUpdatableLabelItem(itemType: .publishKey), ClientCreationUpdatableLabelItem(itemType: .subscribeKey), ClientCreationUpdatableLabelItem(itemType: .origin)])
            self.init(sections: [configSection, creationSection])
        }
    }
    
    struct ClientCreationUpdatableLabelItem: UpdatableTitleContentsItem {
        init(itemType: ClientCreationItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: ClientCreationItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
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
    }
    
    enum ClientCreationSectionType: Int, ItemSectionType {
        case configurationLabels = 0
        case clientCreationButton = 1
    }
    
    enum ClientCreationItemType: ItemType {
        case publishKey
        case subscribeKey
        case origin
        case clientCreationButton
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .clientCreationButton:
                return ButtonCollectionViewCell.self
            case .publishKey, .subscribeKey, .origin:
                return TitleContentsCollectionViewCell.self
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
            case .origin:
                return "Origin"
            case .clientCreationButton:
                return "Create Client"
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .publishKey, .subscribeKey, .origin:
                return ClientCreationSectionType.configurationLabels
            case .clientCreationButton:
                return ClientCreationSectionType.clientCreationButton
            }
        }
        
        var defaultValue: String {
            switch self {
            case .publishKey, .subscribeKey:
                return "demo-36"
            case .origin:
                return "pubsub.pubnub.com"
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
            case .origin:
                return 2
            case .clientCreationButton:
                return 0
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        dataSource = ClientCreationDataSource(clientCreationButton: (self, #selector(self.clientCreationButtonPressed(sender:))))
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
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
    
    func createPubNubClient() -> PubNub? {

        func stringForItem(itemType: ClientCreationItemType) -> String {
            guard let item = dataSource?[itemType] as? ClientCreationUpdatableLabelItem, item.title == itemType.title else {
                fatalError("oops, dataSourceIndex is probably out of whack")
            }
            return item.contents
        }

        let pubKey = stringForItem(itemType: .publishKey)
        let pubKeyProperty: PNConfiguration.KeyValue = PNConfiguration.KeyValue(.PublishKey, pubKey)
        let subKey = stringForItem(itemType: .subscribeKey)
        let subKeyProperty: PNConfiguration.KeyValue = PNConfiguration.KeyValue(.SubscribeKey, subKey)
        let origin = stringForItem(itemType: .origin)
        let originProperty: PNConfiguration.KeyValue = PNConfiguration.KeyValue(.Origin, origin)
        do {
            let config = try PNConfiguration(properties: pubKeyProperty, subKeyProperty, originProperty)
            return PubNub.client(with: config)
        } catch let pubNubError as PubNubConfigurationCreationError {
            let alertController = UIAlertController.alertController(error: pubNubError)
            present(alertController, animated: true)
            return nil
        } catch {
            fatalError("\(error)")
        }
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Client Creation"
    }
}
