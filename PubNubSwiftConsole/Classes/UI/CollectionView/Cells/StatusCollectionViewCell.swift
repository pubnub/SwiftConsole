//
//  StatusCollectionViewCell.swift
//  Pods
//
//  Created by Keith Martin on 8/1/16.
//
//

import Foundation

protocol StatusItem: Item {
    var contents: String {get set}
    mutating func updateContentsString(updatedContents: String?)
}

extension StatusItem {
    mutating func updateContentsString(updatedContents: String) {
        self.contents = updatedContents
    }
    var title: String {
        return itemType.title
    }
}

extension ItemSection {
    mutating func updateLabelContentsString(item: Int, updatedContents: String?) {
        guard var selectedLabelItem = self[item] as? StatusItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedLabelItem.updateContentsString(updatedContents)
        self[item] = selectedLabelItem
    }
}

extension DataSource {
    mutating func updateLabelContentsString(indexPath: NSIndexPath, updatedContents: String?) {
        guard var selectedItem = self[indexPath] as? StatusItem else {
            fatalError("Please contact support@pubnub.com")
        }
        selectedItem.updateContentsString(updatedContents)
        self[indexPath] = selectedItem
    }
}


class StatusCollectionViewCell: CollectionViewCell {
    
    
    
    
}