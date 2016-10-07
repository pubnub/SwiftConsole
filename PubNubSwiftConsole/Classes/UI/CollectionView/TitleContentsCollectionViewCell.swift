//
//  TitleContentsCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

class TitleContentsCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel
    private let contentsLabel: UILabel
    private let stackView: UIStackView
    
    override init(frame: CGRect) {
        let title = UILabel(frame: .zero)
        let contents = UILabel(frame: .zero)
        self.stackView = UIStackView(arrangedSubviews: [title, contents])
        self.titleLabel = title
        self.contentsLabel = contents
        super.init(frame: frame)
        contentView.addSubview(self.stackView)
        stackView.forceAutoLayout()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        let views = [
            "stackView": stackView
        ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String, contents: String) {
        titleLabel.text = title
        contentsLabel.text = contents
        contentView.setNeedsLayout()
    }
    
}
