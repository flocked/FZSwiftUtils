//
//  SynchronizedArray.swift
//
//  Parts taken from:
//  Created by Sherzod Khashimov on 10/4/19.
//  Copyright © 2019 Sherzod Khashimov. All rights reserved.
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

/// A synchronized array.
public class SynchronizedArray<Element>: BidirectionalCollection, RandomAccessCollection, RangeReplaceableCollection, MutableCollection {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedArray", attributes: .concurrent)
    private var array = [Element]()

    public required init(from decoder: Decoder) throws where Element: Decodable {
        var container = try decoder.unkeyedContainer()
        array = try container.decode([Element].self)
    }

    public required init() {}

    public required init(arrayLiteral elements: Element...) {
        array = elements
    }

    public convenience init(_ array: [Element]) {
        self.init()
        self.array = array
    }
}

public extension SynchronizedArray {
    
    var synchronized: [Element] {
        get { queue.sync { self.array } }
        set { queue.async(flags: .barrier) { self.array = newValue } }
    }

    func edit(_ edit: @escaping (inout [Element]) -> Void) {
        queue.async(flags: .barrier) {
            edit(&self.array)
        }
    }

    func index(_ i: Int, offsetBy distance: Int) -> Int {
        queue.sync { self.array.index(i, offsetBy: distance) }
    }

