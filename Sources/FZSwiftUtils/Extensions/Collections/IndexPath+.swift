//
//  IndexPath+.swift
//
//
//  Created by Florian Zand on 21.12.23.
//

import Foundation

extension IndexPath {
    /// An index path with a `item` and `section` value of `0`.
    public static var zero: IndexPath { IndexPath(item: 0, section: 0) }

    #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
    /// `NSIndexPath` representation of the value.
    public var nsIndexPath: NSIndexPath {
        #if os(macOS)
        NSIndexPath(forItem: item, inSection: section)
        #else
        NSIndexPath(item: item, section: section)
        #endif
    }
    #endif
}

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
extension NSIndexPath {
    /// `IndexPath` representation of the value.
    public var indexPath: IndexPath {
        IndexPath(item: item, section: section)
    }
}
#endif
