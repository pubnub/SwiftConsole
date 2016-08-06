//
//  KeyCollectionViewCell.swift
//  Pods
//
//  Created by Keith Martin on 8/5/16.
//
//

import Foundation

protocol LabelItem: Item {
    var contents: String {get}
}

extension LabelItem {
    var title: String {
        return itemType.title
    }
}

class KeyCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let contentsLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/2))
        contentsLabel = UILabel(frame: CGRect(x: 5, y: 25, width: frame.size.width, height: frame.size.height/2))
        
        super.init(frame: frame)
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contentView.addSubview(titleLabel)
        
        contentsLabel.textAlignment = .Center
        contentsLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contentView.addSubview(contentsLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabels(item: LabelItem) {
        self.titleLabel.text = item.title
        self.contentsLabel.text = item.contents
        self.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let keyItem = item as? LabelItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(keyItem)
    }
}
