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

enum ClientProperty: String, PubNubStaticItemGenerator {
    case pubKey = "Publish Key"
    case subKey = "Subscribe Key"
    case channels = "Channels"
    case channelGroups = "Channel Groups"
    case authKey = "PAM Key"
    
    var title: String {
        return rawValue
    }
    
    init?(staticItem: StaticItem) {
        guard let title = staticItem as? Title else {
            return nil
        }
        if let actualProperty = ClientProperty(rawValue: title.title) {
            self = actualProperty
        } else {
            return nil
        }
    }
    
    func generateStaticItem(client: PubNub, isTappable: Bool = false) -> StaticItem {
        switch self {
        case .pubKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().publishKey, isTappable: isTappable)
        case .subKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().subscribeKey, isTappable: isTappable)
        case .channels:
            return TitleContentsItem(title: title, contents: client.channelsString(), isTappable: isTappable)
        case .channelGroups:
            return TitleContentsItem(title: title, contents: client.channelGroupsString(), isTappable: isTappable)
        case .authKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().authKey, isTappable: isTappable)
        }
    }
    func generateStaticItemType(client: PubNub, isTappable: Bool = false) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(client: client, isTappable: isTappable))
    }
}

enum StaticItemType {
    case staticItem(StaticItem)
    case title(Title)
    case titleContents(TitleContents)
    
    var reuseIdentifier: String {
        switch self {
        case .title(_):
            return TitleCollectionViewCell.reuseIdentifier()
        case .titleContents(_):
            return TitleContentsCollectionViewCell.reuseIdentifier()
        default:
            fatalError()
        }
    }
    
    init(staticItem: StaticItem) {
        switch staticItem {
        case let staticItem as TitleContents:
            self = StaticItemType.titleContents(staticItem)
        case let staticItem as Title:
            self = StaticItemType.title(staticItem)
        default:
            self = StaticItemType.staticItem(staticItem)
        }
    }
}

struct StaticItemCellViewFactory: ReusableViewFactoryProtocol {
    typealias TitleViewFactory = ViewFactory<Title, TitleCollectionViewCell>
    typealias TitleContentsViewFactory = ViewFactory<TitleContents, TitleContentsCollectionViewCell>
    let titleCellFactory: TitleViewFactory
    let titleContentsCellFactory: TitleContentsViewFactory
    
    init(titleCellFactory: TitleViewFactory, titleContentsCellFactory: TitleContentsViewFactory) {
        self.titleCellFactory = titleCellFactory
        self.titleContentsCellFactory = titleContentsCellFactory
    }
    
    init() {
        let titleCellFactory = TitleViewFactory(reuseIdentifier: TitleCollectionViewCell.reuseIdentifier()) { (cell, model: Title?, type, collectionView, indexPath) -> TitleCollectionViewCell in
            cell.update(title: model)
            return cell
        }
        let titleContentsCellFactory = TitleContentsViewFactory(reuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier()) { (cell, model: TitleContents?, type, collectionView, indexPath) -> TitleContentsCollectionViewCell in
            cell.update(titleContents: model)
            return cell
        }
        self.init(titleCellFactory: titleCellFactory, titleContentsCellFactory: titleContentsCellFactory)
    }
    
    func reuseIdentiferFor(item: StaticItemType?, type: ReusableViewType, indexPath: IndexPath) -> String {
        return item!.reuseIdentifier
    }
    
    func configure(view: UICollectionViewCell, item: StaticItemType?, type: ReusableViewType, parentView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = item else {
            return view
        }
        switch model {
        case let .title(titleModel):
            let cell = view as! TitleCollectionViewCell
            return titleCellFactory.configure(view: cell, item: titleModel, type: type, parentView: parentView, indexPath: indexPath)
        case let .titleContents(titleContentsModel):
            let cell = view as! TitleContentsCollectionViewCell
            return titleContentsCellFactory.configure(view: cell, item: titleContentsModel, type: type, parentView: parentView, indexPath: indexPath)
        default:
            fatalError()
        }
    }
    
}

typealias ClientCellFactory = ViewFactory<StaticItem, TitleCollectionViewCell>
typealias TitleContentsHeaderViewFactory = TitledSupplementaryViewFactory<StaticItemType>

typealias ConfigurationDataSource = DataSource<Section<StaticItemType>>

protocol DataSourceUpdater {
    // if indexPath is nil then no update occurred
    func update(dataSource: inout ConfigurationDataSource, at indexPath: IndexPath, with item: StaticItemType, isTappable: Bool) -> IndexPath?
}

protocol ClientPropertyUpdater: DataSourceUpdater {
    
    func indexPath(for clientProperty: ClientProperty) -> IndexPath?
    // if indexPath is nil, then no update occurred
    func update(dataSource: inout ConfigurationDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool) -> IndexPath?
}


extension ClientPropertyUpdater {
    func update(dataSource: inout ConfigurationDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool = false) -> IndexPath? {
        guard let propertyIndexPath = indexPath(for: clientProperty) else {
            return nil
        }
        let staticItemType = clientProperty.generateStaticItemType(client: client, isTappable: isTappable)
        return update(dataSource: &dataSource, at: propertyIndexPath, with: staticItemType, isTappable: isTappable)
    }
}

public class ConsoleViewController: ViewController, UICollectionViewDelegate {
    
    struct ConsoleUpdater: ClientPropertyUpdater {
        internal func update(dataSource: inout ConfigurationDataSource, at indexPath: IndexPath, with item: StaticItemType, isTappable: Bool) -> IndexPath? {
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

    var configurationDataSourceProvider: DataSourceProvider<ConfigurationDataSource, StaticItemCellViewFactory, TitleContentsHeaderViewFactory>!
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    let configurationCollectionView: UICollectionView
    
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
        configurationCollectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.reuseIdentifier())
        
        let headerFactory = TitledSupplementaryViewFactory { (header, model: StaticItemType?, kind, collectionView, indexPath) -> TitledSupplementaryView in
            
            header.label.text = "Section \(indexPath.section)"
            header.backgroundColor = .darkGray
            header.label.textColor = .white
            return header
        }
        
        let pubKeyItemType = ClientProperty.pubKey.generateStaticItemType(client: console.client)
        let subKeyItemType = ClientProperty.subKey.generateStaticItemType(client: console.client)
        let channelsItemType = ClientProperty.channels.generateStaticItemType(client: console.client, isTappable: true)
        let channelGroupsItemType = ClientProperty.channelGroups.generateStaticItemType(client: console.client, isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: channelsItemType, channelGroupsItemType)
        
        let cellFactory = StaticItemCellViewFactory()
        
        let dataSource: ConfigurationDataSource = DataSource(sections: section0, section1)
        
        
        configurationDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        
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
            //var dataSource = self.configurationDataSourceProvider.dataSource
            let client = self.console.client
            var updatedIndexPaths = [IndexPath]()
            if let updatedChannelsItemIndexPath = self.consoleUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channels, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelsItemIndexPath)
            }
            if let updatedChannelGroupsItemIndexPath = self.consoleUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channelGroups, with: client, isTappable: true) {
                updatedIndexPaths.append(updatedChannelGroupsItemIndexPath)
            }
            self.configurationCollectionView.reloadItems(at: updatedIndexPaths)
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
