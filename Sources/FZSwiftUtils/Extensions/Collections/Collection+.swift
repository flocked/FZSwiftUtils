//
//  Collection+.swift
//
//
//  Created by Florian Zand on 15.01.22.
//

import Foundation

public extension MutableCollection {
    /// Edits each elements in the collection.
    mutating func editEach(_ transform: (inout Element) throws -> Void) rethrows {
        try indices.forEach({ try transform(&self[$0]) })
    }
}

extension Collection {
    /**
     Returns a subsequence containing the first elements.

     - Parameter amount: The number of elements to return.
     */
    public func first(_ amount: Int) -> SubSequence {
        guard !isEmpty, amount > 0 else { return dropFirst(count) }
        return dropLast(count - amount.clamped(max: count))
    }

    /**
     Returns a subsequence containing the last elements.

     - Parameter amount: The number of elements to return.
     */
    public func last(_ amount: Int) -> SubSequence {
        guard !isEmpty, amount > 0 else { return dropFirst(count) }
        return dropFirst(count - amount.clamped(max: count))
    }
}

public extension Collection {
    /// Returns the element at the index, or `nil` if the collection doesn't the index.
    subscript(safe index: Index) -> Element? {
        guard !isEmpty, index >= startIndex, index < endIndex else { return nil }
        return self[index]
    }

    /// Returns the available elements at the specified indexes.
    subscript(indexes: [Index]) -> [Element] {
        indexes.compactMap { self[safe: $0] }
    }
}

public extension Collection where Index == Int {
    /// Returns the available elements at the specified indexes.
    subscript(indexes: IndexSet) -> [Element] {
        indexes.compactMap { self[safe: $0] }
    }
}

public extension Array {
    init(reserveCapacity capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }
}

public extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= startIndex, index < endIndex else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= startIndex, index < endIndex, let newValue = newValue else { return }
            self[index] = newValue
        }
    }
}

public extension RangeReplaceableCollection where Self: MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= startIndex, index < endIndex else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= startIndex, index < endIndex else { return }
            if let newValue = newValue {
                self[index] = newValue
            } else {
                self.remove(at: index)
            }
        }
    }
}

public extension Collection where Index: Comparable {
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: Range<Index>) -> [Element] {
        !isEmpty ? Array(self[range.clamped(to: startIndex..<endIndex)]) : []
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: ClosedRange<Index>) -> [Element] {
        !isEmpty ? Array(self[range.clamped(to: startIndex..<endIndex)]) : []
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeFrom<Index>) -> [Element] {
        self[safe: range.lowerBound..<endIndex]
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeUpTo<Index>) -> [Element] {
        self[safe: startIndex..<range.upperBound]
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeThrough<Index>) -> [Element] {
        get { self[safe: startIndex...range.upperBound] }
    }
    
    /// Returns the elements of the collection upto the specified maximum count.
    subscript(max maximum: Index) -> [Element] {
        return self[safe: startIndex..<maximum]
    }
}

public extension RangeReplaceableCollection {
    /// Adds the specified optional `Element`.
    static func += (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs.append(rhs)
    }

