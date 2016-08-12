//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit
import PubNub

// This needs the bottom toolbar to deal with publish and other actions
@objc(PNCConsoleViewController)
public class ConsoleViewController: CollectionViewController, CollectionViewControllerDelegate, PublishViewControllerDelegate {
    
    // MARK: - DataSource
    
    final class ConsoleDataSource: BasicDataSource {
        required init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        
        convenience init(client: PubNub, subscribeButton: TargetSelector, channelPresenceButton: TargetSelector, channelGroupPresenceButton: TargetSelector, consoleSegmentedControl: TargetSelector) {
            let clientConfigSection = BasicSection(items: [ConsoleLabelItem(itemType: .publishKey, client: client), ConsoleLabelItem(itemType: .subscribeKey, client: client), ConsoleLabelItem(itemType: .uuid, client: client)])
            let subscribablesSection = BasicSection(items: [ConsoleUpdatableLabelItem(itemType: .channels, client: client), ConsoleUpdatableLabelItem(itemType: .channelGroups, client: client)])
            let subscribeButtonItem = ConsoleButtonItem(itemType: .subscribeButton, targetSelector: subscribeButton)
            let channelPresenceButtonItem = ConsoleButtonItem(itemType: .channelPresenceButton, targetSelector: channelPresenceButton)
            let channelGroupPresenceButtonItem = ConsoleButtonItem(itemType: .channelGroupPresenceButton, targetSelector: channelGroupPresenceButton)
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
            guard var consoleSection = self[ConsoleSectionType.console.rawValue] as? SelectableItemSection else {
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
            self[ConsoleSectionType.console.rawValue] = consoleSection
        }
        
        var selectedConsoleSegmentIndex: Int {
            guard let consoleSegment = self[ConsoleItemType.consoleSegmentedControl.indexPath] as? ConsoleSegmentedControlItem else {
                fatalError()
            }
            return consoleSegment.selectedSegmentIndex
        }
        var selectedConsoleSegment: ConsoleSegmentedControlItem.Segment {
            // forcefully unwrapped because let's catch any issue, this shouldn't cause a crash
            return ConsoleSegmentedControlItem.Segment(rawValue: selectedConsoleSegmentIndex)!
        }
        func updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex index: Int) -> Bool {
            return updateSelectedSegmentIndex(ConsoleItemType.consoleSegmentedControl, updatedSelectedSegmentIndex: index)
        }
        func updateConsoleSelectedSegmentIndex(updatedSelectedSegment segment: ConsoleSegmentedControlItem.Segment) -> Bool {
            return updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex: segment.rawValue)
        }
        func updateSelectedSection(_ selectedSegment: ConsoleSegmentedControlItem.Segment) {
            updateSelectedSection(selectedSegment.rawValue)
        }
        func updateSelectedSection(_ selectedSection: Int) {
            guard var selectableSection = self[ConsoleSectionType.console.rawValue] as? SelectableSection else {
                fatalError()
            }
            selectableSection.updateSelectedSection(selectedSection)
            self[ConsoleSectionType.console.rawValue] = selectableSection // do i need this for classes?
        }
        func push(_ item: Item, consoleSection: ConsoleSegmentedControlItem.Segment) -> IndexPath {
            return push(ConsoleSectionType.console.rawValue, subSection: consoleSection.rawValue, item: item)
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
            case all, subscribeStatuses, messages, presenceEvents
            var title: String {
                switch self {
                case .all:
                    return "All"
                case .subscribeStatuses:
                    return "Subscribes"
                case .messages:
                    return "Messages"
                case .presenceEvents:
                    return "Presence"
                }
            }
            var consoleItemType: ConsoleItemType {
                switch self {
                case .all:
                    // FIXME: come back to this, called by memory warning handler
                    return self.consoleItemType
                case .messages:
                    return ConsoleItemType.message
                case .subscribeStatuses:
                    return ConsoleItemType.subscribeStatus
                case .presenceEvents:
                    return ConsoleItemType.presenceEvent
                }
            }
            static var allValues: [Segment] {
                return [all, subscribeStatuses, messages, presenceEvents]
            }
            static var allValuesTitles: [String] {
                return allValues.map({ (segment) -> String in
                    segment.title
                })
            }
            
        }
        var selectedSegmentIndex: Int = Segment.all.rawValue
        let itemType: ItemType
        let items: [String]
        var targetSelector: TargetSelector
        init(itemType: ConsoleItemType, items: [String], targetSelector: TargetSelector) {
            self.itemType = itemType
            self.items = items
            self.targetSelector = targetSelector
        }
        init(items: [String], targetSelector: TargetSelector) {
            self.init(itemType: ConsoleItemType.consoleSegmentedControl, items: items, targetSelector: targetSelector)
        }
        init(targetSelector: TargetSelector) {
            self.init(items: Segment.allValuesTitles, targetSelector: targetSelector)
        }
        var defaultSelectedSegmentIndex: Int {
            return Segment.all.rawValue
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
        case clientConfig = 0, subscribables, subscribeLoopControls, consoleSegmentedControl, console
    }
    
