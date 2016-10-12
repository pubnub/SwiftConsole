//
//  ConsoleCollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 10/12/16.
//
//

import UIKit
import CoreData
import JSQDataSourcesKit

typealias ConsoleCellFactory = ViewFactory<Result, ResultCollectionViewCell>
typealias ConsoleHeaderViewFactory = TitledSupplementaryViewFactory<Result>
typealias PubNubFRC = FetchedResultsController<Result>

class ConsoleCollectionView: UICollectionView {
    
    let cacheName = "Test"

    var consoleDataSourceProvider: DataSourceProvider<FetchedResultsController<Result>, ConsoleCellFactory, ConsoleHeaderViewFactory>!
    
    var consoleDelegateProvider: FetchedResultsDelegateProvider<ConsoleCellFactory>!
    
    lazy var fetchedResultsController: PubNubFRC = {
        let allResultsFetchRequest: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let controller = PubNubFRC(fetchRequest: allResultsFetchRequest, managedObjectContext: self.console.viewContext, sectionNameKeyPath: #keyPath(Result.creationDate), cacheName: nil)
        assert(self.consoleDelegateProvider != nil, "Console Delegate Provider must exist")
        controller.delegate = self.consoleDelegateProvider.collectionDelegate
        return controller
    }()
    
    func fetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    let console: SwiftConsole
    
    var predicate: NSPredicate? {
        
        willSet {
            //PubNubFRC.deleteCache(withName: cacheName)
        }
        
        didSet {
            fetchedResultsController.fetchRequest.predicate = predicate
            fetch()
        }
    }
    
    required init(frame: CGRect = .zero, console: SwiftConsole, predicate: NSPredicate? = nil) {
        self.predicate = predicate
        let bounds = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = ResultCollectionViewCell.size
        layout.estimatedItemSize = ResultCollectionViewCell.size
        //layout.headerReferenceSize = CGSize(width: bounds.width, height: 50.0)
        self.console = console
        
        let cellFactory = ViewFactory(reuseIdentifier: ResultCollectionViewCell.reuseIdentifier()) { (cell, model: Result?, type, collectionView, indexPath) -> ResultCollectionViewCell in
            cell.update(result: model)
            return cell
        }
        
        let headerFactory = TitledSupplementaryViewFactory { (header, model: Result?, kind, collectionView, indexPath) -> TitledSupplementaryView in
            if let creationDate = model?.creationDate {
                header.label.text = "\(creationDate)"
            } else {
                header.label.text = "No date"
            }
            header.backgroundColor = .darkGray
            return header
        }
        super.init(frame: frame, collectionViewLayout: layout)
        register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.reuseIdentifier())
        register(TitledSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TitledSupplementaryView.identifier)
        self.consoleDelegateProvider = FetchedResultsDelegateProvider(cellFactory: cellFactory, collectionView: self)
        self.consoleDataSourceProvider = DataSourceProvider(dataSource: fetchedResultsController, cellFactory: cellFactory, supplementaryFactory: headerFactory)
        self.dataSource = consoleDataSourceProvider.collectionViewDataSource
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        fetch()
    }

}
