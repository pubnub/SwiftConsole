//
//  PubNubExtension.swift
//  Pods
//
//  Created by Jordan Zucker on 8/5/16.
//
//

import Foundation
import PubNub

enum PubNubConfigurationCreationError: CustomNSError, LocalizedError {
    case nilValue(propertyName: String)
    case emptyStringValue(propertyName: String)
    case originInvalid
    public static var errorDomain: String {
        return "PubNub"
    }
    public var errorCode: Int {
        return 100
    }
    public var errorUserInfo: [String : Any] {
        return ["description": errorDescription!]
    }
    var errorDescription: String? {
        switch self {
        case let .nilValue(name):
            return "Value for " + name + " property is nil"
        case let .emptyStringValue(name):
            return "Value for " + name + " property is empty"
        case .originInvalid:
            return "Origin is invalid, it should be pubsub.pubnub.com or something specially provided"
        }
    }
}

extension UIAlertController {
    static func alertController(error: Error, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        var title = "Unknown"
        var message = "unknown"
        switch error {
        case let creation as PubNubConfigurationCreationError:
            title = "Cannot create client with configuration"
            message = creation.localizedDescription
        case let publish as PubNubPublishError:
            title = "Publish error"
            message = "Cannot publish because \(publish.localizedDescription)"
        case let stringParsing as PubNubSubscribableStringParsingError:
            title = "what"
            message = "Channel "
        default:
            fatalError()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
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
                throw PubNubConfigurationCreationError.nilValue(propertyName: pair.name.rawValue)
            }
            guard value.characters.count > 0 else {
                throw PubNubConfigurationCreationError.emptyStringValue(propertyName: pair.name.rawValue)
            }
            switch pair.name {
            case .SubscribeKey:
                subKey.value = value
            case .PublishKey:
                pubKey.value = value
            case .Origin:
                guard value.hasSuffix(".com") else {
                    throw PubNubConfigurationCreationError.originInvalid
                }
                pair.value = value
                otherProperties.append(pair)
            }
        }
        guard let finalPubKey = pubKey.value else {
            throw PubNubConfigurationCreationError.nilValue(propertyName: PubNubConfigurationProperty.PublishKey.rawValue)
        }
        guard let finalSubKey = subKey.value else {
            throw PubNubConfigurationCreationError.nilValue(propertyName: PubNubConfigurationProperty.SubscribeKey.rawValue)
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
        let whitespaceSet = CharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespaceSet).isEmpty
    }
    var containsPubNubKeyWords: Bool {
        let keywordCharacterSet = CharacterSet(charactersIn: ",:.*/\\")
        if let _ = self.rangeOfCharacter(from: keywordCharacterSet, options: .caseInsensitive) {
            return true
        }
        else {
            return false
        }
    }
}

enum PubNubSubscribableStringParsingError: CustomNSError, LocalizedError {
    case empty
    case channelNameContainsInvalidCharacters(channel: String)
    case channelNameTooLong(channel: String)
    case onlyWhitespace(channel: String)
    case unknown(channel: String)
    public static var errorDomain: String {
        return "PubNub"
    }
    public var errorCode: Int {
        return 300
    }
    public var errorUserInfo: [String : Any] {
        return ["description": errorDescription!]
    }
    var errorDescription: String? {
        switch self {
        case .empty:
            return "string has no length"
        case let .onlyWhitespace(channel):
            return channel + " is only whitespace"
        case let .channelNameContainsInvalidCharacters(channel):
            return channel + " contains keywords that cannot be used with PubNub"
        case let .channelNameTooLong(channel):
            return channel + " is too long (over 92 characters)"
        case let .unknown(channel):
            return channel + " is incorrect with unknown error"
        }
    }
}

enum PubNubPublishError: CustomNSError, LocalizedError {
    case nilMessage
    case nilChannel
    case multipleChannels
    public static var errorDomain: String {
        return "PubNub"
    }
    public var errorCode: Int {
        return 200
    }
    public var errorUserInfo: [String : Any] {
        return ["description": errorDescription!]
    }
    var errorDescription: String? {
        switch self {
        case .nilMessage:
            return "Cannot publish without a message"
        case .nilChannel:
            return "Cannot publish without a channel"
        case .multipleChannels:
            return "Cannot publish on multiple channels"
        }
    }
}

extension PubNub {
    func safePublish(message: Any?, toChannel channel: String, mobilePushPayload push: [String : Any]?, withCompletion block: PNPublishCompletionBlock? = nil) throws {
        guard let actualMessage = message else {
            throw PubNubPublishError.nilMessage
        }
        do {
            guard let channels = try PubNub.stringToSubscribablesArray(channels: channel, commaDelimited: false) else {
                throw PubNubPublishError.nilChannel
            }
            guard channels.count < 2 else {
                throw PubNubPublishError.multipleChannels
            }
            guard let publishChannel = channels.first else {
                throw PubNubSubscribableStringParsingError.unknown(channel: channel)
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
    // should this be `rethrows`?
    func safePublish(message: Any?, toChannel channel: String, withCompletion block: PNPublishCompletionBlock? = nil) throws {
        do {
            try safePublish(message: message, toChannel: channel, mobilePushPayload: nil, withCompletion: block)
        } catch {
            throw error
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
            channelsArray = actualChannelsString.components(separatedBy: ",")
        } else {
            channelsArray = [actualChannelsString]
        }
        for channel in channelsArray {
            guard !channel.isOnlyWhiteSpace else {
                throw PubNubSubscribableStringParsingError.onlyWhitespace(channel: channel)
            }
            guard channel.characters.count > 0 else {
                throw PubNubSubscribableStringParsingError.empty
            }
            guard channel.characters.count <= 92 else {
                throw PubNubSubscribableStringParsingError.channelNameTooLong(channel: channel)
            }
            guard !channel.containsPubNubKeyWords else {
                throw PubNubSubscribableStringParsingError.channelNameContainsInvalidCharacters(channel: channel)
            }
        }
        return channelsArray
    }
    
    func channelsString() -> String? {
        return PubNub.subscribablesToString(subscribables: self.channels())
    }
    func channelGroupsString() -> String? {
        return PubNub.subscribablesToString(subscribables: self.channelGroups())
    }
    internal static func subscribablesToString(subscribables: [String]) -> String? {
        if subscribables.isEmpty {
            return nil
        }
        return subscribables.reduce("", { (accumulator: String, component) in
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

extension PNResult {
    var itemClass: AnyClass {
        switch self {
        case let publishStatus as PNPublishStatus:
            return PublishStatus.self
        case let subscribeStatus as PNSubscribeStatus:
            return SubscribeStatus.self
        case let message as PNMessageResult:
            return Message.self
        case let presenceEvent as PNPresenceEventResult:
            return PresenceEvent.self
        case let errorStatus as PNErrorStatus:
            return ErrorStatus.self
        case let status as PNStatus:
            return Status.self
        default:
            return Result.self
        }
    }
    
    func createItem(itemType: ItemType) -> ResultItem {
//        guard type(of: self.itemClass) is Result.Self else {
//            fatalError()
//        }
        guard let creatingType = self.itemClass as? Result.Type else {
            fatalError()
        }
        return creatingType.createResultItem(itemType: itemType, pubNubResult: self)
//        guard let creatingClass = type(of: self.itemClass) as? Result.Type else {
//            fatalError()
//        }
//        return creatingClass.createResultItem(itemType: itemType, pubNubResult: self)
    }
}

