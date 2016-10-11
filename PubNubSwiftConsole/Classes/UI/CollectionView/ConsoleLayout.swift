//
//  ConsoleLayout.swift
//  Pods
//
//  Created by Jordan Zucker on 10/10/16.
//
//

import UIKit
import CoreData

protocol ConsoleDataSource: class {
    func consoleView(_ consoleView: ConsoleCollectionView, numberOfItemsInConfigurationSection subSection: Int) -> Int
    
    func numberOfSectionsInConfigurationSection(in consoleView: ConsoleCollectionView) -> Int
    
    func consoleView(_ consoleView: ConsoleCollectionView, configure cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    var coreDataSection: Int? { get }
    
    func consoleView(_ consoleView: ConsoleCollectionView, reuseIdentifierForConfigurationItemAt indexPath: IndexPath) -> String
}

protocol ConsoleLayoutDelegate: UICollectionViewDelegateFlowLayout {
    
}

protocol ConsoleDelegate: class {
    func consoleView(_ consoleView: ConsoleCollectionView, didSelectConfigurationItemAt indexPath: IndexPath)
    func consoleView(_ consoleView: ConsoleCollectionView, didSelect result: Result)
}

final class ConsoleCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    weak var consoleDataSource: ConsoleDataSource?
    weak var consoleDelegate: ConsoleDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.reuseIdentifier())
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var viewContext: NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Result> = {
        guard let existingViewContext = self.viewContext else {
            fatalError()
        }
        let allResultsFetchRequest: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: allResultsFetchRequest, managedObjectContext: existingViewContext, sectionNameKeyPath: nil, cacheName: nil)
        creatingFetchedResultsController.delegate = self
        return creatingFetchedResultsController
    }()
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        print(#function)
        guard let currentDataSource = consoleDataSource else {
            return
        }
        switch indexPath.section {
        case let coreDataSection as Int where (currentDataSource.coreDataSection != nil) && (indexPath.section == currentDataSource.coreDataSection!):
            guard let resultCell = cell as? ResultCollectionViewCell else {
                fatalError()
            }
            var adjustedIndexPath = indexPath
            // need to adjust the indexPath section to match the fetched results controller
            adjustedIndexPath.section = 0
            let result = fetchedResultsController.object(at: adjustedIndexPath)
            // Populate cell from the NSManagedObject instance
            resultCell.update(result: result)
        default:
            currentDataSource.consoleView(self, configure: cell, forItemAt: indexPath)
        }
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override func reloadData() {
        super.reloadData() // is this necessary?
        performFetch()
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentDataSource = consoleDataSource else {
            return 0
        }
        switch section {
        case let coreDataSection as Int where (currentDataSource.coreDataSection != nil) && (section == currentDataSource.coreDataSection!):
            guard let onlySectionInfo = fetchedResultsController.sections?.first else {
                fatalError("No sections in fetchedResultsController")
            }
            return onlySectionInfo.numberOfObjects
        default:
            return currentDataSource.consoleView(self, numberOfItemsInConfigurationSection: section)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let currentDataSource = consoleDataSource else {
            return 0
        }
        var totalSections = currentDataSource.numberOfSectionsInConfigurationSection(in: self)
        if let _ = currentDataSource.coreDataSection {
            return totalSections + 1
        } else {
            return totalSections
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentDataSource = consoleDataSource else {
            fatalError()
        }
        var reuseIdentifier: String
        switch indexPath.section {
        case let coreDataSection as Int where (currentDataSource.coreDataSection != nil) && (indexPath.section == currentDataSource.coreDataSection!):
            reuseIdentifier = ResultCollectionViewCell.reuseIdentifier()
        default:
            reuseIdentifier = currentDataSource.consoleView(self, reuseIdentifierForConfigurationItemAt: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentDataSource = consoleDataSource else {
            fatalError()
        }
        switch indexPath.section {
        case let coreDataSection as Int where (currentDataSource.coreDataSection != nil) && (indexPath.section == currentDataSource.coreDataSection!):
            var adjustedIndexPath = indexPath
            adjustedIndexPath.section = 0
            let selectedResult = fetchedResultsController.object(at: adjustedIndexPath)
            consoleDelegate?.consoleView(self, didSelect: selectedResult)
        default:
            consoleDelegate?.consoleView(self, didSelectConfigurationItemAt: indexPath)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let currentDataSource = consoleDataSource, let coreDataSection = currentDataSource.coreDataSection else {
            return
        }
        performBatchUpdates({
            switch type {
            case .insert:
                self.insertSections(IndexSet(integer: coreDataSection))
            case .delete:
                self.deleteSections(IndexSet(integer: coreDataSection))
            case .move:
                break
            case .update:
                break
            }
        })
        
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let currentDataSource = consoleDataSource, let coreDataSection = currentDataSource.coreDataSection else {
            return
        }
        var adjustedIndexPath = indexPath
        var adjustedNewIndexPath = newIndexPath
        adjustedIndexPath?.section = coreDataSection
        adjustedNewIndexPath?.section = coreDataSection
        performBatchUpdates({
            switch type {
            case .insert:
                self.insertItems(at: [adjustedNewIndexPath!])
            case .delete:
                self.deleteItems(at: [adjustedIndexPath!])
            case .update:
                guard let cell = self.cellForItem(at: adjustedIndexPath!) else {
                    fatalError()
                }
                self.configureCell(cell: cell, indexPath: adjustedIndexPath!)
            case .move:
                self.moveItem(at: adjustedIndexPath!, to: adjustedNewIndexPath!)
            }
        })
    }
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
