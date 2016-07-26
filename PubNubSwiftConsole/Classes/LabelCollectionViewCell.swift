//
//  LabelCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

struct LabelItem {
    let titleString: String
    var contentsString: String
}

extension UIAlertController {
    enum LabelItemAction: String {
        case OK, Cancel
    }
    class func labelCellContentsUpdateAlertController(selectedLabelItem: LabelItem, completionHandler: ((UIAlertAction, String?) -> ())) -> UIAlertController {
        let alertController = UIAlertController(title: "Edit publish key", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = selectedLabelItem.contentsString
        })
        alertController.addAction(UIAlertAction(title: LabelItemAction.OK.rawValue, style: .Default, handler: { (action) -> Void in
            var updatedContentsString = alertController.textFields?[0].text
            completionHandler(action, updatedContentsString)
        }))
        alertController.addAction(UIAlertAction(title: LabelItemAction.Cancel.rawValue, style: .Default, handler: { (action) in
            completionHandler(action, nil)
        }))
        alertController.view.setNeedsLayout() // workaround: https://forums.developer.apple.com/thread/18294
        return alertController
    }
}

class LabelCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let contentsLabel: UILabel
    
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
        self.titleLabel.text = item.titleString
        self.contentsLabel.text = item.contentsString
        self.setNeedsLayout() // make sure this occurs during the next update cycle
    }
}
