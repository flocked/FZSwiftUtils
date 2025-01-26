//
//  FSEventMonitor+Options.swift
//  
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation

extension FSEventMonitor {
    /// Options for monitoring.
    public struct MonitorOptions: OptionSet, Hashable {
        /**
         Monitors for changes along the path of the file urls you're watching. For example, if you watch `/foo/bar` and it is renamed to `/foo/bar.old`, you would receive a `rootChanged` event. The same is true if the directory `/foo` were renamed.
         
         The `rootChanged` event contains the original file url, that may no longer exist because it or one of its parents was deleted or renamed.
         
         The event is useful to indicate that you should rescan a particular hierarchy because it changed completely (as opposed to the things inside of it changing). If you want to track the current location of a directory, it is best to open the directory before monitoring the files so that you have a file descriptor for it.
         */
        public static let monitorRoot = Self(rawValue: 1 << 2)
        
        /**
         Monitors the content of folders.
         
         The callback will provide events for individual files in the hierarchy you're watching instead of only receiving events for the provided urls.
         */
        public static let monitorFolderContent = Self(rawValue: 1 << 5)
        
        /**
         Ignores events that were triggered by the current process.
         
         This is useful for reducing the volume of events that are sent. It is only useful if your process might modify the file system hierarchy beneath the path(s) being monitored. Note: this has no effect on `historical` events, i.e., those delivered before the `historyDone` sentinel event.
         */
        public static let ignoreEventsFromSelf = Self(rawValue: 1 << 3)
                
        /**
         This option ensures that events are delivered immediately if more than the specified `latency` seconds
         have passed since the last event, bypassing any deferral or batching.
                  
         If you specify this option and more than the specified `latency` seconds have elapsed since the last event, the callback handler will receive the event immediately. The delivery of the event resets the latency timer and any further events will be delivered after `latency` seconds have elapsed.
         
         This flag is useful for apps that are interactive and want to react immediately to changes but avoid getting swamped by notifications when changes are occurringin rapid succession.
         
         If you do not specify this option, then when an event occurs after a period of no events, the latency timer is started. Any events that occur during the next `latency` seconds will be delivered to the callback handler. The delivery of events resets the latency timer and any further events will be delivered after `latency` seconds. This is the default behavior and is more appropriate for background, daemon or batch processing apps.
         */
        public static let noDefer = Self(rawValue: 1 << 1)
        
        static let useCFTypes = Self(rawValue: 1 << 0)
        static let fileEvents = Self(rawValue: 1 << 4)
        
        var stream: Self {
            var options = self
            options.insert([.useCFTypes, .fileEvents])
            options.remove(.monitorFolderContent)
            return options
        }
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}
#endif
