//
//  OrderedDictionary.swift
//
//  Created by Florian Zand on 23.07.23.
//  Adopted from: Lukas Kubanek
//  OrderedDictionary - https://github.com/frazer-rbsn/orderedset/
//

import Foundation

/**
 An ordered collection of unique objects.
 
 Example usage:
 
 ```swift
 let ingredients: OrderedSet<String> = ["cocoa beans", "sugar", "cocoa butter", "salt"]
 for ingredient in ingredients {
    print(ingredient)
 }
 // => cocoa beans
 // => sugar
 // => cocoa butter
 // => salt
 ```
 */
public struct OrderedSet<Element: Hashable>: RandomAccessCollection, RangeReplaceableCollection, MutableCollection, BidirectionalCollection, ExpressibleByArrayLiteral {
    
    // MARK: - Internal Storage
    
    private var _array: ContiguousArray<Element>
    private var _set: Set<Element>
    private var elementIndexes: [Element: Int]
    
    // MARK: - Public Stored Properties
    
    /// Returns the number of elements in this ordered set.
    public var count: Int {
        _array.count
    }
    
    /// Returns `true` if this ordered set is empty.
    public var isEmpty: Bool {
        _array.isEmpty
    }
    
    public var startIndex: Int { 0 }
    
    public var endIndex: Index { _array.endIndex }
    
    // MARK: - Public Initialisers
    
    /// Creates an empty ordered set.
    public init() {
        _array = []
        _set = []
        elementIndexes = [:]
    }
    
    public init(minimumCapacity: Int) {
        self.init()
        reserveCapacity(minimumCapacity)
    }
    
    /// Creates a new ordered set from a finite sequence of items.
    public init<S>(_ elements: S) where S : Sequence<Element> {
        self.init(elements, retainLastOccurences: false)
    }
    
    /**
     Creates an ordered set with the contents of `sequence`.
     
     - Parameters:
        - sequence: The sequence.
        - retainLastOccurences: A Boolean value indicating whether if an element occurs more than once in the sequence, only the last instance will be included.
     */
    public init<S>(_ sequence: S, retainLastOccurences: Bool) where Element == S.Element, S: Sequence {
        var seen = Set<Element>()
        _array = ContiguousArray(retainLastOccurences ? sequence.reversed().compactMap { seen.insert($0).inserted ? $0 : nil }.reversed() : sequence.compactMap { seen.insert($0).inserted ? $0 : nil })
        _set = seen
        elementIndexes = _array.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    }
    
    /// Creates an ordered set with the contents of `set`, ordered by the given predicate.
    public init(_ set: Set<Element>, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        self._array = ContiguousArray(try set.sorted(by: areInIncreasingOrder))
        self._set = set
        self.elementIndexes = _array.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
       // self.init(array: ContiguousArray(try set.sorted(by: areInIncreasingOrder)))
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
    // MARK: - Computed Properties
    
    /// Returns the contents of this ordered set as an array.
    public var array: [Element] { Array(_array) }
    
    /// Returns the contents of this ordered set as a `ContiguousArray`.
    public var contiguousArray: ContiguousArray<Element> { _array }
    
    /// Returns the contents of this ordered set as an unordered set.
    public var unorderedSet: Set<Element> { _set }
    
    public var capacity: Int  { _set.capacity }
    
    // MARK: - Metadata Functions
    
    public subscript(index: Int) -> Element {
        get { _array[index] }
        set {
            guard let element = _array[safe: index], newValue != element else { return }
            let removeIndex = firstIndex(of: newValue)
            _set.insert(newValue)
            _set.remove(element)
            _array[index] = newValue
            if let removeIndex = removeIndex {
                _array.remove(at: removeIndex)
            }
            elementIndexes[element] = nil
            elementIndexes[newValue] = index
        }
    }
    
    public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try _array.sort(by: areInIncreasingOrder)
        elementIndexes = _array.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    }
    
