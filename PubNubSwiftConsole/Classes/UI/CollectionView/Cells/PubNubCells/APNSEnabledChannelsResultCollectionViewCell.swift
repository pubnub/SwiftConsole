//
//  APNSEnabledChannelsResultCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/18/16.
//
//

import UIKit
import PubNub

protocol APNSEnabledChannelsResultItem: ResultItem {
    init(itemType: ItemType, pubNubResult result: PNAPNSEnabledChannelsResult)
    var apnsChannels: [String] {get}
}

class APNSEnabledChannelsResult: Result, APNSEnabledChannelsResultItem {
    let apnsChannels: [String]
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNAPNSEnabledChannelsResult)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNAPNSEnabledChannelsResult) {
        self.apnsChannels = result.data.channels
        super.init(itemType: itemType, pubNubResult: result as! PNResult)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return APNSEnabledChannelsResult(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return APNSEnabledChannelsResultCollectionViewCell.reuseIdentifier
    }
}

class APNSEnabledChannelsResultCollectionViewCell: ResultCollectionViewCell {
    
    let apnsChannelLabel: UILabel
    
    override init(frame: CGRect) {
        self.apnsChannelLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        // let's put this after the operation label (index 0)
        stackView.insertArrangedSubview(apnsChannelLabel, at: 1)
        // FIXME: // let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let apnsChannelsResult = item as? APNSEnabledChannelsResultItem else {
            fatalError("wrong class")
        }
        apnsChannelLabel.text = "Push channels: \(apnsChannelsResult.apnsChannels)"
        contentView.setNeedsLayout()
    }
}
