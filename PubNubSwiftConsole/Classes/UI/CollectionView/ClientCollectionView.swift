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
    case subscribe = "Subscribe"
    case unsubscribe = "Unsubscribe"
    case uuid = "UUID"
    case streamFilter = "Stream Filter"
    
    
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
            return "IQT-demo"
        case .origin:
            return "iqtdemo.pubnub.com"
        case .uuid:
            return UUID().uuidString
        case .authKey:
            return nil
        case .channels, .channelGroups, .streamFilter:
            return nil
        default:
            return nil
        }
    }
    
    func generateStaticItem(contents: String?, isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItem {
        switch self {
        case .pubKey, .subKey, .origin, .authKey, .channels, .channelGroups, .uuid, .streamFilter:
            return TitleContentsItem(title: title, contents: contents, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
        case .subscribe, .unsubscribe:
            return TitleItem(title: title, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
        }
    }
    
    func generateDefaultStaticItem(isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItem {
        return generateStaticItem(contents: defaultContents, isTappable: isTappable)
    }
    
    func generateDefaultStaticItemType(isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItemType {
        return generateStaticItemType(contents: defaultContents, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
    }
    
    func generateStaticItemType(contents: String?, isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(contents: contents, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor))
    }
    
    func generateStaticItem(client: PubNub, isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItem {
        return generateStaticItem(contents: generateContents(client: client), isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
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
        case .uuid:
            return client.uuid()
        case .subscribe, .unsubscribe:
            return nil
        case .streamFilter:
            return client.filterExpression
        }
    }
    
    func generateStaticItemType(client: PubNub, isTappable: Bool = false, overrideDefaultBackgroundColor: UIColor? = nil) -> StaticItemType {
        return StaticItemType(staticItem: generateStaticItem(client: client, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor))
    }
}

protocol ClientPropertyGetter: StaticItemGetter {
    func indexPath(for clientProperty: ClientProperty) -> IndexPath?
    func staticItem(from dataSource: StaticDataSource, for clientProperty: ClientProperty) -> StaticItem?
}

extension ClientPropertyGetter {
    func staticItem(from dataSource: StaticDataSource, for clientProperty: ClientProperty) -> StaticItem? {
        guard let indexPath = indexPath(for: clientProperty) else {
            return nil
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

class ClientCollectionView: StaticItemCollectionView { }
