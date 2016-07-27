//
//  LabelCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

protocol LabelItem: Item {
    var titleString: String {get}
    var contentsString: String {get set}
    var alertControllerTitle: String {get}
    var alertControllerTextFieldValue: String {get}
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
    
    override func updateCell(item: Item) {
        guard let labelItem = item as? LabelItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateLabels(labelItem)
    }
}
