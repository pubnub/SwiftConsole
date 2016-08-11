//
//  CollectionViewFlowLayout.swift
//  Pods
//
//  Created by Jordan Zucker on 7/17/16.
//
//

import Foundation

@objc(PNCCollectionViewFlowLayout)
class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    required override init() {
        super.init()
        self.sectionInset = UIEdgeInsets(top: 40, left: 0, bottom: 10, right: 0)
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
