//
//  ConsoleLayout.swift
//  Pods
//
//  Created by Jordan Zucker on 10/10/16.
//
//

import UIKit

protocol ConsoleDataSource: class {
    func consoleView(_ consoleView: ConsoleCollectionView, numberOfItemsInConfigurationSection subSection: Int) -> Int
    
    func numberOfSectionsInConfigurationSection(in consoleView: ConsoleCollectionView) -> Int
    
    func consoleView(_ consoleView: ConsoleCollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    var coreDataSection: Int? { get }
    
    func consoleView(_ consoleView: ConsoleCollectionView, reuseIdentifierforItemAt indexPath: IndexPath) -> String
}

protocol ConsoleLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
}

protocol ConsoleDelegate: class {
    func consoleView(_ consoleView: ConsoleCollectionView, didSelectItemAt indexPath: IndexPath)
    func consoleView(_ consoleView: ConsoleCollectionView, didSelect result: Result)
}

class ConsoleLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.scrollDirection = .vertical
        self.itemSize = ResultCollectionViewCell.size
        self.estimatedItemSize = ResultCollectionViewCell.size
        //self.minimumLineSpacing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    override func prepare() {
        super.prepare()
        
    }
    
    override var collectionViewContentSize: CGSize {
        let initialSize = super.collectionViewContentSize
        collectionViewContentSize.height + 200.0
        return collectionViewContentSize
    }
 */
    
}
