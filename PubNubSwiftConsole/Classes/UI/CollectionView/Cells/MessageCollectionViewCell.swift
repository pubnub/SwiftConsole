//
//  MessageCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit
import PubNub

protocol MessageItem: Item {
    init(message: PNMessageResult)
}

class MessageCollectionViewCell: CollectionViewCell {
    private let titleLabel: UILabel
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
        super.init(frame: frame)
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: MessageItem) {
        titleLabel.text = item.title
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let messageItem = item as? MessageItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(messageItem)
    }
}
