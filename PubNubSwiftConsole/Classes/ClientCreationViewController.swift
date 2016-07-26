//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public class ClientCreationViewController: CollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Data Source
    private struct ClientDataSection {
        var items: [LabelItem]
        subscript(index: Int) -> LabelItem {
            get {
                return items[index]
            }
            
            set {
                items[index] = newValue
            }
        }
        var count: Int {
            return items.count
        }
    }
    
    private struct ClientDataSource {
        var sections = [ClientDataSection(items: [LabelItem(titleString: "Pub Key", contentsString: "demo-36")])]
        subscript(index: Int) -> ClientDataSection {
            get {
                return sections[index]
            }
            
            set {
                sections[index] = newValue
            }
        }
        subscript(indexPath: NSIndexPath) -> LabelItem {
            get {
                return self[indexPath.section][indexPath.row]
            }
            set {
                self[indexPath.section][indexPath.row] = newValue
            }
        }
        
        var count: Int {
            return sections.count
        }
    }
    
    private var dataSource = ClientDataSource()
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Actions
    
    func closeButtonPressed(sender: UIBarButtonItem!) {
        var navController = self.navigationController as? NavigationController
        navController?.close()
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LabelCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as? LabelCollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        let indexedLabelItem = dataSource[indexPath]
        cell.updateLabels(indexedLabelItem)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? LabelCollectionViewCell else {
            fatalError("Failed to create collection view cell properly, please contact support@pubnub.com")
        }
        
        var selectedLabelItem = dataSource[indexPath]
        let alertController = UIAlertController.labelCellContentsUpdateAlertController(selectedLabelItem) { (action, updatedContentsString) in
            if (action.title == "OK") { // eventually hard code this into an enum
                if let unwrappedUpdatedContentsString = updatedContentsString {
                    selectedLabelItem.contentsString = unwrappedUpdatedContentsString
                    self.dataSource[indexPath] = selectedLabelItem
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UINavigationItem
    public override var navigationItem: UINavigationItem {
        let navigationItem = UINavigationItem(title: "Create PubNub Client")
        let closeButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(self.closeButtonPressed(_:)))
        navigationItem.rightBarButtonItem = closeButton
        return navigationItem
    }
}
