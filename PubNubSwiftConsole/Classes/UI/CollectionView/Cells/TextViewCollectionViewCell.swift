//
//  TextViewCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

class TextViewCollectionViewCell: UICollectionViewCell {
    
    let textView: UITextView
    
    override init(frame: CGRect) {
        self.textView = UITextView(frame: .zero)
        super.init(frame: frame)
        textView.forceAutoLayout()
        contentView.addSubview(textView)
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        let views = [
            "textView": textView,
            ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[textView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            textView.backgroundColor = (newValue ? .lightGray : .white)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(text: String) {
        textView.text = text
        contentView.setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
        isHighlighted = false
        textView.backgroundColor = .white
        setNeedsLayout() // is this necessary?
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let bounds = UIScreen.main.bounds
        attributes.size.width = bounds.width
        return attributes
    }
    
    static var size: CGSize {
        let bounds = UIScreen.main.bounds
        return CGSize(width: bounds.width, height: 100.0)
    }
    
}
