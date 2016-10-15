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
            case .authKey:
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
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = TitleContentsCollectionViewCell.size
        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 20.0
        layout.estimatedItemSize = TitleContentsCollectionViewCell.size
        //layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        //self.configurationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        let channelsItemType = ClientProperty.channels.generateStaticItemType(client: console.client, isTappable: true)
        let channelGroupsItemType = ClientProperty.channelGroups.generateStaticItemType(client: console.client, isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: channelsItemType, channelGroupsItemType)
        
        let dataSource = DataSource(sections: section0, section1)
        
        configurationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        //configurationDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        
        clientCollectionView.delegate = self
        
        clientCollectionView.dataSource = configurationDataSourceProvider.collectionViewDataSource
        
        
        console.client.addListener(self)
        clientCollectionView.reloadData()
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
            print("console collection view tapped")
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
