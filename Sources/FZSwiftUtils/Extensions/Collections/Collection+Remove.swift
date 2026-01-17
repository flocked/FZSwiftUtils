//
//  Collection+Remove.swift
//  
//
//  Created by Florian Zand on 04.07.25.
//

import Foundation

// MARK: - Remove

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
        !isEmpty && k > 0 ? (0..<Swift.min(k, count)).map { _ in removeFirst() } : []
    }
    
    /// Returns the collection with the first element removed.
    func removingFirst() -> Self {
        removingFirst(1)
    }
    
    /// Returns the collection with the specified number of elements removed.
    func removingFirst(_ k: Int) -> Self {
        var collection = self
        collection.removeFirst(k)
        return collection
    }
    
    /// Returns the collection with the first element removed.
    func removingFirstSafely() -> Self {
        removingFirstSafely(1)
    }
    
    /// Returns the collection with the specified number of elements removed.
    func removingFirstSafely(_ k: Int) -> Self {
        var collection = self
        collection.removeFirstSafetly(k)
        return collection
    }
}

public extension RangeReplaceableCollection where Self: BidirectionalCollection {
    /**
     Removes and returns the last element of the collection safetly.
     
     - Returns: The last element of the collection, or `nil` if the collection is empty.
     */
    @discardableResult
    mutating func removeLastSafetly() -> Element? {
        !isEmpty ? removeLast() : nil
    }
    
    /**
     Removes the specified number of elements from the end of the collection.
          
     - Parameter k: The number of elements to remove from the collection. k must be greater than or equal to `zero`.
     - Returns: The removed elements.
     */
    @discardableResult
    mutating func removeLastSafetly(_ k: Int) -> [Element] {
        !isEmpty && k > 0 ? (0..<Swift.min(k, count)).map { _ in removeLast() } : []
    }
    
    /// Returns the collection with the last element removed from the collection.
    func removingLast() -> Self {
        removingLast(1)
    }
    
    /// Returns the collection with the specified number of elements removed from the end of the collection.
    func removingLast(_ k: Int) -> Self {
        var collection = self
        collection.removeLast(k)
        return collection
    }
    
    /// Returns the collection with the last element removed from the collection.
    func removingLastSafely() -> Self {
        removingLastSafely(1)
    }
    
    /// Returns the collection with the specified number of elements removed from the end of the collection.
    func removingLastSafely(_ k: Int) -> Self {
        var collection = self
        collection.removeLastSafetly(k)
        return collection
    }
}


// MARK: - Remove + Predicate

public extension RangeReplaceableCollection {
    /**
     Removes the first element that satifies the given predicate.
     
     - Parameter shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a `Boolean` value indicating whether the element should be removed from the collection.
     
     - Returns: The removed element, or `nil` if no element in the collection satisfies the given predicate.
     */
    @discardableResult
    mutating func removeFirst(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: shouldBeRemoved) else { return nil }
        return remove(at: index)
    }
    
    /**
     Removes all the elements that satisfy the given predicate upto the specified amount.
     
     - Parameters:
        - amount: The maximum number of elements to remove that satisfy the predicate.
        - shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a `Boolean` value indicating whether the element should be removed from the collection.
     - Returns: An array of the elements that were removed.
     */
    @discardableResult
    mutating func removeFirst(_ amount: Int, where shouldBeRemoved: (Element) throws -> Bool) rethrows -> [Element] {
        guard amount > 0 else { return [] }

        var removed: [Element] = []
        var kept: [Element] = []
        var count = 0

        for element in self {
            if count < amount, try shouldBeRemoved(element) {
                removed.append(element)
                count += 1
            } else {
                kept.append(element)
            }
        }

        self = Self(kept)
        return removed
    }
    
    /**
     Removes the last element that satifies the given predicate.
     
     - Parameter shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a Boolean value indicating whether the element should be removed from the collection.
     
     - Returns: The removed element, or `nil` if no element in the collection satisfies the given predicate.
     */
    mutating func removeLast(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        try removeLast(1, where: shouldBeRemoved).first
    }
    
    /**
     Removes elements from the end of the collection that satisfy the given predicate, up to the specified amount.
     
     - Parameters:
        - amount: The maximum number of elements to remove that satisfy the predicate.
        - shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a `Boolean` value indicating whether the element should be removed from the collection.
     - Returns: An array of the elements that were removed, in the order they originally appeared in the collection.
     */
    @discardableResult
    mutating func removeLast(_ amount: Int, where shouldBeRemoved: (Element) throws -> Bool) rethrows -> [Element] {
        guard amount > 0 else { return [] }

        var removed: [Element] = []
        var kept = Array(self)
        var count = 0

        for index in kept.indices.reversed() {
            if count >= amount { break }
            if try shouldBeRemoved(kept[index]) {
                removed.append(kept.remove(at: index))
                count += 1
            }
        }

        self = Self(kept)
        return removed.reversed()
    }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
    /**
     Removes the last element that satifies the given predicate.
     
     - Parameter shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a Boolean value indicating whether the element should be removed from the collection.
     
     - Returns: The removed element, or `nil` if no element in the collection satisfies the given predicate.
     */
    mutating func removeLast(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Element? {
        guard let lastIndex = try lastIndex(where: shouldBeRemoved) else { return nil }
        return remove(at: lastIndex)
    }
}

