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
    /*
    var consoleDataSourceProvider: DataSourceProvider<FetchedResultsController<Result>, ResultCellFactory, ResultHeaderViewFactory>!
    
    var consoleDelegateProvider: FetchedResultsDelegateProvider<ResultCellFactory>!
    
    var fetchedResultsController: FetchedResultsController<Result>!
    */
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    
    public required init(console: SwiftConsole) {
        self.console = console
        self.consoleCollectionView = ConsoleCollectionView(console: console)
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
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
        ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        consoleCollectionView.delegate = self
        consoleCollectionView.reloadData()
        
        console.client.addListener(self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
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
