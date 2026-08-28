//
//  OrderedSet.swift
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// An ordered collection of unique elements.
public struct OrderedSet<Element: Hashable>: RandomAccessCollection, BidirectionalCollection, ExpressibleByArrayLiteral {
    private var elements: ContiguousArray<Element>
    private var indexes: [Element: Int]

    public init() {
        elements = []
        indexes = [:]
    }

    public init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }

    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init(elements, retainLastOccurrences: false)
    }

    public init<S: Sequence>(_ elements: S, retainLastOccurrences: Bool) where S.Element == Element {
        self.init()
        if retainLastOccurrences {
            var result: [Element] = []
            var seen = Set<Element>()
            for element in Array(elements).reversed() where seen.insert(element).inserted {
                result.append(element)
            }
            append(contentsOf: result.reversed())
        } else {
            append(contentsOf: elements)
        }
    }

    public init(_ set: Set<Element>, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try self.init(set.sorted(by: areInIncreasingOrder))
    }

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    public var count: Int { elements.count }
    public var isEmpty: Bool { elements.isEmpty }

    public subscript(position: Int) -> Element {
        elements[position]
    }

    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }

    public func index(before i: Int) -> Int {
        elements.index(before: i)
    }

    public var array: [Element] {
        Array(elements)
    }

    public var contiguousArray: ContiguousArray<Element> {
        elements
    }

    public var unorderedSet: Set<Element> {
        Set(elements)
    }

    public var capacity: Int {
        Swift.min(elements.capacity, indexes.capacity)
    }

    public func contains(_ element: Element) -> Bool {
        indexes[element] != nil
    }

    public func index(of element: Element) -> Int? {
        indexes[element]
    }

    public func firstIndex(of element: Element) -> Int? {
        indexes[element]
    }

    public func lastIndex(of element: Element) -> Int? {
        indexes[element]
    }

    public subscript(element: Element) -> Bool {
        get { contains(element) }
        set {
            if newValue {
                append(element)
            } else {
                remove(element)
            }
        }
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
        indexes.reserveCapacity(minimumCapacity)
    }

    @discardableResult
    public mutating func append(_ element: Element) -> (inserted: Bool, index: Int) {
        if let index = indexes[element] {
            return (false, index)
        }
        let index = elements.endIndex
        elements.append(element)
        indexes[element] = index
        _assertInvariant()
        return (true, index)
    }

    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        for element in newElements {
            append(element)
        }
    }

    @discardableResult
    public mutating func insert(_ element: Element, at index: Int) -> (inserted: Bool, index: Int) {
        precondition(index >= startIndex && index <= endIndex, "[OrderedSet] Index is out of bounds")
        if let existingIndex = indexes[element] {
            return (false, existingIndex)
        }
        elements.insert(element, at: index)
        rebuildIndexes(from: index)
        _assertInvariant()
        return (true, index)
    }

    @discardableResult
    public mutating func update(_ element: Element, at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedSet] Index is out of bounds")
        let oldElement = elements[index]
        guard oldElement != element else { return oldElement }
        precondition(indexes[element] == nil, "[OrderedSet] Cannot update with duplicate element")
        elements[index] = element
        indexes[oldElement] = nil
        indexes[element] = index
        _assertInvariant()
        return oldElement
    }

    @discardableResult
    public mutating func updateOrAppend(_ element: Element) -> Element? {
        if let index = indexes[element] {
            return update(element, at: index)
        }
        append(element)
        return nil
    }

    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        guard let index = indexes[element] else { return nil }
        return remove(at: index)
    }

    public mutating func remove<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            remove(element)
        }
    }

    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedSet] Index is out of bounds")
        let element = elements.remove(at: index)
        indexes[element] = nil
        rebuildIndexes(from: index)
        _assertInvariant()
        return element
    }

    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "[OrderedSet] Cannot remove first element from an empty set")
        return remove(at: startIndex)
    }

    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "[OrderedSet] Cannot remove last element from an empty set")
        return remove(at: index(before: endIndex))
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        elements.removeAll(keepingCapacity: keepCapacity)
        indexes.removeAll(keepingCapacity: keepCapacity)
        _assertInvariant()
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        precondition(bounds.lowerBound >= startIndex && bounds.upperBound <= endIndex, "[OrderedSet] Range is out of bounds")
        for element in elements[bounds] {
            indexes[element] = nil
        }
        elements.removeSubrange(bounds)
        rebuildIndexes(from: bounds.lowerBound)
        _assertInvariant()
    }

    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where C.Element == Element {
        precondition(subrange.lowerBound >= startIndex && subrange.upperBound <= endIndex, "[OrderedSet] Range is out of bounds")
        let replacement = ContiguousArray(newElements)
        let replacementSet = Set(replacement)
        precondition(replacement.count == replacementSet.count, "[OrderedSet] Cannot replace subrange with duplicate elements")

        var remaining = indexes
        for element in elements[subrange] {
            remaining[element] = nil
        }
        precondition(replacement.allSatisfy { remaining[$0] == nil }, "[OrderedSet] Cannot replace subrange with existing elements")

        elements.replaceSubrange(subrange, with: replacement)
        rebuildIndexes()
        _assertInvariant()
    }

    public mutating func swapAt(_ i: Int, _ j: Int) {
        guard i != j else { return }
        elements.swapAt(i, j)
        indexes[elements[i]] = i
        indexes[elements[j]] = j
        _assertInvariant()
    }

    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try elements.sort(by: areInIncreasingOrder)
        rebuildIndexes()
        _assertInvariant()
    }
    
    public mutating func sort(_ order: SortOrder = .ascending) where Element: Comparable {
        sort(by: order == .ascending ? (<) : (>))
    }

    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        try elements.sorted(by: areInIncreasingOrder)
    }

    public mutating func reverse() {
        elements.reverse()
        rebuildIndexes()
        _assertInvariant()
    }

    public func reversed() -> [Element] {
        elements.reversed()
    }

    public mutating func shuffle<T: RandomNumberGenerator>(using generator: inout T) {
        elements.shuffle(using: &generator)
        rebuildIndexes()
        _assertInvariant()
    }

    public mutating func shuffle() {
        var generator = SystemRandomNumberGenerator()
        shuffle(using: &generator)
    }

    @discardableResult
    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        let index = try elements.partition(by: belongsInSecondPartition)
        rebuildIndexes()
        _assertInvariant()
        return index
    }

    public func isSubset(of other: Set<Element>) -> Bool {
        unorderedSet.isSubset(of: other)
    }

    public func isSubset(of other: Self) -> Bool {
        unorderedSet.isSubset(of: other.unorderedSet)
    }

    public func isSubset<S: Sequence>(of possibleSuperset: S) -> Bool where S.Element == Element {
        isSubset(of: Set(possibleSuperset))
    }

    public func isStrictSubset(of other: Set<Element>) -> Bool {
        unorderedSet.isStrictSubset(of: other)
    }

    public func isStrictSubset(of other: Self) -> Bool {
        unorderedSet.isStrictSubset(of: other.unorderedSet)
    }

    public func isStrictSubset<S: Sequence>(of possibleSuperset: S) -> Bool where S.Element == Element {
        isStrictSubset(of: Set(possibleSuperset))
    }

    public func isSuperset(of other: Set<Element>) -> Bool {
        unorderedSet.isSuperset(of: other)
    }

    public func isSuperset(of other: Self) -> Bool {
        unorderedSet.isSuperset(of: other.unorderedSet)
    }

    public func isSuperset<S: Sequence>(of possibleSubset: S) -> Bool where S.Element == Element {
        isSuperset(of: Set(possibleSubset))
    }

    public func isStrictSuperset(of other: Set<Element>) -> Bool {
        unorderedSet.isStrictSuperset(of: other)
    }

    public func isStrictSuperset(of other: Self) -> Bool {
        unorderedSet.isStrictSuperset(of: other.unorderedSet)
    }

    public func isStrictSuperset<S: Sequence>(of possibleSubset: S) -> Bool where S.Element == Element {
        isStrictSuperset(of: Set(possibleSubset))
    }

    public func isDisjoint(with other: Set<Element>) -> Bool {
        unorderedSet.isDisjoint(with: other)
    }

    public func isDisjoint(with other: Self) -> Bool {
        unorderedSet.isDisjoint(with: other.elements)
    }

    public func isDisjoint<S: Sequence>(with other: S) -> Bool where S.Element == Element {
        unorderedSet.isDisjoint(with: other)
    }

    public func union(_ other: Self) -> Self {
        var result = self
        result.formUnion(other)
        return result
    }

    public mutating func formUnion(_ other: Self) {
        append(contentsOf: other)
    }

    public func intersection(_ other: Self) -> Self {
        OrderedSet(elements.filter { other.contains($0) })
    }

    public mutating func formIntersection(_ other: Self) {
        self = intersection(other)
    }

    public func symmetricDifference(_ other: Self) -> Self {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    public mutating func formSymmetricDifference(_ other: Self) {
        for element in other {
            if contains(element) {
                remove(element)
            } else {
                append(element)
            }
        }
    }

    public func subtracting<S: Sequence>(_ sequence: S) -> Self where S.Element == Element {
        let excluded = Set(sequence)
        return OrderedSet(elements.filter { !excluded.contains($0) })
    }

    public func subtracting(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        retainOrder ? OrderedSet(elements.filter { !set.contains($0) }) : OrderedSet(unorderedSet.subtracting(set))
    }

    public func intersection<S: Sequence>(_ sequence: S) -> Self where S.Element == Element {
        let included = Set(sequence)
        return OrderedSet(elements.filter { included.contains($0) })
    }

    public func intersection(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        retainOrder ? OrderedSet(elements.filter { set.contains($0) }) : OrderedSet(unorderedSet.intersection(set))
    }

    public func filter(_ isIncluded: (Element) throws -> Bool, retainOrder: Bool = true) rethrows -> Self {
        retainOrder ? OrderedSet(try elements.filter(isIncluded)) : OrderedSet(try unorderedSet.filter(isIncluded))
    }

    public func map<T: Hashable>(_ transform: (Element) throws -> T, retainOrder: Bool = true) rethrows -> OrderedSet<T> {
        retainOrder ? OrderedSet<T>(try elements.map(transform)) : OrderedSet<T>(try unorderedSet.map(transform))
    }

    public func compactMap<T: Hashable>(_ transform: (Element) throws -> T?, retainOrder: Bool = true) rethrows -> OrderedSet<T> {
        retainOrder ? OrderedSet<T>(try elements.compactMap(transform)) : OrderedSet<T>(try unorderedSet.compactMap(transform))
    }

    private mutating func rebuildIndexes(from start: Int = 0) {
        guard start < elements.endIndex else { return }
        for index in start..<elements.endIndex {
            indexes[elements[index]] = index
        }
    }

    private mutating func rebuildIndexes() {
        indexes = elements.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    }

    private func _assertInvariant() {
        assert(_computeInvariant(), "[OrderedSet] Broken invariant: elements=\(elements), indexes=\(indexes)")
    }

    private func _computeInvariant() -> Bool {
        guard elements.count == indexes.count else { return false }
        for (index, element) in elements.enumerated() {
            guard indexes[element] == index else { return false }
        }
        return true
    }
}

extension OrderedSet: Equatable {
    public static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        lhs.elements == rhs.elements
    }

    public static func == <C: Collection>(lhs: OrderedSet, rhs: C) -> Bool where C.Element == Element {
        lhs.elements == ContiguousArray(rhs)
    }
}

extension OrderedSet: Hashable { }
extension OrderedSet: Sendable where Element: Sendable { }

extension OrderedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

extension OrderedSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(ContiguousArray<Element>.self))
    }
}

extension OrderedSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var description: String {
        elements.description
    }

    public var debugDescription: String {
        elements.debugDescription
    }

    public var customMirror: Mirror {
        elements.customMirror
    }
}

extension OrderedSet: CVarArg {
    public var _cVarArgEncoding: [Int] {
        Array(elements)._cVarArgEncoding
    }
}
