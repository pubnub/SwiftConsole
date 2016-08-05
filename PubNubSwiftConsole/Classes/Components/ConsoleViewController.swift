//
//  ConsoleViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/26/16.
//
//

import UIKit
import PubNub

public class ConsoleViewController: CollectionViewController, CollectionViewControllerDelegate {
    
    // MARK: - DataSource
    
    class ConsoleDataSource: BasicDataSource {
        required override init(sections: [ItemSection]) {
            super.init(sections: sections)
        }
        convenience init(client: PubNub, subscribeButton: TargetSelector, consoleSegmentedControl: TargetSelector) {
            let subscribablesSection = BasicSection(items: [ConsoleUpdateableLabelItem(itemType: .Channels, client: client), ConsoleUpdateableLabelItem(itemType: .ChannelGroups, client: client)])
            let subscribeButtonItem = ConsoleButtonItem(itemType: .SubscribeButton, targetSelector: subscribeButton)
            let subscribeLoopButtonsSection = BasicSection(items: [subscribeButtonItem])
            let consoleSegmentedControl = ConsoleSegmentedControlItem(targetSelector: consoleSegmentedControl)
            let segmentedControlSection = SingleSegmentedControlSection(segmentedControl: consoleSegmentedControl)
            let allSection = ScrollingSection()
            let subscribeStatusSection = ScrollingSection()
            let messageSection = ScrollingSection()
            let consoleSection = SelectableSection(selectableItemSections: [allSection, subscribeStatusSection, messageSection])
            self.init(sections: [subscribablesSection, subscribeLoopButtonsSection, segmentedControlSection, consoleSection])
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
        var selectedConsoleSegmentItemType: ConsoleItemType {
            return selectedConsoleSegment.consoleItemType
        }
        func updateSelectedSection(selectedSection: Int) {
            guard var selectableSection = self[selectedConsoleSegmentItemType.section] as? SelectableSection else {
                fatalError()
            }
            selectableSection.updateSelectedSection(selectedSection)
//            self[selectedConsoleSegmentItemType.section] = selectableSection // do i need this for classes?
        }
    }
    
    struct ConsoleSubscribeStatusItem: SubscribeStatusItem {
        let itemType: ItemType
        let category: String
        let operation: String
        let creationDate: NSDate
        let statusCode: Int
        var timeToken: NSNumber?
        init(itemType: ConsoleItemType, status: PNStatus) {
            self.itemType = itemType
            self.category = status.stringifiedCategory()
            self.operation = status.stringifiedOperation()
            self.creationDate = NSDate()
            self.statusCode = status.statusCode
            if let subscribeStatus = status as? PNSubscribeStatus {
                self.timeToken = subscribeStatus.data.timetoken
            }
        }
        init(status: PNStatus) {
            self.init(itemType: .SubscribeStatus, status: status)
        }
        var reuseIdentifier: String {
            return SubscribeStatusCollectionViewCell.reuseIdentifier
        }
    }
    
    struct ConsoleMessageItem: MessageItem {
        let itemType: ItemType
        let payload: AnyObject?
        init(itemType: ConsoleItemType, message: PNMessageResult) {
            self.itemType = itemType
            self.payload = message.data.message
        }
        init(message: PNMessageResult) {
            self.init(itemType: .Message, message: message)
        }
        var reuseIdentifier: String {
            return MessageCollectionViewCell.reuseIdentifier
        }
    }
    
    struct ConsoleUpdateableLabelItem: UpdateableLabelItem {
        let itemType: ItemType
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
        
        var contents: String
        var reuseIdentifier: String {
            return UpdateableLabelCollectionViewCell.reuseIdentifier
        }
        
    }
    
