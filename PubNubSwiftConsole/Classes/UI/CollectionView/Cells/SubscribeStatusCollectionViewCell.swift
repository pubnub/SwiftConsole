//
//  SubscribeStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/1/16.
//
//

import UIKit
import PubNub

protocol SubscribeStatusItem: Item {
    init(status: PNStatus)
    var operation: String {get}
    var timeToken: NSNumber {get}
    var timeStamp: NSDate {get}
    var statusCode: NSNumber {get}
}

class SubscribeStatusCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let operationLabel: UILabel
    private let timeTokenLabel: UILabel
    private let timeStampLabel: UILabel
    private let statusCodeLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        operationLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        timeTokenLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        timeStampLabel = UILabel(frame: CGRect(x: 5, y: 90, width: frame.size.width, height: frame.size.height/4))
        statusCodeLabel = UILabel(frame: CGRect(x: 5, y: 120, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(operationLabel)
        self.addSubview(timeTokenLabel)
        self.addSubview(timeStampLabel)
        self.addSubview(statusCodeLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: SubscribeStatusItem) {
        titleLabel.text = item.title
        operationLabel.text = item.operation
        timeTokenLabel.text = "\(item.timeToken)"
        timeStampLabel.text = "\(item.timeStamp)"
        statusCodeLabel.text = "\(item.statusCode)"
        
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(subscribeStatusItem)
    }
}
