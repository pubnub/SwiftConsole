//
//  MessagesViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/18/16.
//
//

import UIKit
import PubNub
import JSQDataSourcesKit

class MessagesViewController: ViewController {
    
    weak var refreshTimer: Timer?
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    
    public required init(console: SwiftConsole) {
        self.console = console
        self.consoleCollectionView = ConsoleCollectionView(console: console)
        //layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        super.init()
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        view.addSubview(consoleCollectionView)
        consoleCollectionView.forceAutoLayout()
        consoleCollectionView.backgroundColor = .white
        
        
        let views = [
            "consoleCollectionView": consoleCollectionView,
            ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[consoleCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        consoleCollectionView.reloadData()
        
        
        
        
        
        
        //refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshScreen), userInfo: nil, repeats: true)
        
    }
    
    func refreshScreen() {
        consoleCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        consoleCollectionView.fetch()
    }
    
    /*
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        consoleCollectionView.contentInset = .zero
        consoleCollectionView.contentOffset = .zero
    }
 */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didBecomeActive(notification: Notification) {
        print("notification: \(notification)")
        consoleCollectionView.fetch()
    }

}
