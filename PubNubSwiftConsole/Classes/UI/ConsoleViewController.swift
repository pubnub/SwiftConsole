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

enum ClientCellType: String {
    case pubKey = "Publish Key"
    case subKey = "Subscribe Key"
    case channels = "Channels"
    case channelGroups = "Channel Groups"
    
    func contents(client: PubNub) -> String? {
        switch self {
        case .pubKey:
            return client.currentConfiguration().publishKey
        case .subKey:
            return client.currentConfiguration().subscribeKey
        case .channels:
            return client.channelsString()
        case .channelGroups:
            return client.channelGroupsString()
        }
    }
    
    var isTappable: Bool {
        switch self {
        case .channels, .channelGroups:
            return true
        default:
            return false
        }
    }
}

enum ClientConfigurationType: TitleContents {
    case pubKey(PubNub)
    case subKey(PubNub)
    case channels(PubNub)
    case channelGroups(PubNub)
    
    var title: String {
        switch self {
        case let .pubKey(client):
            return "Publish Key"
        case let .subKey(client):
            return "Subscribe Key"
        case let .channels(client):
            return "Channels"
        case let .channelGroups(client):
            return "Channel Groups"
        }
    }
    
    var contents: String? {
        switch self {
        case let .pubKey(client):
            return client.currentConfiguration().publishKey
        case let .subKey(client):
            return client.currentConfiguration().subscribeKey
        case let .channels(client):
            return client.channelsString()
        case let .channelGroups(client):
            return client.channelGroupsString()
        }
    }
    
    var isTappable: Bool {
        switch self {
        case .channels, .channelGroups:
            return true
        default:
            return false
        }
    }
}

/*
typealias TitleContentsCellFactory = ViewFactory<TitleContents, TitleContentsCollectionViewCell>
typealias TitleContentsHeaderViewFactory = TitledSupplementaryViewFactory<TitleContents>

typealias ConfigurationSource = DataSource<Section<TitleContents>>
*/

typealias ClientCellFactory = ViewFactory<ClientConfigurationType, TitleContentsCollectionViewCell>
typealias TitleContentsHeaderViewFactory = TitledSupplementaryViewFactory<ClientConfigurationType>

typealias ConfigurationDataSource = DataSource<Section<ClientConfigurationType>>

public class ConsoleViewController: ViewController, UICollectionViewDelegate {
    
    //let configurationDataSource = MainConsoleDataSource()
    /*
    var consoleDataSourceProvider: DataSourceProvider<FetchedResultsController<Result>, ResultCellFactory, ResultHeaderViewFactory>!
    
    var consoleDelegateProvider: FetchedResultsDelegateProvider<ResultCellFactory>!
    
    var fetchedResultsController: FetchedResultsController<Result>!
    */
    var configurationDataSourceProvider: DataSourceProvider<ConfigurationDataSource, ClientCellFactory, TitleContentsHeaderViewFactory>!
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    let configurationCollectionView: UICollectionView
    
    
    let channelsIndexPath = IndexPath(item: 0, section: 1)
    let channelGroupsIndexPath = IndexPath(item: 1, section: 1)
    
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
        self.configurationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        
        view.addSubview(configurationCollectionView)
        configurationCollectionView.forceAutoLayout()
        configurationCollectionView.backgroundColor = .cyan
        
        let configurationYOffset = (UIApplication.shared.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 5.0
        configurationCollectionView.contentInset = UIEdgeInsets(top: configurationYOffset, left: 0.0, bottom: 0.0, right: 0.0)
        //configurationCollectionView.contentOffset = CGPoint(x: 0, y: configurationYOffset)
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
            "configurationCollectionView": configurationCollectionView,
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[configurationCollectionView(300)][consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let configurationHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[configurationCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(configurationHorizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        consoleCollectionView.delegate = self
        consoleCollectionView.reloadData()
        
        configurationCollectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
        
        let section0 = Section(items: ClientConfigurationType.pubKey(console.client), ClientConfigurationType.subKey(console.client))
        let section1 = Section(items: ClientConfigurationType.channels(console.client), ClientConfigurationType.channelGroups(console.client))
        
        let configurationCellFactory = ClientCellFactory(reuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier()) { (cell, model: ClientConfigurationType?, type, collectionView, indexPath) -> TitleContentsCollectionViewCell in
            cell.update(titleContents: model)
            return cell
        }
        
        let headerFactory = TitledSupplementaryViewFactory { (header, model: ClientConfigurationType?, kind, collectionView, indexPath) -> TitledSupplementaryView in
            if let creationDate = model?.title {
                header.label.text = creationDate
            } else {
                header.label.text = "No date"
            }
            header.backgroundColor = .darkGray
            return header
        }
        
        let dataSource: ConfigurationDataSource = DataSource(sections: section0, section1)
        
        
        configurationDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: configurationCellFactory, supplementaryFactory: headerFactory)
        
        configurationCollectionView.delegate = self
        
        configurationCollectionView.dataSource = configurationDataSourceProvider.collectionViewDataSource
        
        
        console.client.addListener(self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        configurationCollectionView.performBatchUpdates({ 
            self.configurationCollectionView.reloadItems(at: [self.channelsIndexPath, self.channelGroupsIndexPath])
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
