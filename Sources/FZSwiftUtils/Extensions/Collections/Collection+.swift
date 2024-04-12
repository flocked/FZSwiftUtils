//
//  Collection+.swift
//
//
//  Created by Florian Zand on 15.01.22.
//

import Foundation

public extension MutableCollection {
    /// Edits the elements.
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in indices {
            try body(&self[index])
        }
    }
}

extension Collection {
    /**
     Returns a subsequence containing the first elements.

     - Parameter amount: The number of elements to return.
     */
    public func first(_ amount: Int) -> Self.SubSequence {
        guard !isEmpty, amount > 0 else { return dropFirst(count) }
        return dropLast(count - amount.clamped(max: count))
    }

    /**
     Returns a subsequence containing the last elements.

     - Parameter amount: The number of elements to return.
     */
    public func last(_ amount: Int) -> Self.SubSequence {
        guard !isEmpty, amount > 0 else { return dropFirst(count) }
        return dropFirst(count - amount.clamped(max: count))
    }
}

public extension Collection {
    subscript(safe index: Index) -> Element? {
        guard !isEmpty, index >= startIndex, index < count else { return nil }
        return self[index]
    }

    subscript(indexes: [Index]) -> [Element] {
        indexes.compactMap { self[safe: $0] }
    }
}

public extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= startIndex, index < count else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= startIndex, index < count, let newValue = newValue else { return }
            self[index] = newValue
        }
    }
}

public extension Collection where Element: Equatable {
    /**
     A Boolean value indicating whether the collection contains any of the specified elements.

     - Parameter elements: The elements.
     - Returns: `true` if any of the elements exists in the collection, or` false` if non exist in the option set.
     */
    func contains<S>(any elements: S) -> Bool where S: Sequence, Element == S.Element {
        for element in elements {
            if contains(element) {
                return true
            }
        }
        return false
    }

    /**
     A Boolean value indicating whether the collection contains all specified elements.

     - Parameter elements: The elements.
     - Returns: `true` if all elements exist in the collection, or` false` if not.
     */
    func contains<S>(all elements: S) -> Bool where S: Sequence, Element == S.Element {
        for element in elements {
            if contains(element) == false {
                return false
            }
        }
        return true
    }
}

public extension Collection {
    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try Dictionary(grouping: self, by: keyForValue)
    }

    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    func grouped<Key>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    /// Splits the collection by the specified keypath and values that are returned for each keypath.
    func split<Key>(by keyPath: KeyPath<Element, Key>) -> [(key: Key, values: [Element])] where Key: Equatable {
        split(by: { $0[keyPath: keyPath] })
    }

    /// Splits the collection by the key returned from the specified closure and values that are returned for each key.
    func split<Key>(by keyForValue: (Element) throws -> Key) rethrows -> [(key: Key, values: [Element])] where Key: Equatable {
        var output: [(key: Key, values: [Element])] = []
        for value in self {
            let key = try keyForValue(value)
            if let index = output.firstIndex(where: { $0.key == key }) {
                output[index].values.append(value)
            } else {
                output.append((key, [value]))
            }
        }
        return output
    }
}

public extension Collection where Index == Int {
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter bounds: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe bounds: Range<Index>) -> [Element] {
        guard !isEmpty else { return [] }
        let range = bounds.clamped(to: 0 ..< count)
        return range.compactMap { self[safe: $0] }
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter bounds: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe bounds: ClosedRange<Int>) -> [Element] {
        guard !isEmpty else { return [] }
        let range = bounds.clamped(to: 0 ... count - 1)
        return range.compactMap { self[safe: $0] }
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter indexes: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(indexes: IndexSet) -> [Element] { indexes.compactMap { self[safe: $0] } }
}

