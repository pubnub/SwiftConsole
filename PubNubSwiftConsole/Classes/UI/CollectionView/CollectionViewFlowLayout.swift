//
//  CollectionViewFlowLayout.swift
//  Pods
//
//  Created by Jordan Zucker on 7/17/16.
//
//

import Foundation

class CollectionViewFlowLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {  
    
    let screenBounds: CGRect
    let screenWidth: CGFloat
    
    public required override init() {
        screenBounds = UIScreen.mainScreen().bounds
        screenWidth = screenBounds.size.width
        super.init()
        self.sectionInset = UIEdgeInsets(top: 40, left: 1, bottom: 10, right: 1)
        //self.itemSize = CGSize(width: (screenWidth/2) - 2, height: (screenWidth/2) - 2)
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? LabelCollectionViewCell {
            return CGSize(width: (screenWidth/2) - 2, height: (screenWidth/2) - 2)
        } else if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ButtonCollectionViewCell {
            return CGSize(width: 300, height: 300)
        }
        return CGSize(width: 100, height: 100)
    }
}
