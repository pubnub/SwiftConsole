//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit
import PubNub
import PubNubPersistence

// This needs the bottom toolbar to deal with publish and other actions
@objc(PNCConsoleViewController)
public class ConsoleViewController: CollectionViewController, CollectionViewControllerDelegate, PublishViewControllerDelegate {
    
    // MARK: - DataSource
    
    final class ConsoleDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        
        convenience init(client: PubNub, subscribeButton: TargetSelector, channelPresenceButton: TargetSelector, channelGroupPresenceButton: TargetSelector, consoleSegmentedControl: TargetSelector) {
            let clientConfigSection = BasicSection(items: [ConsoleLabelItem(itemType: .PublishKey, client: client), ConsoleLabelItem(itemType: .SubscribeKey, client: client), ConsoleLabelItem(itemType: .UUID, client: client)])
            let subscribablesSection = BasicSection(items: [ConsoleUpdatableLabelItem(itemType: .Channels, client: client), ConsoleUpdatableLabelItem(itemType: .ChannelGroups, client: client)])
            let subscribeButtonItem = ConsoleButtonItem(itemType: .SubscribeButton, targetSelector: subscribeButton)
            let channelPresenceButtonItem = ConsoleButtonItem(itemType: .ChannelPresenceButton, targetSelector: channelPresenceButton)
            let channelGroupPresenceButtonItem = ConsoleButtonItem(itemType: .ChannelGroupPresenceButton, targetSelector: channelGroupPresenceButton)
            let subscribeLoopButtonsSection = BasicSection(items: [channelPresenceButtonItem, subscribeButtonItem, channelGroupPresenceButtonItem])
            let consoleSegmentedControlItem = ConsoleSegmentedControlItem(targetSelector: consoleSegmentedControl)
            let segmentedControlSection = SingleSegmentedControlSection(segmentedControl: consoleSegmentedControlItem)
            let allSection = ScrollingSection()
            let subscribeStatusSection = ScrollingSection()
            let messageSection = ScrollingSection()
            let presenceEventSection = ScrollingSection()
            let consoleSection = SelectableSection(selectableItemSections: [allSection, subscribeStatusSection, messageSection, presenceEventSection])
            self.init(sections: [clientConfigSection, subscribablesSection, subscribeLoopButtonsSection, segmentedControlSection, consoleSection])
        }
        
        func clearConsoleSelectableSection() {
            guard var consoleSection = self[ConsoleSectionType.Console.rawValue] as? SelectableItemSection else {
                fatalError()
            }
            // we know that all sections are of type StackItemSection
            // because we built this ourselves
            let clearedStackSections = consoleSection.itemSections.map { (itemSection) -> ItemSection in
                guard var stackSection = itemSection as? StackItemSection else {
                    fatalError()
                }
                stackSection.clear()
                return stackSection as ItemSection
            }
            consoleSection.itemSections = clearedStackSections
            self[ConsoleSectionType.Console.rawValue] = consoleSection
        }
        
