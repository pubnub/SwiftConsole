//
//  PNCLabelCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

class PNCLabelCollectionViewCell: UICollectionViewCell {
    
    var title: UILabel
    var contents: UILabel
    
    static func reuseIdentifier() -> String {
        return String(self.dynamicType)
    }
    
    override init(frame: CGRect) {
        title = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height/3))
        contents = UILabel(frame: CGRect(x: 0, y: title.frame.size.height, width: frame.size.width, height: frame.size.height/3))
    
        super.init(frame: frame)
        title.textAlignment = .Center
        title.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        
        
        contents.textAlignment = .Center
        contents.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        contents.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contents)
        
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
