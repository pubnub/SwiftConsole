//
//  ButtonCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit

protocol ButtonItem: Item {
    var selectedTitle: String? {get}
    var targetSelector: TargetSelector {get set}
    var selected: Bool {get set}
    mutating func toggleSelected()
    mutating func updateSelected(selected: Bool)
}

extension ButtonItem {
    mutating func toggleSelected() {
        selected = (!selected)
    }
    mutating func updateSelected(selected: Bool) {
        self.selected = selected
    }
    var title: String {
        return itemType.title
    }
    var selectedTitle: String? {
        return itemType.selectedTitle
    }
}

extension ItemSection {
    mutating func toggleSelected(item: Int) {
        guard var buttonItem = self[item] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.toggleSelected()
        self[item] = buttonItem
    }
    mutating func updateSelected(item: Int, selected: Bool) {
        guard var buttonItem = self[item] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.updateSelected(selected)
        self[item] = buttonItem
    }
    mutating func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(itemType.item, selected: selected)
    }
}

extension DataSource {
    func toggleSelected(indexPath: NSIndexPath) {
        guard var buttonItem = self[indexPath] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.toggleSelected()
        self[indexPath] = buttonItem
    }
    func updateSelected(indexPath: NSIndexPath, selected: Bool) {
        guard var buttonItem = self[indexPath] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.updateSelected(selected)
        self[indexPath] = buttonItem
    }
    func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(itemType.indexPath, selected: selected)
    }
    func toggleSelected(itemType: ItemType) {
        toggleSelected(itemType.indexPath)
    }
}

public class ButtonCollectionViewCell: CollectionViewCell {
    private let button: UIButton
    private var targetSelector: TargetSelector? {
        willSet {
            button.removeAllTargets()
        }
        didSet {
            if let updatedTargetSelector = targetSelector {
                button.addTarget(updatedTargetSelector.target, action: updatedTargetSelector.selector, forControlEvents: .TouchUpInside)
            }
        }
    }
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        self.button = UIButton(type: .System)
        super.init(frame: frame)
        self.button.setTitle("Create Client", forState: .Normal)
        self.button.sizeToFit()
        self.button.center = self.contentView.center
        self.contentView.addSubview(self.button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.button.center = self.contentView.center
        // this is called for reload, which probably means the caching is pointless
        // TODO: clean this up
        targetSelector = nil
    }
    
    func updateButton(item: ButtonItem) {
        button.setTitle(item.title, forState: .Normal)
        if let selectedTitle = item.selectedTitle {
            button.setTitle(selectedTitle, forState: .Selected)
        }
        // only update the target selector if it's new
        if let currentTargetSelector = targetSelector, let currentTarget = currentTargetSelector.target, let itemTarget = item.targetSelector.target where !((currentTargetSelector.selector == item.targetSelector.selector) && (currentTarget === itemTarget)) {
            targetSelector = item.targetSelector
        } else {
            // if there is no current target selector, then update our internal one (which sets it as well)
            targetSelector = item.targetSelector
        }
        button.selected = item.selected
        button.sizeToFit()
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let buttonItem = item as? ButtonItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateButton(buttonItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 150.0, height: 100.0)
    }
}
