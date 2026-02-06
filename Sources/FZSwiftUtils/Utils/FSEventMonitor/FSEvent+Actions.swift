//
//  FSEvent+Actions.swift
//
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation

extension FSEvent {
    /// Represents the actions for a file system event.
    public struct Actions: OptionSet, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        
        // MARK: - Item
        
        /// An item was created.
        public static let created = Self(kFSEventStreamEventFlagItemCreated)
        /// An item was removed.
        public static let removed = Self(kFSEventStreamEventFlagItemRemoved)
        /// An item was renamed.
        public static let renamed = Self(kFSEventStreamEventFlagItemRenamed)
        /// The item is a clone or was cloned.
        public static let cloned = Self(kFSEventStreamEventFlagItemCloned)
        /// An item was modified.
        public static let modified = Self(kFSEventStreamEventFlagItemModified)
        /// An item's Finder information was modified.
        public static let finderInfoModified = Self(kFSEventStreamEventFlagItemFinderInfoMod)
        /// An item's ownership information was changed.
        public static let ownerModified = Self(kFSEventStreamEventFlagItemChangeOwner)
        /// An item's extended attributes were modified.
        public static let xattrModifed = Self(kFSEventStreamEventFlagItemXattrMod)
        /// An item's inode metadata was modified.
        public static let inodeMetaModied = Self(kFSEventStreamEventFlagItemInodeMetaMod)
        
        // MARK: - Hierarchy
        
        /// The root path of a watched hierarchy has changed.
        public static let rootChanged = Self(kFSEventStreamEventFlagRootChanged)
        
        // MARK: - Volume
        
        /// A volume has been mounted.
        public static let mounted = Self(kFSEventStreamEventFlagMount)
        /// A volume has been unmounted.
        public static let unmounted = Self(kFSEventStreamEventFlagUnmount)
        
        /// All actions.
        public static let all: Actions = [.rootChanged, .created, .removed, .renamed, .cloned, .modified, .xattrModifed, .ownerModified, .finderInfoModified, .inodeMetaModied, .mounted, .unmounted]
        
        public var description: String {
            FSEvent.Flags(rawValue: rawValue).description
        }
        
        public var debugDescription: String {
            FSEvent.Flags(rawValue: rawValue).debugDescription
        }
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        init(_ rawValue: Int) {
            self.rawValue = UInt32(rawValue)
        }
    }
}
#endif
