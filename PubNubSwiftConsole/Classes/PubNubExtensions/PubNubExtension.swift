//
//  PubNubExtension.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
//
//

import Foundation
import PubNub

enum PubNubConfigurationCreationError: ErrorType, CustomStringConvertible {
    case NilValue(propertyName: String)
    case EmptyStringValue(propertyName: String)
    case OriginInvalid
    var description: String {
        switch self {
        case let .NilValue(name):
            return "Value for " + name + " property is nil"
        case let .EmptyStringValue(name):
            return "Value for " + name + " property is empty"
        case .OriginInvalid:
            return "Origin is invalid, it should be pubsub.pubnub.com or something specially provided"
        }
    }
}

extension UIAlertController {
    static func alertControllerForPubNubConfigurationCreationError(error: PubNubConfigurationCreationError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let title = "Cannot create client with configuration"
        let message = error.description
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
}

extension PNConfiguration {
    enum Property: String {
        case SubscribeKey = "Subscribe Key"
        case PublishKey = "Publish Key"
        case Origin
    }
    typealias KeyValue = (name: Property, value: String?)
    // TODO: clean this up
    convenience init(properties: KeyValue...) throws {
        var pubKey: KeyValue = (.PublishKey, nil)
        var subKey: KeyValue = (.SubscribeKey, nil)
        var otherProperties = [KeyValue]()
        for var pair in properties {
            guard let value = pair.value else {
                throw PubNubConfigurationCreationError.NilValue(propertyName: pair.name.rawValue)
            }
            guard value.characters.count > 0 else {
                throw PubNubConfigurationCreationError.EmptyStringValue(propertyName: pair.name.rawValue)
            }
            switch pair.name {
            case .SubscribeKey:
                subKey.value = value
            case .PublishKey:
                pubKey.value = value
            case .Origin:
                guard value.hasSuffix(".com") else {
                    throw PubNubConfigurationCreationError.OriginInvalid
                }
                pair.value = value
                otherProperties.append(pair)
            }
        }
        guard let finalPubKey = pubKey.value else {
            throw PubNubConfigurationCreationError.NilValue(propertyName: Property.PublishKey.rawValue)
        }
        guard let finalSubKey = subKey.value else {
            throw PubNubConfigurationCreationError.NilValue(propertyName: Property.SubscribeKey.rawValue)
        }
        self.init(publishKey: finalPubKey, subscribeKey: finalSubKey)
        for otherPropertyPair in otherProperties {
            switch otherPropertyPair.name {
            case .Origin:
                self.origin = otherPropertyPair.value!
            default:
                continue
            }
        }
    }
}

extension String {
    var isOnlyWhiteSpace: Bool {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        return self.stringByTrimmingCharactersInSet(whitespaceSet).isEmpty
    }
    var containsPubNubKeyWords: Bool {
        let keywordCharacterSet = NSCharacterSet(charactersInString: ",:.*/\\")
        if let _ = self.rangeOfCharacterFromSet(keywordCharacterSet, options: .CaseInsensitiveSearch) {
            return true
        }
        else {
            return false
        }
    }
}

enum PubNubStringParsingError: ErrorType, CustomStringConvertible {
    case Empty
    case ChannelNameContainsInvalidCharacters(channel: String)
    case ChannelNameTooLong(channel: String)
    case OnlyWhitespace(channel: String)
    var description: String {
        switch self {
        case .Empty:
            return "string has no length"
        case let .OnlyWhitespace(channel):
            return channel + " is only whitespace"
        case let .ChannelNameContainsInvalidCharacters(channel):
            return channel + " contains keywords that cannot be used with PubNub"
        case let .ChannelNameTooLong(channel):
            return channel + " is too long (over 92 characters)"
        }
    }
}

extension UIAlertController {
    static func alertControllerForPubNubStringParsingIntoSubscribablesArrayError(source: String?, error: PubNubStringParsingError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let blame = source ?? "string Parsing"
        let title = "Issue with " + blame
        let message = "Could not parse " + blame + " into array because \(error)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
}

extension PubNub {
    // TODO: Implement this, should eventually be a universal function in the PubNub framework
    func stringToSubscribablesArray(channels: String?, commaDelimited: Bool = true) throws -> [String]? {
        guard let actualChannelsString = channels else {
            return nil
        }
        // if the whole string is empty, then return nil
        guard !actualChannelsString.characters.isEmpty else {
            return nil
        }
        var channelsArray: [String]
        if commaDelimited {
            channelsArray = actualChannelsString.componentsSeparatedByString(",")
        } else {
            channelsArray = [actualChannelsString]
        }
        for channel in channelsArray {
            guard !channel.isOnlyWhiteSpace else {
                throw PubNubStringParsingError.OnlyWhitespace(channel: channel)
            }
            guard channel.characters.count > 0 else {
                throw PubNubStringParsingError.Empty
            }
            guard channel.characters.count <= 92 else {
                throw PubNubStringParsingError.ChannelNameTooLong(channel: channel)
            }
            guard !channel.containsPubNubKeyWords else {
                throw PubNubStringParsingError.ChannelNameContainsInvalidCharacters(channel: channel)
            }
        }
        return channelsArray
    }
    
    func channelsString() -> String? {
        return self.subscribablesToString(self.channels())
    }
    func channelGroupsString() -> String? {
        return self.subscribablesToString(self.channelGroups())
    }
    internal func subscribablesToString(subscribables: [String]) -> String? {
        if subscribables.isEmpty {
            return nil
        }
        return subscribables.reduce("", combine: { (accumulator: String, component) in
            if accumulator.isEmpty {
                return component
            }
            return accumulator + "," + component
        })
    }
}

