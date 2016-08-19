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
    let stackView: UIStackView
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
        self.stackView = UIStackView(frame: frame)
        super.init(frame: frame)
        stackView.axis = .vertical
        stackView.alignment = .fill
//        stackView.alignment = .center
        stackView.distribution = .equalSpacing
//        stackView.distribution = .fill
        stackView.spacing = 5.0
        contentView.addSubview(stackView)
        stackView.forceAutoLayout()
        func setStackViewConstraints(withVisualFormat: String) {
            let views = [
                "stackView": stackView,
                ]
            let stackViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: withVisualFormat, options: [], metrics: nil, views: views)
            NSLayoutConstraint.activate(stackViewConstraints)
        }
        // finish setting up stack
        setStackViewConstraints(withVisualFormat: "H:|[stackView]|")
        setStackViewConstraints(withVisualFormat: "V:|[stackView]|")
        // now add arranged subviews
        stackView.addArrangedSubview(operationLabel)
        stackView.addArrangedSubview(creationDateLabel)
        stackView.addArrangedSubview(statusCodeLabel)
        stackView.addArrangedSubview(uuidLabel)
        stackView.addArrangedSubview(clientRequestLabel)
        // FIXME: let's stop using borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        return CGSize(width: collectionViewSize.width, height: 300.0)
    }
}
