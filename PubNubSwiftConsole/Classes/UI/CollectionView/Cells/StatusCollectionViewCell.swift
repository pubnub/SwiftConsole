//
//  StatusCollectionViewCell.swift
//  Pods
//
//  Created by Keith Martin on 8/1/16.
//
//

import Foundation

protocol StatusItem: Item {
    var contents: String {get set}
    var defaultContents: String {get}
    mutating func updateContentsString(updatedContents: String?)
}

extension StatusItem {
    mutating func updateContentsString(updatedContents: String?) {
        self.contents = updatedContents ?? defaultContents
    }
    var title: String {
        return itemType.title
    }
    var defaultContents: String {
        return itemType.defaultValue
    }
}

extension ItemSection {
    mutating func updateStatusContentsString(item: Int, updatedContents: String?) {
        guard var selectedLabelItem = self[item] as? StatusItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedLabelItem.updateContentsString(updatedContents)
        self[item] = selectedLabelItem
    }
}

extension DataSource {
    mutating func updateStatusContentsString(indexPath: NSIndexPath, updatedContents: String?) {
        guard var selectedItem = self[indexPath] as? StatusItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedItem.updateContentsString(updatedContents)
        self[indexPath] = selectedItem
    }
}


class StatusCollectionViewCell: CollectionViewCell {
    
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
    
    func updateLabels(item: StatusItem) {
        self.titleLabel.text = item.title
        self.contentsLabel.text = item.contents
        self.setNeedsLayout() // make sure this occurs during the next update cycle
    }
    
    override func updateCell(item: Item) {
        guard let statusItem = item as? StatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(statusItem)
    }
    
}