//
//  Collection+.swift
//  
//
//  Created by Florian Zand on 15.01.22.
//

import Foundation

public extension MutableCollection {
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}

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
    
    subscript(indexes: [Index]) -> [Element] {
        return indexes.compactMap { self[safe: $0] }
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        var removedElements: [Element] = []
        for element in elements {
            while let index = self.firstIndex(of: element) {
                let removed = self.remove(at: index)
                removedElements.append(removed)
            }
        }
        return removedElements
    }
}

public extension RangeReplaceableCollection where Self.Indices.Element == Int {
    @discardableResult
    /**
     Removes the elements at the specified indexes and returns them.
     - Parameters indexes: The indexes of the elements to remove.
     - Returns: Returns the removed elements.
     */
    mutating func remove(at indexes: IndexSet) -> [Self.Element] {
        var returnItems = [Self.Element]()
        for (index, _) in enumerated().reversed() {
            if indexes.contains(index) {
                returnItems.insert(remove(at: index), at: startIndex)
            }
        }
        return returnItems
    }

    @discardableResult
    /**
     Moves the element at the specified index to the specified position.
     - Parameters index: The index of the element.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(from index: Int, to destinationIndex: Index) -> Bool {
        return move(from: IndexSet([index]), to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the elements at the specified indexes to the specified position.
     - Parameters indexes: The indexes of the elements to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(from indexes: IndexSet, to destinationIndex: Index) -> Bool {
        guard indexes.isSubset(of: IndexSet(indices)) else {
            debugPrint("Source indices out of range.")
            return false
        }
        guard (0 ..< count + indexes.count).contains(destinationIndex) else {
            debugPrint("Destination index out of range.")
            return false
        }

        let itemsToMove = remove(at: indexes)

        let modifiedDestinationIndex: Int = destinationIndex - indexes.filter { destinationIndex > $0 }.count

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
    /**
     Moves the specified element to the specified position.
     - Parameters element: The element to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, to destinationIndex: Index) -> Bool {
        let indexes = self.indexes(for: [element])
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the specified elements to the specified position.
     - Parameters elements: The elements to move.
     - Parameters destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, to destinationIndex: Index) -> Bool {
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }
    
    @discardableResult
    /**
     Moves the specified element before the specified `beforeElement`.
     - Parameters element: The element to move.
     - Parameters beforeElement: The element to move before.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, before beforeElement: Element) -> Bool {
        let indexes = self.indexes(for: [element])
        guard let destinationIndex = self.firstIndex(of: beforeElement) else { return false }
        return move(from: indexes, to: destinationIndex)
    }

    @discardableResult
    /**
     Moves the specified elements before the specified `beforeElement`.
     - Parameters elements: The elements to move.
     - Parameters beforeElement: The element to move before.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, before beforeElement: Element) -> Bool {
        guard let destinationIndex = self.firstIndex(of: beforeElement), destinationIndex + 1 < self.count else { return false }
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }
    
    @discardableResult
    /**
     Moves the specified element after the specified `afterElement`.
     - Parameters element: The element to move.
     - Parameters afterElement: The element to move after.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move(_ element: Element, after afterElement: Element) -> Bool {
        let indexes = self.indexes(for: [element])
        guard let destinationIndex = self.firstIndex(of: afterElement), destinationIndex + 1 < self.count else { return false }
        return move(from: indexes, to: destinationIndex + 1)
    }

    @discardableResult
    /**
     Moves the specified elements after the specified `afterElement`.
     - Parameters elements: The elements to move.
     - Parameters afterElement: The element to move after.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    mutating func move<S: Sequence<Element>>(_ elements: S, after afterElement: Element) -> Bool {
        guard let destinationIndex = self.firstIndex(of: afterElement), destinationIndex + 1 < self.count else { return false }
        let indexes = self.indexes(for: elements)
        return move(from: indexes, to: destinationIndex + 1)
    }

    @discardableResult
    /**
     Removes the specified element.
     - Parameters element: The element remove.
     - Returns: Returns the removed element.
     */
    mutating func remove(_ element: Element) -> Element? {
        let indexes = self.indexes(for: [element])
        return remove(at: indexes).first
    }

    @discardableResult
    /**
     Removes the specified elements.
     - Parameters elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let indexes = self.indexes(for: elements)
        return remove(at: indexes)
    }

    /**
     Replaces the first appearance of the specified element with another.
     - Parameters element: The element to replace.
     - Parameters another: The replacing element.
     */
    mutating func replace(first element: Element, with another: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(another, at: index)
        }
    }

    /**
     Replaces the first appearance of the specified element with other elements.
     - Parameters element: The element to replace.
     - Parameters newElements: The replacing elements.
     */
    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }

    /**
     Replaces all appearances of the specified element with another.
     - Parameters element: The element to replace.
     - Parameters another: The replacing element.
     */
    mutating func replace(_ element: Element, with: Element) {
        replace(first: element, with: with)
        if contains(element) {
            replace(element, with: with)
        }
    }

    /**
     Replaces all appearance of the specified element with other elements.
     - Parameters element: The element to replace.
     - Parameters newElements: The replacing elements.
     */
    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        replace(first: element, with: newElements)
        remove(element)
    }
}

public extension Collection where Element: BinaryInteger {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }

    /// The total sum value of all values in the collection. If the collection is empty, it returns 0.
    func sum() -> Self.Element {
        reduce(0, +)
    }
}

public extension Collection where Element: FloatingPoint {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }

    /// The total sum value of all values in the collection. If the collection is empty, it returns 0.
    func sum() -> Self.Element {
        reduce(0, +)
    }
}
