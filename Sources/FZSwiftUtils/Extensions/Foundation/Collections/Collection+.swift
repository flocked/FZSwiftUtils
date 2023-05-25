//
//  Array+Extension.swift
//  ATest
//
//  Created by Florian Zand on 15.01.22.
//

import Foundation

public extension Collection where Index == Int {
    subscript(safe safeIndex: Index) -> Element? {
        if isEmpty == false, safeIndex < count - 1 {
            return self[safeIndex]
        }
        return nil
    }

    subscript(indexes: IndexSet) -> [Element] {
        return indexes.compactMap { self[safe: $0] }
    }
}

public extension RangeReplaceableCollection where Self.Indices.Element == Int {
    @discardableResult
    mutating func remove(at indexSet: IndexSet) -> [Self.Element] {
        var returnItems = [Self.Element]()
        for (index, _) in enumerated().reversed() {
            if indexSet.contains(index) {
                returnItems.insert(remove(at: index), at: startIndex)
            }
        }
        return returnItems
    }

    @discardableResult
    mutating func move(from index: Int, to destinationIndex: Index) -> Bool {
        return move(from: IndexSet([index]), to: destinationIndex)
    }

    @discardableResult
    mutating func move(from indexSet: IndexSet, to destinationIndex: Index) -> Bool {
        guard indexSet.isSubset(of: IndexSet(indices)) else {
            debugPrint("Source indices out of range.")
            return false
        }
        guard (0 ..< count + indexSet.count).contains(destinationIndex) else {
            debugPrint("Destination index out of range.")
            return false
        }

        let itemsToMove = remove(at: indexSet)

        let modifiedDestinationIndex: Int = destinationIndex - indexSet.filter { destinationIndex > $0 }.count

        insert(contentsOf: itemsToMove, at: modifiedDestinationIndex)

        return true
    }
}

public extension RangeReplaceableCollection where Self.Indices.Element == Int, Element: Equatable {
    func indexes(of element: Element) -> IndexSet {
        indexes(where: { $0 == element })
    }

    mutating func indexes<S: Sequence<Element>>(for elements: S) -> IndexSet {
        indexes(where: { elements.contains($0) })
    }

    @discardableResult
    mutating func move(_ element: Element, to destinationIndex: Index) -> Bool {
        let indexes = self.indexes(for: [element])
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    mutating func move<S: Sequence<Element>>(_ elements: S, to destinationIndex: Index) -> Bool {
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    mutating func remove(_ element: Element) -> [Element] {
        let indexes = self.indexes(for: [element])
        return remove(at: indexes)
    }

    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let indexes = self.indexes(for: elements)
        return remove(at: indexes)
    }

    mutating func replace(first element: Element, with: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(with, at: index)
        }
    }

    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }

    mutating func replace(_ element: Element, with: Element) {
        replace(first: element, with: with)
        if contains(element) {
            replace(element, with: with)
        }
    }

    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        replace(first: element, with: newElements)
        remove(element)
    }
}

public extension Collection where Element: BinaryInteger {
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }

    func sum() -> Self.Element {
        reduce(0, +)
    }
}

public extension Collection where Element: FloatingPoint {
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }

    func sum() -> Self.Element {
        reduce(0, +)
    }
}