    public func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        try _array.sorted(by: areInIncreasingOrder)
    }
    
    public mutating func reverse() {
        _array.reverse()
        elementIndexes = elementIndexes.mapValues { count - 1 - $0 }
    }
    
    public func reversed() -> [Element] {
        _array.reversed()
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
    
    public func index(of element: Element) -> Int? {
        elementIndexes[element]
    }
    
    // MARK: Removing Elements
    
    /// Replaces the specified subrange of elements with the given collection.
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        _set.remove(array[subrange])
        _set.insert(newElements)
        _array.replaceSubrange(subrange, with: newElements)
        (subrange.lowerBound..<array.endIndex).forEach { elementIndexes[_array[$0]] = $0 }
    }
    
    /**
     Returns a new ordered set with the elements filtered by the given predicate.
     
     - Parameters:
        - isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
        - retainOrder: A Boolean value indicating whether to keep the relative order of the  elements. Defaults to `true`.
     */
    public func filter(_ isIncluded: (Element) throws -> Bool, retainOrder: Bool = true) rethrows -> Self {
        retainOrder ? Self(try _array.filter(isIncluded)) : Self(try _set.filter(isIncluded))
    }
    
    // MARK: Transforming Elements
    
    /**
     Returns a new ordered set with the results of mapping the given closure over the ordered set's elements.
     
     - Parameters:
        - transform: A mapping closure. `transform` accepts an element of this ordered set as its parameter and returns a transformed value of the same or of a different type.
        - retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`. If retaining the order is not necessary, passing in `false` may yield a performance benefit.
     
     - note: To return a new ordered set instead of an array, the given closure must return a type that conforms to `Hashable`.
     */
    public func map<T>(_ transform: (Element) throws -> T, retainOrder: Bool = true) rethrows -> OrderedSet<T> where T: Hashable {
        retainOrder ? OrderedSet<T>(try _array.map(transform)) : OrderedSet<T>(try _set.map(transform))
    }
    
    /**
     Returns a new ordered set with the non-nil results of mapping the given closure over the ordered set's elements.
     
     - Parameters:
       - transform: A mapping closure. `transform` accepts an
         element of this ordered set as its parameter and returns a transformed
         value of the same or of a different type.
       - retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
         If retaining the order is not necessary, passing in `false` may yield a performance benefit.
     - note: To return a new ordered set instead of an array, the given closure must return a type that conforms to `Hashable`.
     */
    public func compactMap<T>(_ transform: (Element) throws -> T?, retainOrder: Bool = true) rethrows -> OrderedSet<T> where T: Hashable {
        retainOrder ? OrderedSet<T>(try _array.compactMap(transform)) : OrderedSet<T>(try _set.compactMap(transform))
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _set.reserveCapacity(minimumCapacity)
        _array.reserveCapacity(minimumCapacity)
        elementIndexes.reserveCapacity(minimumCapacity)
    }
    
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        let element = _array.remove(at: index)
        _set.remove(element)
        elementIndexes[element] = nil
        return element
    }
    
    public mutating func removeFirst() -> Element {
        remove(at: 0)
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _array.removeAll(keepingCapacity: keepCapacity)
        _set.removeAll(keepingCapacity: keepCapacity)
        elementIndexes.removeAll(keepingCapacity: keepCapacity)
    }
}

