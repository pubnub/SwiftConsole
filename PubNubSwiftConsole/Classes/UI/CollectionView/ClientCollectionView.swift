//
//  ClientCollectionView.swift
//  Pods
//
//  Created by Jordan Zucker on 10/14/16.
//
//

import UIKit
import PubNub
import JSQDataSourcesKit

enum ClientProperty: String, PubNubStaticItemGenerator {
    case pubKey = "Publish Key"
    case subKey = "Subscribe Key"
    case channels = "Channels"
    case channelGroups = "Channel Groups"
    case authKey = "PAM Key"
    
    var title: String {
        return rawValue
    }
    
    init?(staticItem: StaticItem) {
        guard let title = staticItem as? Title else {
            return nil
        }
        if let actualProperty = ClientProperty(rawValue: title.title) {
            self = actualProperty
        } else {
            return nil
        }
    }
    
    func generateStaticItem(client: PubNub, isTappable: Bool = false) -> StaticItem {
        switch self {
        case .pubKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().publishKey, isTappable: isTappable)
        case .subKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().subscribeKey, isTappable: isTappable)
        case .channels:
            return TitleContentsItem(title: title, contents: client.channelsString(), isTappable: isTappable)
        case .channelGroups:
            return TitleContentsItem(title: title, contents: client.channelGroupsString(), isTappable: isTappable)
        case .authKey:
            return TitleContentsItem(title: title, contents: client.currentConfiguration().authKey, isTappable: isTappable)
        }
    }
    func generateStaticItemType(client: PubNub, isTappable: Bool = false) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(client: client, isTappable: isTappable))
    }
}

protocol ClientPropertyUpdater: StaticDataSourceUpdater {
    
    func indexPath(for clientProperty: ClientProperty) -> IndexPath?
    // if indexPath is nil, then no update occurred
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool) -> IndexPath?
}

extension ClientPropertyUpdater {
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool = false) -> IndexPath? {
        guard let propertyIndexPath = indexPath(for: clientProperty) else {
            return nil
        }
        let staticItemType = clientProperty.generateStaticItemType(client: client, isTappable: isTappable)
        return update(dataSource: &dataSource, at: propertyIndexPath, with: staticItemType, isTappable: isTappable)
    }
}

class ClientCollectionView: StaticItemCollectionView {

}
