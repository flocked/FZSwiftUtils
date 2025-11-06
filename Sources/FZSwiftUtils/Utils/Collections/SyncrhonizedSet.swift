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
public class SynchronizedSet<Element: Hashable>: Collection, ExpressibleByArrayLiteral {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedSet", attributes: .concurrent)
    private var storage: Set<Element> = []
    
    public typealias Index = Set<Element>.Index

    /// Creates a new, empty synchronized set.
    public required init() { }
    
    /**
     Creates an synchronized set containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into an set.
     */
    public required init<S>(_ elements: S) where S : Sequence<Element> {
        storage = .init(elements)
    }

    /**
     Creates a new synchronized set from a set literal with the elements.

     - Parameter elements: The elements to turn into an set.
     */
    public required init(arrayLiteral elements: Element...) {
        storage = .init(elements)
    }
    
    public required init(from decoder: Decoder) throws where Element: Decodable {
        var container = try decoder.unkeyedContainer()
        storage = try container.decode(Set<Element>.self)
    }
}

public extension SynchronizedSet {
    /// Returns the set synchronious.
    var synchronized: Set<Element> {
        get { queue.sync { self.storage } }
        set { queue.async(flags: .barrier) { [weak self] in self?.storage = newValue } }
    }
    
    func edit(_ edit: @escaping (inout Set<Element>) -> Void) {
        queue.async(flags: .barrier) { edit(&self.storage) }
    }
    
    func index(_ i: Index, offsetBy distance: Int) -> Index {
        queue.sync { self.storage.index(i, offsetBy: distance) }
    }
    
