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
    
    /// Create a `IndexPath` with the specified item and the current section.
    func item(_ item: Int) -> IndexPath {
        IndexPath(item: item, section: section)
    }
    
    /// Create a `IndexPath` with the specified section and the current item.
    func section(_ section: Int) -> IndexPath {
        IndexPath(item: item, section: section)
    }
    
    /// Returns the next `IndexPath` with the incremented `item` value
    var next: IndexPath {
        item(item + 1)
    }
    
    /// Returns the previous `IndexPath` with the decremented` item` value, or `nil` if the value is `0`.
    var previous: IndexPath? {
        guard item > 0 else { return nil }
        return item(item - 1)
    }

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

public extension Sequence where Element == IndexPath {
    /// The sections of the index paths.
    var sections: [Int] {
        self.compactMap({$0.section}).uniqued().sorted()
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
    public extension NSIndexPath {
        /// `IndexPath` representation of the value.
        var indexPath: IndexPath {
            IndexPath(item: item, section: section)
        }
    }
#endif
