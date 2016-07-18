//
//  PNCCollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

class PNCCollectionView: UICollectionView {
    
    public required override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        assert((layout is PNCCollectionViewFlowLayout), "How dare you use anything but PNCCollectionViewFlowLayout: \(layout)")
        super.init(frame: frame, collectionViewLayout: layout)
        self.registerClass(PNCLabelCollectionViewCell.self, forCellWithReuseIdentifier: PNCLabelCollectionViewCell.reuseIdentifier())
        self.backgroundColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
