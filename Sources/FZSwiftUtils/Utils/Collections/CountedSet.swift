//
//  CountedSet.swift
//
//
//  Created by Florian Zand on 23.01.26.
//

/// An unordered collection of unique elements that may appear more than once in the collection.
import Foundation

/// An unordered collection of unique elements that tracks the number of occurrences of each element.
public struct CountedSet<Element: Hashable> {

    public private(set) var elementCounts: [Element: Int] = [:]

    /// The number of unique elements in the counted set.
    public var count: Int {
        elementCounts.count
    }
    
    /// The total number of elements, including repeated elements.
    public private(set) var totalCount: Int = 0
    
    /// The total number of unique elements that the counted set can contain without allocating new storage.
    public var capacity: Int {
        elementCounts.capacity
    }

    /// A Boolean value that indicates whether the counted set is empty.
    public var isEmpty: Bool {
        elementCounts.isEmpty
    }

    /// Creates an empty counted set.
    public init() {}

    /// Creates a counted set containing the specified element.
    public init(_ element: Element) {
        elementCounts[element] = 1
        totalCount = 1
    }

    /// Creates a counted set from the specified sequence.
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            elementCounts[element, default: 0] += 1
            totalCount += 1
        }
    }

    /// Creates a counted set from the specified element counts.
    public init(elementCounts: [Element: Int]) {
        self.elementCounts = elementCounts.filter { $0.value > 0 }
        totalCount = self.elementCounts.values.reduce(0, +)
    }
    
    /// Creates an empty counted set with preallocated space for at least the specified number of unique elements.
    public init(minimumCapacity: Int) {
        elementCounts = Dictionary(minimumCapacity: minimumCapacity)
    }

    private init(elementCounts: [Element: Int], totalCount: Int) {
        self.elementCounts = elementCounts
        self.totalCount = totalCount
    }

    /// Accesses the number of occurrences of the specified element.
    public subscript(element: Element) -> Int {
        get {
            elementCounts[element] ?? 0
        }
        set {
            let oldValue = elementCounts[element] ?? 0
            let newValue = Swift.max(newValue, 0)
            guard oldValue != newValue else { return }

            elementCounts[element] = newValue > 0 ? newValue : nil
            totalCount += newValue - oldValue
        }
    }

    /// Returns the number of occurrences of the specified element.
    public func count(for element: Element) -> Int {
        self[element]
    }

    /// Returns a Boolean value that indicates whether the counted set contains the specified element.
    public func contains(_ element: Element) -> Bool {
        elementCounts[element] != nil
    }

    /// Adds an occurrence of the specified element.
    public mutating func add(_ element: Element) {
        elementCounts[element, default: 0] += 1
        totalCount += 1
    }

    /// Adds the specified number of occurrences of an element.
    public mutating func add(_ element: Element, count: Int) {
        guard count > 0 else { return }
        elementCounts[element, default: 0] += count
        totalCount += count
    }

    /// Adds the elements of the specified sequence.
    public mutating func add<S: Sequence>(contentsOf elements: S) where S.Element == Element {
        for element in elements {
            elementCounts[element, default: 0] += 1
            totalCount += 1
        }
    }

    /// Removes an occurrence of the specified element.
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        remove(element, count: 1)
    }

    /// Removes up to the specified number of occurrences of an element.
    @discardableResult
    public mutating func remove(_ element: Element, count: Int) -> Element? {
        guard count > 0, let existingCount = elementCounts[element] else { return nil }

        if existingCount > count {
            elementCounts[element] = existingCount - count
            totalCount -= count
        } else {
            elementCounts.removeValue(forKey: element)
            totalCount -= existingCount
        }

        return element
    }

    /// Removes all occurrences of the specified element.
    @discardableResult
    public mutating func removeAll(_ element: Element) -> Element? {
        guard let count = elementCounts.removeValue(forKey: element) else { return nil }
        totalCount -= count
        return element
    }

    /// Removes all elements from the counted set.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        elementCounts.removeAll(keepingCapacity: keepCapacity)
        totalCount = 0
    }

    /// Reserves enough space to store the specified number of unique elements.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elementCounts.reserveCapacity(minimumCapacity)
    }
}

// MARK: - Set Operations

extension CountedSet {
    /// Returns a counted set containing the maximum count of each element in either counted set.
    public func union(_ other: Self) -> Self {
        var result = self
        result.formUnion(other)
        return result
    }

