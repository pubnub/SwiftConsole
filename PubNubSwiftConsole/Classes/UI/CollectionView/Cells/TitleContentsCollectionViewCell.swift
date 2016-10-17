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
    func updatedTitleContentsItem(with contents: String?) -> TitleContents
}

extension TitleContents {
    func updatedTitleContentsItem(with contents: String?) -> TitleContents {
        guard let actualContents = contents else {
            return TitleContentsItem(title: title, contents: nil, isTappable: isTappable)
        }
        return TitleContentsItem(title: title, contents: actualContents, isTappable: isTappable)
    }
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
        if isTappable {
            titleLabel.textColor = .gray
            contentsLabel.textColor = .black
        }
        update(contents: titleContents?.contents)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentsLabel.text = nil
        contentsLabel.textColor = .black
        titleLabel.textColor = .black
    }
    
    class override var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
