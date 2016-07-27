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
        
    }
    
    struct ConsoleLabelItem: LabelItem {
        let consoleType: ConsoleItemType
        init(consoleType: ConsoleItemType, contentsString: String) {
            self.consoleType = consoleType
            self.contentsString = contentsString
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

    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let section = BasicSection(items: [ConsoleLabelItem(consoleType: .Channels, contentsString: "a"), ConsoleLabelItem(consoleType: .ChannelGroups, contentsString: "a")])
        self.dataSource = BasicDataSource(sections: [section])
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
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
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Console"
    }

}
