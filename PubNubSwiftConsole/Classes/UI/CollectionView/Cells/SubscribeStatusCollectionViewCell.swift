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
    var creationDate: String {get}
    var statusCode: Int {get}
    var timeToken: NSNumber? {get}
}

class SubscribeStatusCollectionViewCell: CollectionViewCell {
    
    private let titleLabel: UILabel
    private let operationLabel: UILabel
    private let timeStampLabel: UILabel
    private let statusCodeLabel: UILabel
    private let timeTokenLabel: UILabel
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height/4))
        operationLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.size.width, height: frame.size.height/4))
        timeStampLabel = UILabel(frame: CGRect(x: 5, y: 60, width: frame.size.width, height: frame.size.height/4))
        statusCodeLabel = UILabel(frame: CGRect(x: 5, y: 90, width: frame.size.width, height: frame.size.height/4))
        timeTokenLabel = UILabel(frame: CGRect(x: 5, y: 120, width: frame.size.width, height: frame.size.height/4))
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(operationLabel)
        self.addSubview(timeStampLabel)
        self.addSubview(statusCodeLabel)
        self.addSubview(timeTokenLabel)
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateStatus(item: SubscribeStatusItem) {
        titleLabel.text = "Channel connection: \(item.title)"
        operationLabel.text = "Action: \(item.operation)"
        timeStampLabel.text = "Creation date: \(item.creationDate)"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        guard let timeToken = item.timeToken else {
            timeTokenLabel.hidden = true
            return
        }
        timeTokenLabel.hidden = false
        timeTokenLabel.text = "Time token: \(timeToken)"
        
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let subscribeStatusItem = item as? SubscribeStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(subscribeStatusItem)
    }
}
