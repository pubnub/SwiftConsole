//
//  CollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit

@objc(PNCCollectionViewCell)
public class CollectionViewCell: UICollectionViewCell {
    class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    func updateCell(item: Item) {
        // override in subclass, this used by the generic collection view subclass
    }
}
