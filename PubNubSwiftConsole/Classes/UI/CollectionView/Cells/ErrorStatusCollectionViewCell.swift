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
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    
    required init(itemType: ItemType, status: PNStatus) {
        fatalError("init(itemType:status:) has not been implemented")
    }
    
    override var reuseIdentifier: String {
        return ErrorStatusCollectionViewCell.reuseIdentifier
    }
}

class ErrorStatusCollectionViewCell: CollectionViewCell {
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let uuidLabel: UILabel
    private let clientRequestLabel: UILabel
    private let categoryLabel: UILabel
    private let channelsLabel: UILabel
    private let channelGroupsLabel: UILabel
    private let informationLabel: UILabel
    
    override init(frame: CGRect) {
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        self.categoryLabel = UILabel(frame: .zero)
        self.channelsLabel = UILabel(frame: .zero)
        self.channelGroupsLabel = UILabel(frame: .zero)
        self.informationLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(clientRequestLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(channelsLabel)
        contentView.addSubview(channelGroupsLabel)
        contentView.addSubview(informationLabel)
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
        channelsLabel.frame = informationLabel.frame.offsetBy(dx: 0.0, dy: informationLabel.frame.size.height)
        channelGroupsLabel.frame = channelsLabel.frame.offsetBy(dx: 0.0, dy: channelsLabel.frame.size.height)
    }
    
    func updateStatus(item: ErrorStatusItem) {
        categoryLabel.text = "Category: \(item.category)"
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        uuidLabel.text = "UUID: \(item.uuid)"
        clientRequestLabel.text = "Client request: \(item.clientRequest)"
        informationLabel.text = "Information: \(item.information)"
        if !item.channels.isEmpty {
            channelsLabel.isHidden = false
            channelsLabel.text = "Channels: \(PubNub.subscribablesToString(subscribables: item.channels))"
        } else {
            channelsLabel.isHidden = true
        }
        if !item.channelGroups.isEmpty {
            channelGroupsLabel.isHidden = false
            channelGroupsLabel.text = "Channel groups: \(PubNub.subscribablesToString(subscribables: item.channelGroups))"
        } else {
            channelGroupsLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let errorStatusItem = item as? ErrorStatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(item: errorStatusItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
