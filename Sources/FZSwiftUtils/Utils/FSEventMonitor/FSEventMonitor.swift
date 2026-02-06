//
//  FSEventMonitor.swift
//  
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import Foundation

/// Monitors files on the file system.
public final class FSEventMonitor {

    private static var eventIDInvalidationDate: Date?
    private var streamRef: FSEventStreamRef?
    private var startEventID: FSEventStreamEventId?
    private var isRunning: Bool { streamRef != nil }

    private var shouldMonitor: Bool {
        isActive && !fileURLs.isEmpty && callback != nil && eventActions != .none
    }

    // MARK: - Public API

    /// A Boolean value indicating whether the monitor is monitoring the files.
    public private(set) var isActive: Bool = false

    /// The handler that gets called when a file sytem event occurs for the monitored file.
    public var callback: ((_ event: FSEvent) -> Void)? {
        didSet { updateMonitoring() }
    }

    /**
     The event actions to monitor.
     
     The default value is `.all`.
     */
    public var eventActions: FSEvent.Actions = .all {
        didSet {
            guard oldValue != eventActions else { return }
            updateMonitoring()
        }
    }

    /// The handler to filter the events provided to the callback.
    public var filter: ((_ event: FSEvent) -> Bool)?

    /**
     The options for monitoring the files.
     
     The default value is `[.monitorRoot, .monitorFolderContent]`.
     */
    public var monitorOptions: MonitorOptions = [.monitorRoot, .monitorFolderContent] {
        didSet {
            guard oldValue != monitorOptions else { return }
            updateMonitoring()
        }
    }

    /**
     The dispatch queue for the monitor.
     
     The default value is `.main`.
     */
    public var queue: DispatchQueue = .main {
        didSet {
            guard oldValue !== queue else { return }
            updateMonitoring()
        }
    }

    /**
     The amount of seconds the monitor should wait after hearing about an event before passing it to the callback.
     
     Specifying a larger value may result in more effective temporal coalescing, resulting in fewer callbacks and greater overall efficiency.
     
     The default value is `0.0`.
     */
    public var latency: TimeInterval = 0 {
        didSet {
            latency = max(0, latency)
            guard oldValue != latency else { return }
            updateMonitoring()
        }
    }

    // MARK: - Paths

    /// The urls of the files to monitor.
    public var fileURLs: Set<URL> = [] {
        didSet {
            fileURLs = fileURLs.filter(\.isFileURL)
            guard fileURLs != oldValue else { return }
            updateMonitoring()
        }
    }

    /// The urls of files to exclude from monitoring.
    public var excludingFileURLs: Set<URL> = [] {
        didSet {
            excludingFileURLs = excludingFileURLs.filter(\.isFileURL)
            guard excludingFileURLs != oldValue else { return }
            updateMonitoring()
        }
    }

    // MARK: - Init / Deinit

    /**
     Creates a file system event monitor.
     
     - Parameters:
        - fileURLs: The urls of the files to observe.
        - eventActions: The event actions to monitor.
        - queue: The queue for the monitor.
        - callback: The handler that gets called when a file sytem event occurs for the monitored file.
     */
    public init(_ fileURLs: Set<URL> = [], eventActions: FSEvent.Actions = .all, queue: DispatchQueue = .main, callback: ((_ event: FSEvent) -> Void)? = nil) {
        self.queue = queue
        self.fileURLs = fileURLs
        self.eventActions = eventActions
        self.callback = callback
    }

    deinit {
        _stop()
    }

    // MARK: - Control

    /// Start monitoring the files.
    public func start() {
        isActive = true
        updateMonitoring()
    }

    /// Start monitoring the files and additionally provide all events that happened since the specified event.
    public func start(withEventsSince event: FSEvent) {
        startEventID = (event.date > (Self.eventIDInvalidationDate ?? .distantPast)) ? event.id : nil
        isActive = true
        updateMonitoring()
    }

    /// Start monitoring the files and additionally provide all events that happened since the specified date.
    public func start(withEventsSince date: Date) {
        startEventID = fileURLs.compactMap(\.resources.volume.url).uniqued().compactMap { $0.lastFSEventID(before: date) }.sorted(.smallestFirst).first
        isActive = true
        updateMonitoring()
    }

