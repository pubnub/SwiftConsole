//
//  ResultCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

class ResultCollectionViewCell: TextViewCollectionViewCell {
    
    func update(result: Result?) {
        guard let actualResult = result else {
            return
        }
        update(text: actualResult.textViewDisplayText)
    }

}
