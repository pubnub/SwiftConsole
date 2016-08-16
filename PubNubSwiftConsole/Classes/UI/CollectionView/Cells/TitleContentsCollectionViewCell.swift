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
        selectedLabelItem.updateContents(updatedContents)
        self[item] = selectedLabelItem
    }
    mutating func updateTitleContents(itemType: ItemType, updatedContents: String?) {
        updateTitleContents(itemType.item, updatedContents: updatedContents)
    }
}

extension DataSource {
    func updateTitleContents(indexPath: NSIndexPath, updatedContents: String?) {
        guard var selectedItem = self[indexPath] as? UpdatableTitleContentsItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedItem.updateContents(updatedContents)
        self[indexPath] = selectedItem
    }
    func updateTitleContents(itemType: ItemType, updatedContents: String?) {
        updateTitleContents(itemType.indexPath, updatedContents: updatedContents)
    }
}

extension UIAlertController {
    enum ItemAction: String {
        case OK, Cancel
    }
    static func updateItemWithAlertController(selectedItem: UpdatableTitleContentsItem?, completionHandler: ((UIAlertAction, String?) -> ())) -> UIAlertController {
        guard let item = selectedItem else {
            fatalError()
        }
        // TODO: use optionals correctly instead of forced unwrapping
        let alertController = UIAlertController(title: item.alertControllerTitle!, message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = item.alertControllerTextFieldValue!
        })
        alertController.addAction(UIAlertAction(title: ItemAction.OK.rawValue, style: .Default, handler: { (action) -> Void in
            let updatedContentsString = alertController.textFields?[0].text
            completionHandler(action, updatedContentsString)
        }))
        alertController.addAction(UIAlertAction(title: ItemAction.Cancel.rawValue, style: .Default, handler: { (action) in
            completionHandler(action, nil)
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
        titleLabel = UILabel(frame: CGRectZero)
        contentsLabel = UILabel(frame: CGRectZero)
        
        super.init(frame: frame)
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contentView.addSubview(titleLabel)
        
        contentsLabel.textAlignment = .Center
        contentsLabel.lineBreakMode = .ByCharWrapping
        contentsLabel.numberOfLines = 2
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contentView.addSubview(contentsLabel)
        contentView.layer.borderWidth = 3
        
        let titleLabelXConstraint = NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let contentsLabelXConstraint = NSLayoutConstraint(item: contentsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let views = [
            "titleLabel" : titleLabel,
            "contentsLabel" : contentsLabel
        ]
        let metrics = [
            "spacer" : NSNumber(integer: 5),
            "titleHeight" : NSNumber(integer: 30),
            "contentsHeight": NSNumber(integer: 40),
        ]
        let titleLabelWidthContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[titleLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let contentsLabelWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-spacer-[contentsLabel]-spacer-|", options: [], metrics: metrics, views: views)
        let labelsYConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacer-[titleLabel(titleHeight)]-spacer-[contentsLabel(>=contentsHeight)]-spacer-|", options: [], metrics: metrics, views: views)
        contentView.addConstraint(titleLabelXConstraint)
        contentView.addConstraint(contentsLabelXConstraint)
        contentView.addConstraints(labelsYConstraints)
        contentView.addConstraints(titleLabelWidthContraints)
        contentView.addConstraints(contentsLabelWidthConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabels(labelItem: TitleContentsItem) {
        self.titleLabel.text = labelItem.title
        self.contentsLabel.text = labelItem.contents
        
    }
    
    override func updateCell(item: Item) {
        guard let labelItem = item as? TitleContentsItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(labelItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 150.0, height: 125.0)
    }
}
