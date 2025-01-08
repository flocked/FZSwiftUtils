//
//  OrderedDictionary.swift
//
//  Created by Frazer Robinson
//  OrderedDictionary - https://github.com/frazer-rbsn/orderedset/
//

import Foundation

/**
 An ordered collection of unique objects.
 
 Example usage:
 
 ```swift
 let ingredients: Set<String> = ["cocoa beans", "sugar", "cocoa butter", "salt"]
 if ingredients.contains("sugar") {
 print("No thanks, too sweet.")
 }
 ```
 */
@frozen public struct OrderedSet<E: Hashable> {
    
    // MARK: - Typealiases
    
    public typealias Element = E
    public typealias Index = Int
    
    @usableFromInline internal typealias HashValue = Int
    @usableFromInline internal typealias HashIndexDict = [HashValue: Index]
    
    // MARK: - Internal Storage
    
    private var _array: ContiguousArray<Element>
    private var _set: Set<Element>
    private var _hashIndexDict: HashIndexDict
    
    
    // MARK: - Public Stored Properties
    
    /// Returns the number of elements in this ordered set.
    public var count: Int {
        _array.count
    }
    
    /// Returns `true` if this ordered set is empty.
    public var isEmpty: Bool {
        _array.isEmpty
    }
    
    
    // MARK: - Public Initialisers
    
    /// Creates an ordered set with the contents of `sequence`.
    /// - parameter retainLastOccurences: If set to `true`, if an element occurs more than once in `sequence`, only the last instance
    ///   will be included. Default value is `false`.
    public init<S>(_ sequence: S, retainLastOccurences: Bool = false) where Element == S.Element, S: Sequence {
        if retainLastOccurences {
            self.init(retainingLastOccurrencesIn: sequence)
        } else {
            self.init(retainingFirstOccurrencesIn: sequence)
        }
    }
    
    /// Creates an ordered set with the contents of `set`, ordered by the given predicate.
    public init(_ set: Set<Element>, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        let sortedArray = try set.sorted(by: areInIncreasingOrder)
        self.init(array: ContiguousArray(sortedArray),
                  set: set,
                  hashIndexDict: Self.hashIndexDict(from: sortedArray))
    }
    
    /// Creates an ordered set with the contents of `set`, sorted according to the member type's conformance to `Comparable`.
    public init(_ set: Set<Element>) where Element: Comparable {
        let sortedArray = set.sorted()
        self.init(array: ContiguousArray(sortedArray),
                  set: set,
                  hashIndexDict: Self.hashIndexDict(from: sortedArray))
    }
    
    /// Creates an empty ordered set.
    public init() {
        self.init(array: [],
                  set: [],
                  hashIndexDict: [:])
    }
    
    
    // MARK: - Private Initialisers
    
    private init<S>(retainingFirstOccurrencesIn sequence: S) where Element == S.Element, S: Sequence {
        var array = ContiguousArray<Element>()
        var set = Set<Element>()
        var indexDict = HashIndexDict()
        for element in sequence {
            let inserted = set.insert(element).inserted
            guard inserted else { continue }
            array.append(element)
            indexDict[element.hashValue] = array.endIndex - 1
        }
        self.init(array: array,
                  set: set,
                  hashIndexDict: indexDict)
    }
    
    private init<S>(retainingLastOccurrencesIn sequence: S) where Element == S.Element, S: Sequence {
        var array = ContiguousArray<Element>()
        var set = Set<Element>()
        for element in sequence {
            let inserted = set.insert(element).inserted
            if !inserted {
                let index = array.lastIndex(of: element)!
                array.remove(at: index)
            }
            array.append(element)
        }
        self.init(array: array,
                  set: set)
    }
    
    private init(array: ContiguousArray<Element>, set: Set<Element>) {
        self.init(array: array,
                  set: set,
                  hashIndexDict: Self.hashIndexDict(from: array))
    }
    
    private init(array: [Element], set: Set<Element>) {
        self.init(array: ContiguousArray(array),
                  set: set,
                  hashIndexDict: Self.hashIndexDict(from: array))
    }
    
    private init(array: ContiguousArray<Element>, set: Set<Element>, hashIndexDict: HashIndexDict) {
        self._array = array
        self._set = set
        self._hashIndexDict = hashIndexDict
    }
    
    private static func hashIndexDict<S>(from sequence: S) -> HashIndexDict where Element == S.Element, S: Sequence {
        var indexDict = HashIndexDict()
        for (index, element) in sequence.enumerated() {
            indexDict[element.hashValue] = index
        }
        return indexDict
    }
    
    
    // MARK: - Computed Properties
    
