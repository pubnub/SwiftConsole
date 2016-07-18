//
//  PNCLabelCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 7/13/16.
//
//

import Foundation

class PNCLabelCollectionViewCell: UICollectionViewCell {
    static func reuseIdentifier() -> String {
        return String(self.dynamicType)
    }
}
