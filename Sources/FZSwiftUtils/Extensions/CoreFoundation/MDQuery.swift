//
//  MDQuery.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

#if os(macOS)
import AppKit

public extension CFType where Self == MDQuery {
    /**
     Creates a new metadata query instance with the specified query string.
     
     - Note: You can't use `kMDItemPath`.
     
     - Parameters:
        - queryString: The query expression string for this query.
        - attributes: The metadata attributes whose values are gathered by the query.
        - sortingAttributses: The metadata attributes whose values are used to sort the results of the query.
     */
    init(queryString: String, attributes: [String] = [], sortingAttributes: [String] = []) {
        let attributes = attributes.filter({$0 != "kMDItemPath" }).uniqued()._bridgeToCF()
        let sortingAttributes = sortingAttributes.filter({$0 != "kMDItemPath" }).uniqued()
        self = MDQueryCreate(.default, queryString as CFString, attributes, sortingAttributes._bridgeToCF())
        (self as MDQuery).setupSortComparator()
    }
    
    /**
     Creates a new metadata query instance that gathers the specified attributes.
     
     - Note: You can't use `kMDItemPath`.
     
     - Parameters:
        - attributes: The metadata attributes whose values are gathered by the query.
        - sortingAttributses: The metadata attributes whose values are used to sort the results of the query.
     */
    init(attributes: [String], sortingAttributes: [String] = []) {
        self.init(queryString: #"kMDItemContentTypeTree == "public.item""#, attributes: attributes, sortingAttributes: sortingAttributes)
    }
}

public extension MDQuery {
   /**
    he maximum number of results returned.
    
    The property must be set before the query is started.
    */
    var maxCount: Int {
        get { getAssociatedValue("maxCount", object: self) ?? 0 }
        set {
            setAssociatedValue(newValue, key: "maxCount", object: self)
            MDQuerySetMaxCount(self, newValue)
        }
    }
   
    /// The dispatch queue on which query results will be delivered by MDQueryExecute.
    var dispatchQueue: DispatchQueue? {
        get { getAssociatedValue("dispatchQueue", object: self) }
        set {
            setAssociatedValue(newValue, key: "dispatchQueue", object: self)
            MDQuerySetDispatchQueue(self, newValue)
        }
    }
   
    /// Returns the query string of the query.
    var queryString: String {
        MDQueryCopyQueryString(self) as String
    }
   
    /// Returns the attribute names used to sort the results.
    var sortingAttributes: [String] {
        MDQueryCopySortingAttributes(self) as! [CFString] as [String]
    }
   
    /// Returns the attribute names for which values are being collected by the query.
    var valueListAttributes: [String] {
        MDQueryCopyValueListAttributes(self) as! [CFString] as [String]
    }
    
    /**
     The interval at which the results gets updated with accumulated changes.
     
     This value is advisory, in that the update will be triggered at some point after the specified seconds passed since the last update.
     */
    var resultUpdateInterval: TimeDuration {
        get { resultUpdateOptions.gatheringInterval }
        set {
            resultUpdateOptions.gatheringInterval = newValue
            resultUpdateOptions.monitoringInterval = newValue
        }
    }
    
    /// The maximum number of changes that can accumulate before updating the results.
    var resultUpdateThreshold: Int {
        get { resultUpdateOptions.gatheringThreshold }
        set {
            resultUpdateOptions.gatheringThreshold = newValue
            resultUpdateOptions.monitoringThreshold = newValue
        }
    }
    
    /**
     The current parameters that control for when the query updates it's results.
     
     This provides more granular configuration options compared to ``resultUpdateInterval`` and ``resultUpdateThreshold``.
     */
    internal var resultUpdateOptions: ResultUpdateOptions {
        get { .init(MDQueryGetBatchingParameters(self)) }
        set { runWithOperationQueue { MDQuerySetBatchingParameters(self, newValue.batching) } }
    }
   
