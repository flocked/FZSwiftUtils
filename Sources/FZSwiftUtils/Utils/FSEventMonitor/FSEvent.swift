//
//  FSEvent.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import Foundation

/// A file system event.
public struct FSEvent: Hashable, Identifiable {
    /// The url of the file.
    public let url: URL
    /// The type of the item.
    public let itemType: FSEventItemType
    /// The actions of the event.
    public let actions: FSEventActions
    /// The event flags.
    public let flags: FSEventFlags
    /// The identifier of the event.
    public let id: FSEventStreamEventId

    init(_ eventId: FSEventStreamEventId, _ eventPath: String, _ eventFlags: FSEventStreamEventFlags) {
        self.id = eventId
        self.flags = FSEventFlags(rawValue: eventFlags)
        self.itemType = flags.itemType
        self.actions = flags.actions
        if itemType.contains(.directory), !eventPath.hasSuffix("/") {
            self.url = URL(fileURLWithPath: eventPath + "/")
        } else {
            self.url = URL(fileURLWithPath: eventPath)
        }
    }
}

extension FSEvent: CustomStringConvertible {
    public var description: String {
        return "FSEvent \(actions.debugDescription): \(url.path)"
    }
}
#endif
