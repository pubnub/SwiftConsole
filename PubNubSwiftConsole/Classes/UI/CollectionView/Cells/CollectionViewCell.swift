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
    
    static var reuseIdentifier: String {
//        return String(describing: type(of: self))
        return NSStringFromClass(self)
    }
    
    func updateCell(item: Item) {
        // override in subclass, this used by the generic collection view subclass
    }
    
    func setUpInitialConstraints() {
        // override in subclass
    }
    
    class func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 300.0, height: 100.0)
    }
}