extension OrderedSet: SetAlgebra {
    @discardableResult
    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let insertation = _set.insert(newMember)
        if insertation.inserted {
            _array.append(newMember)
            elementIndexes[newMember] = endIndex - 1
        }
        return insertation
    }
    
    @discardableResult
    public mutating func update(with newMember: __owned Element) -> Element? {
        if let oldMember = _set.update(with: newMember) {
            if let index = _array.firstIndex(of: oldMember) {
                _array[index] = newMember
                elementIndexes[oldMember] = nil
                elementIndexes[newMember] = index
            }
            return oldMember
        } else {
            _array.append(newMember)
            elementIndexes[newMember] = endIndex - 1
            return nil
        }
    }
    
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        guard let index = elementIndexes[element] else { return nil }
        _set.remove(element)
        elementIndexes[element] = nil
       return  _array.remove(at: index)
    }
    
    public mutating func remove<S>(_ elements: S) where S: Sequence<Element> {
        elements.forEach({ remove($0) })
    }
    
    public func contains(_ element: Element) -> Bool {
        _set.contains(element)
    }
    
    /// Returns a Boolean value indicating whether this set is a subset of the given set.
    public func isSubset(of other: Set<Element>) -> Bool {
        _set.isSubset(of: other)
    }
    
    /// Returns a Boolean value indicating whether this set is a subset of the given set.
    public func isSubset(of other: Self) -> Bool {
        _set.isSubset(of: other._set)
    }
    
    /// Returns a Boolean value indicating whether the set is a subset of the given sequence.
    public func isSubset<S>(of possibleSuperset: S) -> Bool where Element == S.Element, S : Sequence {
        isSubset(of: Self(possibleSuperset))
    }
    
    /// Returns a Boolean value indicating whether the set is a strict subset of the given set.
    public func isStrictSubset(of other: Set<Element>) -> Bool {
        _set.isStrictSubset(of: other)
    }
    
    /// Returns a Boolean value indicating whether the set is a strict subset of the given set.
    public func isStrictSubset(of other: Self) -> Bool {
        _set.isStrictSubset(of: other._set)
    }
    
    /// Returns a Boolean value indicating whether the set is a strict subset of the given sequence.
    public func isStrictSubset<S>(of possibleSuperset: S) -> Bool where Element == S.Element, S : Sequence {
        isStrictSubset(of: Self(possibleSuperset))
    }
    
    /// Returns a Boolean value indicating whether this set is a superset of the given set.
    public func isSuperset(of other: Set<Element>) -> Bool {
        _set.isSuperset(of: other)
    }
    
    /// Returns a Boolean value indicating whether this set is a superset of the given set.
    public func isSuperset(of other: Self) -> Bool {
        _set.isSuperset(of: other._set)
    }
    
    /// Returns a Boolean value indicating whether the set is a superset of the given sequence.
    public func isSuperset<S>(of possibleSubset: S) -> Bool where S: Sequence<Element> {
        isSuperset(of: Self(possibleSubset))
    }
    
    /// Returns a Boolean value indicating whether the set is a strict superset of the given set.
    public func isStrictSuperset(of other: Set<Element>) -> Bool {
        _set.isStrictSuperset(of: other)
    }
    
    /// Returns a Boolean value indicating whether the set is a strict superset of the given set.
    public func isStrictSuperset(of other: Self) -> Bool {
        _set.isStrictSuperset(of: other._set)
    }
    
    /// Returns a Boolean value indicating whether the set is a strict superset of the given sequence.
    public func isStrictSuperset<S>(of possibleSubset: S) -> Bool where Element == S.Element, S : Sequence {
        isStrictSuperset(of: Self(possibleSubset))
    }
    
    /// Returns `true` if this ordered set has elements in common with `otherSet`.
    public func intersects(with otherSet: Set<Element>) -> Bool {
        !_set.isDisjoint(with: otherSet)
    }
    
    /// Returns `true` if this ordered set has elements in common with `otherSet`.
    public func intersects(with otherSet: Self) -> Bool {
        !_set.isDisjoint(with: otherSet._set)
    }
    
    /// Returns a Boolean value indicating whether this set has no members in common with the given set.
    public func isDisjoint(with other: Set<Element>) -> Bool {
        _set.isDisjoint(with: other)
    }
    
    /// Returns a Boolean value indicating whether this set has no members in common with the given set.
    public func isDisjoint<S: Sequence<Element>>(with other: S) -> Bool {
        _set.isDisjoint(with: other)
    }
    
    /// Returns a Boolean value indicating whether this set has no members in common with the given set.
    public func isDisjoint(with other: Self) -> Bool {
        _set.isDisjoint(with: other._set)
    }
            
    /// Returns a new set with the elements of both this set and the given sequence.
    @inlinable public func union(_ other: Self) -> Self {
        var copy = self
        copy.formUnion(other)
        return copy
    }
    
    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: Self) {
        for element in other {
            insert(element)
        }
    }
        
    /// Returns a new set with the elements that are common to both this set and the given set.
    public func intersection(_ other: Self) -> Self {
        var copy = self
        copy.formIntersection(other)
        return copy
    }
    
    /// Removes the elements of this set that aren’t also in the given set.
    public mutating func formIntersection(_ other: Self) {
        _set.formIntersection(other)
        _array.removeAll(where: { !_set.contains($0) })
        elementIndexes = array.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
    }
    
    /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
    public func symmetricDifference(_ other: Self) -> Self {
        var copy = self
        copy.formSymmetricDifference(other)
        return copy
    }
    
    public mutating func formSymmetricDifference(_ other: Self) {
        for element in other {
            if _set.contains(element) {
                remove(element)
            } else {
                insert(element)
            }
        }
    }
    
    /**
     Returns a new ordered set containing the elements of this ordered set that do not occur in the given sequence.
     
     Retains the relative order of the elements in this ordered set.
     */
    public func subtracting<S>(_ sequence: S) -> Self where Element == S.Element, S: Sequence {
        Self(_array.filter { !sequence.contains($0) })
    }
    
    /**
     Returns a new ordered set containing the elements of this ordered set that do not occur in the given set.
     
     - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`. If retaining the order is not necessary, passing in `false` may yield a performance benefit.
     */
    public func subtracting(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        retainOrder ? Self(_array.filter { !set.contains($0) }) : Self(_set.subtracting(set))
    }
    
    /**
     Returns a new ordered set containing the elements of this ordered set that also occur in the given sequence.
     
     Retains the relative order of the elements in this ordered set.
     */
    public func intersection<S>(_ sequence: S) -> Self where Element == S.Element, S: Sequence {
        Self(_array.filter { sequence.contains($0) })
    }
    
    /**
     Returns a new ordered set containing the elements of this ordered set that also occur in the given set.
     
     - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`. If retaining the order is not necessary, passing in `false` may yield a performance benefit.
     */
    public func intersection(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        retainOrder ? Self(_array.filter { set.contains($0) }) : Self(_set.intersection(set))
    }
}

// MARK: - Extensions

extension OrderedSet: Hashable { }
extension OrderedSet: Sendable where Element: Sendable { }

extension OrderedSet: Equatable {
    static public func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        lhs._array == rhs._array
    }
    
    static public func == <C: Collection>(lhs: OrderedSet, rhs: C) -> Bool where C.Element == Element {
        lhs._array == ContiguousArray(rhs)
    }
}

extension OrderedSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Array<Element>.self))
    }
}

extension OrderedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Array(_array))
    }
}

extension OrderedSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var description: String {
        _array.description
    }
    
    public var debugDescription: String {
        _array.description.debugDescription
    }
    
    public var customMirror: Mirror {
        _array.customMirror
    }
}

extension OrderedSet: CVarArg {
    public var _cVarArgEncoding: [Int] {
        Array(_array)._cVarArgEncoding
    }
}
