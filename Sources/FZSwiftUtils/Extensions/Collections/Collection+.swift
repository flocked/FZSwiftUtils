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
        guard !isEmpty, index >= startIndex, index < count else { return nil }
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

public extension RangeReplaceableCollection {
    /**
     Removes the first element that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the collection.
     
     - Returns: The removed element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    @discardableResult
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
    
    /// Removes all elements matching the predicate and returns the removed elements.
    @discardableResult
    mutating func removeAllAndReturn(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> [Element] {
        var removed: [Element] = []
        var kept: Self = .init()
        for element in self {
            if try shouldBeRemoved(element) {
                removed.append(element)
            } else {
                kept.append(element)
            }
        }
        self = kept
        return removed
    }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
    /**
     Removes the last element that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the collection.
     
     - Returns: The removed element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    mutating func removeLast(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let lastIndex = try lastIndex(where: predicate) else { return nil }
        return remove(at: lastIndex)
    }
}

public extension RangeReplaceableCollection where Self: MutableCollection {
    /// Removes all the elements at the specified range.
    mutating func remove(at range: ClosedRange<Int>) {
        let range = range.clamped(to: 0...count - 1)
        remove(atOffsets: IndexSet(range))
    }
    
    /// Removes all the elements at the specified range.
    mutating func remove(at range: Range<Int>) {
        let range = range.clamped(to: 0..<count)
        remove(atOffsets: IndexSet(range))
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
        if let rhs = rhs {
            lhs.append(rhs)
        }
    }

    /// Adds the specified optional `Element`.
    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        return lhs + [rhs]
    }
    
    static func + (lhs: Element, rhs: Self) -> Self {
        [lhs] + rhs
    }

    static func + (lhs: Element?, rhs: Self) -> Self {
        guard let lhs = lhs else { return rhs }
        return [lhs] + rhs
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

public extension RangeReplaceableCollection {
    /**
     Removes the elements at the specified indexes and returns them.

     - Parameter indexes: The indexes of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at indexes: [Index]) -> [Element] {
        indexes.filter({$0 >= startIndex && $0 < endIndex}).indexed().compactMap({ remove(at: self.index($0.element, offsetBy: -$0.index) ) })
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: Range<Index>) -> [Self.Element] {
        let range = range.clamped(to: startIndex..<endIndex)
        let removed = self[safe: range]
        removeSubrange(range)
        return removed
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: ClosedRange<Index>) -> [Self.Element] {
        remove(at: (range.lowerBound..<index(after: range.upperBound)))
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeFrom<Index>) -> [Self.Element] {
        remove(at: range.lowerBound..<endIndex)
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeUpTo<Index>) -> [Self.Element] {
        remove(at: startIndex..<range.upperBound)
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeThrough<Index>) -> [Self.Element] {
        remove(at: startIndex..<index(after:range.upperBound))
    }

    /**
     Moves the element at the specified index to the specified position.

     - Parameters:
        - index: The index of the element.
        - destinationIndex: The index of the destionation.

     - Returns: `true` if moving succeeded, or `false` if not.
     */
    @discardableResult
    mutating func move(from index: Index, to destinationIndex: Index) -> Bool {
        move(from: [index], to: destinationIndex)
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
        let indexes = indexes.filter({ $0 >= startIndex && $0 < endIndex })
        guard !indexes.isEmpty else { return false }
        guard destinationIndex >= startIndex && destinationIndex < index(endIndex, offsetBy: indexes.count) else { return false }
        let itemsToMove = remove(at: indexes)
        insert(contentsOf: itemsToMove, at: index(destinationIndex, offsetBy: -indexes.filter { destinationIndex > $0 }.count))
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
        guard let destinationIndex = firstIndex(of: beforeElement), destinationIndex + 1 < count else { return false }
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
        let indexes = indexes(of: elements)
        return move(from: indexes, to: destinationIndex + 1)
    }

