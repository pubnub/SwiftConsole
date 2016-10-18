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

public class ConsoleViewController: ViewController, UICollectionViewDelegate, UITextFieldDelegate {
    
    struct ClientUpdater: ClientPropertyUpdater {
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
                return IndexPath(item: 0, section: 3)
            case .unsubscribe:
                return IndexPath(item: 1, section: 3)
            case .streamFilter:
                return IndexPath(item: 0, section: 2)
            case .authKey, .origin, .uuid:
                return nil
            }
        }
    }
    
    let clientUpdater = ClientUpdater()

    var configurationDataSourceProvider: StaticDataSourceProvider!
    let console: SwiftConsole
    let consoleCollectionView: ConsoleCollectionView
    let clientCollectionView: ClientCollectionView
    
    class PublishInputAccessoryView: UITextField {
        
        required init(target: Any, action: Selector, frame: CGRect) {
            super.init(frame: frame)
            borderStyle = .line
            backgroundColor = .green
            clearButtonMode = .whileEditing
            let publishFrame = CGRect(x: 0, y: 0, width: frame.width/5.0, height: frame.height)
            placeholder = "Enter message ..."
            let publishButton = UIButton(frame: publishFrame)
            //let publishButton = UIButton(type: .system)
            publishButton.setTitle("Publish", for: .normal)
            let normalImage = UIImage(color: .red, size: publishFrame.size)
            let highlightedImage = UIImage(color: .darkGray, size: publishFrame.size)
            publishButton.setBackgroundImage(normalImage, for: .normal)
            publishButton.setBackgroundImage(highlightedImage, for: .highlighted)
            publishButton.addTarget(target, action: action, for: .touchUpInside)
            rightView = publishButton
            rightViewMode = .unlessEditing
            returnKeyType = .send
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    internal lazy var customAccessoryView: PublishInputAccessoryView = {
        let bounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: 0, width: bounds.width, height: 50.0)
        let publishView = PublishInputAccessoryView(target: self, action: #selector(publishButtonTapped(sender:)), frame: frame)
        publishView.delegate = self
        return publishView
    }()
    
    // TODO: Clean this up for publish accessory view
    /*
    public override var inputAccessoryView: UIView? {
        return customAccessoryView
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
 */
    
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
        consoleCollectionView.backgroundColor = .white
        
        view.addSubview(clientCollectionView)
        clientCollectionView.forceAutoLayout()
        clientCollectionView.backgroundColor = .white
        
        let configurationYOffset = (UIApplication.shared.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 5.0
        clientCollectionView.contentInset = UIEdgeInsets(top: configurationYOffset, left: 0.0, bottom: 0.0, right: 0.0)
        
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
        let overrideBackgroundColor = UIColor.lightGray
        let subscribeItemType = ClientProperty.subscribe.generateStaticItemType(client: console.client, isTappable: true, overrideDefaultBackgroundColor: overrideBackgroundColor)
        let unsubscribeItemType = ClientProperty.unsubscribe.generateStaticItemType(client: console.client, isTappable: true, overrideDefaultBackgroundColor: overrideBackgroundColor)
        let streamFilterType = ClientProperty.streamFilter.generateStaticItemType(client: console.client, isTappable: true, overrideDefaultBackgroundColor: overrideBackgroundColor)
        
        let section0 = Section(items: pubKeyItemType, subKeyItemType)
        let section1 = Section(items: channelsItemType, channelGroupsItemType)
        let section2 = Section(items: streamFilterType)
        let section3 = Section(items: subscribeItemType, unsubscribeItemType)
        
        let dataSource = DataSource(sections: section0, section1, section2, section3)
        
        configurationDataSourceProvider = ClientCollectionView.generateDataSourceProvider(dataSource: dataSource)
        
        clientCollectionView.delegate = self
        
        clientCollectionView.dataSource = configurationDataSourceProvider.collectionViewDataSource
        
        func createKeyboardDismissRecognizer() -> UITapGestureRecognizer {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
            tapGestureRecognizer.cancelsTouchesInView = false
            return tapGestureRecognizer
        }
        
        clientCollectionView.addGestureRecognizer(createKeyboardDismissRecognizer())
        consoleCollectionView.addGestureRecognizer(createKeyboardDismissRecognizer())
        
        
        console.client.addListener(self)
        clientCollectionView.reloadData()
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.consoleCollectionView.predicate = ConsoleSegment.messages.consolePredicate
        }
 */
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        consoleCollectionView.contentInset = .zero
        consoleCollectionView.contentOffset = .zero
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    
    func publishButtonTapped(sender: UIButton) {
        publish()
    }
    
    // MARK: - Publish Action
    
    func publish() {
        // TODO: Should we show anything to the user if there is nothing to publish?
        guard let publishTextField = inputAccessoryView as? PublishInputAccessoryView else {
            fatalError("Expected to find text field")
        }
        publishTextField.resignFirstResponder()
        guard let message = publishTextField.text else {
            navigationItem.setPrompt(with: "There is nothing to publish")
            return
        }
        let alertController = UIAlertController.publishAlertController(withCurrent: message) { (action, channel) -> (Void) in
            // TODO: This should probably throw an error
            guard let actualChannel = channel else {
                self.navigationItem.setPrompt(with: "Must enter a channel to publish")
                return
            }
            self.console.publish(message, toChannel: actualChannel)
        }
        present(alertController, animated: true)
    }
    
    // MARK: - UI Updates
    
    func updateSubscribablesCells(client: PubNub) {
        clientCollectionView.performBatchUpdates({
            let client = self.console.client
            var updatedIndexPaths = [IndexPath]()
            if let updatedChannelsItemIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channels, with: client, isTappable: false) {
                updatedIndexPaths.append(updatedChannelsItemIndexPath)
            }
            if let updatedChannelGroupsItemIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .channelGroups, with: client, isTappable: false) {
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
            let selectedItem = clientUpdater.staticItem(from: configurationDataSourceProvider.dataSource, at: indexPath)
            guard selectedItem.isTappable == true else {
                return
            }
            guard let clientProperty = ClientProperty(staticItem: selectedItem) else {
                return
            }
            switch clientProperty {
            case .subscribe:
                let alertController = UIAlertController.subscribeAlertController(with: { (action, input) -> (Void) in
                    defer {
                        collectionView.deselectItem(at: indexPath, animated: true)
                    }
                    do {
                        guard let subscribablesArray = try PubNub.stringToSubscribablesArray(input) else {
                            return
                        }
                        switch action {
                        case .channels:
                            self.console.client.subscribeToChannels(subscribablesArray, withPresence: true)
                        case .channelGroups:
                            self.console.client.subscribeToChannelGroups(subscribablesArray, withPresence: true)
                        default:
                            return
                        }
                    } catch let userError as AlertControllerError {
                        // TODO: Implement error handling
                        let errorAlertController = UIAlertController.alertController(error: userError)
                        self.present(errorAlertController, animated: true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                })
                present(alertController, animated: true)
            case .unsubscribe:
                let alertController = UIAlertController.unsubscribeAlertController(with: { (action, input) -> (Void) in
                    defer {
                        collectionView.deselectItem(at: indexPath, animated: true)
                    }
                    
                    guard action != .all else {
                        self.console.client.unsubscribeFromAll()
                        return
                    }
                    do {
                        guard let subscribablesArray = try PubNub.stringToSubscribablesArray(input) else {
                            return
                        }
                        switch action {
                        case .channels:
                            self.console.client.unsubscribeFromChannels(subscribablesArray, withPresence: true)
                        case .channelGroups:
                            self.console.client.unsubscribeFromChannelGroups(subscribablesArray, withPresence: true)
                        default:
                            fatalError("Not expecting this kind of action")
                        }
                    } catch let userError as AlertControllerError {
                        // TODO: Implement error handling
                        let errorAlertController = UIAlertController.alertController(error: userError)
                        self.present(errorAlertController, animated: true)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                })
                present(alertController, animated: true)
            case .streamFilter:
                let alertController = UIAlertController.streamFilterAlertController(withCurrent: console.client.filterExpression, handler: { (action, input) -> (Void) in
                    defer {
                        collectionView.deselectItem(at: indexPath, animated: true)
                    }
                    defer {
                        print("ran defer \(#function)")
                        self.clientCollectionView.performBatchUpdates({ 
                            guard let updatedIndexPath = self.clientUpdater.update(dataSource: &self.configurationDataSourceProvider.dataSource, for: .streamFilter, with: self.console.client, isTappable: true) else {
                                return
                            }
                            self.clientCollectionView.reloadItems(at: [updatedIndexPath])
                            })
                    }
                    guard let actualInput = input else {
                        self.console.client.filterExpression = nil
                        return
                    }
                    self.console.client.filterExpression = actualInput
                })
                present(alertController, animated: true)
            default:
                return
            }
        default:
            print("other collection view tapped")
        }
    }

    // MARK: - UIScrollViewDelegate
    /*
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard(sender: scrollView)
    }
 */
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard(sender: scrollView)
    }
    
    // MARK: - PNObjectEventListener
    
    @objc(client:didReceiveStatus:)
    public func client(_ client: PubNub, didReceive status: PNStatus) {
        guard (status.operation == .subscribeOperation) || (status.operation == .unsubscribeOperation) else {
            return
        }
        updateSubscribablesCells(client: client)
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: textField)
        publish()
        return true
    }
    
    func dismissKeyboard(sender: Any) {
        inputAccessoryView?.resignFirstResponder()
    }
    
}