    struct ConsoleSegmentedControlItem: SegmentedControlItem {
        enum Segment: Int {
            case All, SubscribeStatuses, Messages
            var title: String {
                switch self {
                case .All:
                    return "All"
                case .SubscribeStatuses:
                    return "Subscribes"
                case .Messages:
                    return "Messages"
                }
            }
            var consoleItemType: ConsoleItemType {
                switch self {
                case .All:
                    return ConsoleItemType.All
                case .Messages:
                    return ConsoleItemType.Message
                case .SubscribeStatuses:
                    return ConsoleItemType.SubscribeStatus
                }
            }
            static var allValues: [Segment] {
                return [All, SubscribeStatuses, Messages]
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
        var reuseIdentifier: String {
            return SegmentedControlCollectionViewCell.reuseIdentifier
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
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
        
        
    }
    
    enum ConsoleSectionType: Int, ItemSectionType {
        case Subscribables = 0, SubscribeLoopControls, ConsoleSegmentedControl, Console
    }
    
    enum ConsoleItemType: ItemType {
        case Channels
        case ChannelGroups
        case SubscribeButton
        case All
        case SubscribeStatus
        case Message
        case ConsoleSegmentedControl
        indirect case Console(ConsoleItemType)
        
        func size(collectionViewSize: CGSize) -> CGSize {
            switch self {
            case .Channels, .ChannelGroups:
                return CGSize(width: 150.0, height: 125.0)
            case .SubscribeButton:
                return CGSize(width: 250.0, height: 100.0)
            case .SubscribeStatus, .Message, .All:
                return CGSize(width: collectionViewSize.width, height: 150.0)
            case .ConsoleSegmentedControl:
                return CGSize(width: 300.0, height: 75.0)
            case let Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .All:
                    return consoleItemType.size(collectionViewSize)
                default:
                    fatalError("Invalid type passed in")
                }
            }
        }
        
        
        func contents(client: PubNub) -> String {
            switch self {
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
            case .Channels:
                return "Channels"
            case .ChannelGroups:
                return "Channel Groups"
            case .SubscribeButton:
                return "Subscribe"
            default:
                return ""
            }
        }
        
        var selectedTitle: String? {
            switch self {
            case .SubscribeButton:
                return "Unsubscribe"
            default:
                return nil
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .Channels, .ChannelGroups:
                return ConsoleSectionType.Subscribables
            case .SubscribeButton:
                return ConsoleSectionType.SubscribeLoopControls
            case .SubscribeStatus, .Message, .All:
                return ConsoleSectionType.Console
            case .ConsoleSegmentedControl:
                return ConsoleSectionType.ConsoleSegmentedControl
            case let .Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .All:
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
            case .Channels:
                return 0
            case .ChannelGroups:
                return 1
            case .SubscribeButton:
                return 0
            case .SubscribeStatus:
                return 0
            case .Message:
                return 0
            case .All:
                return 0
            case .ConsoleSegmentedControl:
                return 0
            case let .Console(consoleItemType):
                switch consoleItemType {
                case .SubscribeStatus, .Message, .All:
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
        self.client?.addListener(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.client?.removeListener(self)
    }

    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        guard let currentClient = self.client else {
            return
        }
        dataSource = ConsoleDataSource(client: currentClient, subscribeButton: (self, #selector(self.subscribeButtonPressed(_:))), consoleSegmentedControl: (self, #selector(self.consoleSegmentedControlValueChanged(_:))))
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(UpdateableLabelCollectionViewCell.self, forCellWithReuseIdentifier: UpdateableLabelCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(SubscribeStatusCollectionViewCell.self, forCellWithReuseIdentifier: SubscribeStatusCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(MessageCollectionViewCell.self, forCellWithReuseIdentifier: MessageCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(SegmentedControlCollectionViewCell.self, forCellWithReuseIdentifier: SegmentedControlCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        collectionView?.performBatchUpdates({
            self.dataSource?.clear(ConsoleItemType.SubscribeStatus.section)
            self.dataSource?.clear(ConsoleItemType.Message.section)
            self.dataSource?.clear(ConsoleItemType.All.section)
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                fatalError()
            }
            self.collectionView?.reloadSections(currentDataSource.selectedConsoleSegment.consoleItemType.indexSet)
            }, completion: nil)
    }
    
    // MARK: - Actions
    func subscribeButtonPressed(sender: UIButton!) {
        // TODO: clean this up
        if sender.selected {
            client?.unsubscribeFromAll()
            return
        }
        guard let currentDataSource = dataSource, let channelsItem = currentDataSource[ConsoleItemType.Channels] as? ConsoleUpdateableLabelItem, let channelGroupsItem = currentDataSource[ConsoleItemType.ChannelGroups] as? ConsoleUpdateableLabelItem else {
            return
        }
        do {
            typealias SubscribablesTuple = (Channels: [String]?, ChannelGroups: [String]?)
            let currentSubscribables: SubscribablesTuple = (try client?.stringToSubscribablesArray(channelsItem.contents), try client?.stringToSubscribablesArray(channelGroupsItem.contents))
            switch currentSubscribables {
            case let (nil, nil):
                let alertController = UIAlertController(title: "Cannot subscribe", message: "Cannot subscribe with no channels and no channel grouups", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                presentViewController(alertController, animated: true, completion: nil)
            case let (channels, nil) where channels != nil:
                client?.subscribeToChannels(channels!, withPresence: true)
            case let (nil, channelGroups) where channelGroups != nil:
                client?.subscribeToChannelGroups(channelGroups!, withPresence: true)
            default:
                client?.subscribeToChannels(currentSubscribables.Channels!, withPresence: true)
                client?.subscribeToChannelGroups(currentSubscribables.ChannelGroups!, withPresence: true)
            }
        } catch let pubNubError as PubNubStringParsingError {
            let alertController = UIAlertController.alertControllerForPubNubStringParsingIntoSubscribablesArrayError(channelsItem.title, error: pubNubError, handler: nil)
            presentViewController(alertController, animated: true, completion: nil)
            return
        } catch {
            fatalError(#function + " error: \(error)")
        }
    }
    
    func consoleSegmentedControlValueChanged(sender: UISegmentedControl!) {
        collectionView?.performBatchUpdates({ 
            self.dataSource?.updateSelectedSegmentIndex(ConsoleItemType.ConsoleSegmentedControl.indexPath, updatedSelectedSegmentIndex: sender.selectedSegmentIndex)
            guard let currentSegmentedControlValue = ConsoleSegmentedControlItem.Segment(rawValue: sender.selectedSegmentIndex) else {
                fatalError()
            }
            guard let currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            self.dataSource?.updateSelectedSection(ConsoleItemType.Console(currentSegmentedControlValue.consoleItemType).section, selectedSubSection: currentSegmentedControlValue.rawValue)
            self.collectionView?.reloadSections(ConsoleItemType.Console(currentSegmentedControlValue.consoleItemType).indexSet)
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
    
    // MARK: - Update from Client
    
    public func updateSubscribableLabelCells() {
        collectionView?.performBatchUpdates({ 
            self.dataSource?.updateLabelContentsString(ConsoleItemType.Channels.indexPath, updatedContents: self.client?.channelsString())
            self.dataSource?.updateLabelContentsString(ConsoleItemType.ChannelGroups.indexPath, updatedContents: self.client?.channelGroupsString())
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
        print(status.debugDescription)
        if (
            (status.operation == .SubscribeOperation) ||
            (status.operation == .UnsubscribeOperation)
            ){
            collectionView?.performBatchUpdates({
                // performBatchUpdates is nestable, so let's update other sections first
                self.updateSubscribableLabelCells() // this ensures we receive updates to available channels and channel groups even if the changes happen outside the scope of this view controller
                self.updateSubscribeButtonState()
                let subscribeStatus = ConsoleSubscribeStatusItem(status: status)
                guard var currentDataSource = self.dataSource as? ConsoleDataSource else {
                    return
                }
                currentDataSource.push(ConsoleItemType.SubscribeStatus.section, subSection: ConsoleSegmentedControlItem.Segment.SubscribeStatuses.rawValue, item: subscribeStatus)
                currentDataSource.push(ConsoleItemType.All.section, subSection: ConsoleSegmentedControlItem.Segment.All.rawValue, item: subscribeStatus)
                let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
                if currentSegmentedControlValue == .All || currentSegmentedControlValue == .SubscribeStatuses {
                    self.collectionView?.reloadSections(currentDataSource.selectedConsoleSegment.consoleItemType.indexSet)
                }
                }, completion: nil)
        }
    }
    
    public func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        print(message.debugDescription)
        collectionView?.performBatchUpdates({ 
            let message = ConsoleMessageItem(message: message)
            guard var currentDataSource = self.dataSource as? ConsoleDataSource else {
                return
            }
            currentDataSource.push(ConsoleItemType.Message.section, subSection: ConsoleSegmentedControlItem.Segment.Messages.rawValue, item: message)
            currentDataSource.push(ConsoleItemType.All.section, subSection: ConsoleSegmentedControlItem.Segment.All.rawValue, item: message)
            let currentSegmentedControlValue = currentDataSource.selectedConsoleSegment
            if currentSegmentedControlValue == .All || currentSegmentedControlValue == .Messages {
                self.collectionView?.reloadSections(currentDataSource.selectedConsoleSegment.consoleItemType.indexSet)
            }
            }, completion: nil)
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Console"
    }

}
