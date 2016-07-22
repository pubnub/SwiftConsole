//
//  CollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

class CollectionView: UICollectionView {
    
    public required override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        assert((layout is CollectionViewFlowLayout), "How dare you use anything but CollectionViewFlowLayout: \(layout)")
        super.init(frame: frame, collectionViewLayout: layout)
        self.registerClass(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier())
        self.backgroundColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