public extension RangeReplaceableCollection where Index == Int {
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter bounds: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe bounds: Range<Index>) -> [Element] {
        get {
            guard !isEmpty else { return [] }
            let range = bounds.clamped(to: 0 ..< count)
            return range.compactMap { self[safe: $0] }
        }
        set {
            guard !isEmpty else { return }
            let range = bounds.clamped(to: 0 ..< count)
            replaceSubrange(range, with: newValue)
        }
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter bounds: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe bounds: ClosedRange<Int>) -> [Element] {
        get {
            guard !isEmpty else { return [] }
            let range = bounds.clamped(to: 0 ... count - 1)
            return range.compactMap { self[safe: $0] }
        }
        set {
            guard !isEmpty else { return }
            let range = bounds.clamped(to: 0 ... count - 1)
            replaceSubrange(range, with: newValue)
        }
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /**
     Removes the specificed element and returns them.

     - Parameter element: The element to remove.
     - Returns: Returns the removed element.
     */
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        var removedElement: Element?
        while let index = firstIndex(of: element) {
            removedElement = remove(at: index)
        }
        return removedElement
    }

    /**
     Removes the specificed elements and returns them.

     - Parameter elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        var removedElements: [Element] = []
        for element in elements {
            while let index = firstIndex(of: element) {
                let removed = remove(at: index)
                removedElements.append(removed)
            }
        }
        return removedElements
    }
}

public extension RangeReplaceableCollection where Self.Indices.Element == Int {
    /**
     Removes the elements at the specified indexes and returns them.

     - Parameter indexes: The indexes of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at indexes: IndexSet) -> [Self.Element] {
        var returnItems = [Self.Element]()
        for (index, _) in enumerated().reversed() {
            if indexes.contains(index) {
                returnItems.insert(remove(at: index), at: startIndex)
            }
        }
        return returnItems
    }

    /**
     Moves the element at the specified index to the specified position.

     - Parameters:
        - index: The index of the element.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(from index: Int, to destinationIndex: Index) -> Bool {
        move(from: IndexSet([index]), to: destinationIndex)
    }

    /**
     Moves the elements at the specified indexes to the specified position.

     - Parameters:
        - indexes: The indexes of the elements to move.
        - destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
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
    /**
     Moves the specified element to the specified position.

     - Parameters:
        - element: The element to move.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(_ element: Element, to destinationIndex: Self.Indices.Element) -> Bool {
        let indexes = indexes(for: [element])
        return move(from: indexes, to: destinationIndex)
    }

    /**
     Moves the specified elements to the specified position.

     - Parameters:
        - elements: The elements to move.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move<S: Sequence<Element>>(_ elements: S, to destinationIndex: Self.Indices.Element) -> Bool {
        let indexes = indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }

    /**
     Moves the specified element before the specified `beforeElement`.

     - Parameters:
        - element: The element to move.
        - beforeElement: The element to move before.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(_ element: Element, before beforeElement: Element) -> Bool {
        let indexes = indexes(for: [element])
        guard let destinationIndex = firstIndex(of: beforeElement) else { return false }
        return move(from: indexes, to: destinationIndex)
    }

    /**
     Moves the specified elements before the specified `beforeElement`.

     - Parameters:
        - elements: The elements to move.
        - beforeElement: The element to move before.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move<S: Sequence<Element>>(_ elements: S, before beforeElement: Element) -> Bool {
        guard let destinationIndex = firstIndex(of: beforeElement), destinationIndex + 1 < count else { return false }
        let indexes = indexes(for: elements)
        return move(from: indexes, to: destinationIndex)
    }

    /**
     Moves the specified element after the specified `afterElement`.

     - Parameters:
        - element: The element to move.
        - afterElement: The element to move after.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(_ element: Element, after afterElement: Element) -> Bool {
        let indexes = indexes(for: [element])
        guard let destinationIndex = firstIndex(of: afterElement), destinationIndex + 1 < count else { return false }
        return move(from: indexes, to: destinationIndex + 1)
    }

    /**
     Moves the specified elements after the specified `afterElement`.

     - Parameters:
        - elements: The elements to move.
        - afterElement: The element to move after.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move<S: Sequence<Element>>(_ elements: S, after afterElement: Element) -> Bool {
        guard let destinationIndex = firstIndex(of: afterElement), destinationIndex + 1 < count else { return false }
        let indexes = indexes(for: elements)
        return move(from: indexes, to: destinationIndex + 1)
    }

    /**
     Removes the specified element.

     - Parameter element: The element remove.
     - Returns: Returns the removed element.
     */
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        let indexes = indexes(for: [element])
        return remove(at: indexes).first
    }

    /**
     Removes the specified elements.

     - Parameter elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let indexes = indexes(for: elements)
        return remove(at: indexes)
    }

    /**
     Replaces the first appearance of the specified element with another.

     - Parameters:
        - element: The element to replace.
        - another: The replacing element.
     */
    mutating func replace(first element: Element, with another: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(another, at: index)
        }
    }

    /**
     Replaces the first appearance of the specified element with other elements.

     - Parameters:
        - element: The element to replace.
        - newElements: The replacing elements.
     */
    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }

    /**
     Replaces all appearances of the specified element with another.

     - Parameters:
        - element: The element to replace.
        - another: The replacing element.
     */
    mutating func replace(_ element: Element, with _: Element) {
        guard let index = firstIndex(of: element) else { return }
        remove(element)
        insert(element, at: index)
    }

    /**
     Replaces all appearance of the specified element with other elements.

     - Parameters:
        - element: The element to replace.
        - newElements: The replacing elements.
     */
    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
        replace(first: element, with: newElements)
        remove(element)
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /**
     Inserts a new element before the specified element.

     The new element is inserted before the specified element. If the element doesn't exist in the array, the new element won't be inserted.

     - Parameters:
        - newElement: The new element to insert into the array.
        - before: The element before which to insert the new element.
     */
    mutating func insert(_ newElement: Element, before: Element) {
        guard let index = firstIndex(of: before) else { return }
        insert(newElement, at: index)
    }

    /**
     Inserts a new element after the specified element.

     The new element is inserted after the specified element. If the element doesn't exist in the array, the new element won't be inserted.

     - Parameters:
        - newElement: The new element to insert into the array.
        - after: The element after which to insert the new element.
     */
    mutating func insert(_ newElement: Element, after: Element) {
        guard let index = firstIndex(of: after) else { return }
        insert(newElement, at: self.index(after: index))
    }

    /**
     Inserts the new elements before the specified element.

     The new elements are inserted before the specified element. If the element doesn't exist in the array, the new elements won't be inserted.

     - Parameters:
        - newElements: The new elements to insert into the array.
        - before: The element before which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, before: Element) where C: Collection<Element> {
        guard let index = firstIndex(of: before) else { return }
        insert(contentsOf: newElements, at: index)
    }

    /**
     Inserts the new elements after the specified element.

     The new elements are inserted after the specified element. If the element doesn't exist in the array, the new elements won't be inserted.

     - Parameters:
        - newElements: The new elements to insert into the array.
        - after: The element after which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, after: Element) where C: Collection<Element> {
        guard let index = firstIndex(of: after) else { return }
        insert(contentsOf: newElements, at: self.index(after: index))
    }
}

public extension Collection where Element: BinaryInteger {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }
}

public extension Collection where Element: FloatingPoint {
    /// The average value of all values in the collection. If the collection is empty, it returns 0.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
}

public extension Collection where Element: AdditiveArithmetic {
    /// The total sum value of all values in the collection. If the collection is empty, it returns `zero`.
    func sum() -> Self.Element {
        reduce(.zero, +)
    }
}

public extension RangeReplaceableCollection {
    /**
     Returns the collection rotated by the specified amount of positions.

     - Parameter positions: The amount of positions to rotate. A value larger than 0 rotates the collection to the right, a value smaller than 0 left.
     - Returns: The rotated collection.
     */
    func rotated(positions: Int) -> Self {
        guard positions != 0 else { return self }
        let index: Index
        let positions = -positions
        if positions > 0 {
            index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        } else {
            index = self.index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
        }
        return Self(self[index...] + self[..<index])
    }

    /**
     Rotates the collection by the specified amount of positions.

     - Parameter positions: The amount of positions to rotate. A value larger than 0 rotates the collection to the right, a value smaller than 0 left.
     */
    mutating func rotate(positions: Int) {
        guard positions != 0 else { return }
        let positions = -positions
        if positions > 0 {
            let index = index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
            removeSubrange(index...)
            insert(contentsOf: self[index...], at: startIndex)
        } else {
            let index = index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
            removeSubrange(..<index)
            insert(contentsOf: self[..<index], at: endIndex)
        }
    }
}
