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

typealias ResultCellFactory = ViewFactory<Result, ResultCollectionViewCell>
typealias ResultHeaderViewFactory = TitledSupplementaryViewFactory<Result>


public class ConsoleViewController: ViewController, UICollectionViewDelegate {
    
    //let configurationDataSource = MainConsoleDataSource()
    
    var consoleDataSourceProvider: DataSourceProvider<FetchedResultsController<Result>, ResultCellFactory, ResultHeaderViewFactory>!
    
    var consoleDelegateProvider: FetchedResultsDelegateProvider<ResultCellFactory>!
    
    var fetchedResultsController: FetchedResultsController<Result>!
    
    let console: SwiftConsole
    let consoleCollectionView: UICollectionView
    
    public required init(console: SwiftConsole) {
        let bounds = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = ResultCollectionViewCell.size
        layout.estimatedItemSize = ResultCollectionViewCell.size
        layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        self.consoleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.console = console
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
        consoleCollectionView.backgroundColor = UIColor.red
        //consoleCollectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
        consoleCollectionView.register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.reuseIdentifier())
        consoleCollectionView.register(TitledSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TitledSupplementaryView.identifier)
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        let cellFactory = ViewFactory(reuseIdentifier: ResultCollectionViewCell.reuseIdentifier()) { (cell, model: Result?, type, collectionView, indexPath) -> ResultCollectionViewCell in
            cell.update(result: model)
            return cell
        }
        
        let headerFactory = TitledSupplementaryViewFactory { (header, model: Result?, kind, collectionView, indexPath) -> TitledSupplementaryView in
            //header.label.text = "\(item!.colorName) header (\(indexPath.section))"
            //header.label.textColor = item?.displayColor
            if let creationDate = model?.creationDate {
                header.label.text = "\(creationDate)"
            } else {
                header.label.text = "No date"
            }
            header.backgroundColor = .darkGray
            return header
        }
        
        consoleDelegateProvider = FetchedResultsDelegateProvider(cellFactory: cellFactory, collectionView: consoleCollectionView)
        
        let allResultsFetchRequest: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        fetchedResultsController = FetchedResultsController<Result>(fetchRequest: allResultsFetchRequest, managedObjectContext: console.viewContext, sectionNameKeyPath: #keyPath(Result.creationDate), cacheName: nil)
        fetchedResultsController.delegate = consoleDelegateProvider.collectionDelegate
        
        consoleDataSourceProvider = DataSourceProvider(dataSource: fetchedResultsController, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        
        consoleCollectionView.delegate = self
        consoleCollectionView.dataSource = consoleDataSourceProvider.collectionViewDataSource
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        console.client.addListener(self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        
    }
    

    
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
