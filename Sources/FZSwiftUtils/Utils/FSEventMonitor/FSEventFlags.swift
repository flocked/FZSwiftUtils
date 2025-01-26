//
//  FSEventFlags.swift
//  
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation

/// Represents the flags for a file system event.
public struct FSEventFlags: OptionSet, Hashable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    // MARK: - Item
    
    /// An item was created.
    public static let itemCreated = FSEventFlags(rawValue: 256)
    /// An item was removed.
    public static let itemRemoved = FSEventFlags(rawValue: 512)
    /// An item was renamed.
    public static let itemRenamed = FSEventFlags(rawValue: 2048)
    /// The item is a clone or was cloned.
    public static let itemCloned = FSEventFlags(rawValue: 4194304)
    /// An item was modified.
    public static let itemModified = FSEventFlags(rawValue: 4096)
    /// An item's Finder information was modified.
    public static let itemFinderInfoModified = FSEventFlags(rawValue: 8192)
    /// An item's ownership information was changed.
    public static let itemOwnerModified = FSEventFlags(rawValue: 16384)
    /// An item's extended attributes were modified.
    public static let itemXattrModied = FSEventFlags(rawValue: 32768)
    /// An item's inode metadata was modified.
    public static let itemInodeMetaModied = FSEventFlags(rawValue: 1024)
    
    // MARK: - Item Type
    
    /// The item is a file.
    public static let itemIsFile = FSEventFlags(rawValue: 65536)
    /// The item is a directory.
    public static let itemIsDirectory = FSEventFlags(rawValue: 131072)
    /// The item is a symbolic link.
    public static let itemIsSymbolicLink = FSEventFlags(rawValue: 262144)
    /// The item is a hard link.
    public static let itemIsHardlink = FSEventFlags(rawValue: 1048576)
    /// The item is the last hard link to a file.
    public static let itemIsLastHardlink = FSEventFlags(rawValue: 2097152)
    
    // MARK: - Hierarchy
        
    /// The root path of a watched hierarchy has changed.
    public static let rootChanged = FSEventFlags(rawValue: 32)
    
    // MARK: - Volume
    
    /// A volume has been mounted.
    public static let mounted = FSEventFlags(rawValue: 64)
    /// A volume has been unmounted.
    public static let unmounted = FSEventFlags(rawValue: 128)
    
    // MARK: - Monitor Info
    
    /// The event originated from the same process.
    public static let ownEvent = FSEventFlags(rawValue: 524288)
    /// The entire directory hierarchy must be scanned due to events.
    public static let mustScanSubDirectories = FSEventFlags(rawValue: 1)
    /// The user-space event queue overflowed, dropping events.
    public static let userDropped = FSEventFlags(rawValue: 2)
    /// The kernel event queue overflowed, dropping events.
    public static let kernelDropped = FSEventFlags(rawValue: 4)
    /// Event IDs wrapped around, restarting from the beginning.
    public static let eventIdsWrapped = FSEventFlags(rawValue: 8)
    /// The completion of a historical event stream replay.
    public static let historyDone = FSEventFlags(rawValue: 16)
    
    /// No specific flags set for this event.
    public static let none: FSEventFlags = []
    
    /// All flags.
    public static let all: FSEventFlags = [.rootChanged, .itemCreated, .itemRemoved, .itemRenamed, .itemCloned, .itemModified, .itemXattrModied, .itemOwnerModified, .itemFinderInfoModified, .itemInodeMetaModied, .mounted, .unmounted, .itemIsFile, .itemIsDirectory, .itemIsSymbolicLink, .itemIsHardlink, .itemIsLastHardlink, .mustScanSubDirectories, .userDropped, .kernelDropped, .eventIdsWrapped, .historyDone, .ownEvent]
    
    static let filter: FSEventFlags = [.mustScanSubDirectories, .userDropped, .kernelDropped, .historyDone]
    
    static let itemTypes: FSEventFlags = [.itemIsFile, .itemIsDirectory, .itemIsSymbolicLink, .itemIsHardlink, .itemIsLastHardlink]
    
    // MARK: - Description
}

extension FSEventFlags: CustomStringConvertible {
    public var description: String {
        return "[\(self.elements().collect().compactMap({$0._description}).joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        "[\(self.elements().compactMap({$0._debugDescription}).joined(separator: ", "))]"
    }
    
    var _description: String {
        switch self {
        case .none: return "none"
        case .mustScanSubDirectories: return "mustScanSubDirectories"
        case .userDropped: return "userDropped"
        case .kernelDropped: return "kernelDropped"
        case .eventIdsWrapped: return "eventIdsWrapped"
        case .historyDone: return "historyDone"
        case .rootChanged: return "rootChanged"
        case .mounted: return "mounted"
        case .unmounted: return "unmounted"
        case .itemCreated: return "itemCreated"
        case .itemRemoved: return "itemRemoved"
        case .itemInodeMetaModied: return "itemInodeMetaModied"
        case .itemRenamed: return "itemRenamed"
        case .itemModified: return "itemModified"
        case .itemFinderInfoModified: return "itemFinderInfoModified"
        case .itemOwnerModified: return "itemOwnerModified"
        case .itemXattrModied: return "itemXattrModied"
        case .itemIsFile: return "itemIsFile"
        case .itemIsDirectory: return "itemIsDirectory"
        case .itemIsSymbolicLink: return "itemIsSymbolicLink"
        case .ownEvent: return "ownEvent"
        case .itemIsHardlink: return "itemIsHardlink"
        case .itemIsLastHardlink: return "itemIsLastHardlink"
        case .itemCloned: return "itemCloned"
        default: return "unkown"
        }
    }
    
    var _debugDescription: String {
        switch self {
        case .none: return "None"
        case .mustScanSubDirectories: return "Scan subdirectories"
        case .userDropped: return "User dropped"
        case .kernelDropped: return "Kernel dropped"
        case .eventIdsWrapped: return "IDs wrapped"
        case .historyDone: return "History done"
        case .rootChanged: return "Root changed"
        case .mounted: return "Mounted"
        case .unmounted: return "Unmounted"
        case .itemCreated: return "Created"
        case .itemRemoved: return "Removed"
        case .itemInodeMetaModied: return "Inode metadata changed"
        case .itemRenamed: return "Renamed"
        case .itemModified: return "Modified"
        case .itemCloned: return "Cloned"
        case .itemFinderInfoModified: return "Finder info changed"
        case .itemOwnerModified: return "Owner changed"
        case .itemXattrModied: return "Xattr modified"
        case .itemIsFile: return "File"
        case .itemIsDirectory: return "Directory"
        case .itemIsSymbolicLink: return "Symbolic Link"
        case .itemIsHardlink: return "Hardlink"
        case .itemIsLastHardlink: return "Last hardxlink"
        case .ownEvent: return "Own event"
        default: return "Unkown"
        }
    }
    
    var itemTypeString: String {
        let itemTypes = intersection(Self.itemTypes).elements().collect()
        if itemTypes.count > 1 {
            return "[\(itemTypes.compactMap({$0._debugDescription}).joined(separator: ", "))]"
        } else if itemTypes.count == 1 {
            return itemTypes.first!._debugDescription
        }
        return ""
    }
}
#endif
