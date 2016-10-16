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
    //init(title: String, isTappable: Bool)
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
    /*
    init(title: String, isTappable: Bool = false) {
        self.title = title
        self.isTappable = isTappable
    }
 */
    var title: String
    var isTappable: Bool = false
}

class TitleCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel
    internal let stackView: UIStackView
    private var isTappable: Bool = false
    
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
        isTappable = false
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
            if isTappable {
                contentView.backgroundColor = (newValue ? .lightGray : .red)
            }
        }
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
