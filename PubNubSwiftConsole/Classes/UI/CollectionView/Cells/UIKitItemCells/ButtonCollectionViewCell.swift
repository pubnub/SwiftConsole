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
        buttonItem.updateSelected(selected: selected)
        self[item] = buttonItem
    }
    mutating func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(item: itemType.item, selected: selected)
    }
}

extension DataSource {
    func toggleSelected(indexPath: IndexPath) {
        guard var buttonItem = self[indexPath] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.toggleSelected()
        self[indexPath] = buttonItem
    }
    func updateSelected(indexPath: IndexPath, selected: Bool) {
        guard var buttonItem = self[indexPath] as? ButtonItem else {
            fatalError("Please contact support@pubnub.com")
        }
        buttonItem.updateSelected(selected: selected)
        self[indexPath] = buttonItem
    }
    func updateSelected(itemType: ItemType, selected: Bool) {
        updateSelected(indexPath: itemType.indexPath as IndexPath, selected: selected)
    }
    func toggleSelected(itemType: ItemType) {
        toggleSelected(indexPath: itemType.indexPath as IndexPath)
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
                button.addTarget(updatedTargetSelector.target, action: updatedTargetSelector.selector, for: .touchUpInside)
            }
        }
    }
    
    override init(frame: CGRect) {
        self.button = UIButton(type: .system)
        super.init(frame: frame)
        button.setTitle("Create Client", for: .normal)
        button.sizeToFit()
        button.center = self.contentView.center
        contentView.addSubview(self.button)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        button.center = self.contentView.center
        // this is called for reload, which probably means the caching is pointless
        // TODO: clean this up
        targetSelector = nil
    }
    
    func updateButton(item: ButtonItem) {
        button.setTitle(item.title, for: .normal)
        if let selectedTitle = item.selectedTitle {
            button.setTitle(selectedTitle, for: .selected)
        }
        // only update the target selector if it's new
        if let currentTargetSelector = targetSelector, let currentTarget = currentTargetSelector.target, let itemTarget = item.targetSelector.target, !((currentTargetSelector.selector == item.targetSelector.selector) && (currentTarget === itemTarget)) {
            targetSelector = item.targetSelector
        } else {
            // if there is no current target selector, then update our internal one (which sets it as well)
            targetSelector = item.targetSelector
        }
        button.isSelected = item.selected
        button.sizeToFit()
        contentView.setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let buttonItem = item as? ButtonItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateButton(item: buttonItem)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 150.0, height: 100.0)
    }
}