        var selectedConsoleSegmentIndex: Int {
            guard let consoleSegment = self[ConsoleItemType.ConsoleSegmentedControl.indexPath] as? ConsoleSegmentedControlItem else {
                fatalError()
            }
            return consoleSegment.selectedSegmentIndex
        }
        var selectedConsoleSegment: ConsoleSegmentedControlItem.Segment {
            // forcefully unwrapped because let's catch any issue, this shouldn't cause a crash
            return ConsoleSegmentedControlItem.Segment(rawValue: selectedConsoleSegmentIndex)!
        }
        func updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool {
            return updateSelectedSegmentIndex(ConsoleItemType.ConsoleSegmentedControl, updatedSelectedSegmentIndex: index)
        }
        func updateConsoleSelectedSegmentIndex(updatedSelectedSegment segment: ConsoleSegmentedControlItem.Segment) -> Bool {
            return updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex: segment.rawValue)
        }
        func updateSelectedSection(selectedSegment: ConsoleSegmentedControlItem.Segment) {
            updateSelectedSection(selectedSegment.rawValue)
        }
        func updateSelectedSection(selectedSection: Int) {
            guard var selectableSection = self[ConsoleSectionType.Console.rawValue] as? SelectableSection else {
                fatalError()
            }
            selectableSection.updateSelectedSection(selectedSection)
            self[ConsoleSectionType.Console.rawValue] = selectableSection // do i need this for classes?
        }
        func push(item: Item, consoleSection: ConsoleSegmentedControlItem.Segment) -> NSIndexPath {
            return push(ConsoleSectionType.Console.rawValue, subSection: consoleSection.rawValue, item: item)
        }
    }
    
    struct ConsoleLabelItem: TitleContentsItem {
        let itemType: ItemType
        var contents: String
        init(itemType: ConsoleItemType, contents: String) {
            self.itemType = itemType
            self.contents = contents
        }
        
        init(itemType: ConsoleItemType, client: PubNub) {
            self.init(itemType: itemType, contents: itemType.contents(client))
        }
    }
    
    struct ConsoleUpdatableLabelItem: UpdatableTitleContentsItem {
        let itemType: ItemType
        var contents: String
        init(itemType: ConsoleItemType) {
            self.init(itemType: itemType, contents: itemType.defaultValue)
        }
        
        init(itemType: ConsoleItemType, contents: String) {
            self.itemType = itemType
            self.contents = contents
        }
        
        init(itemType: ConsoleItemType, client: PubNub) {
            self.init(itemType: itemType, contents: itemType.contents(client))
        }
    }
    
    
    
    struct ConsoleSegmentedControlItem: SegmentedControlItem {
        enum Segment: Int {
            case All, SubscribeStatuses, Messages, PresenceEvents
            var title: String {
                switch self {
                case .All:
                    return "All"
                case .SubscribeStatuses:
                    return "Subscribes"
                case .Messages:
                    return "Messages"
                case .PresenceEvents:
                    return "Presence"
                }
            }
            var consoleItemType: ConsoleItemType {
                switch self {
                case .All:
                    return self.consoleItemType
                case .Messages:
                    return ConsoleItemType.Message
                case .SubscribeStatuses:
                    return ConsoleItemType.SubscribeStatus
                case .PresenceEvents:
                    return ConsoleItemType.PresenceEvent
                }
            }
            static var allValues: [Segment] {
                return [All, SubscribeStatuses, Messages, PresenceEvents]
            }
            static var allValuesTitles: [String] {
                return allValues.map({ (segment) -> String in
                    segment.title
                })
            }
            
        }
        var selectedSegmentIndex: Int = Segment.All.rawValue
        let itemType: ItemType
        let items: [String]
        var targetSelector: TargetSelector
        init(itemType: ConsoleItemType, items: [String], targetSelector: TargetSelector) {
            self.itemType = itemType
            self.items = items
            self.targetSelector = targetSelector
        }
        init(items: [String], targetSelector: TargetSelector) {
            self.init(itemType: ConsoleItemType.ConsoleSegmentedControl, items: items, targetSelector: targetSelector)
        }
        init(targetSelector: TargetSelector) {
            self.init(items: Segment.allValuesTitles, targetSelector: targetSelector)
        }
        var defaultSelectedSegmentIndex: Int {
            return Segment.All.rawValue
        }
    }
    
    struct ConsoleButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: ConsoleItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: ConsoleItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        
        var selected: Bool = false
        var targetSelector: TargetSelector
    }
    
    enum ConsoleSectionType: Int, ItemSectionType {
        case ClientConfig = 0, Subscribables, SubscribeLoopControls, ConsoleSegmentedControl, Console
    }
    
    enum ConsoleItemType: ItemType {
        case PublishKey
        case SubscribeKey
        case UUID
        case Channels
        case ChannelGroups
        case SubscribeButton
        case ChannelPresenceButton
        case ChannelGroupPresenceButton
        case SubscribeStatus
        case PublishStatus
        case Message
        case PresenceEvent
        case ConsoleSegmentedControl
        indirect case Console(ConsoleItemType)
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .PublishKey, .SubscribeKey, .UUID:
                return TitleContentsCollectionViewCell.self
            case .Channels, .ChannelGroups:
                return TitleContentsCollectionViewCell.self
            case .ChannelPresenceButton, .ChannelGroupPresenceButton:
                return ButtonCollectionViewCell.self
            case .PresenceEvent:
                return PresenceEventCollectionViewCell.self
            case .SubscribeButton:
                return ButtonCollectionViewCell.self
            case .SubscribeStatus:
                return SubscribeStatusCollectionViewCell.self
            case .PublishStatus:
                return PublishStatusCollectionViewCell.self
            case .Message:
                return MessageCollectionViewCell.self
            case .ConsoleSegmentedControl:
                return SegmentedControlCollectionViewCell.self
            case let Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .PublishStatus:
                    return consoleItemType.cellClass
                default:
                    fatalError("Invalid type passed in")
                }
            }
        }
        
        func contents(client: PubNub) -> String {
            switch self {
            case .PublishKey:
                return client.currentConfiguration().publishKey
            case .SubscribeKey:
                return client.currentConfiguration().subscribeKey
            case .UUID:
                return client.currentConfiguration().uuid
            case .Channels:
                return client.channelsString() ?? ""
            case .ChannelGroups:
                return client.channelGroupsString() ?? ""
            default:
                return ""
            }
        }
        
        var title: String {
            switch self {
            case .PublishKey:
                return "Publish Key"
            case .SubscribeKey:
                return "Subscribe Key"
            case .UUID:
                return "UUID"
            case .Channels:
                return "Channels"
            case .ChannelGroups:
                return "Channel Groups"
            case .SubscribeButton:
                return "Subscribe"
            case .ChannelPresenceButton:
                return "Channels No Presence"
            case .ChannelGroupPresenceButton:
                return "Channel Group No Presence"
            default:
                return ""
            }
        }
        
        var selectedTitle: String? {
            switch self {
            case .SubscribeButton:
                return "Unsubscribe"
            case .ChannelPresenceButton:
                return "Channel Presence"
            case .ChannelGroupPresenceButton:
                return "Channel Group Presence"
            default:
                return nil
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .PublishKey, .SubscribeKey, .UUID:
                return ConsoleSectionType.ClientConfig
            case .Channels, .ChannelGroups:
                return ConsoleSectionType.Subscribables
            case .SubscribeButton, .ChannelPresenceButton, .ChannelGroupPresenceButton:
                return ConsoleSectionType.SubscribeLoopControls
            case .SubscribeStatus, .Message, .PublishStatus, .PresenceEvent:
                return ConsoleSectionType.Console
            case .ConsoleSegmentedControl:
                return ConsoleSectionType.ConsoleSegmentedControl
            case let .Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .PublishStatus, .PresenceEvent:
                    return consoleItemType.sectionType
                default:
                    fatalError("Invalid type passed in")
                }
            }
        }
        
        var defaultValue: String {
            switch self {
            default:
                return ""
            }
        }
        
        var item: Int {
            switch self {
            case .PublishKey:
                return 0
            case .SubscribeKey:
                return 1
            case .UUID:
                return 2
            case .Channels:
                return 0
            case .ChannelGroups:
                return 1
            case .SubscribeButton:
                return 1
            case .ChannelPresenceButton:
                return 0
            case .ChannelGroupPresenceButton:
                return 2
            case .SubscribeStatus:
                return 0
            case .PublishStatus:
                return 0
            case .Message:
                return 0
            case .PresenceEvent:
                return 0
            case .ConsoleSegmentedControl:
                return 0
            case let .Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .PublishStatus, .PresenceEvent:
                    return consoleItemType.item
                default:
                    print("Invalid type passed in")
                    fatalError("Invalid type passed in")
                }
            }
        }
    }
 
    // MARK: - Constructors
    
    public required init(client: PubNub, persistence: PubNubPersistence) {
        super.init(persistence: persistence)
        self.client = client
        self.client?.addListener(self) // didSet isn't triggered in initialization
    }
    
    public convenience init(client: PubNub) {
        let persistenceConfig = PNPPersistenceConfiguration(client: client)
        let persistence = PubNubPersistence(configuration: persistenceConfig)
        self.init(client: client, persistence: persistence)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(persistence: PubNubPersistence?) {
        fatalError("init(persistence:) has not been implemented")
    }

    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        guard let currentClient = self.client else {
            return
        }
        let subscribeButton: TargetSelector = (self, #selector(self.subscribeButtonPressed(_:)))
        let channelPresenceButton: TargetSelector = (self, #selector(self.channelPresenceButtonPressed(_:)))
        let channelGroupPresenceButton: TargetSelector = (self, #selector(self.channelGroupPresenceButtonPressed(_:)))
        let consoleSegmentedControl: TargetSelector = (self, #selector(self.consoleSegmentedControlValueChanged(_:)))
        dataSource = ConsoleDataSource(client: currentClient, subscribeButton: subscribeButton, channelPresenceButton: channelPresenceButton, channelGroupPresenceButton: channelGroupPresenceButton, consoleSegmentedControl: consoleSegmentedControl)
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(SubscribeStatusCollectionViewCell.self, forCellWithReuseIdentifier: SubscribeStatusCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(MessageCollectionViewCell.self, forCellWithReuseIdentifier: MessageCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(SegmentedControlCollectionViewCell.self, forCellWithReuseIdentifier: SegmentedControlCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(PresenceEventCollectionViewCell.self, forCellWithReuseIdentifier: PresenceEventCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
        guard let navController = self.navigationController as? NavigationController else {
            return
        }
        let publishBarButtonItemItem = navController.publishBarButtonItem()
        // FIXME: this probably needs attention
        self.toolbarItems = [publishBarButtonItemItem]
    }
    
    // MARK: - Memory Warning
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        collectionView?.performBatchUpdates({
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                fatalError()
            }
            currentDataSource.clearConsoleSelectableSection()
            self.collectionView?.reloadSections(ConsoleSectionType.Console.indexSet)
            }, completion: nil)
    }
    
    // MARK: - Actions
    
    enum SubscribePresenceChange {
        case Channels
        case ChannelGroups
        var consoleItemType: ConsoleItemType {
            switch self {
            case .Channels:
                return ConsoleItemType.ChannelPresenceButton
            case .ChannelGroups:
                return ConsoleItemType.ChannelGroupPresenceButton
            }
        }
        var indexPath: NSIndexPath {
            return consoleItemType.indexPath
        }
    }
    
    func toggleSubscribePresence(change: SubscribePresenceChange) {
        
        func alertControllerForInvalidPresenceChange() -> UIAlertController {
            let alertController = UIAlertController(title: "Invalid Presence Change", message: "Cannot change presence while subscribing", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            return alertController
        }
        
        guard let currentClient = self.client where !currentClient.isSubscribing else {
            let alertController = alertControllerForInvalidPresenceChange()
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        collectionView?.performBatchUpdates({
            self.dataSource?.toggleSelected(change.consoleItemType)
            self.collectionView?.reloadItemsAtIndexPaths([change.indexPath])
            }, completion: nil)
    }
    
    func channelPresenceButtonPressed(sender: UIButton!) {
        toggleSubscribePresence(.Channels)
    }
    
    func channelGroupPresenceButtonPressed(sender: UIButton!) {
        toggleSubscribePresence(.ChannelGroups)
    }
    
    func subscribeButtonPressed(sender: UIButton!) {
        // TODO: clean this up
        if sender.selected {
            client?.unsubscribeFromAll()
            return
        }
        guard let currentDataSource = dataSource, let channelsItem = currentDataSource[ConsoleItemType.Channels] as? ConsoleUpdatableLabelItem, let channelGroupsItem = currentDataSource[ConsoleItemType.ChannelGroups] as? ConsoleUpdatableLabelItem else {
            return
        }
        var channelPresence: Bool
        var channelGroupPresence: Bool
        if let channelPresenceItem = currentDataSource[ConsoleItemType.ChannelPresenceButton] as? ConsoleButtonItem, let channelGroupPresenceItem = currentDataSource[ConsoleItemType.ChannelGroupPresenceButton] as? ConsoleButtonItem {
            channelPresence = channelPresenceItem.selected
            channelGroupPresence = channelGroupPresenceItem.selected
        } else {
            channelPresence = true
            channelGroupPresence = true
        }
        
        do {
            typealias SubscribablesTuple = (Channels: [String]?, ChannelGroups: [String]?)
            let currentSubscribables: SubscribablesTuple = (try PubNub.stringToSubscribablesArray(channelsItem.contents), try PubNub.stringToSubscribablesArray(channelGroupsItem.contents))
            switch currentSubscribables {
            case (nil, nil):
                let alertController = UIAlertController(title: "Cannot subscribe", message: "Cannot subscribe with no channels and no channel grouups", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                presentViewController(alertController, animated: true, completion: nil)
            case let (channels, nil) where channels != nil:
                client?.subscribeToChannels(channels!, withPresence: channelPresence)
            case let (nil, channelGroups) where channelGroups != nil:
                client?.subscribeToChannelGroups(channelGroups!, withPresence: channelGroupPresence)
            default:
                client?.subscribeToChannels(currentSubscribables.Channels!, withPresence: channelPresence)
                client?.subscribeToChannelGroups(currentSubscribables.ChannelGroups!, withPresence: channelGroupPresence)
            }
        } catch let pubNubError as PubNubSubscribableStringParsingError {
            let alertController = UIAlertController.alertControllerForPubNubStringParsingIntoSubscribablesArrayError(channelsItem.title, error: pubNubError, handler: nil)
            presentViewController(alertController, animated: true, completion: nil)
            return
        } catch {
            fatalError(#function + " error: \(error)")
        }
    }
    
    func consoleSegmentedControlValueChanged(sender: UISegmentedControl!) {
        collectionView?.performBatchUpdates({
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            let shouldUpdate = currentDataSource.updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex: sender.selectedSegmentIndex)
            if (shouldUpdate) {
                currentDataSource.updateSelectedSection(sender.selectedSegmentIndex)
                self.collectionView?.reloadSections(ConsoleSectionType.Console.indexSet)
            }
            }, completion: nil)
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: NSIndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?) {
        if let actionTitle = selectedAlertAction.title, let alertDecision = UIAlertController.ItemAction(rawValue: actionTitle) {
            switch (alertDecision) {
            case .OK:
                client?.unsubscribeFromAll() // unsubscribe whenever a subscribable is changed
            default:
                return
            }
        }
    }
    
    // MARK: - PublishViewControllerDelegate
    
    public func publishView(publishView: PublishViewController, receivedPublishStatus status: PNPublishStatus) {
        self.collectionView?.performBatchUpdates({ 
            let publishStatus = PublishStatus(itemType: ConsoleItemType.PublishStatus, publishStatus: status)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the index path is the same for both calls
            let publishStatusIndexPath = currentDataSource.push(publishStatus, consoleSection: .All)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .All {
                self.collectionView?.insertItemsAtIndexPaths([publishStatusIndexPath])
            }
            }, completion: nil)
    }
    
    // MARK: - Update from Client
    
    public func updateSubscribableLabelCells() {
        collectionView?.performBatchUpdates({ 
            self.dataSource?.updateTitleContents(ConsoleItemType.Channels.indexPath, updatedContents: self.client?.channelsString())
            self.dataSource?.updateTitleContents(ConsoleItemType.ChannelGroups.indexPath, updatedContents: self.client?.channelGroupsString())
            self.collectionView?.reloadItemsAtIndexPaths([ConsoleItemType.Channels.indexPath, ConsoleItemType.ChannelGroups.indexPath])
            }, completion: nil)
    }
    
    public func updateSubscribeButtonState() {
        guard let currentClient = self.client else {
            return
        }
        collectionView?.performBatchUpdates({ 
            let subscribing = currentClient.isSubscribing
            let indexPath = ConsoleItemType.SubscribeButton.indexPath
            self.dataSource?.updateSelected(indexPath, selected: subscribing)
            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
    
    // MARK: - PNObjectEventListener
    
    public func client(client: PubNub, didReceiveStatus status: PNStatus) {
        if (
            (status.operation == .SubscribeOperation) ||
            (status.operation == .UnsubscribeOperation)
            ){
            collectionView?.performBatchUpdates({
                // performBatchUpdates is nestable, so let's update other sections first
                self.updateSubscribableLabelCells() // this ensures we receive updates to available channels and channel groups even if the changes happen outside the scope of this view controller
                self.updateSubscribeButtonState()
                let subscribeStatus = SubscribeStatus(itemType: ConsoleItemType.SubscribeStatus, status: status)
                guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                    return
                }
                // the index path is the same for both calls
                let subscribeStatusIndexPath = currentDataSource.push(subscribeStatus, consoleSection: .SubscribeStatuses)
                currentDataSource.push(subscribeStatus, consoleSection: .All)
                let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
                if currentSegmentedControlValue == .All || currentSegmentedControlValue == .SubscribeStatuses {
                    self.collectionView?.insertItemsAtIndexPaths([subscribeStatusIndexPath])
                }
                }, completion: nil)
        }
    }
    
    public func client(client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        collectionView?.performBatchUpdates({
            let receivedPresenceEvent = PresenceEvent(itemType: ConsoleItemType.PresenceEvent, event: event)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the indexPath is the same for both calls
            let presenceEventIndexPath = currentDataSource.push(receivedPresenceEvent, consoleSection: .PresenceEvents)
            currentDataSource.push(receivedPresenceEvent, consoleSection: .All)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .All || currentSegmentedControlValue == .PresenceEvents {
                self.collectionView?.insertItemsAtIndexPaths([presenceEventIndexPath])
            }
            }, completion: nil)
    }
    
    public func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        collectionView?.performBatchUpdates({
            let receivedMessage = Message(itemType: ConsoleItemType.Message, message: message)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the indexPath is the same for both calls
            let messageIndexPath = currentDataSource.push(receivedMessage, consoleSection: .Messages)
            currentDataSource.push(receivedMessage, consoleSection: .All)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .All || currentSegmentedControlValue == .Messages {
                self.collectionView?.insertItemsAtIndexPaths([messageIndexPath])
            }
            }, completion: nil)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Console"
    }
    
    // MARK: - Toolbar
    
    public override var showsToolbar: Bool {
        return true
    }

}
