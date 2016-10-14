//
//  TitleCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/12/16.
//
//

import UIKit

protocol Tappable {
    
}

protocol Title {
    var title: String { get }
}

struct TitleItem: Title {
    var title: String
}

class TitleCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel
    internal let stackView: UIStackView
    private var isHighlightable: Bool = false
    
    override init(frame: CGRect) {
        let title = UILabel(frame: .zero)
        title.textAlignment = .center
        self.stackView = UIStackView(arrangedSubviews: [title])
        self.titleLabel = title
        super.init(frame: frame)
        contentView.backgroundColor = .red
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
    
    func update(title: String) {
        titleLabel.text = title
        contentView.setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        isHighlighted = false
        isHighlightable = false
        contentView.backgroundColor = .red
        contentView.setNeedsLayout()
    }
    
    override var isHighlighted: Bool {
        get {
            print(#function)
            return super.isHighlighted
        }
        set {
            print(#function)
            super.isHighlighted = newValue
            if isHighlightable {
                contentView.backgroundColor = (newValue ? .lightGray : .red)
            }
        }
    }
    
    func update(title: Title?) {
        guard let actualTitle = title else {
            return
        }
        isHighlightable = ((actualTitle is Tappable) ? true : false)
        update(title: actualTitle.title)
    }
    
    class var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    class func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
