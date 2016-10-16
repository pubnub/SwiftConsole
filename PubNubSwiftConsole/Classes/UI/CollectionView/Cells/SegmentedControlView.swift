//
//  SegmentedControlView.swift
//  Pods
//
//  Created by Jordan Zucker on 10/12/16.
//
//

import UIKit

enum ConsoleSegment: Int {
    case all, messages, presence
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .messages:
            return "Messages"
        case .presence:
            return "Presence Events"
        }
    }
    
    static var defaultValue: ConsoleSegment {
        return .all
    }
    
    static var defaultSegments: [ConsoleSegment] {
        return [.all, .messages, .presence]
    }
    
    static var defaultSegmentItems: [String] {
        return defaultSegments.map {
            $0.title
        }
    }
    
    //@“self.entity = %@ and subentityProperty = %@“ or even @“relationship.entity = %@ and relationship.onlysomedestinationsubentitiesAttribute = %@“
    var consolePredicate: NSPredicate? {
        switch self {
        case .all:
            return nil
        case .messages:
            return NSPredicate(format: "self.entity == %@", argumentArray: [MessageResult.entity()])
        case .presence:
            return NSPredicate(format: "self.entity = %@", argumentArray: [PresenceEventResult.self])
        }
    }
}

class SegmentedControlView: /*UICollectionViewCell*/ UICollectionReusableView {
    
    private let segmentedControl: UISegmentedControl
    
    override init(frame: CGRect) {
        self.segmentedControl = UISegmentedControl(items: ["What", "Is", "Life?"])
        super.init(frame: frame)
        addSubview(segmentedControl)
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedControl.center = center
    }
    
    func update(updated selectedSegmentIndex: Int) {
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        setNeedsLayout()
    }
    
    class var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    private func segmentedControlValueChanged(sender: UISegmentedControl) {
        
    }

}
