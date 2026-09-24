//
//  SynchronizedSet.swift
//
//  Parts taken from:
//  Created by Sherzod Khashimov on 10/4/19.
//  Copyright © 2019 Sherzod Khashimov. All rights reserved.
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

/// A thread-safe, synchronized set.
public final class SynchronizedSet<Element: Hashable>: Collection, ExpressibleByArrayLiteral {
    private let storage: SynchronizedStorage<Set<Element>>
    
    public typealias Index = Set<Element>.Index

    /// Creates a new, empty synchronized set.
    public required init() {
        storage = SynchronizedStorage([])
    }

    /// Creates a new, empty synchronized set using the specified synchronization mechanism.
    public init(usingMutex: Bool = false) {
        storage = SynchronizedStorage([], usingMutex: usingMutex)
    }
    
    /// Creates a synchronized set from the specified set.
    public init(_ set: Set<Element>, usingMutex: Bool = false) {
        storage = SynchronizedStorage(set, usingMutex: usingMutex)
    }
    
    /**
     Creates an synchronized set containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into an set.
     */
    public required init<S>(_ elements: S) where S : Sequence<Element> {
        storage = SynchronizedStorage(Set(elements))
    }

    /// Creates a synchronized set containing the elements of a sequence using the specified synchronization mechanism.
    public init<S>(_ elements: S, usingMutex: Bool) where S: Sequence<Element> {
        storage = SynchronizedStorage(Set(elements), usingMutex: usingMutex)
    }

    /**
     Creates a new synchronized set from a set literal with the elements.

     - Parameter elements: The elements to turn into an set.
     */
    public required init(arrayLiteral elements: Element...) {
        storage = SynchronizedStorage(Set(elements))
    }
    
    public required init(from decoder: Decoder) throws where Element: Decodable {
        storage = SynchronizedStorage(try Set(from: decoder))
    }
}

public extension SynchronizedSet {
    /// Returns the set synchronously. Access is synchronized for both reads and writes.
    var synchronized: Set<Element> {
        get { storage.read { $0 } }
        set { storage.write { $0 = newValue } }
    }
    
    func edit(_ edit: (inout Set<Element>) throws -> Void) rethrows {
        try storage.write(edit)
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        storage.read { $0.index(i, offsetBy: distance) }
    }
    
