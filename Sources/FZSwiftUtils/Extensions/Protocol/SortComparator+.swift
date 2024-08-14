//
//  SortComparator+.swift
//  
//
//  Created by Florian Zand on 14.08.24.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension RangeReplaceableCollection where Element: SortComparator {
    /// Sets the order of all sort comparators.
    @discardableResult
    public mutating func order(_ order: SortOrder) -> Self {
        let elements = compactMap({
            var element = $0
            element.order = order
            return element
        })
        self = Self(elements)
        return self
    }
}
