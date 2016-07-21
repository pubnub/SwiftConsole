//
//  PNCClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public class PNCClientCreationViewController: PNCCollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
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
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PNCLabelCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as? PNCLabelCollectionViewCell else {
            fatalError("Failed to dequeue cell properly, please contact support@pubnub.com")
        }
        let indexedLabelItem = dataSource[indexPath]
        cell.updateLabels(indexedLabelItem)
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PNCLabelCollectionViewCell else { return }
//        guard cell.contentsLabel.text != nil else { return }
//        presentEditFieldsAlertController(cell.contentsLabel.text!)
    }
    
    public func presentEditFieldsAlertController(contentFieldText: String) {
        var alert = UIAlertController(title: "Edit publish key", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = contentFieldText
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