    func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        queue.sync { self.storage.index(i, offsetBy: distance, limitedBy: limit) }
    }
    
    func formIndex(after i: inout Index) {
        queue.sync { self.storage.formIndex(after: &i) }
    }
    
    func distance(from start: Index, to end: Index) -> Int {
        queue.sync { self.storage.distance(from: start, to: end) }
    }
    
    func index(after i: Index) -> Index {
        queue.sync { self.storage.index(after: i) }
    }
    
    var startIndex: Index {
        queue.sync { self.storage.startIndex }
    }
    
    var endIndex: Index {
        queue.sync { self.storage.endIndex }
    }
    
    var count: Int {
        queue.sync { self.storage.count }
    }
    
    func firstIndex(of element: Element) -> Index? where Element: Equatable {
        queue.sync { self.storage.firstIndex(of: element) }
    }
    
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        try queue.sync { try self.storage.firstIndex(where: predicate) }
    }
    
    var first: Element? {
        queue.sync { self.storage.first }
    }
    
    var isEmpty: Bool {
        queue.sync { self.storage.isEmpty }
    }
    
    subscript(index: Index) -> Element {
        get { queue.sync { self.storage[index] } }
    }
    
    func contains(_ member: Element) -> Bool {
        queue.sync { self.storage.contains(member) }
    }
    
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try queue.sync { try self.storage.contains(where: predicate) }
    }
    
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        queue.sync { self.storage.contains(any: members) }
    }
    
    func contains<S: Sequence<Element>>(all members: S) -> Bool {
        queue.sync { self.storage.contains(all: members) }
    }
    
    func insert(_ element: Element) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.insert(element) }
    }
    
    @_disfavoredOverload
    func insert(_ element: Element, completion: ((_ inserted: Bool, _ memberAfterInsert: Element) -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let insert = self.storage.insert(element)
            DispatchQueue.main.async { completion?(insert.inserted, insert.memberAfterInsert) }
        }
    }
    
    func insert<S: Sequence<Element>>(_ elements: S) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.insert(elements) }
    }
    
    @_disfavoredOverload
    func insert<S: Sequence<Element>>(_ elements: S, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.insert(elements)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func remove(_ element: Element) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.remove(element) }
    }
    
    @_disfavoredOverload
    func remove(_ element: Element, completion: ((Element?) -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let removed = self.storage.remove(element)
            DispatchQueue.main.async { completion?(removed) }
        }
    }
    
    func remove<S: Sequence<Element>>(_ elements: S) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.remove(elements) }
    }
    
    @_disfavoredOverload
    func remove<S: Sequence<Element>>(_ elements: S, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.remove(elements)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func removeAll() {
        queue.async(flags: .barrier) { [weak self] in self?.storage.removeAll() }
    }
    
    func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
        queue.async(flags: .barrier) { [weak self] in  _ = try? self?.storage.removeAll(where: shouldBeRemoved) }
    }
    
    @_disfavoredOverload
    func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool, completion: (() -> ())? = nil) rethrows {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            _ = try? self.storage.removeAll(where: shouldBeRemoved)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func union(_ other: Set<Element>) -> Set<Element> {
        queue.sync { Set(storage.union(other)) }
    }
    
    func formUnion(_ other: Set<Element>) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.formUnion(other) }
    }
    
    @_disfavoredOverload
    func formUnion(_ other: Set<Element>, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.formUnion(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func intersection(_ other: Set<Element>) -> Set<Element> {
        queue.sync { Set(storage.intersection(other)) }
    }
    
    func formIntersection(_ other: Set<Element>) {
        queue.async(flags: .barrier) { [weak self] in  self?.storage.formIntersection(other) }
    }
    
    @_disfavoredOverload
    func formIntersection(_ other: Set<Element>, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.formIntersection(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func symmetricDifference(_ other: Set<Element>) -> Set<Element> {
        queue.sync { Set(storage.symmetricDifference(other)) }
    }
    
    func formSymmetricDifference(_ other: Set<Element>) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.formSymmetricDifference(other) }
    }
    
    @_disfavoredOverload
    func formSymmetricDifference(_ other: Set<Element>, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.formSymmetricDifference(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func subtracting(_ other: Set<Element>) -> Set<Element> {
        queue.sync { Set(storage.subtracting(other)) }
    }
    
    func subtract(_ other: Set<Element>) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.subtract(other) }
    }
    
    @_disfavoredOverload
    func subtract(_ other: Set<Element>, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.storage.subtract(other)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func isSubset(of other: Set<Element>) -> Bool {
        queue.sync { storage.isSubset(of: other) }
    }
    
    func isSuperset(of other: Set<Element>) -> Bool {
        queue.sync { storage.isSuperset(of: other) }
    }
    
    func isStrictSubset(of other: Set<Element>) -> Bool {
        queue.sync { storage.isStrictSubset(of: other) }
    }
    
    func isStrictSuperset(of other: Set<Element>) -> Bool {
        queue.sync { storage.isStrictSuperset(of: other) }
    }
    
    func isDisjoint(with other: Set<Element>) -> Bool {
        queue.sync { storage.isDisjoint(with: other) }
    }
    
    func update(with newMember: Element) {
        queue.async(flags: .barrier) { [weak self] in self?.storage.update(with: newMember) }
    }
    
    @_disfavoredOverload
    func update(with newMember: Element, completion: ((Element?) -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let update = self.storage.update(with: newMember)
            DispatchQueue.main.async { completion?(update) }
        }
    }
    
    subscript(_ element: Element) -> Bool {
        get { queue.sync { storage.contains(element) } }
        set {
            queue.async(flags: .barrier) { [weak self] in
                if newValue {
                    self?.insert(element)
                } else {
                    self?.remove(element)
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
        queue.sync { self.storage.first(where: predicate) }
    }

    /**
     Returns a set containing, in order, the elements of the sequence that satisfy the given predicate.
     
     - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned set.
     - Returns: A set of the elements that includeElement allowed.
     */
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        queue.sync { self.storage.filter(isIncluded) }
    }

    /**
     Returns the first index in which an element of the collection satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: The index of the first element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    func firstIndex(where predicate: (Element) -> Bool) -> Index? {
        queue.sync { self.storage.firstIndex(where: predicate) }
    }

    /**
     Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
     - Returns: A sorted set of the collection’s elements.
     */
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        queue.sync { self.storage.sorted(by: areInIncreasingOrder) }
    }

    /**
     A set of the elements sorted by the given keypath.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value : Comparable {
        queue.sync { self.storage.sorted(by: keyPath, order) }
    }

    /**
     A set of the elements sorted by the given keypath.
     */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value : Comparable {
        queue.sync { self.storage.sorted(by: keyPath, order) }
    }

    /**
     Returns a set containing the results of mapping the given closure over the sequence’s elements.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: A set of the non-`nil` results of calling transform with each element of the sequence.
     */
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        queue.sync { self.storage.map(transform) }
    }

    /**
     Returns a set containing the non-`nil` results of calling the given transformation with each element of this sequence.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: A set of the non-`nil` results of calling transform with each element of the sequence.
     */
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        queue.sync { self.storage.compactMap(transform) }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value. initialResult is passed to nextPartialResult the first time the closure is executed.
       - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: @escaping (ElementOfResult, Element) -> ElementOfResult) -> ElementOfResult {
        queue.sync { self.storage.reduce(initialResult, nextPartialResult) }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value.
       - updateAccumulatingResult: A closure that updates the accumulating value with an element of the sequence.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: @escaping (inout ElementOfResult, Element) -> Void) -> ElementOfResult {
        queue.sync { self.storage.reduce(into: initialResult, updateAccumulatingResult) }
    }

    /**
     Calls the given closure on each element in the sequence in the same order as a for-in loop.
     
     - Parameter body: A closure that takes an element of the sequence as a parameter.
     */
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.storage.forEach(body) }
    }

    /**
     Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
     */
    func contains(where predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.storage.contains(where: predicate) }
    }

    /**
     Returns a Boolean value indicating whether every element of a sequence satisfies a given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element satisfies a condition.
     - Returns: true if the sequence contains only elements that satisfy predicate; otherwise, false.
     */
    func allSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.storage.allSatisfy(predicate) }
    }
    
    /// Returns a sequence of pairs (n, x), where n represents a consecutive integer starting at zero and x represents an element of the sequence.
    func enumerated() -> EnumeratedSequence<Set<Element>> {
        queue.sync { self.storage.enumerated() }
    }
    
    func count<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int where E : Error {
        do {
            return try queue.sync { try self.storage.count(where: predicate) }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Unexpected error type: \(error)")
        }
    }
    
    /// Returns the elements of the sequence, shuffled.
    func shuffled() -> [Element] {
        queue.sync {  self.storage.shuffled() }
    }
    
    /// Returns an set containing the elements of this set in reverse order.
    func reversed() -> [Element] {
        queue.sync {  self.storage.reversed() }
    }
    
    func randomElement() -> Element? {
        queue.sync { self.storage.randomElement() }
    }

    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        queue.sync { self.storage.randomElement(using: &generator) }
    }
    
    static func == (lhs: SynchronizedSet<Element>, rhs: SynchronizedSet<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

public extension SynchronizedSet where Element: Comparable {
    /// Returns the elements of the sequence, sorted.
    func sorted() -> [Element] {
        queue.sync {  self.storage.sorted() }
    }
    
    func min() -> Element? {
        queue.sync { self.storage.min() }
    }
    
    func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try queue.sync { try self.storage.min(by: areInIncreasingOrder)}
    }
    
    func max() -> Element? {
        queue.sync { self.storage.max() }
    }
    
    func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try queue.sync { try self.storage.max(by: areInIncreasingOrder)}
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

extension SynchronizedSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: synchronized)
    }
}

extension SynchronizedSet: Decodable where Element: Decodable { }

extension SynchronizedSet: CVarArg {
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}
