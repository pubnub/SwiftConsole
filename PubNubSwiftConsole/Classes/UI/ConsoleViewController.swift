//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData
import PubNub
import JSQDataSourcesKit

public class ConsoleViewController: ViewController, UICollectionViewDelegate {
    
    struct ConsoleUpdater: ClientPropertyUpdater {
        internal func update(dataSource: inout StaticDataSource, at indexPath: IndexPath, with item: StaticItemType, isTappable: Bool) -> IndexPath? {
            dataSource[indexPath] = item
            return indexPath
        }

        func indexPath(for clientProperty: ClientProperty) -> IndexPath? {
            switch clientProperty {
            case .pubKey:
                return IndexPath(item: 0, section: 0)
            case .subKey:
                return IndexPath(item: 1, section: 0)
            case .channels:
                return IndexPath(row: 0, section: 1)
            case .channelGroups:
                return IndexPath(item: 1, section: 1)
            case .subscribe:
                return IndexPath(item: 0, section: 2)
            case .unsubscribe:
                return IndexPath(item: 1, section: 2)
            case .authKey, .origin:
                return nil
            }
        }
    }
    
    let consoleUpdater = ConsoleUpdater()

    var configurationDataSourceProvider: StaticDataSourceProvider!
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    let clientCollectionView: ClientCollectionView
    
    public required init(console: SwiftConsole) {
        self.console = console
        self.consoleCollectionView = ConsoleCollectionView(console: console)
        let bounds = UIScreen.main.bounds
        let layout = StaticItemCollectionViewFlowLayout()
        //layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        self.clientCollectionView = ClientCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init()
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(consoleCollectionView)
        consoleCollectionView.forceAutoLayout()
        consoleCollectionView.backgroundColor = .red
        
        view.addSubview(clientCollectionView)
        clientCollectionView.forceAutoLayout()
        clientCollectionView.backgroundColor = .cyan
        
        let configurationYOffset = (UIApplication.shared.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 5.0
        clientCollectionView.contentInset = UIEdgeInsets(top: configurationYOffset, left: 0.0, bottom: 0.0, right: 0.0)
        //configurationCollectionView.contentOffset = CGPoint(x: 0, y: configurationYOffset)
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
            "clientCollectionView": clientCollectionView,
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[clientCollectionView(300)][consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let configurationHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[clientCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(configurationHorizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        consoleCollectionView.delegate = self
        consoleCollectionView.reloadData()
        
        let pubKeyItemType = ClientProperty.pubKey.generateStaticItemType(client: console.client)
        let subKeyItemType = ClientProperty.subKey.generateStaticItemType(client: console.client)
        let channelsItemType = ClientProperty.channels.generateStaticItemType(client: console.client)
        let channelGroupsItemType = ClientProperty.channelGroups.generateStaticItemType(client: console.client)
        let subscribeItemType = ClientProperty.subscribe.generateStaticItemType(client: console.client, isTappable: true)
        let unsubscribeItemType = ClientProperty.unsubscribe.generateStaticItemType(client: console.client, isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: channelsItemType, channelGroupsItemType)
        let section2 = Section(items: subscribeItemType, unsubscribeItemType)
        
        let dataSource = DataSource(sections: section0, section1, section2)
        
        configurationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        //configurationDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        
        clientCollectionView.delegate = self
        
        clientCollectionView.dataSource = configurationDataSourceProvider.collectionViewDataSource
        
        
        console.client.addListener(self)
        clientCollectionView.reloadData()
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.consoleCollectionView.predicate = ConsoleSegment.messages.consolePredicate
        }
 */
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        clientCollectionView.performBatchUpdates({
            let client = self.console.client
            var updatedIndexPaths = [IndexPath]()
            if let updatedChannelsItemIndexPath = self.consoleUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channels, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelsItemIndexPath)
            }
            if let updatedChannelGroupsItemIndexPath = self.consoleUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channelGroups, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelGroupsItemIndexPath)
            }
            self.clientCollectionView.reloadItems(at: updatedIndexPaths)
            })
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case collectionView as ConsoleCollectionView:
            return
            
        case collectionView as ClientCollectionView:
            print("console collection view tapped")
            let selectedItem = consoleUpdater.staticItem(from: configurationDataSourceProvider.dataSource, at: indexPath)
            guard selectedItem.isTappable == true else {
                return
            }
            guard let clientProperty = ClientProperty(staticItem: selectedItem) else {
                return
            }
            switch clientProperty {
            case .subscribe:
                let alertController = UIAlertController(title: "Subscribe", message: "Enter a value, comma delimited", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Channel or group name ..."
                })
                let channelSubscribe = UIAlertAction(title: "Subscribe as channel", style: .default, handler: { (action) in
                    print(action)
                    guard let textFieldInput = alertController.textFields?[0].text else {
                        return
                    }
                    print("textFieldInput")
                })
                let channelGroupSubscribe = UIAlertAction(title: "Subscribe as channel group", style: .default, handler: { (action) in
                    print(action)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                alertController.addAction(channelSubscribe)
                alertController.addAction(channelGroupSubscribe)
                alertController.addAction(cancelAction)
                present(alertController, animated: true)
            case .unsubscribe:
                let alertController = UIAlertController(title: "Unsubscribe", message: "Choose an option", preferredStyle: .alert)
                let unsubscribeFromAll = UIAlertAction(title: "Unsubscribe from all", style: .default, handler: { (action) in
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                alertController.addAction(unsubscribeFromAll)
                alertController.addAction(cancelAction)
                present(alertController, animated: true)
            default:
                return
            }
        default:
            print("other collection view tapped")
        }
    }
    /*
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        cell.contentView.backgroundColor = .blue
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        cell.contentView.backgroundColor = nil
    }
 */

    
    // MARK: - PNObjectEventListener
    
    @objc(client:didReceiveStatus:)
    public func client(_ client: PubNub, didReceive status: PNStatus) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! \(#function)")
        guard (status.operation == .subscribeOperation) || (status.operation == .unsubscribeOperation) else {
            return
        }
        updateSubscribablesCells(client: client)
    }
    
}
