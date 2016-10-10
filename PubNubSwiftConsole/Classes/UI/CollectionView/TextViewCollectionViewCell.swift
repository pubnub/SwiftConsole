//
//  TextViewCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

class TextViewCollectionViewCell: ThingCollectionViewCell {
    
    let textView: UITextView
    
    override init(frame: CGRect) {
        self.textView = UITextView(frame: .zero)
        super.init(frame: frame)
        textView.forceAutoLayout()
        contentView.addSubview(textView)
        textView.isEditable = false
        textView.isSelectable = false
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func update(thing: Thing) {
        guard let text = thing as? TextThing else {
            fatalError()
        }
        textView.text = text.text
        contentView.setNeedsLayout()
    }
    
    /*
    func update(result: Result) {
        textView.text = result.textViewDisplayText
        contentView.setNeedsLayout()
    }
 */
    override class func size(collectionViewSize: CGSize) -> CGSize {
        let bounds = UIScreen.main.bounds
        return CGSize(width: bounds.width, height: 100.0)
    }
    
    static var size: CGSize {
        let bounds = UIScreen.main.bounds
        return CGSize(width: bounds.width, height: 100.0)
    }
    
}
