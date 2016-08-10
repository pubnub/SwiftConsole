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

enum PubNubConfigurationProperty: String {
    case SubscribeKey = "Subscribe Key"
    case PublishKey = "Publish Key"
    case Origin
}

extension PNConfiguration {
    typealias KeyValue = (name: PubNubConfigurationProperty, value: String?)
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
            throw PubNubConfigurationCreationError.NilValue(propertyName: PubNubConfigurationProperty.PublishKey.rawValue)
        }
        guard let finalSubKey = subKey.value else {
            throw PubNubConfigurationCreationError.NilValue(propertyName: PubNubConfigurationProperty.SubscribeKey.rawValue)
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

enum PubNubSubscribableStringParsingError: ErrorType, CustomStringConvertible {
    case Empty
    case ChannelNameContainsInvalidCharacters(channel: String)
    case ChannelNameTooLong(channel: String)
    case OnlyWhitespace(channel: String)
    case Unknown(channel: String)
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
        case let .Unknown(channel):
            return channel + " is incorrect with unknown error"
        }
    }
}

enum PubNubPublishError: ErrorType, CustomStringConvertible {
    case NilMessage
    case NilChannel
    case MultipleChannels
    var description: String {
        switch self {
        case .NilMessage:
            return "Cannot publish without a message"
        case .NilChannel:
            return "Cannot publish without a channel"
        case .MultipleChannels:
            return "Cannot publish on multiple channels"
        }
    }
}

extension UIAlertController {
    static func alertControllerForPubNubPublishingError(error: PubNubPublishError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let title = "Publish error"
        let message = "Cannot publish because \(error)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
    static func alertControllerForPubNubStringParsingIntoSubscribablesArrayError(source: String?, error: PubNubSubscribableStringParsingError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let blame = source ?? "string Parsing"
        let title = "Issue with " + blame
        let message = "Could not parse " + blame + " into array because \(error)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
}

extension PubNub {
    func safePublish(message: AnyObject?, toChannel channel: String, withCompletion block: PNPublishCompletionBlock?) throws {
        guard let actualMessage = message else {
            throw PubNubPublishError.NilMessage
        }
        do {
            guard let channels = try PubNub.stringToSubscribablesArray(channel, commaDelimited: false) else {
                throw PubNubPublishError.NilChannel
            }
            guard channels.count < 2 else {
                throw PubNubPublishError.MultipleChannels
            }
            guard let publishChannel = channels.first else {
                throw PubNubSubscribableStringParsingError.Unknown(channel: channel)
            }
            self.publish(actualMessage, toChannel: publishChannel, withCompletion: block)
        } catch let channelStringError as PubNubSubscribableStringParsingError {
            throw channelStringError
        } catch let publishError as PubNubPublishError {
            throw publishError // probably a better way than catching and throwing the same error (maybe rethrow?)
        } catch {
            fatalError()
        }
    }
    // TODO: Implement this, should eventually be a universal function in the PubNub framework
    static func stringToSubscribablesArray(channels: String?, commaDelimited: Bool = true) throws -> [String]? {
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
                throw PubNubSubscribableStringParsingError.OnlyWhitespace(channel: channel)
            }
            guard channel.characters.count > 0 else {
                throw PubNubSubscribableStringParsingError.Empty
            }
            guard channel.characters.count <= 92 else {
                throw PubNubSubscribableStringParsingError.ChannelNameTooLong(channel: channel)
            }
            guard !channel.containsPubNubKeyWords else {
                throw PubNubSubscribableStringParsingError.ChannelNameContainsInvalidCharacters(channel: channel)
            }
        }
        return channelsArray
    }
    
    func channelsString() -> String? {
        return PubNub.subscribablesToString(self.channels())
    }
    func channelGroupsString() -> String? {
        return PubNub.subscribablesToString(self.channelGroups())
    }
    internal static func subscribablesToString(subscribables: [String]) -> String? {
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
    var isSubscribingToChannels: Bool {
        return !self.channels().isEmpty
    }
    var isSubscribingToChannelGroups: Bool {
        return !self.channelGroups().isEmpty
    }
    var isSubscribing: Bool {
        return isSubscribingToChannels || isSubscribingToChannelGroups
    }
}