    /**
     Attempts to start the query.
          
     A query can’t be started if the receiver is already running a query or no predicate has been specified.
          
     - Returns; `true` when successful; otherwise, `false`. A query may fail to start if it does not specify a predicate, or if the query has already been started.
     */
    @discardableResult
    func start() -> Bool {
        guard !isStarted else { return false }
        let isExecuting = runWithOperationQueue {
            MDQueryExecute(self, options.rawValue)
        }
        guard isExecuting else { return false }
        isStarted = true
        isStopped = false
        notificationTokens = []
        notificationTokens += NotificationCenter.default.observe(MDQuery.MDQueryDidFinishGatheringNotification, object: self) { [weak self] _ in
            guard let self = self else { return }
            
        }
        NotificationCenter.default.post(name: MDQuery.MDQueryDidStartGatheringNotification, object: self)
        return true
    }
   
    /**
     Stops the receiver’s current query from gathering any further results.
     
     The receiver first completes gathering any unprocessed results. If a query is stopped before the gathering phase finishes, it does not post an NSMetadataQueryDidStartGatheringNotification notification.
     
     You call this function to stop a query that is generating too many results to be useful but you still want to access the available results. If the receiver is sent a startQuery message after performing this method, the existing results are discarded.
     */
    func stop() {
        guard isStarted else { return }
        MDQueryStop(self)
        isStarted = false
        isStopped = true
        notificationTokens = []
    }
    
    /**
     A Boolean value that indicates whether the query has started.
     
     This property contains true when the receiver has executed the startQuery method; otherwise, false.
     */
    private(set) var isStarted: Bool {
        get { getAssociatedValue("isStarted", object: self) ?? false }
        set { setAssociatedValue(newValue, key: "isStarted", object: self) }
    }
   
    /**
     A Boolean value that indicates whether the receiver is in the initial gathering phase of the query.
     
     This property contains true when the query is in the initial gathering phase; otherwise, false.
     */
    var isGathering: Bool {
        isStarted && !MDQueryIsGatheringComplete(self)
    }
   
    /**
     A Boolean value that indicates whether the query has stopped.
     
     This property contains true when the receiver has stopped the query; otherwise, false.
     */
    private(set) var isStopped: Bool {
        get { getAssociatedValue("isStopped", object: self) ?? true }
        set { setAssociatedValue(newValue, key: "isStopped", object: self) }
    }
   
    /// Enables updates to the query results.
    func enableUpdates() {
        MDQueryEnableUpdates(self)
        isDisabled = false
    }
    
    /// Disables updates to the query results.
    func disableUpdates() {
        MDQueryDisableUpdates(self)
        isDisabled = true
    }
   
    /// The number of results returned by the query.
    var resultCount: Int {
        MDQueryGetResultCount(self) as Int
    }
   
    /**
     Returns the index of a query result object in the receiver’s results array.
     
     - Parameter item: The query result object being inquired about.
     - Returns: Index of result in the query result array.
     */
    func index(of item: AnyObject) -> Int {
        return runDisabled {
            MDQueryGetIndexOfResult(self, UnsafeRawPointer(Unmanaged.passUnretained(item).toOpaque())) as Int
        }
    }
   
    /**
     Returns the query result at a specific index.
     
     - Parameter index: The index of the desired result in the query result array.
     - Returns: The query result at the position specified by idx. By default, this method returns an `MDQuery` object representing the requested result; however, the query’s delegate can substitute this object with an instance of a different class.
     */
    func item(at index: Int) -> AnyObject? {
        return runDisabled {
            _item(at: index)
        }
    }
    
    private func _item(at index: Int) -> AnyObject? {
        guard let rawPointer = MDQueryGetResultAtIndex(self, index as CFIndex) else { return nil }
        return Unmanaged<MDItem>.fromOpaque(rawPointer).takeUnretainedValue()
    }
    
    /// An array containing the query’s results.
    var results: [Any] {
        runDisabled {
            (0..<resultCount).compactMap({ _item(at: $0) })
        }
    }
    
