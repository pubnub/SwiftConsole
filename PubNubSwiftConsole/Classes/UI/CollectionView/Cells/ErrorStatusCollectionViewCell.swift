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
    init(itemType: ItemType, pubNubResult result: PNErrorStatus)
}

class ErrorStatus: Status, ErrorStatusItem {
    let channels: [String]
    let channelGroups: [String]
    let information: String

    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNErrorStatus)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNErrorStatus) {
        self.channels = result.errorData.channels
        self.channelGroups = result.errorData.channelGroups
        self.information = result.errorData.information
        super.init(itemType: itemType, pubNubResult: result as! PNStatus)
    }
    
    required convenience init(itemType: ItemType, pubNubResult result: PNStatus) {
        self.init(itemType: itemType, pubNubResult: result as! PNErrorStatus)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return ErrorStatus(itemType: itemType, pubNubResult: result)
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
        // let's put it after the category (index 1) and after the operation (index 0)
        stackView.insertArrangedSubview(channelsLabel, at: 2)
        stackView.insertArrangedSubview(channelGroupsLabel, at: 3)
        stackView.addArrangedSubview(informationLabel) // this can just go at the end
        // FIXME: let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
