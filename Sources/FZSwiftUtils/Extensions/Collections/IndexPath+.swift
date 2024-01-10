//
//  IndexPath+.swift
//
//
//  Created by Florian Zand on 21.12.23.
//

import Foundation

public extension IndexPath {
    /// An index path with a `item` and `section` value of `0`.
    static var zero: IndexPath { IndexPath(item: 0, section: 0) }

    #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
        /// `NSIndexPath` representation of the value.
        var nsIndexPath: NSIndexPath {
            #if os(macOS)
                NSIndexPath(forItem: item, inSection: section)
            #else
                NSIndexPath(item: item, section: section)
            #endif
        }
    #endif
}

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
    public extension NSIndexPath {
        /// `IndexPath` representation of the value.
        var indexPath: IndexPath {
            IndexPath(item: item, section: section)
        }
    }
#endif