    /// Returns the contents of this ordered set as an array.
    public var array: [Element] { Array(_array) }
    
    /// Returns the contents of this ordered set as a `ContiguousArray`.
    /// - complexity: O(1)
    public var contiguousArray: ContiguousArray<Element> { _array }
    
    /// Returns the contents of this ordered set as an unordered set.
    /// - complexity: O(1)
    public var unorderedSet: Set<Element> { _set }
    
    
    // MARK: - Metadata Functions
    
    /// Returns `true` if this ordered set is a subset of `otherSet`.
    public func isSubset(of otherSet: Set<Element>) -> Bool {
        _set.isSubset(of: otherSet)
    }
    
    /// Returns `true` if this ordered set is a subset of `otherSet`.
    public func isSubset(of otherSet: Self) -> Bool {
        _set.isSubset(of: otherSet)
    }
    
    /// Returns `true` if this ordered set is a superset of `otherSet`.
    public func isSuperset(of otherSet: Set<Element>) -> Bool {
        _set.isSuperset(of: otherSet)
    }
    
    /// Returns `true` if this ordered set is a superset of `otherSet`.
    public func isSuperset(of otherSet: Self) -> Bool {
        _set.isSuperset(of: otherSet)
    }
    
    /// Returns `true` if this ordered set has elements in common with `otherSet`.
    public func intersects(with otherSet: Set<Element>) -> Bool {
        !_set.isDisjoint(with: otherSet)
    }
    
    /// Returns `true` if this ordered set has elements in common with `otherSet`.
    public func intersects(with otherSet: Self) -> Bool {
        !_set.isDisjoint(with: otherSet)
    }
    
    /// Returns `true` if this ordered set has no elements in common with `otherSet`.
    public func isDisjoint(with otherSet: Set<Element>) -> Bool {
        _set.isDisjoint(with: otherSet)
    }
    
    /// Returns `true` if this ordered set has no elements in common with `otherSet`.
    public func isDisjoint(with otherSet: Self) -> Bool {
        _set.isDisjoint(with: otherSet)
    }
            