    enum ConsoleItemType: ItemType {
        case publishKey
        case subscribeKey
        case uuid
        case channels
        case channelGroups
        case subscribeButton
        case channelPresenceButton
        case channelGroupPresenceButton
        case subscribeStatus
        case publishStatus
        case message
        case presenceEvent
        case consoleSegmentedControl
        indirect case console(ConsoleItemType)
        
        var cellClass: CollectionViewCell.Type {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return TitleContentsCollectionViewCell.self
            case .channels, .channelGroups:
                return TitleContentsCollectionViewCell.self
            case .channelPresenceButton, .channelGroupPresenceButton:
                return ButtonCollectionViewCell.self
            case .presenceEvent:
                return PresenceEventCollectionViewCell.self
            case .subscribeButton:
                return ButtonCollectionViewCell.self
            case .subscribeStatus:
                return SubscribeStatusCollectionViewCell.self
            case .publishStatus:
                return PublishStatusCollectionViewCell.self
            case .message:
                return MessageCollectionViewCell.self
            case .consoleSegmentedControl:
                return SegmentedControlCollectionViewCell.self
            case let .console(consoleItemType):
                switch consoleItemType {
                case .subscribeStatus, .message, .publishStatus:
                    return consoleItemType.cellClass
                default:
                    fatalError("Invalid type passed in")
                }
            }
        }
        
        func contents(_ client: PubNub) -> String {
            switch self {
            case .publishKey:
                return client.currentConfiguration().publishKey
            case .subscribeKey:
                return client.currentConfiguration().subscribeKey
            case .uuid:
                return client.currentConfiguration().uuid
            case .channels:
                return client.channelsString() ?? ""
            case .channelGroups:
                return client.channelGroupsString() ?? ""
            default:
                return ""
            }
        }
        
        var title: String {
            switch self {
            case .publishKey:
                return "Publish Key"
            case .subscribeKey:
                return "Subscribe Key"
            case .uuid:
                return "UUID"
            case .channels:
                return "Channels"
            case .channelGroups:
                return "Channel Groups"
            case .subscribeButton:
                return "Subscribe"
            case .channelPresenceButton:
                return "Channels No Presence"
            case .channelGroupPresenceButton:
                return "Channel Group No Presence"
            default:
                return ""
            }
        }
        
        var selectedTitle: String? {
            switch self {
            case .subscribeButton:
                return "Unsubscribe"
            case .channelPresenceButton:
                return "Channel Presence"
            case .channelGroupPresenceButton:
                return "Channel Group Presence"
            default:
                return nil
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .publishKey, .subscribeKey, .uuid:
                return ConsoleSectionType.clientConfig
            case .channels, .channelGroups:
                return ConsoleSectionType.subscribables
            case .subscribeButton, .channelPresenceButton, .channelGroupPresenceButton:
                return ConsoleSectionType.subscribeLoopControls
            case .subscribeStatus, .message, .publishStatus, .presenceEvent:
                return ConsoleSectionType.console
            case .consoleSegmentedControl:
                return ConsoleSectionType.consoleSegmentedControl
            case let .console(consoleItemType):
                switch consoleItemType {
                case .subscribeStatus, .message, .publishStatus, .presenceEvent:
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
            case .publishKey:
                return 0
            case .subscribeKey:
                return 1
            case .uuid:
                return 2
            case .channels:
                return 0
            case .channelGroups:
                return 1
            case .subscribeButton:
                return 1
            case .channelPresenceButton:
                return 0
            case .channelGroupPresenceButton:
                return 2
            case .subscribeStatus:
                return 0
            case .publishStatus:
                return 0
            case .message:
                return 0
            case .presenceEvent:
                return 0
            case .consoleSegmentedControl:
                return 0
            case let .console(consoleItemType):
                switch consoleItemType {
                case .subscribeStatus, .message, .publishStatus, .presenceEvent:
                    return consoleItemType.item
                default:
                    print("Invalid type passed in")
                    fatalError("Invalid type passed in")
                }
            }
        }
    }
 
