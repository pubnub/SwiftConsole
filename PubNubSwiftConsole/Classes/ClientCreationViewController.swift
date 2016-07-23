//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation


public class ClientCreationViewController: CollectionViewController, UICollectionViewDataSource {
    // MARK: Data Source
    private struct ClientDataSection {
        var items: [LabelItem]
        subscript(index: Int) -> LabelItem {
            return items[index]
        }
        var count: Int {
            return items.count
        }
    }
    
    private struct ClientDataSource {
        let sections = [ClientDataSection(items: [LabelItem(titleString: "Pub Key", contentsString: "demo-36")])]
        subscript(index: Int) -> ClientDataSection {
            return sections[index]
        }
        subscript(indexPath: NSIndexPath) -> LabelItem {
            return self[indexPath.section][indexPath.row]
        }
        var count: Int {
            return sections.count
        }
    }
    
    private let dataSource = ClientDataSource()
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.dataSource = self
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
}