    func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        queue.sync { self.array.index(i, offsetBy: distance, limitedBy: limit) }
    }

    func formIndex(after i: inout Int) {
        queue.sync { self.array.formIndex(after: &i) }
    }

    func formIndex(before i: inout Int) {
        queue.sync { self.array.formIndex(before: &i) }
    }

    func distance(from start: Int, to end: Int) -> Int {
        queue.sync { self.array.distance(from: start, to: end) }
    }

    func index(before i: Int) -> Int {
        queue.sync { array.index(before: i) }
    }

    func index(after i: Int) -> Int {
        queue.sync { array.index(after: i) }
    }

    var startIndex: Int {
        queue.sync { array.startIndex }
    }

    var endIndex: Int {
        queue.sync { array.endIndex }
    }

    var count: Int {
        queue.sync { self.array.count }
    }
    
    func firstIndex(of element: Element) -> Int? where Element: Equatable {
        queue.sync { self.array.firstIndex(of: element) }
    }
    
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try queue.sync { try self.array.firstIndex(where: predicate) }
    }
    
    func lastIndex(of element: Element) -> Int? where Element: Equatable {
        queue.sync { self.array.lastIndex(of: element) }
    }
    
    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try queue.sync { try self.array.lastIndex(where: predicate) }
    }

    var first: Element? {
        queue.sync { self.array.first }
    }

    var last: Element? {
        queue.sync { self.array.last }
    }

    var isEmpty: Bool {
        queue.sync { self.array.isEmpty }
    }

    subscript(index: Int) -> Element {
        get { queue.sync { self.array[index] } }
        set { queue.async(flags: .barrier) { self.array[index] = newValue } }
    }

    subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { queue.sync { self.array[range] } }
        set { queue.async(flags: .barrier) { self.array[range] = newValue } }
    }

    subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { queue.sync { self.array[range] } }
        set { queue.async(flags: .barrier) { self.array[range] = newValue } }
    }
    
    func append(_ element: Element, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) {
            self.array.append(element)
            DispatchQueue.main.async { completion?() }
        }
    }

    func append<S>(contentsOf elements: S, completion: (() -> ())? = nil) where S: Sequence<Element> {
        queue.async(flags: .barrier) {
            self.array += elements
            DispatchQueue.main.async { completion?() }
        }
    }

    func insert(_ element: Element, at index: Int, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func insert<C>(contentsOf newElements: C, at index: Int, completion: (() -> ())? = nil) where C: Collection<Element> {
        queue.async(flags: .barrier) {
            self.array.insert(contentsOf: newElements, at: index)
            DispatchQueue.main.async { completion?() }
        }
    }

    func remove(at index: Int, completion: ((_ removed: Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func removeFirst(_ k: Int, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.array.removeFirst(k)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func removeFirst(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.removeFirst()
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func removeFirst(where predicate: @escaping (Element) -> Bool, completion: ((Element?) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.removeFirst(where: predicate)
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func removeLast(_ k: Int, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.array.removeLast(k)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func removeLast(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.removeLast()
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func remove(atOffsets offsets: IndexSet, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.array.remove(atOffsets: offsets)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func remove<C>(_ elements: C, completion: (([Element])->())? = nil) where Element: Equatable, C: Collection<Element> {
        queue.async(flags: .barrier) {
            let elements = self.array.remove(elements)
            DispatchQueue.main.async { completion?(elements) }
        }
    }

    func removeAll(where predicate: @escaping (Element) -> Bool, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.array.removeAll(where: predicate)
            DispatchQueue.main.async { completion?() }
        }
    }

    func removeAll(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.array.removeAll()
            DispatchQueue.main.async { completion?() }
        }
    }
    
    func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        queue.async(flags: .barrier) {
            self.array.replaceSubrange(subrange, with: newElements)
        }
    }
    
    func replaceSubrange<C, R>(_ subrange: R, with newElements: C, completion: @escaping (() -> Void))
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        queue.async(flags: .barrier) {
            self.array.replaceSubrange(subrange, with: newElements)
            DispatchQueue.main.async { completion() }
        }
    }
}

public extension SynchronizedArray {
    /// Adds a new element at the end of the array.
    ///
    /// - Parameters:
    ///   - left: The collection to append to.
    ///   - right: The element to append to the array.
    static func += (left: inout SynchronizedArray, right: Element) {
        left.append(right)
    }

    /// Adds new elements at the end of the array.
    ///
    /// - Parameters:
    ///   - left: The collection to append to.
    ///   - right: The elements to append to the array.
    static func += (left: inout SynchronizedArray, right: [Element]) {
        left.append(contentsOf: right)
    }
}

public extension SynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
    func first(where predicate: (Element) -> Bool) -> Element? {
        queue.sync { self.array.first(where: predicate) }
    }

    /// Returns the last element of the sequence that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The last element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
    func last(where predicate: (Element) -> Bool) -> Element? {
        queue.sync { self.array.last(where: predicate) }
    }

    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        queue.sync { self.array.filter(isIncluded) }
    }

    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns `true. If no elements in the collection satisfy the given predicate, returns `nil`.
    func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        queue.sync { self.array.firstIndex(where: predicate) }
    }

    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        queue.sync { self.array.sorted(by: areInIncreasingOrder) }
    }
    
    /// An array of the elements sorted by the given keypath.
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value : Comparable {
        queue.sync { self.array.sorted(by: keyPath, order) }
    }
    
    /// An array of the elements sorted by the given keypath.
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value : Comparable {
        queue.sync { self.array.sorted(by: keyPath, order) }
    }

    /// Returns an array containing the results of mapping the given closure over the sequence’s elements.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-`nil` results of calling transform with each element of the sequence.
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        queue.sync { self.array.map(transform) }
    }

    /// Returns an array containing the non-`nil` results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-`nil` results of calling transform with each element of the sequence.
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        queue.sync { self.array.compactMap(transform) }
    }

    /// Returns the result of combining the elements of the sequence using the given closure.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value. initialResult is passed to nextPartialResult the first time the closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: @escaping (ElementOfResult, Element) -> ElementOfResult) -> ElementOfResult {
        queue.sync { self.array.reduce(initialResult, nextPartialResult) }
    }

    /// Returns the result of combining the elements of the sequence using the given closure.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: A closure that updates the accumulating value with an element of the sequence.
    /// - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: @escaping (inout ElementOfResult, Element) -> Void) -> ElementOfResult {
        queue.sync { self.array.reduce(into: initialResult, updateAccumulatingResult) }
    }

    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }

    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    func contains(where predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.array.contains(where: predicate) }
    }

    /// Returns a Boolean value indicating whether every element of a sequence satisfies a given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element satisfies a condition.
    /// - Returns: true if the sequence contains only elements that satisfy predicate; otherwise, false.
    func allSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.array.allSatisfy(predicate) }
    }
}

public extension SynchronizedArray where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        queue.sync { self.array.contains(element) }
    }
}

public extension SynchronizedArray where Element: Comparable {
    func index(_ element: Element) -> Int? {
        queue.sync { self.array.firstIndex(where: { $0 == element }) }
    }
    
    func sorted() {
        queue.async(flags: .barrier) { self.array = self.array.sorted() }
    }
}

extension SynchronizedArray: Equatable where Element: Equatable {
    public static func == (lhs: SynchronizedArray<Element>, rhs: SynchronizedArray<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

extension SynchronizedArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(synchronized)
    }
}

extension SynchronizedArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
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

extension SynchronizedArray: ExpressibleByArrayLiteral {}

extension SynchronizedArray: @unchecked Sendable where Element: Sendable {}

extension SynchronizedArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: synchronized)
    }
}

extension SynchronizedArray: Decodable where Element: Decodable {}

extension SynchronizedArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}
