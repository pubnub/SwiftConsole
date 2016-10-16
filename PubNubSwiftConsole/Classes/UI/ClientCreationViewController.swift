//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/14/16.
//
//

import UIKit
import PubNub
import JSQDataSourcesKit

public class ClientCreationViewController: ViewController, UICollectionViewDelegate {
    
    struct ClientCreationUpdater: ClientPropertyUpdater {
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
            case .authKey:
                return IndexPath(row: 0, section: 1)
            case .origin:
                return IndexPath(item: 1, section: 1)
            default:
                fatalError("\(clientProperty)")
            }
        }
    }
    
    let clientCreationUpdater = ClientCreationUpdater()
    
    var clientCreationDataSourceProvider: StaticDataSourceProvider!
    
    let clientCollectionView: ClientCollectionView
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        let layout = StaticItemCollectionViewFlowLayout()
        self.clientCollectionView = ClientCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(clientCollectionView)
        clientCollectionView.forceAutoLayout()
        clientCollectionView.backgroundColor = .cyan
        
        //let configurationYOffset = (UIApplication.shared.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 5.0
        //clientCollectionView.contentInset = UIEdgeInsets(top: configurationYOffset, left: 0.0, bottom: 0.0, right: 0.0)
        
        let views = [
            "clientCollectionView": clientCollectionView,
            ]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[clientCollectionView]|", options: [], metrics: nil, views: views)
        let configurationHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[clientCollectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(configurationHorizontalConstraints)
        NSLayoutConstraint.activate(verticalConstraints)
        self.view.setNeedsLayout()
        
        
        let pubKeyItemType = ClientProperty.pubKey.generateDefaultStaticItemType(isTappable: true)
        let subKeyItemType = ClientProperty.subKey.generateDefaultStaticItemType(isTappable: true)
        let authKeyItemType = ClientProperty.authKey.generateDefaultStaticItemType(isTappable: true)
        let originItemType = ClientProperty.origin.generateDefaultStaticItemType(isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: authKeyItemType, originItemType)
        
        let dataSource = DataSource(sections: section0, section1)
        
        clientCreationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        //configurationDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        
        clientCollectionView.delegate = self
        
        clientCollectionView.dataSource = clientCreationDataSourceProvider.collectionViewDataSource
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(clientCreationItemTapped(sender:)))
        
        clientCollectionView.reloadData()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - UINavigation Actions
    
    func clientCreationItemTapped(sender: UIBarButtonItem) {
        let publishItem = clientCreationUpdater.staticItem(from: clientCreationDataSourceProvider.dataSource, for: .pubKey) as! TitleContents
        let subscribeItem = clientCreationUpdater.staticItem(from: clientCreationDataSourceProvider.dataSource, for: .subKey) as! TitleContents
        let originItem = clientCreationUpdater.staticItem(from: clientCreationDataSourceProvider.dataSource, for: .origin) as! TitleContents
        let authKeyItem = clientCreationUpdater.staticItem(from: clientCreationDataSourceProvider.dataSource, for: .authKey) as! TitleContents
        let config = PNConfiguration(publishKey: publishItem.contents!, subscribeKey: subscribeItem.contents!)
        config.authKey = authKeyItem.contents
        config.origin = originItem.contents!
        
        let client = PubNub.clientWithConfiguration(config)
        let swiftConsole = SwiftConsole(client: client)
        let consoleView = ConsoleViewController(console: swiftConsole)
        navigationController?.pushViewController(consoleView, animated: true)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let titleContents = clientCreationDataSourceProvider.dataSource[indexPath].staticItem as? TitleContentsItem else {
            fatalError()
        }
        print("\(titleContents)")
        let alertController = UIAlertController.update(titleContents: titleContents) { (inputString) in
            let updatedTitleContents = titleContents.updatedTitleContentsItem(with: inputString)
            let updatedItemType = StaticItemType(staticItem: updatedTitleContents)
            print("updatedTitleContents: \(updatedTitleContents)")
            collectionView.performBatchUpdates({
                guard let updatedIndexPath = self.clientCreationUpdater.update(dataSource: &self.clientCreationDataSourceProvider.dataSource, at: indexPath, with: updatedItemType, isTappable: true) else {
                    return
                }
                collectionView.reloadItems(at: [updatedIndexPath])
                })
            
        }
        present(alertController, animated: true)
        
    }

}

extension UIAlertController {
    // seems like it could be a compiler bug with @escaping
    static func update(titleContents: TitleContents, handler: /*@escaping*/((String?) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Update \(titleContents.title)", message: "Enter something to update", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter values ..."
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            let textFieldInput = alertController.textFields?[0].text
            handler?(textFieldInput)
        }
        alertController.addAction(okAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        return alertController
    }
}
