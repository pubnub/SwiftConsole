//
//  SegmentedControlCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit

protocol SegmentedControlItem: Item {
    var items: [String] {get}
    var defaultSelectedSegmentIndex: Int {get}
    var selectedSegmentIndex: Int {get set}
    var numberOfSegments: Int {get}
    var targetSelector: TargetSelector {get set}
    mutating func updateSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool // returns yes if the value changed, no if it stayed the same (for use in optimizing collection view reloads)
}

extension SegmentedControlItem {
    mutating func segmentedControlValueChanged(sender: UISegmentedControl!) {
        self.selectedSegmentIndex = sender.selectedSegmentIndex
    }
    var title: String {
        return ""
    }
    mutating func updateSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool {
        let oldSelectedSegmentIndex = self.selectedSegmentIndex
        self.selectedSegmentIndex = index
        return ((oldSelectedSegmentIndex != index) ? true : false)
    }
    var defaultSelectedSegmentIndex: Int {
        return 0
    }
    var numberOfSegments: Int {
        return items.count
    }
}

extension ItemSection {
    mutating func updateSelectedSegmentIndex(item: Int, updatedSelectedSegmentIndex index: Int) -> Bool {
        guard var segmentedControlItem = self[item] as? SegmentedControlItem else {
            fatalError("Please contact support@pubnub.com")
        }
        let result = segmentedControlItem.updateSelectedSegmentIndex(updatedSelectedSegmentIndex: index)
        self[item] = segmentedControlItem
        return result
    }
    mutating func updateSelectedSegmentIndex(itemType: ItemType, updatedSelectedSegmentIndex index: Int) -> Bool {
        return updateSelectedSegmentIndex(itemType.item, updatedSelectedSegmentIndex: index)
    }
}

// assumes there is only one segmented control in the section
protocol SingleSegementedControlItemSection: ItemSection {
    init(segmentedControl: SegmentedControlItem)
    var segmentedControl: SegmentedControlItem {get}
    var selectedSegmentIndex: Int {get}
    mutating func updateSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool
}

extension SingleSegementedControlItemSection {
    var segmentIndex: Int {
        return 0
    }
    var segmentedControl: SegmentedControlItem {
        guard let segmentedControl = self.items[segmentIndex] as? SegmentedControlItem else {
            fatalError("This should only have 1 SegmentedControlItem")
        }
        return segmentedControl
    }
    var selectedSegmentIndex: Int {
        return segmentedControl.selectedSegmentIndex
    }
    mutating func updateSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool {
        return updateSelectedSegmentIndex(segmentIndex, updatedSelectedSegmentIndex: index)
    }
}

extension DataSource {
    func updateSelectedSegmentIndex(indexPath: NSIndexPath, updatedSelectedSegmentIndex index: Int) -> Bool {
        guard var segmentedControlItem = self[indexPath] as? SegmentedControlItem else {
            fatalError("Please contact support@pubnub.com")
        }
        let result = segmentedControlItem.updateSelectedSegmentIndex(updatedSelectedSegmentIndex: index)
        self[indexPath] = segmentedControlItem
        return result
    }
    func selectedSegmentIndex(indexPath: NSIndexPath) -> Int {
        guard let segmentedControlItem = self[indexPath] as? SegmentedControlItem else {
            fatalError()
        }
        return segmentedControlItem.selectedSegmentIndex
    }
    func updateSelectedSegmentIndex(itemType: ItemType, updatedSelectedSegmentIndex index: Int) -> Bool {
        return updateSelectedSegmentIndex(itemType.indexPath, updatedSelectedSegmentIndex: index)
    }
    func selectedSegmentIndex(itemType: ItemType) -> Int {
        return selectedSegmentIndex(itemType.indexPath)
    }
}

public class SegmentedControlCollectionViewCell: CollectionViewCell {
    private var segmentedControl: UISegmentedControl?
    private var targetSelector: TargetSelector? {
        willSet {
            segmentedControl?.removeAllTargets()
        }
        didSet {
            if let updatedTargetSelector = targetSelector {
                segmentedControl?.addTarget(updatedTargetSelector.target, action: updatedTargetSelector.selector, forControlEvents: .ValueChanged)
            }
        }
    }
    
    override class var reuseIdentifier: String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        // this is called for reload, which probably means the caching is pointless
        // TODO: clean this up
        targetSelector = nil
        segmentedControl?.removeFromSuperview()
        segmentedControl = nil
    }
    
    func updateSegmentedControl(item: SegmentedControlItem) {
        if let oldSegmentedControl = segmentedControl {
            oldSegmentedControl.removeFromSuperview()
        }
        segmentedControl = nil
        segmentedControl = UISegmentedControl(items: item.items)
        segmentedControl?.tintColor = UIColor.purpleColor()
        segmentedControl?.selectedSegmentIndex = item.selectedSegmentIndex
        // only update the target selector if it's new
        if let currentTargetSelector = targetSelector, let currentTarget = currentTargetSelector.target, let itemTarget = item.targetSelector.target where !((currentTargetSelector.selector == item.targetSelector.selector) && (currentTarget === itemTarget)) {
            targetSelector = item.targetSelector
        } else {
            // if there is no current target selector, then update our internal one (which sets it as well)
            targetSelector = item.targetSelector
        }
//        segmentedControl?.center = self.center
        contentView.addSubview(self.segmentedControl!) // forced unwrap ok because we init this a few lines above
        setNeedsLayout()
    }
    
    override func updateCell(item: Item) {
        guard let segmentedControlItem = item as? SegmentedControlItem else {
            fatalError("init(coder:) has not been implemented")
        }
        updateSegmentedControl(segmentedControlItem)
    }
}
