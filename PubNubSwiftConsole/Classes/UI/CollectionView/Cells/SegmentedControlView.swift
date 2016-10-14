//
//  SegmentedControlView.swift
//  Pods
//
//  Created by Jordan Zucker on 10/12/16.
//
//

import UIKit

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
