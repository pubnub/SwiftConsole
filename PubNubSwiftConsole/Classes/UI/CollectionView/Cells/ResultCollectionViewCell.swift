//
//  ResultCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/16/16.
//
//

import UIKit
import PubNub

protocol ResultItem: Item {
    init(itemType: ItemType, result: PNResult)
    var statusCode: Int {get}
    var operation: String {get}
    var creationDate: Date {get}
    var uuid: String {get}
    var clientRequest: String? {get}
}

extension ResultItem {
    var title: String {
        return operation
    }
}

class Result: ResultItem {
    let itemType: ItemType
    let statusCode: Int
    let operation: String
    let creationDate: Date
    let uuid: String
    let clientRequest: String?
    required init(itemType: ItemType, result: PNResult) {
        self.itemType = itemType
        self.operation = result.stringifiedOperation()
        self.creationDate = Date()
        self.uuid = result.uuid
        self.statusCode = result.statusCode
        self.clientRequest = result.clientRequest?.url?.absoluteString
    }
    var reuseIdentifier: String {
        return ResultCollectionViewCell.reuseIdentifier
    }
}

class ResultCollectionViewCell: CollectionViewCell {
    private let operationLabel: UILabel
    private let creationDateLabel: UILabel
    private let statusCodeLabel: UILabel
    private let uuidLabel: UILabel
    private let clientRequestLabel: UILabel
    
    override init(frame: CGRect) {
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        contentView.addSubview(creationDateLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(uuidLabel)
        contentView.addSubview(clientRequestLabel)
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        operationLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
    }
    
    func updateResult(item: ResultItem) {
        operationLabel.text = "Operation: \(item.operation)"
        creationDateLabel.text = "Creation date: \(item.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(item.statusCode)"
        uuidLabel.text = "UUID: \(item.uuid)"
        clientRequestLabel.text = "Client request: \(item.clientRequest)"
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let resultItem = item as? ResultItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateResult(item: resultItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