    /// Adds the specified optional `Element`.
    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        return lhs + [rhs]
    }
    
    static func + (lhs: Element?, rhs: Self) -> Self {
        guard let lhs = lhs else { return rhs }
        return [lhs] + rhs
    }
    
    static func + (lhs: Element, rhs: Self) -> Self {
        [lhs] + rhs
    }
    
    /// Adds the specified optional `Element`.
    static func += <Other>(lhs: inout Self, rhs: Other?) where Other: Sequence<Element> {
        guard let rhs = rhs else { return }
        lhs += rhs
    }
    
    static func + <Other>(lhs: Self, rhs: Other?) -> Self where Other: Sequence<Element> {
        guard let rhs = rhs else { return lhs }
        return lhs + rhs
    }
    
    static func + <Other>(lhs: Other?, rhs: Self) -> Self where Other: Sequence<Element> {
        guard let lhs = lhs else { return rhs }
        return lhs + rhs
    }
    
    /**
     Adds a new element at the start of the collection.
     
     Use this method to prepend a single element to the start of a mutable collection.
     
     ```swift
     var numbers = [1, 2, 3, 4, 5]
     numbers.prepend(100)
     print(numbers)
     // Prints "[100, 1, 2, 3, 4, 5]"
     ```
     
     - Parameter newElement: The element to prepend to the collection.
     */
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: startIndex)
    }
    
    /**
     Adds the elements of a sequence or collection to the start of this collection.

     The collection being appended to allocates any additional necessary storage to hold the new elements.
     
     The following example prepends the elements of a Range<Int> instance to an array of integers:
     
     ```swift
     var numbers = [1, 2, 3, 4, 5]
     numbers.prepend(contentsOf: 10...15)
     print(numbers)
     // Prints "[10, 11, 12, 13, 14, 15, 1, 2, 3, 4, 5]"
     ```
     
     - Parameter newElements: The elements to prepend to the collection.
     */
    mutating func prepend<S>(contentsOf newElements: S) where S : Collection<Element> {
        insert(contentsOf: newElements, at: startIndex)
    }
}

public extension RangeReplaceableCollection {
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: Range<Index>) -> [Element] {
        get { Array(self[range.clamped(to: startIndex..<endIndex)]) }
        set { replaceSubrange(range.clamped(to: startIndex..<endIndex), with: newValue) }
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: ClosedRange<Index>) -> [Element] {
        get { Array(self[range.clamped(to: startIndex..<endIndex)]) }
        set { replaceSubrange(range.clamped(to: startIndex..<endIndex), with: newValue) }
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeFrom<Index>) -> [Element] {
        get { self[safe: range.lowerBound..<endIndex] }
        set { self[safe: range.lowerBound..<endIndex] = newValue }
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeUpTo<Index>) -> [Element] {
        get { self[safe: startIndex..<range.upperBound] }
        set { self[safe: startIndex..<range.upperBound] = newValue }
    }
    
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: PartialRangeThrough<Index>) -> [Element] {
        get { self[safe: startIndex...range.upperBound] }
        set { self[safe: startIndex...range.upperBound] = newValue }
    }
}

public extension RangeReplaceableCollection {