    /// Stops observing the files for events.
    public func stop() {
        isActive = false
        updateMonitoring()
    }

    // MARK: - Monitoring

    private func updateMonitoring() {
        guard shouldMonitor else {
            _stop()
            return
        }
        if isRunning {
            _stop()
        }
        _start()
    }

    private func _start() {
        guard !isRunning, shouldMonitor else { return }
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: retainCallback, release: releaseCallback, copyDescription: nil)
        let paths = fileURLs.map(\.path) as CFArray
        guard let stream = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, paths, startEventID ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow), latency, monitorOptions.flags) else {
            isActive = false
            startEventID = nil
            return
        }

        streamRef = stream

        if !excludingFileURLs.isEmpty {
            let exclusions = excludingFileURLs.map(\.path) as CFArray
            FSEventStreamSetExclusionPaths(stream, exclusions)
        }

        FSEventStreamSetDispatchQueue(stream, queue)
        guard FSEventStreamStart(stream) else {
            startEventID = nil
            stop()
            return
        }
        startEventID = nil
    }

    private func _stop() {
        guard let streamRef else { return }
        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
        FSEventStreamRelease(streamRef)
        self.streamRef = nil
    }

    // MARK: - Sending

    private func sendEvents(_ events: [FSEvent]) {
        guard let callback else { return }
        var events = events
        if events.contains(where: { $0.flags.contains(.eventIdsWrapped) }) {
            Self.eventIDInvalidationDate = Date()
        }
        events.removeAll { $0.flags.contains(any: FSEvent.Flags.filter) }
        if eventActions != .all {
            events.removeAll { !eventActions.contains(any: $0.actions) }
        }
        if !monitorOptions.contains(.monitorFolderContent) {
            let monitorRoot = monitorOptions.contains(.monitorRoot)
            events.removeAll { !fileURLs.contains($0.url) && !(monitorRoot && $0.flags.contains(.rootChanged)) }
        }
        if let filter {
            events.removeAll { !filter($0) }
        }
        events.forEach(callback)
    }

    // MARK: - Callbacks

    private let eventCallback: FSEventStreamCallback = {
        stream, contextInfo, numEvents, eventPaths, eventFlags, eventIds in
        Swift.print("AAAA")
        guard let contextInfo else { return }
        let monitor = Unmanaged<FSEventMonitor>.fromOpaque(contextInfo).takeUnretainedValue()
        let rawArray = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as NSArray
        var events: [FSEvent] = .init(reserveCapacity: numEvents)
        for i in 0..<numEvents {
            guard i < rawArray.count else { break }
            guard let dict = rawArray[i] as? [String: Any] else { continue }
            guard let path = dict[kFSEventStreamEventExtendedDataPathKey] as? String else {
                continue
            }
            let fileID = dict[kFSEventStreamEventExtendedFileIDKey] as? UInt64
            let docID = dict[kFSEventStreamEventExtendedDocIDKey] as? Int
            events.append(FSEvent(eventIds[i], path, eventFlags[i], fileID, docID))
        }
        monitor.sendEvents(events)
    }

    private let retainCallback: CFAllocatorRetainCallBack = { info in
        guard let info else { return nil }
        _ = Unmanaged<FSEventMonitor>.fromOpaque(info).retain()
        return info
    }

    private let releaseCallback: CFAllocatorReleaseCallBack = { info in
        guard let info else { return }
        Unmanaged<FSEventMonitor>.fromOpaque(info).release()
    }
}

fileprivate extension URL {
    var deviceID: dev_t? {
        guard isFileURL else { return nil }
        var info = stat()
        let result = withUnsafeFileSystemRepresentation { fsPath in
            guard let fsPath else { return Int32(-1) }
            return stat(fsPath, &info)
        }
        return result == 0 ? info.st_dev : nil
    }
    
    func lastFSEventID(before date: Date) -> FSEventStreamEventId? {
        guard let deviceID else { return nil }
        return FSEventsGetLastEventIdForDeviceBeforeTime(deviceID, date.timeIntervalSince1970)
    }
}
#endif
