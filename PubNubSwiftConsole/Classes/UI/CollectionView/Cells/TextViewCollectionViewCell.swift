//
//  TextViewCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import Foundation

protocol TextViewItem: UpdatableTitleContentsItem {
}

class TextViewCollectionViewCell: CollectionViewCell {
    private let textView: UITextView
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        self.textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        super.init(frame: frame)
        contentView.addSubview(self.textView)
        
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTextView(item: TextViewItem) {
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
