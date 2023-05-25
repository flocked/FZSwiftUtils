//
//  Sequence+.swift
//  
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    func indexes(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        var indexes = IndexSet()
        for (index, element) in self.enumerated() {
            if (try predicate(element) == true) {
                indexes.insert(index)
            }
        }
        return indexes
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable  {
    func rawValues() -> [Element.RawValue] {
        self.compactMap({$0.rawValue})
    }
    
    func first(rawValue: Element.RawValue) -> Element? {
        return self.first(where: {$0.rawValue == rawValue})
    }
}

public extension Sequence where Element: Equatable  {
    func contains<S: Sequence<Element>>(any elements: S) -> Bool {
        for element in elements {
            if (self.contains(element)) {
                return true
            }
        }
        return false
    }
    
    func contains<S: Sequence<Element>>(all elements: S) -> Bool {
        for checkElement in elements {
            if (self.contains(checkElement) == false) {
                return false
            }
        }
        return true
    }
}

public extension Sequence where Element == String {
    func joinedByLines() -> String {
        self.joined(separator: "\n")
    }
}
