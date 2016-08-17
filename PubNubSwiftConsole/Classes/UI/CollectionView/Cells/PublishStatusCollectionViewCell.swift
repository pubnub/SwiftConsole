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
        contentView.addSubview(timetokenLabel)
        timetokenLabel.forceAutoLayout()
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        categoryLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
        operationLabel.frame = categoryLabel.frame.offsetBy(dx: 0.0, dy: categoryLabel.frame.size.height)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
        informationLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
        timetokenLabel.frame = informationLabel.frame.offsetBy(dx: 0.0, dy: informationLabel.frame.size.height)
        channelsLabel.frame = timetokenLabel.frame.offsetBy(dx: 0.0, dy: timetokenLabel.frame.size.height)
        channelGroupsLabel.frame = channelsLabel.frame.offsetBy(dx: 0.0, dy: channelsLabel.frame.size.height)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let publishStatusItem = item as? PublishStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        timetokenLabel.text = "Timetoken: \(publishStatusItem.timetoken)"
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
