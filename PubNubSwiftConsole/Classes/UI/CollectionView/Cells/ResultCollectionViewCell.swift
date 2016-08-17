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

extension UIView {
    var hasConstraints: Bool {
        let hasHorizontalConstraints = !self.constraintsAffectingLayout(for: .horizontal).isEmpty
        let hasVerticalConstraints = !self.constraintsAffectingLayout(for: .vertical).isEmpty
        return hasHorizontalConstraints || hasVerticalConstraints
    }
}

class ResultCollectionViewCell: CollectionViewCell {
    let operationLabel: UILabel
    let creationDateLabel: UILabel
    let statusCodeLabel: UILabel
    let uuidLabel: UILabel
    let clientRequestLabel: UILabel
    
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
        // FIXME: let's stop using borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    override func updateConstraints() {
        guard hasConstraints else {
            return
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        operationLabel.frame = CGRect(x: 5.0, y: 10.0, width: 100.0, height: 30.0)
//        creationDateLabel.frame = operationLabel.frame.offsetBy(dx: 0.0, dy: operationLabel.frame.size.height)
//        statusCodeLabel.frame = creationDateLabel.frame.offsetBy(dx: 0.0, dy: creationDateLabel.frame.size.height)
//        uuidLabel.frame = statusCodeLabel.frame.offsetBy(dx: 0.0, dy: statusCodeLabel.frame.size.height)
//        clientRequestLabel.frame = uuidLabel.frame.offsetBy(dx: 0.0, dy: uuidLabel.frame.size.height)
//    }
    
    override func updateCell(item: Item) {
        guard let resultItem = item as? ResultItem else {
            fatalError("wrong item passed in")
        }
        operationLabel.text = "Operation: \(resultItem.operation)"
        creationDateLabel.text = "Creation date: \(resultItem.creationDate.creationTimeStampString())"
        statusCodeLabel.text = "Status code: \(resultItem.statusCode)"
        uuidLabel.text = "UUID: \(resultItem.uuid)"
        if let actualClientRequest = resultItem.clientRequest {
            clientRequestLabel.text = "Client request: \(actualClientRequest)"
            clientRequestLabel.isHidden = false
        } else {
            clientRequestLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 250.0)
    }
}
