//
//  PNCCollectionViewFlowLayout.swift
//  Pods
//
//  Created by Jordan Zucker on 7/17/16.
//
//

import Foundation

class PNCCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    public required override init() {
        let screenBounds = UIScreen.mainScreen().bounds
        let screenWidth = screenBounds.size.width
        super.init()
        self.sectionInset = UIEdgeInsets(top: 40, left: 1, bottom: 10, right: 1)
        self.itemSize = CGSize(width: (screenWidth/2) - 2, height: (screenWidth/2) - 2)
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
