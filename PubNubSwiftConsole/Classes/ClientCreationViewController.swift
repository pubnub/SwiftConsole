//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public class ClientCreationViewController: CollectionViewController, UICollectionViewDataSource {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.dataSource = self
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LabelCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as? LabelCollectionViewCell else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LabelCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as UICollectionViewCell
            return cell
        }
        cell.titleLabel.text = "Publish Key"
        cell.contentsLabel.text = "pub-c-63c972fb-df4e-47f7-82da-e659e28f7cb7"
        return cell
    }
}
