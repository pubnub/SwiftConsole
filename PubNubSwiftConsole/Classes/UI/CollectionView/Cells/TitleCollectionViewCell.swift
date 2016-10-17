//
//  TitleCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/12/16.
//
//

import UIKit
import PubNub

protocol Tappable {
    var isTappable: Bool {get}
}

extension Tappable {
    var isTappable: Bool {
        return false
    }
}

protocol StaticItem: Tappable {
    
}

protocol PubNubStaticItemGenerator {
    func generateStaticItem(client: PubNub, isTappable: Bool) -> StaticItem
    func generateStaticItemType(client: PubNub, isTappable: Bool) -> StaticItemType
}

protocol Title: StaticItem {
    var title: String { get }
    func updatedTitleItem(with title: String?) -> Title?
}

extension Title {
    func updatedTitleItem(with title: String?) -> Title? {
        guard let actualTitle = title else {
            return nil
        }
        return TitleItem(title: actualTitle, isTappable: isTappable)
    }
}

struct TitleItem: Title {
    var title: String
    var isTappable: Bool = false
}

class TitleCollectionViewCell: UICollectionViewCell {
    
    internal let titleLabel: UILabel
    internal let stackView: UIStackView
    private(set) var isTappable: Bool = false
    
    override init(frame: CGRect) {
        let title = UILabel(frame: .zero)
        title.textAlignment = .center
        self.stackView = UIStackView(arrangedSubviews: [title])
        self.titleLabel = title
        super.init(frame: frame)
        titleLabel.textColor = .black
        contentView.backgroundColor = defaultBackgroundColor
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
        isTappable = false
        contentView.backgroundColor = defaultBackgroundColor
        titleLabel.textColor = .black
        contentView.setNeedsLayout()
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            contentView.backgroundColor = highlightedBackgroundColor
        }
    }
    
    var defaultBackgroundColor: UIColor {
        return .white
    }
    
    var highlightedBackgroundColor: UIColor {
        return (isTappable ? .lightGray : defaultBackgroundColor)
    }
    
    func update(title: Title?) {
        guard let actualTitle = title else {
            return
        }
        isTappable = ((actualTitle.isTappable) ? true : false)
        update(title: actualTitle.title)
    }
    
    class var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    class func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
