//
//  FSEventActions.swift
//
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation


/// Represents the actions for a file system event.
public struct FSEventActions: OptionSet, Hashable {
    
    // MARK: - Item
    
    /// An item was created.
    public static let created = FSEventActions(rawValue: 256)
    /// An item was removed.
    public static let removed = FSEventActions(rawValue: 512)
    /// An item was renamed.
    public static let renamed = FSEventActions(rawValue: 2048)
    /// The item is a clone or was cloned.
    public static let cloned = FSEventActions(rawValue: 4194304)
    /// An item was modified.
    public static let modified = FSEventActions(rawValue: 4096)
    /// An item's Finder information was modified.
    public static let finderInfoModified = FSEventActions(rawValue: 8192)
    /// An item's ownership information was changed.
    public static let ownerModified = FSEventActions(rawValue: 16384)
    /// An item's extended attributes were modified.
    public static let xattrModied = FSEventActions(rawValue: 32768)
    /// An item's inode metadata was modified.
    public static let inodeMetaModied = FSEventActions(rawValue: 1024)
    
    // MARK: - Hierarchy
        
    /// The root path of a watched hierarchy has changed.
    public static let rootChanged = FSEventActions(rawValue: 32)
    
    // MARK: - Volume
    
    /// A volume has been mounted.
    public static let mounted = FSEventActions(rawValue: 64)
    /// A volume has been unmounted.
    public static let unmounted = FSEventActions(rawValue: 128)
    
    /// No specific action set for this event.
    public static let none: FSEventActions = []
    
    /// All actions.
    public static let all: FSEventActions = [.rootChanged, .created, .removed, .renamed, .cloned, .modified, .xattrModied, .ownerModified, .finderInfoModified, .inodeMetaModied, .mounted, .unmounted]
    
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension FSEventActions: CustomStringConvertible {
    public var description: String {
        return "[\(self.elements().collect().compactMap({$0._description}).joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        self == .none ? "[.none]" : "[\(self.elements().compactMap({$0._debugDescription}).joined(separator: ", "))]"
    }
    
    var _description: String {
        switch self {
        case .none: return "none"
        case .rootChanged: return "rootChanged"
        case .mounted: return "mounted"
        case .unmounted: return "unmounted"
        case .created: return "created"
        case .removed: return "removed"
        case .inodeMetaModied: return "inodeMetaModied"
        case .renamed: return "renamed"
        case .modified: return "modified"
        case .finderInfoModified: return "finderInfoModified"
        case .ownerModified: return "ownerModified"
        case .xattrModied: return "xattrModied"
        case .cloned: return "cloned"
        default: return "unkown"
        }
    }
    
    var _debugDescription: String {
        switch self {
        case .none: return "None"
        case .rootChanged: return "Root changed"
        case .mounted: return "Mounted"
        case .unmounted: return "Unmounted"
        case .created: return "Created"
        case .removed: return "Removed"
        case .inodeMetaModied: return "Inode metadata changed"
        case .renamed: return "Renamed"
        case .modified: return "Modified"
        case .cloned: return "Cloned"
        case .finderInfoModified: return "Finder info changed"
        case .ownerModified: return "Owner changed"
        case .xattrModied: return "Xattr modified"
        default: return "Unkown"
        }
    }
}
#endif