    /**
     Returns the value for the attribute name attrName at the index in the results specified by idx.
     
     - Parameters:
        - attributeName: The attribute of the result object at idx being inquired about. The attribute must be specified in valueListAttributes, as a sorting key in a specified sort descriptor, or as one of the grouping attributes specified set for the query.
        - index: The index of the desired return object in the query results array.
     - Returns: Value for attrName in the result object at idx in the query result array.
     */
    func value(ofAttribute attributeName: String, forResultAt index: Int) -> Any? {
        guard let rawPointer = MDQueryGetAttributeValueOfResultAtIndex(self, attributeName as CFString, index as CFIndex) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(rawPointer).takeUnretainedValue()
    }
   
    /**
     An array of search scopes to search at.
     
     The query searches for items at the search scopes. The default value is an empty array which indicates that there is no limitation on where the query searches.
     
     The query can alternativly also search at specific file-system directories via ``searchLocations``.
     
     - Note: Setting this property while a query is running stops the query, discards the current results and immediately starts a new query.
     */
    var searchScopes: [SearchScope] {
        get { getAssociatedValue("searchScopes", object: self) ?? [] }
        set {
            setAssociatedValue([URL](), key: "searchLocations", object: self)
            setAssociatedValue(newValue, key: "searchScopes", object: self)
            runWithOperationQueue {
                MDQuerySetSearchScope(self, newValue.map({$0.rawValue}) as [CFString] as CFArray, 0)
            }
        }
    }
   
    /**
     An array of file-system directory URLs to search at.
     
     The query searches for items at these search locations. An empty array indicates that there is no limitation on where the query searches.
     
     The query can alternativly also search at specific scopes via ``searchScopes``.
     
     - Note: Setting this property while a query is running stops the query, discards the current results and immediately starts a new query.
     */
    var searchLocations: [URL] {
        get { getAssociatedValue("searchLocations", object: self) ?? [] }
        set {
            setAssociatedValue([String](), key: "searchScopes", object: self)
            setAssociatedValue(newValue, key: "searchLocations", object: self)
            runWithOperationQueue {
                MDQuerySetSearchScope(self, newValue as [CFURL] as CFArray, 0)
            }
        }
    }
    
    /**
     A Boolean value indicating whether the monitoring of changes to the results is enabled.
               
     If set to `true`, updates are triggered after gathering the initial results, when…
     - …an item starts or stops matching the ``predicate``
     - …an item changes of it's attributes specified in ``attributes``, ``groupingAttributes`` or ``sortedBy``.
          
     Items that begin to match the query are added to ``results``, while items that no longer match are removed.
     
     The ``resultsHandler`` gets called for any changes.
     
     The default value is `false`,
          
     In the following example the result handler is called whenever a screenshot is captured or deleted.
     
     ```swift
     query.predicate = { $0.isScreenCapture }
     query.monitorResults = true
     query.resultsHandler = { items, _ in
     // Is called whenever a new screenshot is taken.
     }
     query.start()
     ```
     */
    var monitorResults: Bool {
        get { getAssociatedValue("monitorResults", object: self) ?? false }
        set {
            setAssociatedValue(newValue, key: "monitorResults", object: self)
        }
    }
    
    /**
     A Boolean value indicating whether the query blocks during the initial gathering phase.
     
     It’s run loop will run in the default mode.
     
     The default value is `false`.
     */
    var isSynchronous: Bool {
        get { options.contains(.synchronous) }
        set {
            guard newValue != isSynchronous else { return }
            options[.synchronous] = newValue
        }
    }
    
    private var options: Options {
        get { getAssociatedValue("options", object: self) ?? [] }
        set { setAssociatedValue(newValue, key: "options", object: self) }
    }
    
