//
//  PNCCollectionViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation

public class PNCCollectionViewController: PNCViewController {
    var collectionView: PNCCollectionView?
    
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public required init() {
        super.init()
    }
    
    public override func loadView() {
        super.loadView()
        let layout = PNCCollectionViewFlowLayout()
        self.collectionView = PNCCollectionView(frame: self.view.frame, collectionViewLayout: layout)
        guard let pubNubCollectionView = self.collectionView else {
            fatalError("We expected to have a collection view by now. Please contact support@pubnub.com")
        }
        self.view.addSubview(pubNubCollectionView)
    }
}
