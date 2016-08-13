//
//  TitleContentsCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

protocol TitleContentsItem: Item {
    var contents: String {get set}
}

extension TitleContentsItem {
    var title: String {
        return itemType.title
    }
}

protocol UpdatableTitleContentsItem: TitleContentsItem {
    var contents: String {get set}
    var defaultContents: String {get}
    var alertControllerTitle: String? {get}
    var alertControllerTextFieldValue: String? {get}
    mutating func updateContents(updatedContents: String?)
}

extension UpdatableTitleContentsItem {
    var defaultContents: String {
        return itemType.defaultValue
    }
    var alertControllerTitle: String? {
        return title
    }
    var alertControllerTextFieldValue: String? {
        return contents
    }
    mutating func updateContents(updatedContents: String?) {
        self.contents = updatedContents ?? defaultContents
    }
}

extension ItemSection {
    mutating func updateTitleContents(item: Int, updatedContents: String?) {
        guard var selectedLabelItem = self[item] as? UpdatableTitleContentsItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedLabelItem.updateContents(updatedContents: updatedContents)
        self[item] = selectedLabelItem
    }
    mutating func updateTitleContents(itemType: ItemType, updatedContents: String?) {
        updateTitleContents(item: itemType.item, updatedContents: updatedContents)
    }
}

extension DataSource {
    func updateTitleContents(indexPath: IndexPath, updatedContents: String?) {
        guard var selectedItem = self[indexPath] as? UpdatableTitleContentsItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedItem.updateContents(updatedContents: updatedContents)
        self[indexPath] = selectedItem
    }
    func updateTitleContents(itemType: ItemType, updatedContents: String?) {
        updateTitleContents(indexPath: itemType.indexPath as IndexPath, updatedContents: updatedContents)
    }
}

extension UIAlertController {
    enum ItemAction: String {
        case OK, Cancel
    }
    static func updateItemWithAlertController(selectedItem: UpdatableTitleContentsItem?, completionHandler: ((UIAlertAction, String?) -> Void)? = nil) -> UIAlertController {
        guard let item = selectedItem else {
            fatalError()
        }
        // TODO: use optionals correctly instead of forced unwrapping
        let alertController = UIAlertController(title: item.alertControllerTitle!, message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = item.alertControllerTextFieldValue!
        })
        alertController.addAction(UIAlertAction(title: ItemAction.OK.rawValue, style: .default, handler: { (action) -> Void in
            let updatedContentsString = alertController.textFields?[0].text
            completionHandler?(action, updatedContentsString)
        }))
        alertController.addAction(UIAlertAction(title: ItemAction.Cancel.rawValue, style: .default, handler: { (action) in
            completionHandler?(action, nil)
        }))
        alertController.view.setNeedsLayout() // workaround: https://forums.developer.apple.com/thread/18294
        return alertController
    }
}

final class TitleContentsCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let contentsLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        self.titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/2))
        self.contentsLabel = UILabel(frame: CGRect(x: 5, y: frame.size.height/2, width: frame.size.width, height: frame.size.height/2))
        
        super.init(frame: frame)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubview(titleLabel)
        
        contentsLabel.textAlignment = .center
        contentsLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubview(contentsLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabels(item: TitleContentsItem) {
        titleLabel.text = item.title
        contentsLabel.text = item.contents
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let labelItem = item as? TitleContentsItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(item: labelItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 150.0, height: 125.0)
    }
}