    /// Posted when the receiver begins with the initial result-gathering phase of the query.
    static let MDQueryDidStartGatheringNotification = Notification.Name("MDQueryDidStartGathering")
    /// Posted as the receiver is collecting results during the initial result-gathering phase of the query.
    static let MDQueryGatheringProgressNotification = Notification.Name(kMDQueryProgressNotification as String)
    /// Posted when the receiver has finished with the initial result-gathering phase of the query.
    static let MDQueryDidFinishGatheringNotification = Notification.Name(kMDQueryDidFinishNotification as String)
    /// Posted when the receiver’s results have changed during the live-update phase of the query.
    static let MDQueryDidUpdateNotification = Notification.Name(kMDQueryDidUpdateNotification as String)
   
    /// The handlers of the metadata query.
    var handlers: Handlers {
        get { getAssociatedValue("handlers", object: self) ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers", object: self)
            setupHandlers(newValue)
        }
    }
    
    /// The handlers of a metadata query.
    struct Handlers {
        /**
         Returns a different object for a given query result object.
         
         By default query result objects are instances of the `MDQuery` class. By providing this handler, you can return an object of a different class type for the specified result object.
         
         - Parameter result: The query result object to replace.
         - Returns: Object that replaces the query result object.
         */
        public var replacementObject: ((_ result: MDItem)->(AnyObject))?
        /**
         Returns a different value for a given attribute and value.
         
         By providing this handler, you can onvert specific query attribute values to other attribute values, for example, converting date object values to formatted strings for display.
         
         - Parameter attributeName: The attribute in question.
         - Returns: The attribute value to replace.
         */
        public var replacementValue: ((_ attributeName: String, _ value: AnyObject)->(AnyObject))?
    }
    
    private func setupHandlers(_ newValue: Handlers) {
        if let replacementObject = newValue.replacementObject {
            let createResultFunction: MDQueryCreateResultFunction = { query, item, context in
                guard let item = item, let context = context else { return nil }
                let wrapper = Unmanaged<ReplacementObjectWrapper>.fromOpaque(context).takeUnretainedValue()
                return UnsafeRawPointer(Unmanaged.passUnretained(wrapper.handler(item)).toOpaque())
            }
            self.replacementObjectWrapper = ReplacementObjectWrapper(replacementObject)
            let contextPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(replacementObjectWrapper!).toOpaque())
            MDQuerySetCreateResultFunction(self, createResultFunction, contextPointer, nil)
        } else if replacementObjectWrapper != nil {
            MDQuerySetCreateResultFunction(self, nil, nil, nil)
            replacementObjectWrapper = nil
        }
       
