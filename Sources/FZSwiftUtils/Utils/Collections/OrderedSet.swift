//
//  OrderedSet.swift
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// An ordered collection of unique elements.
public struct OrderedSet<Element: Hashable>: RandomAccessCollection, BidirectionalCollection, SetAlgebra, ExpressibleByArrayLiteral {
    private var _elements: ContiguousArray<Element>
    private var indexes: [Element: Int]

    /// Creates an empty ordered set.
    public init() {
        _elements = []
        indexes = [:]
    }

    /// Creates an empty ordered set and reserves storage for at least the specified number of elements.
    public init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }

    /// Creates an ordered set from a sequence, keeping the first occurrence of each element.
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        self.init(elements, retainLastOccurrences: false)
    }

    /**
     Creates an ordered set from a sequence.

     When `retainLastOccurrences` is `false`, the first occurrence of each element is kept. When it is `true`, the last occurrence of each element is kept while preserving the order of those retained elements.
     */
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

    /**
     Creates an ordered set from a sequence that is expected to contain unique elements.

     This initializer skips incremental duplicate checks while building the set and traps if duplicates are found.
     */
    public init<S: Sequence>(uncheckedUniqueElements elements: S) where S.Element == Element {
        _elements = ContiguousArray(elements)
        indexes = [:]
        rebuildIndexes()
        precondition(_elements.count == indexes.count, "[OrderedSet] Sequence contains duplicate elements")
    }

    /// Creates an ordered set from a set sorted by the specified predicate.
    public init(_ set: Set<Element>, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try self.init(set.sorted(by: areInIncreasingOrder))
    }

    /// Creates an ordered set from an array literal.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    /// The position of the first element.
    public var startIndex: Int { _elements.startIndex }
    /// The position one past the last element.
    public var endIndex: Int { _elements.endIndex }
    /// The number of elements in the ordered set.
    public var count: Int { _elements.count }
    /// A Boolean value indicating whether the ordered set is empty.
    public var isEmpty: Bool { _elements.isEmpty }

    /// Accesses the element at the specified position.
    public subscript(position: Int) -> Element {
        _elements[position]
    }

    /// Returns the position immediately after the specified index.
    public func index(after i: Int) -> Int {
        _elements.index(after: i)
    }

    /// Returns the position immediately before the specified index.
    public func index(before i: Int) -> Int {
        _elements.index(before: i)
    }

    /// The elements as an array in their stored order.
    public var array: [Element] {
        Array(_elements)
    }

    /// The elements as an array in their stored order.
    public var elements: [Element] {
        get { Array(_elements) }
        set { self = Self(newValue) }
        @inline(__always)
        _modify {
          var members = Array(_elements)
          _elements = []
          defer { self = .init(members) }
          yield &members
        }
    }

    /// The elements as a contiguous array in their stored order.
    public var contiguousArray: ContiguousArray<Element> {
        _elements
    }

    /// The elements as an unordered set.
    public var unorderedSet: Set<Element> {
        Set(_elements)
    }

    /// The current reserved capacity of the ordered set.
    public var capacity: Int {
        Swift.min(_elements.capacity, indexes.capacity)
    }

    /// Returns whether the ordered set contains the specified element.
    public func contains(_ element: Element) -> Bool {
        indexes[element] != nil
    }

    /// Returns the position of the specified element, or `nil` if it is not present.
    public func index(of element: Element) -> Int? {
        indexes[element]
    }

    /// Returns the first position of the specified element, or `nil` if it is not present.
    public func firstIndex(of element: Element) -> Int? {
        indexes[element]
    }

    /// Returns the last position of the specified element, or `nil` if it is not present.
    public func lastIndex(of element: Element) -> Int? {
        indexes[element]
    }

    /// Accesses membership for an element.
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

    /// Reserves enough space to store the specified number of elements.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _elements.reserveCapacity(minimumCapacity)
        indexes.reserveCapacity(minimumCapacity)
    }

    /// Appends an element if it is not already present.
    @discardableResult
    public mutating func append(_ element: Element) -> (inserted: Bool, index: Int) {
        if let index = indexes[element] {
            return (false, index)
        }
        let index = _elements.endIndex
        _elements.append(element)
        indexes[element] = index
        return (true, index)
    }

    /// Appends the unique elements from a sequence, ignoring elements already present.
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        for element in newElements {
            append(element)
        }
    }

    /// Inserts an element at the end of the ordered set if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let result = append(newMember)
        return (result.inserted, self[result.index])
    }

    /// Updates an existing member or appends it if it is not already present.
    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        updateOrAppend(newMember)
    }

    /// Inserts an element at the specified position if it is not already present.
    @discardableResult
    public mutating func insert(_ element: Element, at index: Int) -> (inserted: Bool, index: Int) {
        precondition(index >= startIndex && index <= endIndex, "[OrderedSet] Index is out of bounds")
        if let existingIndex = indexes[element] {
            return (false, existingIndex)
        }
        _elements.insert(element, at: index)
        rebuildIndexes(from: index)
        return (true, index)
    }

    /// Replaces the element at the specified position with a new unique element.
    @discardableResult
    public mutating func update(_ element: Element, at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedSet] Index is out of bounds")
        let oldElement = _elements[index]
        guard oldElement != element else { return oldElement }
        precondition(indexes[element] == nil, "[OrderedSet] Cannot update with duplicate element")
        _elements[index] = element
        indexes[oldElement] = nil
        indexes[element] = index
        return oldElement
    }

    /// Updates an existing element or appends it if it is not already present.
    @discardableResult
    public mutating func updateOrAppend(_ element: Element) -> Element? {
        if let index = indexes[element] {
            return update(element, at: index)
        }
        append(element)
        return nil
    }

    /// Updates an existing element or inserts it at the specified position if it is not already present.
    @discardableResult
    public mutating func updateOrInsert(_ element: Element, at index: Int) -> (originalMember: Element?, index: Int) {
        precondition(index >= startIndex && index <= endIndex, "[OrderedSet] Index is out of bounds")
        if let existingIndex = indexes[element] {
            let originalMember = update(element, at: existingIndex)
            return (originalMember, existingIndex)
        }

        insert(element, at: index)
        return (nil, index)
    }

    /// Removes the specified element if it is present.
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        guard let index = indexes[element] else { return nil }
        return remove(at: index)
    }

    /// Removes all elements in the specified sequence.
    public mutating func remove<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            remove(element)
        }
    }

    /// Removes and returns the element at the specified position.
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(indices.contains(index), "[OrderedSet] Index is out of bounds")
        let element = _elements.remove(at: index)
        indexes[element] = nil
        rebuildIndexes(from: index)
        return element
    }

    /// Removes and returns the first element.
    public mutating func removeFirst() -> Element {
        precondition(!isEmpty, "[OrderedSet] Cannot remove first element from an empty set")
        return remove(at: startIndex)
    }

    /// Removes and returns the last element.
    public mutating func removeLast() -> Element {
        precondition(!isEmpty, "[OrderedSet] Cannot remove last element from an empty set")
        return remove(at: index(before: endIndex))
    }

    /// Removes all elements, optionally preserving allocated storage.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _elements.removeAll(keepingCapacity: keepCapacity)
        indexes.removeAll(keepingCapacity: keepCapacity)
    }

    /// Removes every element that satisfies the specified predicate.
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        _elements = try _elements.filter { try !shouldBeRemoved($0) }
        rebuildIndexes()
    }

    /// Removes the elements in the specified range.
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        precondition(bounds.lowerBound >= startIndex && bounds.upperBound <= endIndex, "[OrderedSet] Range is out of bounds")
        for element in _elements[bounds] {
            indexes[element] = nil
        }
        _elements.removeSubrange(bounds)
        rebuildIndexes(from: bounds.lowerBound)
    }

    /// Replaces the specified range with unique elements that are not already present outside the range.
    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where C.Element == Element {
        precondition(subrange.lowerBound >= startIndex && subrange.upperBound <= endIndex, "[OrderedSet] Range is out of bounds")
        let replacement = ContiguousArray(newElements)
        let replacementSet = Set(replacement)
        precondition(replacement.count == replacementSet.count, "[OrderedSet] Cannot replace subrange with duplicate elements")

        var remaining = indexes
        for element in _elements[subrange] {
            remaining[element] = nil
        }
        precondition(replacement.allSatisfy { remaining[$0] == nil }, "[OrderedSet] Cannot replace subrange with existing elements")

        _elements.replaceSubrange(subrange, with: replacement)
        rebuildIndexes()
        _assertInvariant()
    }

    /// Exchanges the elements at the specified positions.
    public mutating func swapAt(_ i: Int, _ j: Int) {
        guard i != j else { return }
        _elements.swapAt(i, j)
        indexes[_elements[i]] = i
        indexes[_elements[j]] = j
        _assertInvariant()
    }

    /// Moves the element at `source` to `destination`.
    public mutating func move(from source: Int, to destination: Int) {
        precondition(indices.contains(source), "[OrderedSet] Source index is out of bounds")
        precondition(destination >= startIndex && destination <= endIndex, "[OrderedSet] Destination index is out of bounds")
        guard source != destination && source + 1 != destination else { return }

        let element = _elements.remove(at: source)
        let adjustedDestination = destination > source ? destination - 1 : destination
        _elements.insert(element, at: adjustedDestination)
        rebuildIndexes()
        _assertInvariant()
    }

    /// Moves the elements at the specified offsets to a destination offset.
    public mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        precondition(source.allSatisfy { indices.contains($0) }, "[OrderedSet] Source contains out of bounds indexes")
        precondition(destination >= startIndex && destination <= endIndex, "[OrderedSet] Destination index is out of bounds")
        guard !source.isEmpty else { return }

        let moving = source.sorted().map { _elements[$0] }
        for index in source.sorted(by: >) {
            _elements.remove(at: index)
        }
        let lowerRemovedBeforeDestination = source.filter { $0 < destination }.count
        _elements.insert(contentsOf: moving, at: destination - lowerRemovedBeforeDestination)
        rebuildIndexes()
        _assertInvariant()
    }

    /// Sorts the ordered set in place using the specified predicate.
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try _elements.sort(by: areInIncreasingOrder)
        rebuildIndexes()
    }

    /// Sorts the ordered set in place using the specified order.
    public mutating func sort(_ order: SortOrder = .ascending) where Element: Comparable {
        sort(by: order == .ascending ? (<) : (>))
    }

    /// Returns a sorted ordered set using the specified predicate.
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self {
        try Self(uncheckedUniqueElements: _elements.sorted(by: areInIncreasingOrder))
    }

    /// Returns a sorted ordered set in ascending order.
    public func sorted() -> Self where Element: Comparable {
        sorted(by: <)
    }

    /// Returns a sorted ordered set using the specified order.
    public func sorted(_ order: SortOrder) -> Self where Element: Comparable {
        sorted(by: order == .ascending ? (<) : (>))
    }

    /// Reverses the order of the elements in place.
    public mutating func reverse() {
        _elements.reverse()
        indexes = indexes.mapValues { count - 1 - $0 }
    }

    /// Returns an ordered set with the elements in reverse order.
    @_disfavoredOverload
    public func reversed() -> Self {
        .init(uncheckedUniqueElements: _elements.reversed())
    }

    /// Shuffles the elements in place using the specified random number generator.
    public mutating func shuffle<T: RandomNumberGenerator>(using generator: inout T) {
        _elements.shuffle(using: &generator)
        rebuildIndexes()
        _assertInvariant()
    }

    /// Shuffles the elements in place.
    public mutating func shuffle() {
        var generator = SystemRandomNumberGenerator()
        shuffle(using: &generator)
    }

    /// Reorders the elements so matching elements are after nonmatching elements and returns the partition index.
    @discardableResult
    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        let index = try _elements.partition(by: belongsInSecondPartition)
        rebuildIndexes()
        _assertInvariant()
        return index
    }

    /// Returns a new ordered set by applying the specified collection difference.
    public func applying(_ difference: CollectionDifference<Element>) -> Self? {
        guard let elements = Array(_elements).applying(difference) else { return nil }
        return Self(uncheckedUniqueElements: elements)
    }

    /// Returns whether the ordered set is a subset of the specified set.
    public func isSubset(of other: Set<Element>) -> Bool {
        unorderedSet.isSubset(of: other)
    }

    /// Returns whether the ordered set is a subset of another ordered set.
    public func isSubset(of other: Self) -> Bool {
        unorderedSet.isSubset(of: other.unorderedSet)
    }

    /// Returns whether the ordered set is a subset of the specified sequence.
    public func isSubset<S: Sequence>(of possibleSuperset: S) -> Bool where S.Element == Element {
        isSubset(of: Set(possibleSuperset))
    }

    /// Returns whether the ordered set is a strict subset of the specified set.
    public func isStrictSubset(of other: Set<Element>) -> Bool {
        unorderedSet.isStrictSubset(of: other)
    }

    /// Returns whether the ordered set is a strict subset of another ordered set.
    public func isStrictSubset(of other: Self) -> Bool {
        unorderedSet.isStrictSubset(of: other.unorderedSet)
    }

    /// Returns whether the ordered set is a strict subset of the specified sequence.
    public func isStrictSubset<S: Sequence>(of possibleSuperset: S) -> Bool where S.Element == Element {
        isStrictSubset(of: Set(possibleSuperset))
    }

    /// Returns whether the ordered set is a superset of the specified set.
    public func isSuperset(of other: Set<Element>) -> Bool {
        unorderedSet.isSuperset(of: other)
    }

    /// Returns whether the ordered set is a superset of another ordered set.
    public func isSuperset(of other: Self) -> Bool {
        unorderedSet.isSuperset(of: other.unorderedSet)
    }

    /// Returns whether the ordered set is a superset of the specified sequence.
    public func isSuperset<S: Sequence>(of possibleSubset: S) -> Bool where S.Element == Element {
        isSuperset(of: Set(possibleSubset))
    }

    /// Returns whether the ordered set is a strict superset of the specified set.
    public func isStrictSuperset(of other: Set<Element>) -> Bool {
        unorderedSet.isStrictSuperset(of: other)
    }

    /// Returns whether the ordered set is a strict superset of another ordered set.
    public func isStrictSuperset(of other: Self) -> Bool {
        unorderedSet.isStrictSuperset(of: other.unorderedSet)
    }

    /// Returns whether the ordered set is a strict superset of the specified sequence.
    public func isStrictSuperset<S: Sequence>(of possibleSubset: S) -> Bool where S.Element == Element {
        isStrictSuperset(of: Set(possibleSubset))
    }

    /// Returns whether the ordered set has no members in common with the specified set.
    public func isDisjoint(with other: Set<Element>) -> Bool {
        unorderedSet.isDisjoint(with: other)
    }

    /// Returns whether the ordered set has no members in common with another ordered set.
    public func isDisjoint(with other: Self) -> Bool {
        unorderedSet.isDisjoint(with: other._elements)
    }

    /// Returns whether the ordered set has no members in common with the specified sequence.
    public func isDisjoint<S: Sequence>(with other: S) -> Bool where S.Element == Element {
        unorderedSet.isDisjoint(with: other)
    }

    /// Returns whether the ordered set contains the same members as another ordered set, ignoring order.
    public func isEqualSet(to other: Self) -> Bool {
        count == other.count && isSubset(of: other)
    }

    /// Returns whether the ordered set contains the same members as the specified sequence, ignoring order.
    public func isEqualSet<S: Sequence>(to other: S) -> Bool where S.Element == Element {
        let otherSet = Set(other)
        return count == otherSet.count && unorderedSet == otherSet
    }

    /// Returns a new ordered set that keeps this set's order and appends new elements from the other set in their order.
    public func union(_ other: Self) -> Self {
        var result = self
        result.formUnion(other)
        return result
    }

    /// Adds new elements from another ordered set to the end, keeping all existing elements in their current order.
    public mutating func formUnion(_ other: Self) {
        append(contentsOf: other)
    }

    /// Returns a new ordered set containing common elements, keeping their order from this set.
    public func intersection(_ other: Self) -> Self {
        OrderedSet(uncheckedUniqueElements: _elements.filter { other.contains($0) })
    }

    /// Keeps only elements that are also present in another ordered set, preserving their current order.
    public mutating func formIntersection(_ other: Self) {
        self = intersection(other)
    }

    /**
     Returns a new ordered set containing elements that are present in exactly one ordered set.

     Elements unique to this set keep their current order, followed by elements unique to `other` in `other`'s order.
     */
    public func symmetricDifference(_ other: Self) -> Self {
        var result = self
        result.formSymmetricDifference(other)
        return result
    }

    /// Replaces this set with its symmetric difference, keeping current-order elements first and appending new elements from `other` in their order.
    public mutating func formSymmetricDifference(_ other: Self) {
        for element in other {
            if contains(element) {
                remove(element)
            } else {
                append(element)
            }
        }
    }

    /// Returns a new ordered set by removing elements found in the specified sequence while preserving this set's order.
    public func subtracting<S: Sequence>(_ sequence: S) -> Self where S.Element == Element {
        let excluded = Set(sequence)
        return OrderedSet(uncheckedUniqueElements: _elements.filter { !excluded.contains($0) })
    }

    /// Returns a new ordered set by removing elements found in the specified set while preserving this set's order.
    public func subtracting(_ set: Set<Element>) -> Self {
        OrderedSet(uncheckedUniqueElements: _elements.filter { !set.contains($0) })
    }

    /// Removes elements found in another ordered set while preserving the order of the remaining elements.
    public mutating func subtract(_ other: Self) {
        self = subtracting(other)
    }

    /// Returns a new ordered set containing elements also found in the specified sequence, preserving this set's order.
    public func intersection<S: Sequence>(_ sequence: S) -> Self where S.Element == Element {
        let included = Set(sequence)
        return OrderedSet(uncheckedUniqueElements: _elements.filter { included.contains($0) })
    }

    /// Returns a new ordered set containing elements also found in the specified set while preserving this set's order.
    public func intersection(_ set: Set<Element>) -> Self {
        OrderedSet(uncheckedUniqueElements: _elements.filter { set.contains($0) })
    }

    /// Returns a new ordered set containing matching elements while preserving this set's order.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        try OrderedSet(uncheckedUniqueElements: _elements.filter(isIncluded))
    }

    private mutating func rebuildIndexes(from start: Int = 0) {
        guard start < _elements.endIndex else { return }
        for index in start..<_elements.endIndex {
            indexes[_elements[index]] = index
        }
    }

    private mutating func rebuildIndexes() {
        indexes = _elements.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    }

    #if DEBUG
    private func _assertInvariant() {
        assert(_computeInvariant(), "[OrderedSet] Broken invariant: elements=\(_elements), indexes=\(indexes)")
    }
    #else
    private func _assertInvariant() {}
    #endif

    private func _computeInvariant() -> Bool {
        guard _elements.count == indexes.count else { return false }
        for (index, element) in _elements.enumerated() {
            guard indexes[element] == index else { return false }
        }
        return true
    }
}