    /// Forms a counted set containing the maximum count of each element in either counted set.
    public mutating func formUnion(_ other: Self) {
        for (element, otherCount) in other.elementCounts {
            let count = elementCounts[element] ?? 0
            guard otherCount > count else { continue }
            elementCounts[element] = otherCount
            totalCount += otherCount - count
        }
    }

    /// Returns a counted set containing the minimum count of each element common to both counted sets.
    public func intersection(_ other: Self) -> Self {
        var result = self
        result.formIntersection(other)
        return result
    }

    /// Forms a counted set containing the minimum count of each element common to both counted sets.
    public mutating func formIntersection(_ other: Self) {
        for (element, count) in elementCounts {
            guard let otherCount = other.elementCounts[element] else {
                elementCounts.removeValue(forKey: element)
                totalCount -= count
                continue
            }

            if otherCount < count {
                elementCounts[element] = otherCount
                totalCount -= count - otherCount
            }
        }
    }

    /// Returns a counted set containing the absolute difference between the counts of each element.
    public func symmetricDifference(_ other: Self) -> Self {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    /// Forms a counted set containing the absolute difference between the counts of each element.
    public mutating func formSymmetricDifference(_ other: Self) {
        for (element, otherCount) in other.elementCounts {
            guard let count = elementCounts[element] else {
                elementCounts[element] = otherCount
                totalCount += otherCount
                continue
            }
            let difference = abs(count - otherCount)
            if difference > 0 {
                elementCounts[element] = difference
            } else {
                elementCounts.removeValue(forKey: element)
            }
            totalCount += difference - count
        }
    }

    /// Returns a counted set by subtracting the counts of another counted set.
    public func subtracting(_ other: Self) -> Self {
        var result = self
        result.subtract(other)
        return result
    }

    /// Subtracts the counts of another counted set.
    public mutating func subtract(_ other: Self) {
        for (element, otherCount) in other.elementCounts {
            guard let count = elementCounts[element] else { continue }

            if count > otherCount {
                elementCounts[element] = count - otherCount
                totalCount -= otherCount
            } else {
                elementCounts.removeValue(forKey: element)
                totalCount -= count
            }
        }
    }
}

// MARK: - Relationships

extension CountedSet {
    /// Returns whether every element occurs at least as many times in the other counted set.
    public func isSubset(of other: Self) -> Bool {
        guard count <= other.count, totalCount <= other.totalCount else { return false }

        for (element, count) in elementCounts {
            guard (other.elementCounts[element] ?? 0) >= count else { return false }
        }

        return true
    }

    /// Returns whether every element of the other counted set occurs at least as many times in this counted set.
    public func isSuperset(of other: Self) -> Bool {
        other.isSubset(of: self)
    }

    /// Returns whether this counted set is a proper subset of the other counted set.
    public func isStrictSubset(of other: Self) -> Bool {
        self != other && isSubset(of: other)
    }

    /// Returns whether this counted set is a proper superset of the other counted set.
    public func isStrictSuperset(of other: Self) -> Bool {
        self != other && isSuperset(of: other)
    }

    /// Returns whether the two counted sets have no elements in common.
    public func isDisjoint(with other: Self) -> Bool {
        if count <= other.count {
            for element in elementCounts.keys where other.elementCounts[element] != nil {
                return false
            }
        } else {
            for element in other.elementCounts.keys where elementCounts[element] != nil {
                return false
            }
        }

        return true
    }

    /// Returns whether the two counted sets have at least one element in common.
    public func intersects(_ other: Self) -> Bool {
        !isDisjoint(with: other)
    }
}

// MARK: - Sequence


// MARK: - Literals

extension CountedSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension CountedSet: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Element, Int)...) {
        self.init(elementCounts: Dictionary(elements, uniquingKeysWith: +))
    }
}

// MARK: - Equatable

extension CountedSet: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.elementCounts == rhs.elementCounts
    }
}

// MARK: - Hashable

extension CountedSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elementCounts)
    }
}

// MARK: - CustomStringConvertible

extension CountedSet: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        elementCounts.description
    }

    public var debugDescription: String {
        elementCounts.debugDescription
    }
}

// MARK: - Transformations

