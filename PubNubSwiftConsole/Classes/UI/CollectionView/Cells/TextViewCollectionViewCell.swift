//
//  TextViewCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import Foundation

protocol TextViewItem: UpdateableLabelItem {
}

class TextViewCollectionViewCell: CollectionViewCell {
//    private let titleLabel: UILabel
    private let textView: UITextView
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
//        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
//        contentsLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.size.height, width: frame.size.width, height: frame.size.height/3))
        self.textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        
        super.init(frame: frame)
//        titleLabel.textAlignment = .Center
//        titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(titleLabel)
        
//        contentsLabel.textAlignment = .Center
//        contentsLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize())
//        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentsLabel.numberOfLines = 3
//        contentView.addSubview(contentsLabel)
        contentView.addSubview(self.textView)
        
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTextView(item: TextViewItem) {
//        self.titleLabel.text = item.title
//        self.contentsLabel.text = item.contents
        self.textView.text = item.contents
        self.setNeedsLayout() // make sure this occurs during the next update cycle
    }
    
    override func updateCell(item: Item) {
        guard let textViewItem = item as? TextViewItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateTextView(textViewItem)
    }
}
