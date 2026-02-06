//
//  FSEvent+ItemType.swift
//  
//
//  Created by Florian Zand on 26.01.25.
//

#if os(macOS)
import Foundation

extension FSEvent {
    /// Represents the item type for a file system event.
    public struct ItemType: OptionSet, Hashable, CustomStringConvertible {
        /// The item is a file.
        public static let file = Self(kFSEventStreamEventFlagItemIsFile)
        /// The item is a directory.
        public static let directory = Self(kFSEventStreamEventFlagItemIsDir)
        /// The item is a symbolic link.
        public static let symbolicLink = Self(kFSEventStreamEventFlagItemIsSymlink)
        /// The item is a hard link.
        public static let hardlink = Self(kFSEventStreamEventFlagItemIsHardlink)
        /// The item is the last hard link to a file.
        public static let lastHardlink = Self(kFSEventStreamEventFlagItemIsLastHardlink)
        
        public var description: String {
            FSEvent.Flags(rawValue: rawValue).description
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
