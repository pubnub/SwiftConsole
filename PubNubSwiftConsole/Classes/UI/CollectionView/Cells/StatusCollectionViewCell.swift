//
//  StatusCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import UIKit
import PubNub

protocol StatusItem: ResultItem {
    var category: String {get}
    var error: Bool {get}
    init(itemType: ItemType, status: PNStatus)
}

class Status: Result, StatusItem {
    let category: String
    let error: Bool
    required init(itemType: ItemType, status: PNStatus) {
        self.category = status.stringifiedCategory()
        self.error = status.isError
        super.init(itemType: itemType, result: status)
    }
    
    required init(itemType: ItemType, result: PNResult) {
        fatalError("init(itemType:result:) has not been implemented")
    }
    override var reuseIdentifier: String {
        return StatusCollectionViewCell.reuseIdentifier
    }
    
}

class StatusCollectionViewCell: CollectionViewCell {
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let uuidLabel: UILabel
    private let clientRequestLabel: UILabel
    private let categoryLabel: UILabel
    
    override init(frame: CGRect) {
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        self.categoryLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(clientRequestLabel)
        contentView.addSubview(categoryLabel)
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
    }
    
    func updateStatus(item: StatusItem) {
        categoryLabel.text = "Category: \(item.category)"
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        uuidLabel.text = "UUID: \(item.uuid)"
        clientRequestLabel.text = "Client request: \(item.clientRequest)"
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let statusItem = item as? StatusItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateStatus(item: statusItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