    // MARK: - Constructors
    public required init(client: PubNub) {
        super.init()
        self.client = client
    }
    
    public required init() {
        super.init()
        self.client?.add(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.client?.remove(self)
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
        collectionView.register(TitleContentsCollectionViewCell.self, forCellWithReuseIdentifier: TitleContentsCollectionViewCell.reuseIdentifier)
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.register(SubscribeStatusCollectionViewCell.self, forCellWithReuseIdentifier: SubscribeStatusCollectionViewCell.reuseIdentifier)
        collectionView.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: MessageCollectionViewCell.reuseIdentifier)
        collectionView.register(SegmentedControlCollectionViewCell.self, forCellWithReuseIdentifier: SegmentedControlCollectionViewCell.reuseIdentifier)
        collectionView.register(PublishStatusCollectionViewCell.self, forCellWithReuseIdentifier: PublishStatusCollectionViewCell.reuseIdentifier)
        collectionView.register(PresenceEventCollectionViewCell.self, forCellWithReuseIdentifier: PresenceEventCollectionViewCell.reuseIdentifier)
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
            self.collectionView?.reloadSections(ConsoleSectionType.console.indexSet as IndexSet)
            }, completion: nil)
    }
    
    // MARK: - Actions
    
    enum SubscribePresenceChange {
        case channels
        case channelGroups
        var consoleItemType: ConsoleItemType {
            switch self {
            case .channels:
                return ConsoleItemType.channelPresenceButton
            case .channelGroups:
                return ConsoleItemType.channelGroupPresenceButton
            }
        }
        var indexPath: IndexPath {
            return consoleItemType.indexPath as IndexPath
        }
    }
    
    func toggleSubscribePresence(_ change: SubscribePresenceChange) {
        
        func alertControllerForInvalidPresenceChange() -> UIAlertController {
            let alertController = UIAlertController(title: "Invalid Presence Change", message: "Cannot change presence while subscribing", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            return alertController
        }
        
        guard let currentClient = self.client, !currentClient.isSubscribing else {
            let alertController = alertControllerForInvalidPresenceChange()
            present(alertController, animated: true, completion: nil)
            return
        }
        
        collectionView?.performBatchUpdates({
            self.dataSource?.toggleSelected(change.consoleItemType)
            self.collectionView?.reloadItems(at: [change.indexPath])
            }, completion: nil)
    }
    
    func channelPresenceButtonPressed(_ sender: UIButton!) {
        toggleSubscribePresence(.channels)
    }
    
    func channelGroupPresenceButtonPressed(_ sender: UIButton!) {
        toggleSubscribePresence(.channelGroups)
    }
    
    func subscribeButtonPressed(_ sender: UIButton!) {
        // TODO: clean this up
        if sender.isSelected {
            client?.unsubscribeFromAll()
            return
        }
        guard let currentDataSource = dataSource, let channelsItem = currentDataSource[ConsoleItemType.channels] as? ConsoleUpdatableLabelItem, let channelGroupsItem = currentDataSource[ConsoleItemType.channelGroups] as? ConsoleUpdatableLabelItem else {
            return
        }
        var channelPresence: Bool
        var channelGroupPresence: Bool
        if let channelPresenceItem = currentDataSource[ConsoleItemType.channelPresenceButton] as? ConsoleButtonItem, let channelGroupPresenceItem = currentDataSource[ConsoleItemType.channelGroupPresenceButton] as? ConsoleButtonItem {
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
                let alertController = UIAlertController(title: "Cannot subscribe", message: "Cannot subscribe with no channels and no channel grouups", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            case let (channels, nil) where channels != nil:
                client?.subscribe(toChannels: channels!, withPresence: channelPresence)
            case let (nil, channelGroups) where channelGroups != nil:
                client?.subscribe(toChannelGroups: channelGroups!, withPresence: channelGroupPresence)
            default:
                client?.subscribe(toChannels: currentSubscribables.Channels!, withPresence: channelPresence)
                client?.subscribe(toChannelGroups: currentSubscribables.ChannelGroups!, withPresence: channelGroupPresence)
            }
        } catch let pubNubError as PubNubSubscribableStringParsingError {
//            let alertController = UIAlertController.alertControllerForPubNubStringParsingIntoSubscribablesArrayError(channelsItem.title, error: pubNubError, handler: nil)
//            present(alertController, animated: true, completion: nil)
            return
        } catch {
            fatalError(#function + " error: \(error)")
        }
    }
    
    func consoleSegmentedControlValueChanged(_ sender: UISegmentedControl!) {
        collectionView?.performBatchUpdates({
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            let shouldUpdate = currentDataSource.updateConsoleSelectedSegmentIndex(updatedSelectedSegmentIndex: sender.selectedSegmentIndex)
            if (shouldUpdate) {
                currentDataSource.updateSelectedSection(sender.selectedSegmentIndex)
                self.collectionView?.reloadSections(ConsoleSectionType.console.indexSet as IndexSet)
            }
            }, completion: nil)
    }
    
    // MARK: - CollectionViewControllerDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didUpdateItemWithTextFieldAlertControllerAtIndexPath indexPath: IndexPath, selectedAlertAction: UIAlertAction, updatedTextFieldString updatedString: String?) {
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
    
    public func publishView(_ publishView: PublishViewController, receivedPublishStatus status: PNPublishStatus) {
        self.collectionView?.performBatchUpdates({ 
            let publishStatus = PublishStatus(itemType: ConsoleItemType.publishStatus, publishStatus: status)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the index path is the same for both calls
            let publishStatusIndexPath = currentDataSource.push(publishStatus, consoleSection: .all)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .all {
                self.collectionView?.insertItems(at: [publishStatusIndexPath])
            }
            }, completion: nil)
    }
    
    // MARK: - Update from Client
    
    public func updateSubscribableLabelCells() {
        collectionView?.performBatchUpdates({ 
            self.dataSource?.updateTitleContents(ConsoleItemType.channels.indexPath, updatedContents: self.client?.channelsString())
            self.dataSource?.updateTitleContents(ConsoleItemType.channelGroups.indexPath, updatedContents: self.client?.channelGroupsString())
            self.collectionView?.reloadItems(at: [ConsoleItemType.channels.indexPath as IndexPath, ConsoleItemType.channelGroups.indexPath as IndexPath])
            }, completion: nil)
    }
    
    public func updateSubscribeButtonState() {
        guard let currentClient = self.client else {
            return
        }
        collectionView?.performBatchUpdates({ 
            let subscribing = currentClient.isSubscribing
            let indexPath = ConsoleItemType.subscribeButton.indexPath
            self.dataSource?.updateSelected(indexPath, selected: subscribing)
            self.collectionView?.reloadItems(at: [indexPath as IndexPath])
            }, completion: nil)
    }
    
    // MARK: - PNObjectEventListener
    
    public func client(_ client: PubNub, didReceiveStatus status: PNStatus) {
        if (
            (status.operation == .subscribeOperation) ||
            (status.operation == .unsubscribeOperation)
            ){
            collectionView?.performBatchUpdates({
                // performBatchUpdates is nestable, so let's update other sections first
                self.updateSubscribableLabelCells() // this ensures we receive updates to available channels and channel groups even if the changes happen outside the scope of this view controller
                self.updateSubscribeButtonState()
                let subscribeStatus = SubscribeStatus(itemType: ConsoleItemType.subscribeStatus, status: status)
                guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                    return
                }
                // the index path is the same for both calls
                let subscribeStatusIndexPath = currentDataSource.push(subscribeStatus, consoleSection: .subscribeStatuses)
                currentDataSource.push(subscribeStatus, consoleSection: .all)
                let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
                if currentSegmentedControlValue == .all || currentSegmentedControlValue == .subscribeStatuses {
                    self.collectionView?.insertItems(at: [subscribeStatusIndexPath])
                }
                }, completion: nil)
        }
    }
    
    public func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        collectionView?.performBatchUpdates({
            let receivedPresenceEvent = PresenceEvent(itemType: ConsoleItemType.presenceEvent, event: event)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the indexPath is the same for both calls
            let presenceEventIndexPath = currentDataSource.push(receivedPresenceEvent, consoleSection: .presenceEvents)
            currentDataSource.push(receivedPresenceEvent, consoleSection: .all)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .all || currentSegmentedControlValue == .presenceEvents {
                self.collectionView?.insertItems(at: [presenceEventIndexPath])
            }
            }, completion: nil)
    }
    
    public func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        collectionView?.performBatchUpdates({
            let receivedMessage = Message(itemType: ConsoleItemType.message, message: message)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            // the indexPath is the same for both calls
            let messageIndexPath = currentDataSource.push(receivedMessage, consoleSection: .messages)
            currentDataSource.push(receivedMessage, consoleSection: .all)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .all || currentSegmentedControlValue == .messages {
                self.collectionView?.insertItems(at: [messageIndexPath])
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
