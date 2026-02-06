//
//  FSEvent.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import Foundation

/// A file system event.
public struct FSEvent: Hashable, Identifiable, CustomStringConvertible {
    /// The url of the file.
    public let url: URL
    /// The type of the item.
    public let itemType: ItemType
    /// The actions of the event.
    public let actions: Actions
    /// The event flags.
    public let flags: Flags
    /// The identifier of the event.
    public let id: FSEventStreamEventId
    /// The identifier of the file.
    public let fileID: UInt64?
    /// The identifier of the document.
    public let documentID: Int?

    let date = Date()
    
    public var description: String {
        return "FSEvent \(actions.description): \(url.path)"
    }
    
    init(_ eventId: FSEventStreamEventId, _ eventPath: String, _ eventFlags: FSEventStreamEventFlags, _ fileID: UInt64?, _ documentID: Int?) {
        self.id = eventId
        self.fileID = fileID
        self.documentID = documentID
        self.flags = Flags(rawValue: eventFlags)
        self.itemType = flags.itemType
        self.actions = flags.actions
        self.url = URL(fileURLWithPath: eventPath, isDirectory: itemType.contains(.directory))
    }
}
#endif
