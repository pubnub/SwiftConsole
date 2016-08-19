//
//  PublishStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/8/16.
//
//

import UIKit
import PubNub

protocol PublishStatusItem: ErrorStatusItem {
    init(itemType: ItemType, pubNubResult result: PNPublishStatus)
    var timetoken: NSNumber {get}
}

class PublishStatus: ErrorStatus, PublishStatusItem {
    let timetoken: NSNumber
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNPublishStatus)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNPublishStatus) {
        self.timetoken = result.data.timetoken
        super.init(itemType: itemType, pubNubResult: result as! PNErrorStatus)
    }
    
    required convenience init(itemType: ItemType, pubNubResult result: PNErrorStatus) {
        self.init(itemType: itemType, pubNubResult: result as! PNPublishStatus)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return PublishStatus(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return PublishStatusCollectionViewCell.reuseIdentifier
    }
}

class PublishStatusCollectionViewCell: ErrorStatusCollectionViewCell {
    let timetokenLabel: UILabel
    
    override init(frame: CGRect) {
        self.timetokenLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        stackView.insertArrangedSubview(timetokenLabel, at: 0)
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let publishStatusItem = item as? PublishStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        timetokenLabel.text = "Timetoken: \(publishStatusItem.timetoken)"
        contentView.setNeedsLayout()
    }
}
