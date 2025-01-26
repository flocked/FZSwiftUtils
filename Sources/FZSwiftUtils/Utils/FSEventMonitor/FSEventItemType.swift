//
//  FSEventItemType.swift
//  
//
//  Created by Florian Zand on 26.01.25.
//

import Foundation

/// Represents the item type for a file system event.
public struct FSEventItemType: OptionSet, Hashable {
    /// The item is a file.
    public static let file = Self(rawValue: 65536)
    /// The item is a directory.
    public static let directory = Self(rawValue: 131072)
    /// The item is a symbolic link.
    public static let symbolicLink = Self(rawValue: 262144)
    /// The item is a hard link.
    public static let hardlink = Self(rawValue: 1048576)
    /// The item is the last hard link to a file.
    public static let lastHardlink = Self(rawValue: 2097152)
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension FSEventItemType: CustomStringConvertible {
    public var description: String {
        "[\(elements().compactMap({$0._description}).joined(separator: ", "))]"
    }
    
    var _description: String {
        switch self {
        case .file: return "File"
        case .directory: return "Directory"
        case .symbolicLink: return "SymbolicLink"
        case .hardlink: return "Hardlink"
        case .lastHardlink: return "Last hardlink"
        default: return ""
        }
    }
}
