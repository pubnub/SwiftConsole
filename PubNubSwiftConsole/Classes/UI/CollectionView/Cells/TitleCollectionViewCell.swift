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
    var overrideDefaultBackgroundColor: UIColor? {get}
}

extension Tappable {
    var isTappable: Bool {
        return false
    }
    var overrideDefaultBackgroundColor: UIColor? {
        return nil
    }
}

protocol StaticItem: Tappable {
    
}

protocol PubNubStaticItemGenerator {
    func generateStaticItem(client: PubNub, isTappable: Bool, overrideDefaultBackgroundColor: UIColor?) -> StaticItem
    func generateStaticItemType(client: PubNub, isTappable: Bool, overrideDefaultBackgroundColor: UIColor?) -> StaticItemType
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
        return TitleItem(title: actualTitle, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
    }
}

struct TitleItem: Title {
    var title: String
    var isTappable: Bool = false
    var overrideDefaultBackgroundColor: UIColor?
}

class TitleCollectionViewCell: UICollectionViewCell {
    
    internal let titleLabel: UILabel
    internal let stackView: UIStackView
    private(set) var isTappable: Bool = false
    private(set) var overrideDefaultBackgroundColor: UIColor?
    
    override init(frame: CGRect) {
        let title = UILabel(frame: .zero)
        title.textAlignment = .center
        self.stackView = UIStackView(arrangedSubviews: [title])
        self.titleLabel = title
        super.init(frame: frame)
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
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
        contentView.backgroundColor = unselectedBackgroundColor
        titleLabel.text = title
        contentView.setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        isSelected = false
        isHighlighted = false
        isTappable = false
        overrideDefaultBackgroundColor = nil
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
            contentView.backgroundColor = (newValue ? highlightedBackgroundColor : defaultBackgroundColor)
        }
    }
    
    var unselectedBackgroundColor: UIColor {
        return (overrideDefaultBackgroundColor ?? defaultBackgroundColor)
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            contentView.backgroundColor = (newValue ? selectedBackgroundColor : defaultBackgroundColor)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        print("superview: \(self.superview)")
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        /*
        let bounds = UIScreen.main.bounds
        if attributes.size.width > bounds.width {
            attributes.size.width = bounds.width
        } else {
            let widestWidth = bounds.width * 0.4
            if widestWidth > attributes.size.width {
                attributes.size.width = widestWidth
            } else {
                
            }
        }
 */
        attributes.size.width += 10.0
        attributes.size.height += 10.0
        return attributes
    }
    
    var selectedBackgroundColor: UIColor {
        return (isTappable ? .red : defaultBackgroundColor)
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
        overrideDefaultBackgroundColor = title?.overrideDefaultBackgroundColor
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
