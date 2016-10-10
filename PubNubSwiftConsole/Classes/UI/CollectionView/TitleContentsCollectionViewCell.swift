//
//  TitleContentsCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

class ThingCollectionViewCell: UICollectionViewCell {
    func update(thing: Thing) {
        
    }
    
    class func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
}

class TitleContentsCollectionViewCell: ThingCollectionViewCell {
    
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
    
    override func update(thing: Thing) {
        guard let titleContents = thing as? TitleContentsThing else {
            fatalError()
        }
        titleLabel.text = titleContents.title
        contentsLabel.text = titleContents.contents
        contentView.setNeedsLayout()
    }
    
    override class func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
