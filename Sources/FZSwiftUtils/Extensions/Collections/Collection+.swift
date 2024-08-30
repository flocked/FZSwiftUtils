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
            guard !isEmpty, index >= startIndex, index < count else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= startIndex, index < count, let newValue = newValue else { return }
            self[index] = newValue
        }
    }
}

public extension Collection where Index == Int {
    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: Range<Index>) -> [Element] {
        Array(self[Swift.min(range.lowerBound, count)..<Swift.min(range.upperBound, count)])
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter range: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(safe range: ClosedRange<Int>) -> [Element] {
        self[safe: range.lowerBound..<range.upperBound+1]
    }

    /**
     Accesses a contiguous subrange of the collection’s elements.

     - Parameter indexes: A range of integers.
     - Returns: The available elements of the collection at the range.
     */
    subscript(indexes: IndexSet) -> [Element] { indexes.compactMap { self[safe: $0] } }
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
        var copy = lhs
        if let rhs = rhs {
            copy.append(rhs)
        }
        return copy
    }

    static func + (lhs: Element?, rhs: Self) -> Self {
        if let lhs = lhs {
            return [lhs] + rhs
        }
        return rhs
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
        self = [newElement] + self
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
    mutating func prepend<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence {
        self = newElements + self
    }
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
        for index in indexes(for: elements) {
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
        for index in indexes(for: elements) {
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

public extension Collection where Element: BinaryInteger {
    /// The average value of all values in the collection. If the collection is empty, it returns `0`.
    func average() -> Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }
    
    /// The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
    func weightedAverage() -> Double {
        compactMap({Double($0)}).weightedAverage()
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     - Parameter weights: The weight of each element in the sequence.
     
     - Note: `weights` needs to have the same number of elements as the collection.
     */
    func weightedAverage(weights: [Double]) -> Double {
        compactMap({Double($0)}).weightedAverage(weights: weights)
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     The first value of the collection is weighted by the upper bound value of the range and the last value by the lower bound value of the range.
     
     - Parameter weighting: The range of the weights.
     */
    func weightedAverage(weighting: ClosedRange<Double>) -> Double {
        compactMap({Double($0)}).weightedAverage(weighting: weighting)
    }
}

public extension Collection where Element: FloatingPoint {
    /// The average value of all values in the collection. If the collection is empty, it returns `0`.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
}

public extension Collection where Element: BinaryFloatingPoint {
    /// The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
    func weightedAverage() -> Element {
        var weights: [Element] = []
        var value: Element = 1.0
        let divider: Element = 1.0/Element(count)
        for _ in 0..<count {
            weights.append(value)
            value = value - divider
        }
        return weightedAverage(weights: weights)
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
     
     - Parameter weights: The weight of each element in the sequence.
     
     - Note: `weights` needs to have the same number of elements as the collection.
     */
    func weightedAverage(weights: [Element]) -> Element {
        guard !isEmpty, count == weights.count else { return .zero }
        let totalWeight = weights.sum()
        guard totalWeight > 0 else { return .zero }
        return zip(self, weights).map { $0 * $1 }.reduce(.zero, +) / totalWeight
    }
    
    /**
     The weighted average value of all values in the collection. If the collection is empty, it returns `0`.
          
     The first value of the collection is weighted by the upper bound value of the range and the last value by the lower bound value of the range.

     - Parameter weighting: The range of the weights.
     */
    func weightedAverage(weighting: ClosedRange<Element>) -> Element {
        var weights: [Element] = []
        let range = weighting.upperBound-weighting.lowerBound
        let divider: Element = 1.0/Element(count-1)
        var value: Element = 1.0
        for _ in 0..<count {
            weights.append((range*value)+weighting.lowerBound)
            value = value - divider
        }
        return weightedAverage(weights: weights)
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
        self = self.rotated(by: positions)
    }
}

public extension RangeReplaceableCollection {
    /**
     Removes and returns the first element of the collection safetly.
     
     - Returns: The removed element, or `nil` if the collection is empty.
     */
    mutating func removeFirstSafetly() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
    
    /**
     Removes the specified number of elements from the beginning of the collection.
     
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.`
     */
    mutating func removeFirstSafetly(_ k: Int) {
        guard !isEmpty else { return }
        removeFirst(Swift.min(k, count))
    }
    
    /**
     Removes and returns the specified number of elements from the beginning of the collection.
     
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.`
     - Returns: The removed elements.
     */
    @discardableResult
    mutating func removeFirstSafetly(_ k: Int) -> [Element] where Index == Int {
        guard !isEmpty else { return [] }
        let values = self[safe: 0..<k]
        removeFirst(Swift.min(k, count))
        return values
    }
    
    /**
     Removes and returns the last element of the collection safetly.
     
     - Returns: The last element of the collection, or `nil` if the collection is empty.
     */
    mutating func removeLastSafetly() -> Element? where Self: BidirectionalCollection {
        guard !isEmpty else { return nil }
        return removeLast()
    }
    
    /**
     Removes the specified number of elements from the end of the collection.
          
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.
     */
    mutating func removeLastSafetly(_ k: Int) where Self: BidirectionalCollection {
        guard !isEmpty else { return }
        removeLast(Swift.min(k, count))
    }
    
    /**
     Removes and returns the specified number of elements from the end of the collection.
          
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.
     */
    @discardableResult
    mutating func removeLastSafetly(_ k: Int) -> [Element] where Index == Int {
        guard !isEmpty else { return [] }
        let values = self[safe: Swift.max(count-k, 0)..<count]
        removeFirst(Swift.min(k, count))
        return values
    }
}
