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
    /// The identifier of the file.
    public let fileID: UInt64?
    /// The identifier of the document.
    public let documentID: Int?

    let date = Date()
    
    
    /// The new url of the file for a renamed file.
    // public fileprivate(set) var newURL: URL?
    
    init(_ eventId: FSEventStreamEventId, _ eventPath: String, _ eventFlags: FSEventStreamEventFlags, _ fileID: UInt64?, _ documentID: Int?) {
        self.id = eventId
        self.fileID = fileID
        self.documentID = documentID
        self.flags = FSEventFlags(rawValue: eventFlags)
        self.itemType = flags.itemType
        self.actions = flags.actions
        self.url = URL(fileURLWithPath: eventPath, isDirectory: itemType.contains(.directory))
    }
}

extension FSEvent: CustomStringConvertible {
    public var description: String {
        return "FSEvent \(actions.debugDescription): \(url.path)"
    }
}

/*
extension Array where Element == FSEvent {
    var mappedEvents: Self {
        var events: [FSEvent] = []
        for event in enumerated() {
            var event = event.element
            if event.actions.contains(.renamed), let fileID = event.fileID, let other = first(where: { $0.fileID == fileID && $0.id > event.id }) {
                event.newURL = other.url
            }
            events += event
        }
        return events
    }
}
 */
#endif
