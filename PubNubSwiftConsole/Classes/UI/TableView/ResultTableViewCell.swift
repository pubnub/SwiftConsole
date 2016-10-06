//
//  ResultTableViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/5/16.
//
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    let textView: UITextView
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.textView = UITextView(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(result: Result) {
        textView.text = result.textViewDisplayText
        contentView.setNeedsLayout()
    }
    
    static var height: CGFloat {
        return 100.0
    }

}