    func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        storage.read { $0.index(i, offsetBy: distance, limitedBy: limit) }
    }
    
    func formIndex(after i: inout Index) {
        storage.read { $0.formIndex(after: &i) }
    }
    
    func distance(from start: Index, to end: Index) -> Int {
        storage.read { $0.distance(from: start, to: end) }
    }
    
    func index(after i: Index) -> Index {
        storage.read { $0.index(after: i) }
    }
    
    var startIndex: Index {
        storage.read { $0.startIndex }
    }
    
    var endIndex: Index {
        storage.read { $0.endIndex }
    }
    
    var count: Int {
        storage.read { $0.count }
    }
    
    func firstIndex(of element: Element) -> Index? where Element: Equatable {
        storage.read { $0.firstIndex(of: element) }
    }
    
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        try storage.read { try $0.firstIndex(where: predicate) }
    }
    
    var first: Element? {
        storage.read { $0.first }
    }
    
    var isEmpty: Bool {
        storage.read { $0.isEmpty }
    }
    
    subscript(index: Index) -> Element {
        get { storage.read { $0[index] } }
    }
    
    func contains(_ member: Element) -> Bool {
        storage.read { $0.contains(member) }
    }
    
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try storage.read { try $0.contains(where: predicate) }
    }
    
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        storage.read { $0.contains(any: members) }
    }
    
    func contains<S: Sequence<Element>>(all members: S) -> Bool {
        storage.read { $0.contains(all: members) }
    }
    
    func insert(_ element: Element) {
        storage.write { _ = $0.insert(element) }
    }
    
    @_disfavoredOverload
    func insert(_ element: Element, completion: ((_ inserted: Bool, _ memberAfterInsert: Element) -> ())? = nil) {
        storage.write {
            let insert = $0.insert(element)
            DispatchQueue.main.async { completion?(insert.inserted, insert.memberAfterInsert) }
        }
    }
    
    func insert<S: Sequence<Element>>(_ elements: S) {
        storage.write { $0.insert(elements) }
    }
    
    @_disfavoredOverload
    func insert<S: Sequence<Element>>(_ elements: S, completion: (() -> ())? = nil) {
        storage.write {
            $0.insert(elements)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func remove(_ element: Element) {
        storage.write { _ = $0.remove(element) }
    }
    
    @_disfavoredOverload
    func remove(_ element: Element, completion: ((Element?) -> ())? = nil) {
        storage.write {
            let removed = $0.remove(element)
            DispatchQueue.main.async { completion?(removed) }
        }
    }
    
    func remove<S: Sequence<Element>>(_ elements: S) {
        storage.write { $0.remove(elements) }
    }
    
    @_disfavoredOverload
    func remove<S: Sequence<Element>>(_ elements: S, completion: (() -> ())? = nil) {
        storage.write {
            $0.remove(elements)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func removeAll() {
        storage.write { $0.removeAll() }
    }
    
    func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
        storage.write {  _ = try? $0.removeAll(where: shouldBeRemoved) }
    }
    
    @_disfavoredOverload
    func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool, completion: (() -> ())? = nil) rethrows {
        storage.write {
            _ = try? $0.removeAll(where: shouldBeRemoved)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func union(_ other: Set<Element>) -> Set<Element> {
        storage.read { Set($0.union(other)) }
    }
    
    func formUnion(_ other: Set<Element>) {
        storage.write { $0.formUnion(other) }
    }
    
    @_disfavoredOverload
    func formUnion(_ other: Set<Element>, completion: (() -> ())? = nil) {
        storage.write {
            $0.formUnion(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func intersection(_ other: Set<Element>) -> Set<Element> {
        storage.read { Set($0.intersection(other)) }
    }
    
    func formIntersection(_ other: Set<Element>) {
        storage.write {  $0.formIntersection(other) }
    }
    
    @_disfavoredOverload
    func formIntersection(_ other: Set<Element>, completion: (() -> ())? = nil) {
        storage.write {
            $0.formIntersection(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func symmetricDifference(_ other: Set<Element>) -> Set<Element> {
        storage.read { Set($0.symmetricDifference(other)) }
    }
    
    func formSymmetricDifference(_ other: Set<Element>) {
        storage.write { $0.formSymmetricDifference(other) }
    }
    
    @_disfavoredOverload
    func formSymmetricDifference(_ other: Set<Element>, completion: (() -> ())? = nil) {
        storage.write {
            $0.formSymmetricDifference(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func subtracting(_ other: Set<Element>) -> Set<Element> {
        storage.read { Set($0.subtracting(other)) }
    }
    
    func subtract(_ other: Set<Element>) {
        storage.write { $0.subtract(other) }
    }
    
    @_disfavoredOverload
    func subtract(_ other: Set<Element>, completion: (() -> ())? = nil) {
        storage.write {
            $0.subtract(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func isSubset(of other: Set<Element>) -> Bool {
        storage.read { $0.isSubset(of: other) }
    }
    
    func isSuperset(of other: Set<Element>) -> Bool {
        storage.read { $0.isSuperset(of: other) }
    }
    
    func isStrictSubset(of other: Set<Element>) -> Bool {
        storage.read { $0.isStrictSubset(of: other) }
    }
    
    func isStrictSuperset(of other: Set<Element>) -> Bool {
        storage.read { $0.isStrictSuperset(of: other) }
    }
    
    func isDisjoint(with other: Set<Element>) -> Bool {
        storage.read { $0.isDisjoint(with: other) }
    }
    
    func update(with newMember: Element) {
        storage.write { _ = $0.update(with: newMember) }
    }
    
    @_disfavoredOverload
    func update(with newMember: Element, completion: ((Element?) -> ())? = nil) {
        storage.write {
            let update = $0.update(with: newMember)
            DispatchQueue.main.async { completion?(update) }
        }
    }
    
    subscript(_ element: Element) -> Bool {
        get { storage.read { $0.contains(element) } }
        set {
            storage.write { set in
                if newValue {
                    set.insert(element)
                } else {
                    set.remove(element)
                }
            }
        }
    }
}

public extension SynchronizedSet {
    /**
     Appends a new element to the set.
     
     - Parameters:
        - lhs: The set to append to.
        - rhs: The element to append to the set.
     */
    static func += (lhs: inout SynchronizedSet, rhs: Element) {
        lhs.insert(rhs)
    }
    
    /**
     Appends the elements of a sequence to the set.
     
     - Parameters:
        - lhs: The set to append to.
        - rhs: A collection or finite sequence.
     */
    static func += <S: Sequence<Element>>(lhs: inout SynchronizedSet, rhs: S) {
        lhs.insert(rhs)
    }
}

public extension SynchronizedSet {
    /**
     Returns the first element of the sequence that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     - Returns: The first element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
     */
    func first(where predicate: (Element) -> Bool) -> Element? {
        storage.read { $0.first(where: predicate) }
    }

    /**
     Returns a set containing, in order, the elements of the sequence that satisfy the given predicate.
     
     - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned set.
     - Returns: A set of the elements that includeElement allowed.
     */
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        storage.read { $0.filter(isIncluded) }
    }

    /**
     Returns the first index in which an element of the collection satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: The index of the first element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    func firstIndex(where predicate: (Element) -> Bool) -> Index? {
        storage.read { $0.firstIndex(where: predicate) }
    }

    /**
     Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
     - Returns: A sorted set of the collection’s elements.
     */
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        storage.read { $0.sorted(by: areInIncreasingOrder) }
    }

    /**
     A set of the elements sorted by the given keypath.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) -> [Element] where Value : Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }

    /**
     A set of the elements sorted by the given keypath.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) -> [Element] where Value : Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }

    /**
     Returns a set containing the results of mapping the given closure over the sequence’s elements.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: A set of the non-`nil` results of calling transform with each element of the sequence.
     */
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        storage.read { $0.map(transform) }
    }

    /**
     Returns a set containing the non-`nil` results of calling the given transformation with each element of this sequence.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: A set of the non-`nil` results of calling transform with each element of the sequence.
     */
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        storage.read { $0.compactMap(transform) }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value. initialResult is passed to nextPartialResult the first time the closure is executed.
       - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: @escaping (ElementOfResult, Element) -> ElementOfResult) -> ElementOfResult {
        storage.read { $0.reduce(initialResult, nextPartialResult) }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value.
       - updateAccumulatingResult: A closure that updates the accumulating value with an element of the sequence.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: @escaping (inout ElementOfResult, Element) -> Void) -> ElementOfResult {
        storage.read { $0.reduce(into: initialResult, updateAccumulatingResult) }
    }

    /**
     Calls the given closure on each element in the sequence in the same order as a for-in loop.
     
     - Parameter body: A closure that takes an element of the sequence as a parameter.
     */
    func forEach(_ body: (Element) -> Void) {
        storage.read { $0.forEach(body) }
    }

    /**
     Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
     */
    func contains(where predicate: (Element) -> Bool) -> Bool {
        storage.read { $0.contains(where: predicate) }
    }

    /**
     Returns a Boolean value indicating whether every element of a sequence satisfies a given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element satisfies a condition.
     - Returns: true if the sequence contains only elements that satisfy predicate; otherwise, false.
     */
    func allSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        storage.read { $0.allSatisfy(predicate) }
    }
    
    /// Returns a sequence of pairs (n, x), where n represents a consecutive integer starting at zero and x represents an element of the sequence.
    func enumerated() -> EnumeratedSequence<Set<Element>> {
        storage.read { $0.enumerated() }
    }
    
    func count<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int where E : Error {
        do {
            return try storage.read { try $0.count(where: predicate) }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Unexpected error type: \(error)")
        }
    }
    
    /// Returns the elements of the sequence, shuffled.
    func shuffled() -> [Element] {
        storage.read {  $0.shuffled() }
    }
    
    /// Returns an set containing the elements of this set in reverse order.
    func reversed() -> [Element] {
        storage.read {  $0.reversed() }
    }
    
    func randomElement() -> Element? {
        storage.read { $0.randomElement() }
    }

    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        storage.read { $0.randomElement(using: &generator) }
    }
    
    static func == (lhs: SynchronizedSet<Element>, rhs: SynchronizedSet<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

public extension SynchronizedSet where Element: Comparable {
    /// Returns the elements of the sequence, sorted.
    func sorted() -> [Element] {
        storage.read {  $0.sorted() }
    }
    
    func min() -> Element? {
        storage.read { $0.min() }
    }
    
    func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.min(by: areInIncreasingOrder)}
    }
    
    func max() -> Element? {
        storage.read { $0.max() }
    }
    
    func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.max(by: areInIncreasingOrder)}
    }
}

extension SynchronizedSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(synchronized)
    }
}

extension SynchronizedSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        synchronized.customMirror
    }

    public var debugDescription: String {
        synchronized.debugDescription
    }

    public var description: String {
        synchronized.description
    }
}

extension SynchronizedSet: @unchecked Sendable where Element: Sendable { }

extension SynchronizedSet: Decodable where Element: Decodable { }
extension SynchronizedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        try synchronized.encode(to: encoder)
    }
}

extension SynchronizedSet: CVarArg {
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}

extension SynchronizedSet: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> NSSet {
        storage.read { $0._bridgeToObjectiveC() }
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSSet, result: inout SynchronizedSet?) {
        var set: Set<Element>?
        Set<Element>._forceBridgeFromObjectiveC(source, result: &set)
        result = set.map { .init($0) }
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: NSSet, result: inout SynchronizedSet?) -> Bool {
        var set: Set<Element>?
        guard Set<Element>._conditionallyBridgeFromObjectiveC(source, result: &set),
              let set else {
            result = nil
            return false
        }
        result = .init(set)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSSet?) -> SynchronizedSet {
        .init(Set<Element>._unconditionallyBridgeFromObjectiveC(source))
    }
}
