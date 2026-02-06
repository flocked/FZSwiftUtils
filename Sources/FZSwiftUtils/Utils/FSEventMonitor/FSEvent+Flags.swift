//
//  FSEvent+Flags.swift
//  
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation

extension FSEvent {
    /// Represents the flags for a file system event.
    public struct Flags: OptionSet, Hashable {
        
        // MARK: - Item
        
        /// An item was created.
        public static let itemCreated = Self(kFSEventStreamEventFlagItemCreated)
        /// An item was removed.
        public static let itemRemoved = Self(kFSEventStreamEventFlagItemRemoved)
        /// An item was renamed.
        public static let itemRenamed = Self(kFSEventStreamEventFlagItemRenamed)
        /// The item is a clone or was cloned.
        public static let itemCloned = Self(kFSEventStreamEventFlagItemCloned)
        /// An item was modified.
        public static let itemModified = Self(kFSEventStreamEventFlagItemModified)
        /// An item's Finder information was modified.
        public static let itemFinderInfoModified = Self(kFSEventStreamEventFlagItemFinderInfoMod)
        /// An item's ownership information was changed.
        public static let itemOwnerModified = Self(kFSEventStreamEventFlagItemChangeOwner)
        /// An item's extended attributes were modified.
        public static let itemXattrModied = Self(kFSEventStreamEventFlagItemXattrMod)
        /// An item's inode metadata was modified.
        public static let itemInodeMetaModied = Self(kFSEventStreamEventFlagItemInodeMetaMod)
        
        // MARK: - Hierarchy
        
        /// The root path of a watched hierarchy has changed.
        public static let rootChanged = Self(kFSEventStreamEventFlagRootChanged)
        
        // MARK: - Item Type
        
        /// The item is a file.
        public static let itemIsFile = Self(kFSEventStreamEventFlagItemIsFile)
        /// The item is a directory.
        public static let itemIsDirectory = Self(kFSEventStreamEventFlagItemIsDir)
        /// The item is a symbolic link.
        public static let itemIsSymbolicLink = Self(kFSEventStreamEventFlagItemIsSymlink)
        /// The item is a hard link.
        public static let itemIsHardlink = Self(kFSEventStreamEventFlagItemIsHardlink)
        /// The item is the last hard link to a file.
        public static let itemIsLastHardlink = Self(kFSEventStreamEventFlagItemIsLastHardlink)
        
        // MARK: - Volume
        
        /// A volume has been mounted.
        public static let mounted = Self(kFSEventStreamEventFlagMount)
        /// A volume has been unmounted.
        public static let unmounted = Self(kFSEventStreamEventFlagUnmount)
        
        // MARK: - Monitor Info
        
        /// The event originated from the same process.
        public static let ownEvent = Self(kFSEventStreamEventFlagOwnEvent)
        /// The entire directory hierarchy must be scanned due to events.
        public static let mustScanSubDirectories = Self(kFSEventStreamEventFlagMustScanSubDirs)
        /// The user-space event queue overflowed, dropping events.
        public static let userDropped = Self(kFSEventStreamEventFlagUserDropped)
        /// The kernel event queue overflowed, dropping events.
        public static let kernelDropped = Self(kFSEventStreamEventFlagKernelDropped)
        /// Event IDs wrapped around, restarting from the beginning.
        public static let eventIdsWrapped = Self(kFSEventStreamEventFlagEventIdsWrapped)
        /// The completion of a historical event stream replay.
        public static let historyDone = Self(kFSEventStreamEventFlagHistoryDone)
        
        /// No specific flags set for this event.
        public static let none = Self(kFSEventStreamEventFlagNone)
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        init(_ rawValue: Int) {
            self.rawValue = UInt32(rawValue)
        }
                
        static let actions: Flags = [.rootChanged, .itemCreated, .itemRemoved, .itemRenamed, .itemCloned, .itemModified, .itemXattrModied, .itemOwnerModified, .itemFinderInfoModified, .itemInodeMetaModied, .mounted, .unmounted]
        
        static let itemTypes: Flags = [.itemIsFile, .itemIsDirectory, .itemIsSymbolicLink, .itemIsHardlink, .itemIsLastHardlink]
        
        static let filter: Flags = [.mustScanSubDirectories, .userDropped, .kernelDropped, .eventIdsWrapped, .historyDone]
        
        var itemType: ItemType {
            ItemType(rawValue: intersection(Self.itemTypes).rawValue)
        }
        
        var actions: Actions {
            Actions(rawValue: intersection(Self.actions).rawValue)
        }
    }
}

extension FSEvent.Flags: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "[\(elements().collect().compactMap({$0._description}).joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        "[\(elements().compactMap({$0._debugDescription}).joined(separator: ", "))]"
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
        default: return "\(rawValue)"
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
        default: return "\(rawValue)"
        }
    }
}
#endif
