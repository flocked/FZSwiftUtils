//
//  Array+Identifable.swift
//  FZCollection
//
//  Created by Florian Zand on 03.05.22.
//

import Foundation

public extension Sequence where Element: Identifiable {
    /// An array of IDs of the elements.
    var ids: [Element.ID] {
        return compactMap { $0.id }
    }
    
    subscript(firstID id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    subscript(id id: Element.ID) -> [Element] {
        self.filter({$0.id == id})
    }

    subscript<S: Sequence<Element.ID>>(ids ids: S) -> [Element] {
        filter { ids.contains($0.id) }
    }
}

public extension Collection where Element: Identifiable {
    func index(of element: Element) -> Self.Index? {
        return firstIndex(where: { $0.id == element.id })
    }

    func indexes<S: Sequence<Element>>(of elements: S) -> [Self.Index] {
        return elements.compactMap { self.index(of: $0) }
    }
}

public extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }

    mutating func remove<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            remove(element)
        }
    }
}

public extension Array where Element: Identifiable {
    mutating func move<S: Sequence>(_ elements: S, before: Element) where S.Element == Element {
        if let toIndex = index(of: before) {
            let indexSet = IndexSet(indexes(of: elements))
            move(from: indexSet, to: toIndex)
        }
    }

    mutating func move<S: Sequence>(_ elements: S, after: Element) where S.Element == Element {
        if let toIndex = index(of: after) {
            let indexSet = IndexSet(indexes(of: elements))
            move(from: indexSet, to: toIndex)
        }
    }
}