extension CountedSet {
    /// Returns a counted set by transforming the count of each element and discarding elements with nonpositive counts.
    public func mapCounts(_ transform: (Element, Int) throws -> Int) rethrows -> Self {
        var result = self

        for (element, count) in elementCounts {
            let newCount = Swift.max(try transform(element, count), 0)
            result.elementCounts[element] = newCount > 0 ? newCount : nil
            result.totalCount += newCount - count
        }

        return result
    }

    /// Returns a counted set by transforming the count of each element and discarding nil and nonpositive counts.
    public func compactMapCounts(_ transform: (Element, Int) throws -> Int?) rethrows -> Self {
        var result = self

        for (element, count) in elementCounts {
            let newCount = Swift.max(try transform(element, count) ?? 0, 0)
            result.elementCounts[element] = newCount > 0 ? newCount : nil
            result.totalCount += newCount - count
        }

        return result
    }

    /// Returns a counted set by transforming each element while preserving its count.
    public func mapElements<U: Hashable>(_ transform: (Element) throws -> U) rethrows -> CountedSet<U> {
        var newCounts: [U: Int] = [:]
        newCounts.reserveCapacity(elementCounts.count)

        for (element, count) in elementCounts {
            newCounts[try transform(element), default: 0] += count
        }

        return CountedSet<U>(elementCounts: newCounts, totalCount: totalCount)
    }

    /// Returns a counted set by transforming each element and its count.
    public func mapElements<U: Hashable>(_ transform: (Element, Int) throws -> (element: U, count: Int)) rethrows -> CountedSet<U> {
        var newCounts: [U: Int] = [:]
        newCounts.reserveCapacity(elementCounts.count)
        var totalCount = 0

        for (element, count) in elementCounts {
            let transformed = try transform(element, count)
            guard transformed.count > 0 else { continue }
            newCounts[transformed.element, default: 0] += transformed.count
            totalCount += transformed.count
        }

        return CountedSet<U>(elementCounts: newCounts, totalCount: totalCount)
    }

    /// Returns a counted set by transforming each element while preserving its count and discarding nil results.
    public func compactMapElements<U: Hashable>(_ transform: (Element) throws -> U?) rethrows -> CountedSet<U> {
        var newCounts: [U: Int] = [:]
        newCounts.reserveCapacity(elementCounts.count)
        var totalCount = 0

        for (element, count) in elementCounts {
            guard let element = try transform(element) else { continue }
            newCounts[element, default: 0] += count
            totalCount += count
        }

        return CountedSet<U>(elementCounts: newCounts, totalCount: totalCount)
    }

    /// Returns a counted set by transforming each element and its count and discarding nil results.
    public func compactMapElements<U: Hashable>(_ transform: (Element, Int) throws -> (element: U, count: Int)?) rethrows -> CountedSet<U> {
        var newCounts: [U: Int] = [:]
        newCounts.reserveCapacity(elementCounts.count)
        var totalCount = 0

        for (element, count) in elementCounts {
            guard let transformed = try transform(element, count), transformed.count > 0 else { continue }
            newCounts[transformed.element, default: 0] += transformed.count
            totalCount += transformed.count
        }

        return CountedSet<U>(elementCounts: newCounts, totalCount: totalCount)
    }

    /// Returns a counted set containing the elements that satisfy the specified predicate.
    public func filter(_ isIncluded: (Element, Int) throws -> Bool) rethrows -> Self {
        var result = self

        for (element, count) in elementCounts {
            guard try !isIncluded(element, count) else { continue }
            result.elementCounts.removeValue(forKey: element)
            result.totalCount -= count
        }

        return result
    }
}


// MARK: - Codable

extension CountedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        try elementCounts.encode(to: encoder)
    }
}

extension CountedSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(elementCounts: try [Element: Int](from: decoder))
    }
}

// MARK: - Collection

extension CountedSet: Collection {
    public typealias Iterator = Dictionary<Element, Int>.Keys.Iterator
    public typealias Index = Dictionary<Element, Int>.Index

    public var startIndex: Index {
        elementCounts.startIndex
    }

    public var endIndex: Index {
        elementCounts.endIndex
    }

    public func index(after i: Index) -> Index {
        elementCounts.index(after: i)
    }

    public subscript(position: Index) -> Element {
        elementCounts[position].key
    }

    public func makeIterator() -> Iterator {
        elementCounts.keys.makeIterator()
    }
}

// MARK: - Sendable

extension CountedSet: Sendable where Element: Sendable {}
 
 extension CountedSet: CustomReflectable {
     public var customMirror: Mirror {
         elementCounts.customMirror
     }
 }