    /**
     Removes the specified element.

     - Parameter element: The element remove.
     - Returns: Returns the removed element.
     */
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        let indexes = indexes(of: [element])
        return remove(at: indexes).first
    }

    /**
     Removes the specified elements.

     - Parameter elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let indexes = indexes(of: elements)
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
    mutating func replace<C>(first element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
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
    mutating func replace<C>(_ element: Element, with newElements: C) where C: Collection, Self.Element == C.Element {
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

public extension RangeReplaceableCollection {
    /**
     Returns the collection rotated by the specified amount of positions.
     
     Example:
     
     ```swift
     let values = [1, 2, 3, 4, 5]
     print(values.rotated(by: 1)) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     - Returns: The rotated collection.
     */
    func rotated(by positions: Int) -> Self {
        guard !isEmpty else { return self }
        let positions = positions.quotientAndRemainder(dividingBy: count).remainder
        guard positions != .zero else { return self }
        let index: Index
        if positions > 0 {
            index = self.index(endIndex, offsetBy: -positions, limitedBy: startIndex) ?? startIndex
        } else {
            index = self.index(startIndex, offsetBy: -positions, limitedBy: endIndex) ?? endIndex
        }
        return Self(self[index...] + self[..<index])
    }
    
    /**
     Returns the collection rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    func rotated(toStartAt index: Int) -> Self {
        guard index >= 0, index < count else { return self }
        return rotated(by: -index)
    }

    /**
     Rotates the collection by the specified amount of positions.
     
     Example:
     
     ```swift
     var values = [1, 2, 3, 4, 5]
     values.rotate(by: 1)
     print(values) // [5, 1, 2, 3, 4]
     ```

     - Parameter positions: The amount of positions to rotate. A value larger than `0` rotates the collection to the right, a value smaller than `0` left.
     */
    mutating func rotate(by positions: Int) {
        self = rotated(by: positions)
    }
    
    /**
     Returns the collection rotated to start at the specified index.
     
     - Parameter index: The index of the element that should be at the start after rotating.
    */
    mutating func rotate(toStartAt index: Int) {
        guard index >= 0, index < count else { return }
        rotate(by: -index)
    }
}

public extension RangeReplaceableCollection {
    /**
     Removes and returns the first element of the collection safetly.
     
     - Returns: The removed element, or `nil` if the collection is empty.
     */
    @discardableResult
    mutating func removeFirstSafetly() -> Element? {
        !isEmpty ? removeFirst() : nil
    }
    
    /**
     Removes and returns the specified number of elements from the beginning of the collection.
     
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.`
     - Returns: The removed elements.
     */
    @discardableResult
    mutating func removeFirstSafetly(_ k: Int) -> [Element] {
        guard !isEmpty else { return [] }
        return (0..<k.clamped(max: count)).compactMap({ _ in removeFirst() })
    }
    
    /**
     Removes and returns the last element of the collection safetly.
     
     - Returns: The last element of the collection, or `nil` if the collection is empty.
     */
    @discardableResult
    mutating func removeLastSafetly() -> Element? where Self: BidirectionalCollection {
        !isEmpty ? removeLast() : nil
    }
    
    /**
     Removes the specified number of elements from the end of the collection.
          
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.
     */
    mutating func removeLastSafetly(_ k: Int) where Self: BidirectionalCollection {
        guard !isEmpty else { return }
        removeLast(k.clamped(max: count))
    }
    
    /**
     Removes and returns the specified number of elements from the end of the collection.
          
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.
     */
    @discardableResult
    mutating func removeLastSafetly(_ k: Int) -> [Element] where Index == Int {
        guard !isEmpty else { return [] }
        return ((count-k).clamped(min: 0)..<count).compactMap({ remove(at: $0) })
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
        let elements = sorted ? self.sorted() : Array(self)
        return !(1..<count).contains(where: { elements[$0] != elements[$0 - 1] + value })
    }
}

extension Collection where Self: RandomAccessCollection, Element: BinaryFloatingPoint {
    /**
     A Boolean value indicating whether the elements in the array are incrementing by the specified value.
     
     - Parameters:
        - value: The incrementing value.
        - sorted: A Boolean value indicating whether to check the elements in a sorted order.
     */
    public func isIncrementing(by value: Element = 1, sorted: Bool = false) -> Bool {
        let elements = sorted ? self.sorted() : Array(self)
        return !(1..<count).contains(where: { elements[$0] != elements[$0 - 1] + value })
    }
}
