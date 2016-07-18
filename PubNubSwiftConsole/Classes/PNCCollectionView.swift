//
//  PNCCollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

class PNCCollectionView: UICollectionView {
    init() {
        let screenFrame = UIScreen.mainScreen().bounds
        let layout = PNCCollectionViewFlowLayout()
        super.init(frame: screenFrame, collectionViewLayout: layout)
        self.registerClass(PNCLabelCollectionViewCell.self, forCellWithReuseIdentifier: PNCLabelCollectionViewCell.reuseIdentifier())
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("required init")
        fatalError("init(coder:) has not been implemented")
    }
    
}
