//
//  ErrorStatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import UIKit
import PubNub

protocol ErrorStatusItem: StatusItem {
    var channels: [String] {get}
    var channelGroups: [String] {get}
    var information: String {get}
    init(itemType: ItemType, errorStatus: PNErrorStatus)
    init(itemType: ItemType, result: PNErrorStatus)
}

class ErrorStatus: Status, ErrorStatusItem {
    let channels: [String]
    let channelGroups: [String]
    let information: String
    required init(itemType: ItemType, errorStatus: PNErrorStatus) {
        self.channels = errorStatus.errorData.channels
        self.channelGroups = errorStatus.errorData.channelGroups
        self.information = errorStatus.errorData.information
        super.init(itemType: itemType, status: errorStatus)
    }
    
    required convenience init(itemType: ItemType, result: PNResult) {
        self.init(itemType: itemType, errorStatus: result as! PNErrorStatus)
    }
    
    required convenience init(itemType: ItemType, status: PNStatus) {
        self.init(itemType: itemType, errorStatus: status as! PNErrorStatus)
    }
    
    required convenience init(itemType: ItemType, result: PNErrorStatus) {
        self.init(itemType: itemType, errorStatus: result)
    }
    
    override var reuseIdentifier: String {
        return ErrorStatusCollectionViewCell.reuseIdentifier
    }
}

class ErrorStatusCollectionViewCell: StatusCollectionViewCell {
    let channelsLabel: UILabel
    let channelGroupsLabel: UILabel
    let informationLabel: UILabel
    
    override init(frame: CGRect) {
        self.channelsLabel = UILabel(frame: .zero)
        self.channelGroupsLabel = UILabel(frame: .zero)
        self.informationLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(channelsLabel)
        channelsLabel.forceAutoLayout()
        contentView.addSubview(channelGroupsLabel)
        channelGroupsLabel.forceAutoLayout()
        contentView.addSubview(informationLabel)
        informationLabel.forceAutoLayout()
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // don't call super let's control layout ourselves
        categoryLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
        operationLabel.frame = categoryLabel.frame.offsetBy(dx: 0.0, dy: categoryLabel.frame.size.height)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
        informationLabel.frame = clientRequestLabel.frame.offsetBy(dx: 0.0, dy: clientRequestLabel.frame.size.height)
        channelsLabel.frame = informationLabel.frame.offsetBy(dx: 0.0, dy: informationLabel.frame.size.height)
        channelGroupsLabel.frame = channelsLabel.frame.offsetBy(dx: 0.0, dy: channelsLabel.frame.size.height)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let errorStatusItem = item as? ErrorStatusItem else {
            fatalError("wrong item")
        }
        informationLabel.text = "Information: \(errorStatusItem.information)"
        if !errorStatusItem.channels.isEmpty {
            channelsLabel.isHidden = false
            channelsLabel.text = "Channels: \(PubNub.subscribablesToString(subscribables: errorStatusItem.channels))"
        } else {
            channelsLabel.isHidden = true
        }
        if !errorStatusItem.channelGroups.isEmpty {
            channelGroupsLabel.isHidden = false
            channelGroupsLabel.text = "Channel groups: \(PubNub.subscribablesToString(subscribables: errorStatusItem.channelGroups))"
        } else {
            channelGroupsLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