        if let replacementValue = newValue.replacementValue {
            let createValueFunction: MDQueryCreateValueFunction = { query, attribute, value, context in
                guard let attribute = attribute as? String, let _value = value, let value = (_value as? any _ObjectiveCBridgeable)?._bridgeToObjectiveC(), let context = context else { return nil }
                let wrapper = Unmanaged<ReplacementValueWrapper>.fromOpaque(context).takeUnretainedValue()
                let newValue = wrapper.handler(attribute, value)
                return UnsafeRawPointer(Unmanaged.passUnretained(newValue === value ? _value : newValue).toOpaque())
            }
            self.replacementValueWrapper = ReplacementValueWrapper(replacementValue)
            let contextPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(replacementValueWrapper!).toOpaque())
            MDQuerySetCreateValueFunction(self, createValueFunction, contextPointer, nil)
        } else if replacementValueWrapper != nil {
            MDQuerySetCreateValueFunction(self, nil, nil, nil)
            replacementValueWrapper = nil
        }
    }
   
    private var replacementObjectWrapper: ReplacementObjectWrapper? {
        get { getAssociatedValue("replacementObjectWrapper", object: self) }
        set { setAssociatedValue(newValue, key: "replacementObjectWrapper", object: self) }
    }
   
    private class ReplacementObjectWrapper {
        let handler: (MDItem) -> AnyObject
        init(_ handler: @escaping (MDItem) -> AnyObject) {
            self.handler = handler
        }
    }
   
    private var replacementValueWrapper: ReplacementValueWrapper? {
        get { getAssociatedValue("replacementValueWrapper", object: self) }
        set { setAssociatedValue(newValue, key: "replacementValueWrapper", object: self) }
    }
   
    private class ReplacementValueWrapper {
        let handler: ((_ attribute: String, _ value: AnyObject)->(AnyObject))
        init(_ handler: @escaping ((_ attribute: String, _ value: AnyObject)->(AnyObject))) {
            self.handler = handler
        }
    }
    
    private var isDisabled: Bool {
        get { getAssociatedValue("isDisabled", object: self) ?? false }
        set { setAssociatedValue(newValue, key: "isDisabled", object: self) }
    }
    
    private func runWithOperationQueue<T>(_ block: ()->(T)) -> T {
        if let dispatchQueue = dispatchQueue {
            return dispatchQueue.sync {
                return block()
            }
        } else {
            return block()
        }
    }
    
    private func runDisabled<T>(_ block: ()->(T)) -> T {
        let isDisabled = isDisabled
        var result: T!
        disableUpdates()
        result = block()
        if !isDisabled {
            enableUpdates()
        }
        return result
    }
    
    private var notificationTokens: [NotificationToken] {
        get { getAssociatedValue("notificationTokens", object: self) ?? [] }
        set { setAssociatedValue(newValue, key: "notificationTokens", object: self)}
    }
}

public extension MDQuery {
    /// Search scopes for where the metadata query searches files.
    enum SearchScope: String, Hashable {
        /// Searches the user’s home directory.
        case home
        
        /**
         Searches all local mounted volumes, including the user's home directory.
         
         The user’s home directory is searched even if it is a remote volume.
         */
        case local
        
        /**
         Searches all indexed local mounted volumes including the user’s home directory.
         
         The user’s home directory is searched even if it is a remote volume.
         */
        case localIndexed
        
        /// Searches all user-mounted remote volumes.
        case network
        
        /// Searches all indexed user-mounted remote volumes.
        case networkIndexed
        
        /// Searches all files in the Documents directories of the app’s iCloud container directories.
        case ubiquitousDocuments
        
        /// Searches all files not in the Documents directories of the app’s iCloud container directories.
        case ubiquitousData
        
        /// Searches for documents outside the app’s container. This search can locate iCloud documents that the user previously opened using a document picker view controller. This lets your app access the documents again without requiring direct user interaction. The result’s metadata items return a security-scoped URL for their url property.
        case accessibleUbiquitousExternalDocuments
        
        public var rawValue: String {
            switch self {
            case .home: return NSMetadataQueryUserHomeScope
            case .local: return NSMetadataQueryLocalComputerScope
            case .localIndexed: return NSMetadataQueryIndexedLocalComputerScope
            case .network: return NSMetadataQueryNetworkScope
            case .networkIndexed: return NSMetadataQueryIndexedNetworkScope
            case .ubiquitousDocuments: return NSMetadataQueryUbiquitousDocumentsScope
            case .ubiquitousData: return NSMetadataQueryUbiquitousDataScope
            case .accessibleUbiquitousExternalDocuments: return NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope
            }
        }
    }

    /// Options for when the metadata query updates it's results with accumulated changes.
    struct ResultUpdateOptions: Hashable {
        /// The inital maximum time (in seconds) that can pass after the query begins before updating the results with accumulated changes.
        public var initialDelay: TimeDuration = .seconds(0.08)
        
        /// The initial maximum number of changes that can accumulate after the query started before updating the results.
        public var initialThreshold: Int = 20
        
        /**
         The interval (in seconds) at which the results gets updated with accumulated changes while gathering.
         
         This value is advisory, in that the update will be triggered at some point after the specified seconds passed since the last update.
         */
        public var gatheringInterval: TimeDuration = .seconds(1.0)
        
