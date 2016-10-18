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

public protocol ClientCreationViewControllerDelegate: NSObjectProtocol {
    func clientCreation(_ clientCreationViewController: ClientCreationViewController, createdClient: PubNub)
    func clientCreation(_ clientCreationViewController: ClientCreationViewController, failedWithError: Error)
}

public class ClientCreationViewController: ViewController, UICollectionViewDelegate {
    
    public weak var delegate: ClientCreationViewControllerDelegate?
    
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
            case .uuid:
                return IndexPath(item: 0, section: 2)
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
        clientCollectionView.backgroundColor = .white
                
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
        let uuidItemType = ClientProperty.uuid.generateDefaultStaticItemType(isTappable: true)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: authKeyItemType, originItemType)
        let section2 = Section(items: uuidItemType)
        
        let dataSource = DataSource(sections: section0, section1, section2)
        
        clientCreationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        
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
        
        delegate?.clientCreation(self, createdClient: client)
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let titleContents = clientCreationDataSourceProvider.dataSource[indexPath].staticItem as? TitleContentsItem else {
            fatalError()
        }
        print("\(titleContents)")
        let alertController = UIAlertController.titleContentsAlertController(withCurrent: titleContents) { (action, input) -> (Void) in
            defer {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
            switch action {
            case .ok:
                let updatedTitleContents = titleContents.updatedTitleContentsItem(with: input)
                let updatedItemType = StaticItemType(staticItem: updatedTitleContents)
                print("updatedTitleContents: \(updatedTitleContents)")
                collectionView.performBatchUpdates({
                    guard let updatedIndexPath = self.clientCreationUpdater.update(dataSource: &self.clientCreationDataSourceProvider.dataSource, at: indexPath, with: updatedItemType, isTappable: true) else {
                        return
                    }
                    collectionView.reloadItems(at: [updatedIndexPath])
                })
            case .cancel:
                return
            }
        }
        present(alertController, animated: true)
        
    }

}

extension UIAlertController {
    typealias TitleContentsActionHandler = (TitleContentsAction, String?) -> (Swift.Void)
    enum TitleContentsAction: String {
        case ok = "OK"
        case cancel = "Cancel"
        
        static func alertActionHandler(action type: TitleContentsAction, withInput textField: UITextField, handler: TitleContentsActionHandler? = nil) -> AlertActionHandler {
            return { (action) in
                guard let actualTitle = action.title, let actionType = TitleContentsAction(rawValue: actualTitle), type == actionType else {
                    fatalError()
                }
                handler?(actionType, textField.text)
            }
        }
        
        func alertAction(withInput textField: UITextField, handler: TitleContentsActionHandler? = nil) -> UIAlertAction {
            let titleContentsHandler = TitleContentsAction.alertActionHandler(action: self, withInput: textField, handler: handler)
            return UIAlertAction(title: rawValue, style: .default, handler: titleContentsHandler)
        }
    }
    
    // seems like it could be a compiler bug with @escaping
    static func titleContentsAlertController(withCurrent titleContents: TitleContents, handler: /*@escaping*/TitleContentsActionHandler? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Update \(titleContents.title)", message: "Enter something to update", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter values ..."
            textField.text = titleContents.contents
        })
        guard let inputTextField = alertController.textFields?[0] else {
            fatalError("Didn't find textField")
        }
        let okAction = TitleContentsAction.ok.alertAction(withInput: inputTextField, handler: handler)
        let cancelAction = TitleContentsAction.cancel.alertAction(withInput: inputTextField, handler: handler)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
