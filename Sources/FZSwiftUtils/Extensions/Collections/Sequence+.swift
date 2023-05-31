//
//  Sequence+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /**
     Returns indexes of elements that satisfies the given predicate.

     - Parameters predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     
     - Returns: The indexes of the elements that satisfies the given predicate.
     */
    func indexes(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        var indexes = IndexSet()
        for (index, element) in enumerated() {
            if try (predicate(element) == true) {
                indexes.insert(index)
            }
        }
        return indexes
    }
}

public extension Sequence where Element: RawRepresentable {
    /// An array of corresponding values of the raw type.
    func rawValues() -> [Element.RawValue] {
        compactMap { $0.rawValue }
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable {
    /**
     Returns the first element of the sequence that satisfies the  raw value.

     - Parameters rawValue: The raw value.
     
     - Returns: The first element of the sequence that matches the raw value.
     */
    func first(rawValue: Element.RawValue) -> Element? {
        return first(where: { $0.rawValue == rawValue })
    }
}

public extension Sequence where Element: Equatable {
    func contains<S: Sequence<Element>>(any elements: S) -> Bool {
        for element in elements {
            if contains(element) {
                return true
            }
        }
        return false
    }

    func contains<S: Sequence<Element>>(all elements: S) -> Bool {
        for checkElement in elements {
            if contains(checkElement) == false {
                return false
            }
        }
        return true
    }
}

public extension Sequence where Element == String {
    func joined(by option: String.JoinOptions) -> String {
        switch option {
        case .line: return self.joined(separator: "\n")
        }
    }
}

public extension String {
    enum JoinOptions {
        case line
    }
}
