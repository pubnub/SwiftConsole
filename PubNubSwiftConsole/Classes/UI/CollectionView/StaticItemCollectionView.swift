//
//  StaticItemCollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 10/14/16.
//
//

import UIKit
import JSQDataSourcesKit

enum StaticItemType {
    case staticItem(StaticItem)
    case title(Title)
    case titleContents(TitleContents)
    
    var staticItem: StaticItem {
        switch self {
        case let .title(aTitle):
            return aTitle
        case let .titleContents(aTitleContents):
            return aTitleContents
        case let .staticItem(aStaticItem):
            return aStaticItem
        }
    }
    
    var reuseIdentifier: String {
        switch self {
        case .title(_):
            return TitleCollectionViewCell.reuseIdentifier()
        case .titleContents(_):
            return TitleContentsCollectionViewCell.reuseIdentifier()
        default:
            fatalError()
        }
    }
    
    init(staticItem: StaticItem) {
        switch staticItem {
        case let staticItem as TitleContents:
            self = StaticItemType.titleContents(staticItem)
        case let staticItem as Title:
            self = StaticItemType.title(staticItem)
        default:
            self = StaticItemType.staticItem(staticItem)
        }
    }
}

struct StaticItemCellViewFactory: ReusableViewFactoryProtocol {
    typealias TitleViewFactory = ViewFactory<Title, TitleCollectionViewCell>
    typealias TitleContentsViewFactory = ViewFactory<TitleContents, TitleContentsCollectionViewCell>
    let titleCellFactory: TitleViewFactory
    let titleContentsCellFactory: TitleContentsViewFactory
    
    init(titleCellFactory: TitleViewFactory, titleContentsCellFactory: TitleContentsViewFactory) {
        self.titleCellFactory = titleCellFactory
        self.titleContentsCellFactory = titleContentsCellFactory
    }
    
    init() {
        let titleCellFactory = TitleViewFactory(reuseIdentifier: TitleCollectionViewCell.reuseIdentifier()) { (cell, model: Title?, type, collectionView, indexPath) -> TitleCollectionViewCell in
            cell.update(title: model)
            return cell
        }
        let titleContentsCellFactory = TitleContentsViewFactory(reuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier()) { (cell, model: TitleContents?, type, collectionView, indexPath) -> TitleContentsCollectionViewCell in
            cell.update(titleContents: model)
            return cell
        }
        self.init(titleCellFactory: titleCellFactory, titleContentsCellFactory: titleContentsCellFactory)
    }
    
    func reuseIdentiferFor(item: StaticItemType?, type: ReusableViewType, indexPath: IndexPath) -> String {
        return item!.reuseIdentifier
    }
    
    func configure(view: UICollectionViewCell, item: StaticItemType?, type: ReusableViewType, parentView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = item else {
            return view
        }
        switch model {
        case let .title(titleModel):
            let cell = view as! TitleCollectionViewCell
            return titleCellFactory.configure(view: cell, item: titleModel, type: type, parentView: parentView, indexPath: indexPath)
        case let .titleContents(titleContentsModel):
            let cell = view as! TitleContentsCollectionViewCell
            return titleContentsCellFactory.configure(view: cell, item: titleContentsModel, type: type, parentView: parentView, indexPath: indexPath)
        default:
            fatalError()
        }
    }
    
}

typealias TitleContentsHeaderViewFactory = TitledSupplementaryViewFactory<StaticItemType>
typealias StaticSection = Section<StaticItemType>
typealias StaticDataSource = DataSource<StaticSection>
typealias StaticDataSourceProvider = DataSourceProvider<StaticDataSource, StaticItemCellViewFactory, TitleContentsHeaderViewFactory>

protocol StaticDataSourceUpdater {
    // if indexPath is nil then no update occurred
    func update(dataSource: inout StaticDataSource, at indexPath: IndexPath, with item: StaticItemType, isTappable: Bool) -> IndexPath?
}

class StaticItemCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override required init() {
        super.init()
        itemSize = TitleContentsCollectionViewCell.size
        minimumLineSpacing = 20.0
        minimumInteritemSpacing = 20.0
        estimatedItemSize = TitleContentsCollectionViewCell.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StaticItemCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.reuseIdentifier())
        register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func generateHeaderFactory() -> TitleContentsHeaderViewFactory {
        return TitledSupplementaryViewFactory { (header, model: StaticItemType?, kind, collectionView, indexPath) -> TitledSupplementaryView in
            
            header.label.text = "Section \(indexPath.section)"
            header.backgroundColor = .darkGray
            header.label.textColor = .white
            return header
        }
    }
    
    class func generateDataSourceProvider(dataSource: StaticDataSource, cellFactory: StaticItemCellViewFactory = StaticItemCellViewFactory()) -> StaticDataSourceProvider {
        let headerFactory = generateHeaderFactory()
        return DataSourceProvider(dataSource: dataSource, cellFactory: cellFactory, supplementaryFactory: headerFactory)
    }

}
