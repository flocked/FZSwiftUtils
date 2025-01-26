//
//  FSEventMonitor.swift
//  
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import Foundation

/// Monitores files on the file system.
public class FSEventMonitor {
    private var streamRef: FSEventStreamRef?
    private var isRunning: Bool { streamRef != nil }
    private var startEventID: FSEventStreamEventId? = nil
    private var shouldMonitor: Bool {
        isActive && !fileURLs.isEmpty && callback != nil && eventActions != .none
    }
    
    /// The urls of the files to monitor.
    public var fileURLs: [URL] {
        didSet {
            fileURLs = fileURLs.filter({ $0.isFileURL }).uniqued()
            guard oldValue != fileURLs else { return }
            if fileURLs.isEmpty {
                _stop()
            } else if isActive {
                stop()
                start()
            }
        }
    }
    
    /// The urls of files to exclude from monitoring.
    public var excludingFileURLs: [URL] = [] {
        didSet {
            excludingFileURLs = excludingFileURLs.filter({ $0.isFileURL }).uniqued()
            guard oldValue != excludingFileURLs, isRunning else { return }
            restart()
        }
    }
    
    /**
     The event actions to monitor.
     
     The default value is `all`.
     */
    public var eventActions: FSEventActions = .all {
        didSet { updateMonitoring() }
    }
    
    /// The options for monitoring the files.
    public var monitorOptions: MonitorOptions = [] {
        didSet {
            guard oldValue != monitorOptions, isRunning else { return }
            restart()
        }
    }
    
    /// The handler that gets called when a file sytem event occurs for the monitored file.
    public var callback: ((_ event: FSEvent) -> Void)? {
        didSet { updateMonitoring() }
    }
    
    /**
     The dispatch queue for the monitor.
     
     The default value is `main`.
     */
    public var queue: DispatchQueue = .main {
        didSet {
            guard oldValue != queue, isRunning else { return }
            restart()
        }
    }
    
    /**
     The amount of seconds the monitor should wait after hearing about an event before passing it to the callback.
     
     Specifying a larger value may result in more effective temporal coalescing, resulting in fewer callbacks and greater overall efficiency.
     
     The default value is `0.0`.
     */
    public var latency: CGFloat = 0.0 {
        didSet {
            latency = latency.clamped(min: 0.0)
            guard oldValue != latency, isRunning else { return }
            restart()
        }
    }
    
    /// A Boolean value indicating whether the monitor is monitoring the files.
    public var isActive = false {
        didSet { updateMonitoring() }
    }
    
    /**
     Creates a file system event monitor.
     
     - Parameter fileURLs: The urls of the files to observe.
     */
    public init(_ fileURLs: [URL] = []) {
        self.fileURLs = fileURLs
    }
    
    /// Start monitoring the files.
    public func start() {
        isActive = true
    }
    

    /// Start monitoring the files and additionally provide all events that have happened since the specified event.
    public func start(since event: FSEvent) {
        startEventID = event.id
        restart()
        isActive = true
    }
    
    /// Stops observing the files for events.
    public func stop() {
        isActive = false
    }
    
    private func updateMonitoring() {
        if !shouldMonitor {
            _stop()
        } else {
            _start()
        }
    }
    
    private func restart() {
        guard isRunning else { return }
        _stop()
        _start()
    }
    
    private func _start() {
        guard !isRunning, shouldMonitor else { return }
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: retainCallback,
            release: releaseCallback,
            copyDescription: nil
        )
        streamRef = FSEventStreamCreate(
            kCFAllocatorDefault,
            eventCallback,
            &context,
            fileURLs.compactMap({$0.path}) as CFArray,
            startEventID ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            CFTimeInterval(latency),
            monitorOptions.stream.rawValue
        )
        if !excludingFileURLs.isEmpty {
            FSEventStreamSetExclusionPaths(streamRef!, excludingFileURLs.compactMap({$0.path}) as CFArray)
        }
        FSEventStreamSetDispatchQueue(streamRef!, queue)
        FSEventStreamStart(streamRef!)
        startEventID = nil
    }
    
    private func _stop() {
        guard isRunning else { return }
        FSEventStreamStop(streamRef!)
        FSEventStreamInvalidate(streamRef!)
        FSEventStreamRelease(streamRef!)
        streamRef = nil
    }
    
    private let eventCallback: FSEventStreamCallback = {(
        stream: ConstFSEventStreamRef,
        contextInfo: UnsafeMutableRawPointer?,
        numEvents: Int,
        eventPaths: UnsafeMutableRawPointer,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        eventIds: UnsafePointer<FSEventStreamEventId>) in
        let fileSystemWatcher = Unmanaged<FSEventMonitor>.fromOpaque(contextInfo!).takeUnretainedValue()
        let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
        var events = (0..<numEvents).compactMap({ FSEvent(eventIds[$0], paths[$0], eventFlags[$0]) })
        let eventCount = events.count
        for event in events {
            Swift.print(event)
        }
        events = events.filter({ $0.flags.contains(.historyDone) })
        if fileSystemWatcher.eventActions != .all {
            events = events.filter({ fileSystemWatcher.eventActions.contains(any: $0.actions) })
        }
        if !fileSystemWatcher.monitorOptions.contains(.monitorFolderContent) {
            let monitorRoot = fileSystemWatcher.monitorOptions.contains(.monitorRoot)
            events = events.filter({
                if fileSystemWatcher.fileURLs.contains($0.url) { return true } else if monitorRoot, $0.flags.contains(.rootChanged) { return true } else { return false }
            })
        }
        events.forEach({ fileSystemWatcher.callback?($0) })
    }
    
    private let retainCallback: CFAllocatorRetainCallBack = {(info: UnsafeRawPointer?) in
        _ = Unmanaged<FSEventMonitor>.fromOpaque(info!).retain()
        return info
    }
    
    private let releaseCallback: CFAllocatorReleaseCallBack = {(info: UnsafeRawPointer?) in
        Unmanaged<FSEventMonitor>.fromOpaque(info!).release()
    }
}
#endif