    /// Returns a new set with the elements of both this set and the given sequence.
    @inlinable public func union(_ other: Self) -> Self {
        self + other
    }
    
    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: Self) {
        self = union(other)
    }
    
    /// Returns a Boolean value that indicates whether this set is a strict subset of the given set.
    public func isStrictSubset(of other: Self) -> Bool {
        _set.isStrictSubset(of: other._set)
    }
    
    /// Returns a Boolean value that indicates whether this set is a strict superset of the given set.
    public func isStrictSuperset(of other: Self) -> Bool {
        _set.isStrictSuperset(of: other._set)
    }
        
    /// Returns a new set with the elements that are common to both this set and the given set.
    public func intersection(_ other: Self) -> Self {
        let set = _set.intersection(other)
        let array = _array.filter({ set.contains($0) })
        return OrderedSet(array: array, set: set)
    }
    
    /// Removes the elements of this set that aren’t also in the given set.
    public mutating func formIntersection(_ other: Self) {
        self = intersection(other)
    }
    
    /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
    public func symmetricDifference(_ other: Self) -> Self {
        let set = _set.symmetricDifference(other)
        let array = _array.filter({ set.contains($0) })
        return OrderedSet(array: array, set: set)
    }
    
    public mutating func formSymmetricDifference(_ other: Self) {
        self = symmetricDifference(other)
    }
    
    // MARK: Removing Elements
    
    /// Replaces the specified subrange of elements with the given collection.
    public mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C) where C : Collection, Self.Element == C.Element {
        var array = _array
        array.replaceSubrange(subrange, with: newElements)
        self = Self(array)
    }
    
    /// Returns a new ordered set with the elements filtered by the given predicate.
    /// - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
    ///   If retaining the order is not necessary, passing in `false` may yield a performance benefit.
    public func filter(_ isIncluded: (Element) throws -> Bool, retainOrder: Bool = true) rethrows -> Self {
        if retainOrder {
            return Self(try _array.filter(isIncluded))
        } else {
            return Self(try _set.filter(isIncluded))
        }
    }
    
    /// Returns a new ordered set containing the elements of this ordered set that do not occur in the given sequence.
    /// Retains the relative order of the elements in this ordered set.
    public func subtracting<S>(_ sequence: S) -> Self where Element == S.Element, S: Sequence {
        Self(_array.filter { !sequence.contains($0) })
    }
    
    /// Returns a new ordered set containing the elements of this ordered set that do not occur in the given set.
    /// - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
    ///   If retaining the order is not necessary, passing in `false` may yield a performance benefit.
    public func subtracting(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        if retainOrder {
            return Self(_array.filter { !set.contains($0) })
        } else {
            return Self(_set.subtracting(set))
        }
    }
    
    /// Returns a new ordered set containing the elements of this ordered set that also occur in the given sequence.
    /// Retains the relative order of the elements in this ordered set.
    public func intersection<S>(_ sequence: S) -> Self where Element == S.Element, S: Sequence {
        Self(_array.filter { sequence.contains($0) })
    }
    
    /// Returns a new ordered set containing the elements of this ordered set that also occur in the given set.
    /// - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
    ///   If retaining the order is not necessary, passing in `false` may yield a performance benefit.
    public func intersection(_ set: Set<Element>, retainOrder: Bool = true) -> Self {
        if retainOrder {
            return Self(_array.filter { set.contains($0) })
        } else {
            return Self(_set.intersection(set))
        }
    }
    
    // MARK: Transforming Elements
    
    /// Returns a new ordered set with the results of mapping the given closure over the ordered set's elements.
    /// - parameter transform: A mapping closure. `transform` accepts an
    ///   element of this ordered set as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
    ///   If retaining the order is not necessary, passing in `false` may yield a performance benefit.
    /// - note: To return a new ordered set instead of an array, the given closure must return a type that conforms to `Hashable`.
    /// - note: Documentation based on `Swift.Collection.map(_:)`
    public func map<T>(_ transform: (Element) throws -> T, retainOrder: Bool = true) rethrows -> OrderedSet<T> where T: Hashable {
        if retainOrder {
            return OrderedSet<T>(try _array.map(transform))
        } else {
            return OrderedSet<T>(try _set.map(transform))
        }
    }
    
    /// Returns a new ordered set with the non-nil results of mapping the given closure over the ordered set's elements.
    /// - parameter transform: A mapping closure. `transform` accepts an
    ///   element of this ordered set as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - parameter retainOrder: The returned ordered set retains the relative order of the elements. Defaults to `true`.
    ///   If retaining the order is not necessary, passing in `false` may yield a performance benefit.
    /// - note: To return a new ordered set instead of an array, the given closure must return a type that conforms to `Hashable`.
    /// - note: Documentation based on `Swift.Collection.compactMap(_:)`
    public func compactMap<T>(_ transform: (Element) throws -> T?, retainOrder: Bool = true) rethrows -> OrderedSet<T> where T: Hashable {
        if retainOrder {
            return OrderedSet<T>(try _array.compactMap(transform))
        } else {
            return OrderedSet<T>(try _set.compactMap(transform))
        }
    }
}

// MARK: - Extensions

extension OrderedSet: Hashable { }
extension OrderedSet: Sendable where Element: Sendable { }
extension OrderedSet: RangeReplaceableCollection { }
extension OrderedSet: MutableCollection { }
extension OrderedSet: BidirectionalCollection { }

extension OrderedSet {
    static public func + (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.append(rhs)
        return lhs
    }
    
    static public func + <S>(lhs: Self, rhs: S) -> Self where S: Sequence<Element> {
        var lhs = lhs
        lhs.append(contentsOf: rhs)
        return lhs
    }
    
    static public func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
    
    static public func += <S>(lhs: inout Self, rhs: S) where S: Sequence<Element> {
        lhs.append(contentsOf: rhs)
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
}

extension OrderedSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension OrderedSet: RandomAccessCollection {
    public var startIndex: Index { 0 }
    
    public var endIndex: Index { _array.endIndex }
    
    public subscript(index: Index) -> Element { 
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
            self = OrderedSet(array: _array, set: _set)
        }
    }
}

extension OrderedSet: Equatable {
    static public func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        lhs._array == rhs._array
    }
}

extension OrderedSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let array = try c.decode(ContiguousArray<Element>.self)
        let set = Set(array)
        guard set.count == array.endIndex else {
            throw Error.nonUniqueElements
        }
        self.init(array: array, set: set)
    }
}

extension OrderedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(_array)
    }
}

extension OrderedSet {
    enum Error : LocalizedError {
        case nonUniqueElements
        
        var errorDescription: String? {
            switch self {
            case .nonUniqueElements:
                return "Attempted to decode an array into an OrderedSet, but found non-unique elements in the collection."
            }
        }
    }
}

extension OrderedSet: CustomStringConvertible {
    public var description: String {
        "\(_array)"
    }
    
    public var debugDescription: String {
        "OrderedSet (\(count) elements): " + description
    }
}