// MARK: - Remove + Index

public extension RangeReplaceableCollection where Self: MutableCollection {
    /// Removes all the elements at the specified range.
    mutating func remove(at range: ClosedRange<Int>) {
        remove(atOffsets: IndexSet(range.clamped(to: 0...count - 1)))
    }
    
    /// Removes all the elements at the specified range.
    @_disfavoredOverload
    mutating func remove(at range: Range<Int>) {
        remove(atOffsets: IndexSet(range.clamped(to: 0..<count)))
    }
    
    /// Removes the elements at the specified range.
    @discardableResult
    mutating func remove(at range: Range<Index>) -> SubSequence where Index: Comparable {
        let clamped = range.clamped(to: startIndex..<endIndex)
        let removed = self[clamped]
        removeSubrange(clamped)
        return removed
    }
    
    /// Removes the elements at the specified range.
    @discardableResult
    mutating func remove(at range: ClosedRange<Index>) -> SubSequence where Index: Comparable, Self: BidirectionalCollection {
        let clamped = range.clamped(to: startIndex...index(before: endIndex))
        let removed = self[clamped]
        removeSubrange(clamped)
        return removed
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
        indexes.filter({$0 >= startIndex && $0 < endIndex}).indexed().compactMap({ remove(at: index($0.element, offsetBy: -$0.index) ) })
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove(at range: Range<Index>) -> [Element] {
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
    mutating func remove(at range: ClosedRange<Index>) -> [Element] {
        remove(at: (range.lowerBound..<index(after: range.upperBound)))
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeFrom<Index>) -> [Element] {
        remove(at: range.lowerBound..<endIndex)
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeUpTo<Index>) -> [Element] {
        remove(at: startIndex..<range.upperBound)
    }
    
    /**
     Removes the elements at the specified range and returns them.

     - Parameter range: The index range of the elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    mutating func remove(at range: PartialRangeThrough<Index>) -> [Element] {
        remove(at: startIndex..<index(after:range.upperBound))
    }
}

// MARK: - Remove + Element

public extension RangeReplaceableCollection where Element: Equatable {
    /**
     Removes the specificed element.

     - Parameter element: The element to remove.
     - Returns: The removed element.
     */
    @_disfavoredOverload
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        guard let index = firstIndex(of: element) else { return nil }
        return remove(at: index)
    }
    
    /**
     Removes the specificed elements and returns them.

     - Parameter elements: The elements to remove.
     - Returns: An array of the removed elements.
     */
    @_disfavoredOverload
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        elements.compactMap({ remove($0) })
    }
}

public extension RangeReplaceableCollection where Element: Hashable {
    /**
     Removes the specificed elements and returns them.

     - Parameter elements: The elements to remove.
     - Returns: An array of the removed elements.
     */
    @_disfavoredOverload
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        let targets = Set(elements)
        var removed: [Element] = []
        removeAll { element in
            if targets.contains(element) {
                removed.append(element)
                return true
            }
            return false
        }
        return removed
    }
}

public extension RangeReplaceableCollection where Element: AnyObject {
    /**
     Removes the specificed element.

     - Parameter element: The element to remove.
     - Returns: The removed element.
     */
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        guard let index = firstIndex(where: { $0 === element }) else { return nil }
        return remove(at: index)
    }
    
    /**
     Removes the specificed elements and returns them.

     - Parameter elements: The elements to remove.
     - Returns: An array of the removed elements.
     */
    @discardableResult
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        elements.compactMap({ remove($0) })
    }
}

public extension RangeReplaceableCollection {
    
    /**
     Removes all the elements that satisfy the given predicate and returns them:
     
     - Parameter shouldBeRemoved: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the collection.
     - Returns: The elements removed.
     */
    @_disfavoredOverload
    @discardableResult
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> [Element] {
        var removed: [Element] = []
        
        try removeAll { element in
            if try shouldBeRemoved(element) {
                removed.append(element)
                return true
            }
            return false
        }
        return removed
    }
}
