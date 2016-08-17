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
    init(itemType: ItemType, pubNubResult result: PNResult)
    static func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem
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
    class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return Result(itemType: itemType, pubNubResult: result)
    }
    required init(itemType: ItemType, pubNubResult result: PNResult) {
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
    let operationLabel: UILabel
    let creationDateLabel: UILabel
    let statusCodeLabel: UILabel
    let uuidLabel: UILabel
    let clientRequestLabel: UILabel
    var clientRequestLabelConstraints: [NSLayoutConstraint]?
    
    override init(frame: CGRect) {
        self.operationLabel = UILabel(frame: .zero)
        self.creationDateLabel = UILabel(frame: .zero)
        self.statusCodeLabel = UILabel(frame: .zero)
        self.uuidLabel = UILabel(frame: .zero)
        self.clientRequestLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(operationLabel)
        operationLabel.forceAutoLayout()
        contentView.addSubview(creationDateLabel)
        creationDateLabel.forceAutoLayout()
        contentView.addSubview(statusCodeLabel)
        statusCodeLabel.forceAutoLayout()
        contentView.addSubview(uuidLabel)
        uuidLabel.forceAutoLayout()
        contentView.addSubview(clientRequestLabel)
        clientRequestLabel.forceAutoLayout()
        // FIXME: let's stop using borderWidth
        contentView.layer.borderWidth = 3
        setUpInitialConstraints()
        contentView.setNeedsLayout()
    }
    
    override func setUpInitialConstraints() {
//        let operationLabelCenterXConstraint = NSLayoutConstraint(item: operationLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let creationDateLabelCenterXConstraint = NSLayoutConstraint(item: creationDateLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let statusCodeLabelCenterXConstraint = NSLayoutConstraint(item: statusCodeLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let uuidLabelCenterXConstraint = NSLayoutConstraint(item: uuidLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let clientRequestLabelCenterXConstraint = NSLayoutConstraint(item: clientRequestLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let views = [
            "operation": operationLabel,
            "creationDate": creationDateLabel,
            "statusCode": statusCodeLabel,
            "uuid": uuidLabel,
            "clientRequest": clientRequestLabel,
        ]
        
        let metrics = [
            "labelHeight": NSNumber(integerLiteral: 30),
            "horizontalPadding": NSNumber(integerLiteral: 5),
            "verticalPadding": NSNumber(integerLiteral: 5),
        ]
        
        let resultConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalPadding-[operation(labelHeight)]-verticalPadding-[creationDate(==operation)]-verticalPadding-[statusCode(==operation)]-verticalPadding-[uuid(==operation)]-verticalPadding-[clientRequest(==operation)]", options: .alignAllCenterX, metrics: metrics, views: views)
        NSLayoutConstraint.activate(resultConstraints)
    }
    
//    override func updateConstraints() {
//        
//    }
    
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
