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
    
    /**
     Removes all elements matching the predicate and returns the removed elements.
     
     - Parameter shouldBeRemoved: A closure that takes an element of the collection as its argument and returns a `Boolean` value indicating whether the element should be removed from the collection.
     - Returns: An array of the elements that were removed.
     */
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

public extension RangeReplaceableCollection where Element: Equatable {
    /**
     Removes the specificed element.

     - Parameter element: The element to remove.
     - Returns: The removed element.
     */
    @discardableResult
    @_disfavoredOverload
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
     - Returns: An array of the removed elements.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        remove(at: indexes(of: elements))
    }
}

public extension RangeReplaceableCollection where Indices.Element == Int, Element: Equatable {
    /**
     Removes the specified element.

     - Parameter element: The element remove.
     - Returns: Returns the removed element.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove(_ element: Element) -> Element? {
        remove(at: indexes(of: [element])).first
    }

    /**
     Removes the specified elements.

     - Parameter elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        remove(at: indexes(of: elements))
    }
}

public extension RangeReplaceableCollection where Indices.Element == Int, Element: Hashable {
    /**
     Removes the specified element.

     - Parameter element: The element remove.
     - Returns: Returns the removed element.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove(_ element: Element) -> Element? {
        remove(at: indexes(of: [element])).first
    }

    /**
     Removes the specified elements.

     - Parameter elements: The elements to remove.
     - Returns: Returns the removed elements.
     */
    @discardableResult
    @_disfavoredOverload
    mutating func remove<S: Sequence<Element>>(_ elements: S) -> [Element] {
        remove(at: indexes(of: elements))
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
     Removes the specificed elements.

     - Parameter elements: The elements to remove.
     - Returns: An array of the removed elements.
     */
    @discardableResult
    mutating func remove<S>(_ elements: S) -> [Element] where S: Sequence<Element> {
        remove(at: indexes(of: elements))
    }
}
