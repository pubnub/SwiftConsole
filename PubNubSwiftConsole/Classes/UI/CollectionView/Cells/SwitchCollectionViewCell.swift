//
//  SwitchCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
//
//

import Foundation

protocol SwitchItem: Item {
    var selectedTitle: String? {get}
    var targetSelector: TargetSelector {get set}
    var selected: Bool {get set}
    mutating func updateSelected(selected: Bool)
}

extension SwitchItem {
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
    mutating func updateSelected(item: Int, selected: Bool) {
        guard var switchItem = self[item] as? SwitchItem else {
            fatalError("Please contact support@pubnub.com")
        }
        switchItem.updateSelected(selected)
        self[item] = switchItem
    }
    mutating func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(itemType.item, selected: selected)
    }
}

extension DataSource {
    mutating func updateSelected(indexPath: NSIndexPath, selected: Bool) {
        guard var buttonItem = self[indexPath] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.updateSelected(selected)
        self[indexPath] = buttonItem
    }
    mutating func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(itemType.indexPath, selected: selected)
    }
}

public class SwitchCollectionViewCell: CollectionViewCell {
    private let switchControl: UISwitch
    private var targetSelector: TargetSelector? {
        willSet {
            switchControl.removeAllTargets()
        }
        didSet {
            if let updatedTargetSelector = targetSelector {
                switchControl.addTarget(updatedTargetSelector.target, action: updatedTargetSelector.selector, forControlEvents: .TouchUpInside)
            }
        }
    }
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        self.switchControl = UISwitch()
        super.init(frame: frame)
//        self.switchControl.setTitle("Create Client", forState: .Normal)
//        self.switchControl.sizeToFit()
        self.switchControl.center = self.contentView.center
        self.contentView.addSubview(self.switchControl)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.switchControl.center = self.contentView.center
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
}
