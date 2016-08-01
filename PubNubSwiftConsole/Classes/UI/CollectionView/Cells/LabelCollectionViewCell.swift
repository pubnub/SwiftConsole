//
//  LabelCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

protocol LabelItem: Item {
    var contents: String {get set}
    var defaultContents: String {get}
    var alertControllerTitle: String? {get}
    var alertControllerTextFieldValue: String? {get}
    mutating func updateContentsString(updatedContents: String?)
}

extension LabelItem {
    mutating func updateContentsString(updatedContents: String?) {
        self.contents = updatedContents ?? defaultContents
    }
    var defaultContents: String {
        return itemType.defaultValue
    }
    var title: String {
        return itemType.title
    }
    var alertControllerTitle: String? {
        return title
    }
    var alertControllerTextFieldValue: String? {
        return contents
    }
}

extension ItemSection {
    mutating func updateLabelContentsString(item: Int, updatedContents: String?) {
        guard var selectedLabelItem = self[item] as? LabelItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedLabelItem.updateContentsString(updatedContents)
        self[item] = selectedLabelItem
    }
}

extension DataSource {
    mutating func updateLabelContentsString(indexPath: NSIndexPath, updatedContents: String?) {
        guard var selectedItem = self[indexPath] as? LabelItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedItem.updateContentsString(updatedContents)
        self[indexPath] = selectedItem
    }
}

extension UIAlertController {
    enum ItemAction: String {
        case OK, Cancel
    }
    class func updateItemWithAlertController(selectedItem: LabelItem?, completionHandler: ((UIAlertAction, String?) -> ())) -> UIAlertController {
        guard let item = selectedItem else {
            fatalError()
        }
        // TODO: use optionals correctly instead of forced unwrapping
        let alertController = UIAlertController(title: item.alertControllerTitle!, message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = item.alertControllerTextFieldValue!
        })
        alertController.addAction(UIAlertAction(title: ItemAction.OK.rawValue, style: .Default, handler: { (action) -> Void in
            var updatedContentsString = alertController.textFields?[0].text
            completionHandler(action, updatedContentsString)
        }))
        alertController.addAction(UIAlertAction(title: ItemAction.Cancel.rawValue, style: .Default, handler: { (action) in
            completionHandler(action, nil)
        }))
        alertController.view.setNeedsLayout() // workaround: https://forums.developer.apple.com/thread/18294
        return alertController
    }
}

class LabelCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let contentsLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
        contentsLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.size.height, width: frame.size.width, height: frame.size.height/3))
    
        super.init(frame: frame)
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        contentsLabel.textAlignment = .Center
        contentsLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsLabel.numberOfLines = 3
        contentView.addSubview(contentsLabel)
        
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabels(item: LabelItem) {
        self.titleLabel.text = item.title
        self.contentsLabel.text = item.contents
        self.setNeedsLayout() // make sure this occurs during the next update cycle
    }
    
    override func updateCell(item: Item) {
        guard let labelItem = item as? LabelItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(labelItem)
    }
}
