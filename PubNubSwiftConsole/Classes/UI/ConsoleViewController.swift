//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit
import CoreData

open class ConsoleViewController: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    let console: SwiftConsole
    let collectionView: UICollectionView
    
    lazy var fetchedResultsController: NSFetchedResultsController<Result> = {
        let allResultsFetchRequest: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: allResultsFetchRequest, managedObjectContext: self.console.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        creatingFetchedResultsController.delegate = self
        return creatingFetchedResultsController
    }()
    
    public required init(console: SwiftConsole) {
        let bounds = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = ResultCollectionViewCell.size
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.console = console
        super.init()
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.forceAutoLayout()
        collectionView.backgroundColor = UIColor.red
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
        collectionView.register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.reuseIdentifier())
        //collectionView.register(TitleContentsCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
        //tableView.rowHeight = ResultTableViewCell.height
        let views = [
            "collectionView": collectionView,
        ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.view.setNeedsLayout()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        guard let resultCell = cell as? ResultCollectionViewCell else {
            fatalError()
        }
        let result = fetchedResultsController.object(at: indexPath)
        // Populate cell from the NSManagedObject instance
        resultCell.update(result: result)
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            guard let onlySectionInfo = fetchedResultsController.sections?.first else {
                fatalError("No sections in fetchedResultsController")
            }
            return onlySectionInfo.numberOfObjects
        default:
            fatalError("Can't handle this")
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        /*
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
 */
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier(), for: indexPath) as? TitleContentsCollectionViewCell else {
                fatalError("Unexpected cell type")
            }
            cell.update(title: "Channels", contents: "a, c")
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultCollectionViewCell.reuseIdentifier(), for: indexPath)
            var adjustedIndexPath = indexPath
            adjustedIndexPath.section -= 1
            configureCell(cell: cell, indexPath: adjustedIndexPath)
            return cell
        default:
            fatalError("Can't handle section 3")
        }
        /*
        var adjustedIndexPath = indexPath
        adjustedIndexPath.section += 1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultCollectionViewCell.reuseIdentifier(), for: adjustedIndexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
 */
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier(), for: indexPath) as? TitleContentsCollectionViewCell else {
                fatalError("Can't handle other types right now")
            }
            cell.update(title: "Channels", contents: "1")
            return cell
        default:
            fatalError("Can't deal with anything else but headers")
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Change channel", message: "Enter new channels, or remove some, comma separated", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter channels ..."
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let textFieldText = alertController.textFields?[0].text else {
                return
            }
            self.console.client.subscribeToChannels([textFieldText], withPresence: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
        
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        collectionView.performBatchUpdates({ 
            switch type {
            case .insert:
                var adjustedSectionIndex = sectionIndex
                adjustedSectionIndex += 1
                self.collectionView.insertSections(IndexSet(integer: adjustedSectionIndex))
            case .delete:
                var adjustedSectionIndex = sectionIndex
                adjustedSectionIndex += 1
                self.collectionView.deleteSections(IndexSet(integer: adjustedSectionIndex))
            case .move:
                break
            case .update:
                break
            }
            })
        
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var adjustedIndexPath = indexPath
        adjustedIndexPath?.section += 1
        var adjustedNewIndexPath = newIndexPath
        adjustedNewIndexPath?.section += 1
        collectionView.performBatchUpdates({ 
            switch type {
            case .insert:
                self.collectionView.insertItems(at: [adjustedNewIndexPath!])
            case .delete:
                self.collectionView.deleteItems(at: [adjustedIndexPath!])
            case .update:
                guard let cell = self.collectionView.cellForItem(at: adjustedIndexPath!) else {
                    fatalError()
                }
                self.configureCell(cell: cell, indexPath: adjustedIndexPath!)
            case .move:
                self.collectionView.moveItem(at: adjustedIndexPath!, to: adjustedNewIndexPath!)
            }
            })
    }

}
