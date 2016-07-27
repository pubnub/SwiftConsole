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
    
    enum ClientCreationItemType: String {
        case PublishKey = "Publish Key"
        case SubscribeKey = "Subscribe Key"
        case Origin
        var defaultValue: String {
            switch self {
            case .PublishKey, .SubscribeKey:
                return "demo-36"
            case .Origin:
                return "pubsub.pubnub.com"
            }
        }
        var dataSourceIndex: Int {
            switch self {
            case .PublishKey:
                return 0
            case .SubscribeKey:
                return 1
            case .Origin:
                return 2
            }
        }
        
    }
    
    struct ClientCreationLabelItem: LabelItem {
        init(clientCreationType: ClientCreationItemType) {
            self.init(clientCreationType: clientCreationType, contentsString: clientCreationType.defaultValue)
        }
        
        init(clientCreationType: ClientCreationItemType, contentsString: String) {
            self.clientCreationType = clientCreationType
            self.contentsString = contentsString
        }
        
        let clientCreationType: ClientCreationItemType
        var titleString: String {
            return clientCreationType.rawValue
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
    
    struct ClientCreationButtonItem: ButtonItem {
        var title: String {
            return "Create Client"
        }
        var selectedTitle: String? {
            return nil
        }
        init(selected: Bool, targetSelector: TargetSelector) {
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(targetSelector: TargetSelector) {
            self.init(selected: false, targetSelector: targetSelector)
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
        
        
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let buttonItem = ClientCreationButtonItem(targetSelector: (self, #selector(self.clientCreationButtonPressed(_:))))
        let buttonSection = BasicSection(items: [buttonItem])
        let configSection = BasicSection(items: [ClientCreationLabelItem(clientCreationType: .PublishKey), ClientCreationLabelItem(clientCreationType: .SubscribeKey), ClientCreationLabelItem(clientCreationType: .Origin)])
        self.dataSource = BasicDataSource(sections: [configSection, buttonSection])
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
        // we know there is only 1 section
        // TODO: make this into a constant or something
        guard let section = dataSource[0] as? BasicSection else {
            fatalError()
        }
        
        func stringForItem(itemType: ClientCreationItemType) -> String {
            guard let item = section[itemType.dataSourceIndex] as? ClientCreationLabelItem where item.titleString == itemType.rawValue else {
                fatalError("oops, dataSourceIndex is probably out of whack")
            }
            return item.contentsString
        }
        
        let pubKey = stringForItem(ClientCreationItemType.PublishKey)
        let subKey = stringForItem(ClientCreationItemType.SubscribeKey)
        let origin = stringForItem(ClientCreationItemType.Origin)
        
        let config = PNConfiguration(publishKey: pubKey, subscribeKey: subKey)
        config.origin = origin
        
        return PubNub.clientWithConfiguration(config)
    }
    
    // MARK: - CollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?) {
        if let actionTitle = selectedAlertAction.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
            switch (alertDecision) {
            case .OK:
                guard var selectedLabelItem = self.dataSource[indexPath] as? ClientCreationLabelItem else {
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
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Client Creation"
    }
}
