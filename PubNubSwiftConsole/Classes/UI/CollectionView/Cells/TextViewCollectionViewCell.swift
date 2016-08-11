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

@objc public protocol TextViewCollectionViewCellDelegate: NSObjectProtocol {
    optional func textViewCell(cell: TextViewCollectionViewCell, textViewDidEndEditing textView: UITextView)
}

public class TextViewCollectionViewCell: CollectionViewCell, UITextViewDelegate {
    
    var delegate: TextViewCollectionViewCellDelegate?
    
    private let textView: UITextView
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        self.textView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height))
        super.init(frame: frame)
        self.textView.delegate = self
        contentView.addSubview(self.textView)
        
        contentView.layer.borderWidth = 3
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTextView(item: TextViewItem) {
        // TODO: investigate if this should always be replaced
        self.textView.text = item.contents
        self.setNeedsLayout() // make sure this occurs during the next update cycle
    }
    
    override func updateCell(item: Item) {
        guard let textViewItem = item as? TextViewItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateTextView(textViewItem)
    }
    
    // MARK: - UITextViewDelegate
    
    public func textViewDidEndEditing(textView: UITextView) {
        self.delegate?.textViewCell?(self, textViewDidEndEditing: textView)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 300.0, height: 300.0)
    }
}