        /// The maximum number of changes that can accumulate while gathering before updating the results.
        public var gatheringThreshold: Int = 10000
        
        /**
         The interval (in seconds) at which the results gets updated with accumulated changes while monitoring.
         
         This value is advisory, in that the update will be triggered at some point after the specified seconds passed since the last update.
         */
        public var monitoringInterval: TimeDuration = .seconds(1.0)
        
        /// The maximum number of changes that can accumulate while monitoring before updating the results.
        public var monitoringThreshold: Int = 10000
        
        internal var batching: MDQueryBatchingParams {
            MDQueryBatchingParams(first_max_num: initialThreshold, first_max_ms: Int(initialDelay.milliseconds.rounded()), progress_max_num: gatheringThreshold, progress_max_ms: Int(gatheringInterval.milliseconds.rounded()), update_max_num: monitoringThreshold, update_max_ms: Int(monitoringInterval.milliseconds.rounded()))
        }
        
        init(_ batching: MDQueryBatchingParams) {
            initialThreshold = batching.first_max_num
            gatheringThreshold = batching.progress_max_num
            monitoringThreshold = batching.update_max_num
            initialDelay = .milliseconds(Double(batching.first_max_ms))
            gatheringInterval = .milliseconds(Double(batching.progress_max_ms))
            monitoringInterval = .milliseconds(Double(batching.update_max_ms))
        }
    }
}

extension MDQuery {
    struct Options: OptionSet, CustomStringConvertible {
        /**
         The query blocks during the initial gathering phase.
        
         It’s run loop will run in the default mode.
        
         If this option is not specified the query returns immediately after starting it asynchronously.
         */
        public static let synchronous = Self(rawValue: 1 << 0)
       
        /**
         The query provides live-updates to the results after the initial gathering phase.
        
         Updates occur during the live-update phase if a change in a file occurs such that it no longer matches the query or if it begins to match the query. Files which begin to match the query are added to the result list, and files which no longer match the query expression are removed from the result list.
        
         If this option isn't used, the query stops after gathering the inital matching items.
        
         This option is ignored if the `synchronous` option is specified.
         */
        public static let wantsUpdates = Self(rawValue: 1 << 2)
       
        /**
         The query interacts directly with the filesystem to resolve parts of the query, in addition to using the Spotlight metadata index.
        
         Normally, metadata queries rely heavily on their pre-built index for speed. However, the index might not always be perfectly synchronized with the live state of the file system (e.g., immediately after a file change).
        
         Using this option permits the query to go "live" to the file system to verify information or gather attributes that might be missing or potentially stale in the index.
        
         - Note: Consulting the live file system is significantly slower than querying the optimized Spotlight index. Therefore, using this option will almost always result in considerably slower query performance. It should generally be avoided unless there's a very specific need for this behavior and the performance impact is acceptable.
         */
        public static let allowFSTranslation = Self(rawValue: 1 << 3)
       
        public var description: String {
            var strings: [String] = []
            if contains(.synchronous) { strings.append(".synchronous") }
            if contains(.wantsUpdates) { strings.append(".wantsUpdates") }
            if contains(.allowFSTranslation) { strings.append(".allowFSTranslation") }
            return "[\(strings.joined(separator: ", "))]"
        }
       
        public init(rawValue: UInt) { self.rawValue = rawValue }
        public let rawValue: UInt
    }
}


extension MDQuery {
    internal func setupSortComparator() {
        let sortComparator: MDQuerySortComparatorFunction = { values1, values2, context in
            guard let value1 = values1?.pointee?.takeUnretainedValue() else {
                return .compareGreaterThan
            }
            guard let value2 = values2?.pointee?.takeUnretainedValue() else {
                return .compareLessThan
            }
            if let value1 = value1 as? (any CFComparable) {
                return value1.compare(to: value2, context: context).reversed()
            }
            return .compareLessThan
        }
        MDQuerySetSortComparator(self, sortComparator, nil)
    }
}
#endif
