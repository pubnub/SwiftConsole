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
    case origin = "Origin"
    
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
    
    var defaultContents: String? {
        switch self {
        case .pubKey, .subKey:
            return "demo-36"
        case .origin:
            return "pubsub.pubnub.com"
        case .authKey:
            return nil
        case .channels, .channelGroups:
            return nil
        }
    }
    
    func generateStaticItem(contents: String?, isTappable: Bool = false) -> StaticItem {
        return TitleContentsItem(title: title, contents: contents, isTappable: isTappable)
    }
    
    func generateDefaultStaticItem(isTappable: Bool = false) -> StaticItem {
        return generateStaticItem(contents: defaultContents, isTappable: isTappable)
    }
    
    func generateDefaultStaticItemType(isTappable: Bool = false) -> StaticItemType {
        return generateStaticItemType(contents: defaultContents, isTappable: isTappable)
    }
    
    func generateStaticItemType(contents: String?, isTappable: Bool = false) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(contents: contents, isTappable: isTappable))
    }
    
    func generateStaticItem(client: PubNub, isTappable: Bool = false) -> StaticItem {
        return generateStaticItem(contents: generateContents(client: client), isTappable: isTappable)
    }
    
    func generateContents(client: PubNub) -> String? {
        switch self {
        case .pubKey:
            return client.currentConfiguration().publishKey
        case .subKey:
            return client.currentConfiguration().subscribeKey
        case .channels:
            return client.channelsString()
        case .channelGroups:
            return client.channelGroupsString()
        case .authKey:
            return client.currentConfiguration().authKey
        case .origin:
            return client.currentConfiguration().origin
        }
    }
    
    func generateStaticItemType(client: PubNub, isTappable: Bool = false) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(client: client, isTappable: isTappable))
    }
}

protocol ClientPropertyGetter: StaticItemGetter {
    func indexPath(for clientProperty: ClientProperty) -> IndexPath?
    func staticItem(from dataSource: StaticDataSource, for clientProperty: ClientProperty) -> StaticItem
}

extension ClientPropertyGetter {
    func staticItem(from dataSource: StaticDataSource, for clientProperty: ClientProperty) -> StaticItem {
        guard let indexPath = indexPath(for: clientProperty) else {
            fatalError()
        }
        return staticItem(from: dataSource, at: indexPath)
    }
}

protocol ClientPropertyUpdater: StaticDataSourceUpdater, ClientPropertyGetter {
    
    // if indexPath is nil, then no update occurred
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool) -> IndexPath?
    // below only works with title contents
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with contents: String?, isTappable: Bool) -> IndexPath?
}

extension ClientPropertyUpdater {
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with client: PubNub, isTappable: Bool = false) -> IndexPath? {
        guard let propertyIndexPath = indexPath(for: clientProperty) else {
            return nil
        }
        let staticItemType = clientProperty.generateStaticItemType(client: client, isTappable: isTappable)
        return update(dataSource: &dataSource, at: propertyIndexPath, with: staticItemType, isTappable: isTappable)
    }
    func update(dataSource: inout StaticDataSource, for clientProperty: ClientProperty, with contents: String?, isTappable: Bool = false) -> IndexPath? {
        guard let propertyIndexPath = indexPath(for: clientProperty) else {
            return nil
        }
        let staticItemType = clientProperty.generateStaticItemType(contents: contents, isTappable: isTappable)
        return update(dataSource: &dataSource, at: propertyIndexPath, with: staticItemType, isTappable: isTappable)
    }
}

class ClientCollectionView: StaticItemCollectionView {

}