    /**
     Moves the element at the specified index to the specified position.

     - Parameters:
        - index: The index of the element.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(from index: Index, to destinationIndex: Index) -> Bool {
        guard index != destinationIndex, indices.contains(index), indices.contains(destinationIndex) else { return false }
        insert(remove(at: index), at: destinationIndex)
        return true
    }

    /**
     Moves the elements at the specified indexes to the specified position.

     - Parameters:
        - indexes: The indexes of the elements to move.
        - destinationIndex: The index of the destionation.
     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(from indexes: [Index], to destinationIndex: Index) -> Bool {
        guard destinationIndex >= startIndex && destinationIndex <= endIndex else { return false }
        let indexes = indexes.filter { $0 >= startIndex && $0 < endIndex }.sorted()
        guard !indexes.isEmpty else { return false }
        let adjustedDestination = index(destinationIndex, offsetBy: -indexes.filter { $0 < destinationIndex }.count)
        insert(contentsOf: remove(at: indexes), at: adjustedDestination)
        return true
    }
}

public extension RangeReplaceableCollection where Indices.Element == Int, Element: Equatable {
    /**
     Moves the specified element to the specified position.

     - Parameters:
        - element: The element to move.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(_ element: Element, to destinationIndex: Indices.Element) -> Bool {
        let indexes = indexes(of: element)
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
    mutating func move<S: Sequence<Element>>(_ elements: S, to destinationIndex: Indices.Element) -> Bool {
        let indexes = indexes(of: elements)
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
        let indexes = indexes(of: element)
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
        guard let destinationIndex = firstIndex(of: beforeElement), destinationIndex + 1 < endIndex else { return false }
        let indexes = indexes(of: elements)
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
        let indexes = indexes(of: [element])
        guard let destinationIndex = firstIndex(of: afterElement), destinationIndex + 1 < endIndex else { return false }
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
        guard let destinationIndex = firstIndex(of: afterElement), destinationIndex + 1 < endIndex else { return false }
        let indexes = indexes(of: elements)
        return move(from: indexes, to: destinationIndex + 1)
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
     Replaces all appearances of the specified element with another.

     - Parameters:
        - element: The element to replace.
        - another: The replacing element.
     */
    mutating func replace(_ element: Element, with another: Element) {
        for index in indexes(of: element) {
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
    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Element == C.Element {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }
    
    /**
     Replaces all appearance of the specified element with other elements.

     - Parameters:
        - element: The element to replace.
        - newElements: The replacing elements.
     */
    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Element == C.Element {
        for index in indexes(of: element) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }
    
    /**
     Replaces all appearances of the specified elements with another.

     - Parameters:
        - elements: The elements to replace.
        - another: The replacing element.
     */
    mutating func replace<C: Sequence<Element>>(_ elements: C, with another: Element) {
        for index in indexes(of: elements) {
            remove(at: index)
            insert(another, at: index)
        }
    }
    
    /**
     Replaces all appearances of the specified elements with another.

     - Parameters:
        - elements: The elements to replace.
        - newElements: The replacing elements.
     */
    mutating func replace<C: Collection<Element>, R: Collection<Element>>(_ elements: C, with newElements: R) {
        for index in indexes(of: elements) {
            remove(at: index)
            insert(contentsOf: newElements, at: index)
        }
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /**
     Inserts a new element before the specified element.

     The new element is inserted before the specified element. If the element doesn't exist in the collection, the new element won't be inserted.

     - Parameters:
        - newElement: The new element to insert into the collection.
        - before: The element before which to insert the new element.
     */
    mutating func insert(_ newElement: Element, before: Element) {
        guard let index = firstIndex(of: before) else { return }
        insert(newElement, at: index)
    }

    /**
     Inserts a new element after the specified element.

     The new element is inserted after the specified element. If the element doesn't exist in the collection, the new element won't be inserted.

     - Parameters:
        - newElement: The new element to insert into the collection.
        - after: The element after which to insert the new element.
     */
    mutating func insert(_ newElement: Element, after: Element) {
        guard let index = firstIndex(of: after) else { return }
        insert(newElement, at: self.index(after: index))
    }

    /**
     Inserts the new elements before the specified element.

     The new elements are inserted before the specified element. If the element doesn't exist in the collection, the new elements won't be inserted.

     - Parameters:
        - newElements: The new elements to insert into the collection.
        - before: The element before which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, before: Element) where C: Collection<Element> {
        guard let index = firstIndex(of: before) else { return }
        insert(contentsOf: newElements, at: index)
    }

    /**
     Inserts the new elements after the specified element.

     The new elements are inserted after the specified element. If the element doesn't exist in the collection, the new elements won't be inserted.

     - Parameters:
        - newElements: The new elements to insert into the collection.
        - after: The element after which to insert the new elements.
     */
    mutating func insert<C>(_ newElements: C, after: Element) where C: Collection<Element> {
        guard let index = firstIndex(of: after) else { return }
        insert(contentsOf: newElements, at: self.index(after: index))
    }
}

extension Collection where Element: BinaryInteger {
    /**
     A Boolean value indicating whether the integers in the array are incrementing by the specified value.
     
     - Parameters:
        - value: The incrementing value.
        - sorted: A Boolean value indicating whether to check the integers in a sorted order.
     */
    public func isIncrementing(by value: Element = 1, sorted: Bool = false) -> Bool {
        guard count > 1 else { return true }
        let elements = sorted ? self.sorted() : self as? Array ?? Array(self)
        return !elements.indices.dropFirst().contains { elements[$0] != elements[$0 - 1] + value }
    }
}

extension Collection where Self: RandomAccessCollection, Element: BinaryFloatingPoint {
    /**
     A Boolean value indicating whether the elements in the array are incrementing by the specified value.
     
     - Parameters:
        - value: The incrementing value.
        - tolerance: The maximum allowed difference when comparing increments. Default is `0` (exact match).
        - sorted: A Boolean value indicating whether to check the elements in a sorted order.
     */
    public func isIncrementing(by value: Element = 1, tolerance: Element = 0, sorted: Bool = false) -> Bool {
        guard count > 1 else { return true }
        let elements = sorted ? self.sorted() : self as? Array ?? Array(self)
        return !elements.indices.dropFirst().contains { abs(elements[$0] - elements[elements.index(before: $0)] - value) > tolerance }
    }
}

extension BidirectionalCollection {
    /**
     Returns an index that is the specified distance from the given index.
     
     - Parameters:
        - index: A valid index of the collection.
        - distance: The distance to offset `index`.
        - loop: A Boolean value indicating whether the offset wraps around the collection when the end or start is exceeded. If `false`, the index will clamp to the start and end index.
     i
     */
    public func index(_ index: Index, offsetBy value: Int = 1, loop: Bool) -> Index {
        guard !isEmpty else { return startIndex }
        let count = self.count
        var pos = distance(from: startIndex, to: index) + value
        pos = loop
            ? (pos % count + count) % count
        : Swift.min(Swift.max(pos, 0), count - 1)
        return self.index(startIndex, offsetBy: pos)
    }
    
    /**
     Returns an array of indices offset from a given index by the specified amount.
     
     A positive `count` moves forward, negative `count` moves backward.
     
     - Parameters:
       - index: The starting index.
       - count: The number of indices to return. Positive for forward, negative for backward.
       - loop: A Boolean value indicating whether to loop around the collection when reaching the start or end.
     */
    public func indexes(from index: Index, offsetBy count: Int, loop: Bool = true) -> [Index] {
        guard !isEmpty, count != 0 else { return [] }

        let direction = count.signum()
        var steps = abs(count)

        if !loop {
            let maxSteps = count > 0
                ? distance(from: index, to: self.index(before: endIndex))
                : -distance(from: startIndex, to: index)
            steps = Swift.min(steps, abs(maxSteps))
        }

        var index = index
        return (0..<steps).map { _ in
            index = self.index(index, offsetBy: direction, loop: loop)
            return index
        }
    }
}

public extension Collection where Element: AnyObject {
    /**
     Returns the first index where the specified value appears in the collection.
     
     After using `firstIndex(of:)` to find the position of a particular element in a collection, you can use it to access the element by subscripting.
     
     This example shows how you can modify one of the names in an array of students:
     ```swift
     var students = ["Ben", "Ivy", "Jordell", "Maxime"]
     if let i = students.firstIndex(of: "Maxime") {
         students[i] = "Max"
     }
     print(students)
     // Prints "["Ben", "Ivy", "Jordell", "Max"]"
     ```
     
     - Parameter element: An element to search for in the collection.
     - Returns: The first index where element is found. If element is not found in the collection, returns `nil`.
     */
    @_disfavoredOverload
    func firstIndex(of element: Element) -> Index? {
        firstIndex(where: { $0 === element })
    }
    
    /**
     Returns the indexes of the specified elements.

     - Parameter elements: The elements.

     - Returns: An array of the indexes of the elements.
     */
    @_disfavoredOverload
    func indexes<S>(of elements: S) -> [Index] where S: Sequence<Element> {
        elements.reduce(into: []) { $0 += firstIndex(of: $1) }
    }
    
    /**
     Returns the indexes of the specified elements.

     - Parameter elements: The elements.

     - Returns: An array of the indexes of the elements.
     */
    @_disfavoredOverload
    func indexes<S>(of elements: S) -> [Index] where S: Sequence<Element>, Self: RangeReplaceableCollection {
        var values = self
        return elements.reduce(into: []) {
            guard let index = values.firstIndex(of: $1) else { return }
            values.remove(at: index)
            $0 += index
        }
    }
}
