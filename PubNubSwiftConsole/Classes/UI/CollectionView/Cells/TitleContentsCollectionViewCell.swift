//
//  TitleContentsCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

protocol TitleContents: Title {
    var contents: String? { get }
}

struct TitleContentsItem: TitleContents {
    var title: String
    var contents: String?
    var isTappable: Bool = false
}

class TitleContentsCollectionViewCell: TitleCollectionViewCell {
    
    private let contentsLabel: UILabel
    
    override init(frame: CGRect) {
        self.contentsLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentsLabel.textAlignment = .center
        stackView.addArrangedSubview(contentsLabel)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    func update(title: String, contents: String?) {
        super.update(title: title)
        contentsLabel.text = contents
        contentView.setNeedsLayout()
    }
 */
    
    func update(contents: String?) {
        contentsLabel.text = contents
        contentView.setNeedsLayout()
    }
    
    func update(titleContents: TitleContents?) {
        super.update(title: titleContents)
        update(contents: titleContents?.contents)
    }
    
    class override var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