extension OrderedSet: Equatable {
    /// Returns whether two ordered sets contain the same elements in the same order.
    public static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        lhs._elements == rhs._elements
    }

    /// Returns whether an ordered set contains the same elements in the same order as another collection.
    public static func == <C: Collection>(lhs: OrderedSet, rhs: C) -> Bool where C.Element == Element {
        lhs._elements == ContiguousArray(rhs)
    }
}

extension OrderedSet: Hashable { }
extension OrderedSet: Sendable where Element: Sendable { }

extension OrderedSet: Encodable where Element: Encodable {
    /// Encodes the ordered set as an ordered sequence of elements.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(_elements)
    }
}

extension OrderedSet: Decodable where Element: Decodable {
    /// Decodes an ordered set from an ordered sequence of elements.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(ContiguousArray<Element>.self))
    }
}

extension OrderedSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A textual representation of the ordered set.
    public var description: String {
        _elements.description
    }

    /// A debug textual representation of the ordered set.
    public var debugDescription: String {
        _elements.debugDescription
    }

    /// A mirror that reflects the ordered set as its stored elements.
    public var customMirror: Mirror {
        _elements.customMirror
    }
}

extension OrderedSet: CVarArg {
    /// The C variadic argument encoding for the ordered set's elements.
    public var _cVarArgEncoding: [Int] {
        Array(_elements)._cVarArgEncoding
    }
}
