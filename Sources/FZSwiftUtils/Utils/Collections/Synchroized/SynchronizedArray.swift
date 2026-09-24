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

/// A thread-safe, synchronized array.
public final class SynchronizedArray<Element>: BidirectionalCollection, RandomAccessCollection, RangeReplaceableCollection, MutableCollection, ExpressibleByArrayLiteral {
    private let storage: SynchronizedStorage<[Element]>

    /// Creates a new, empty synchronized array.
    public required init() {
        storage = SynchronizedStorage([], usingMutex: false)
    }

    /// Creates a new, empty synchronized array using the specified synchronization mechanism.
    public init(usingMutex: Bool = false) {
        storage = SynchronizedStorage([], usingMutex: usingMutex)
    }

    /// Creates a synchronized array from the specified array.
    public init(_ elements: [Element], usingMutex: Bool = false) {
        storage = SynchronizedStorage(elements, usingMutex: usingMutex)
    }

    /**
     Creates a synchronized array containing the elements of a sequence.

     - Parameters:
       - elements: The sequence of elements to turn into an array.
       - usingMutex: A Boolean value indicating whether the array uses a mutex for synchronization.
     */
    public required init<S>(_ elements: S) where S: Sequence<Element> {
        storage = SynchronizedStorage(Array(elements), usingMutex: false)
    }

    /// Creates a synchronized array containing the elements of a sequence using the specified synchronization mechanism.
    public init<S>(_ elements: S, usingMutex: Bool) where S: Sequence<Element> {
        storage = SynchronizedStorage(Array(elements), usingMutex: usingMutex)
    }

    /**
     Creates a new synchronized array containing the specified number of a single, repeated value.

     - Parameters:
       - repeatedValue: The element to repeat.
       - count: The number of times to repeat the value.
     */
    public required init(repeating repeatedValue: Element, count: Int) {
        storage = SynchronizedStorage(Array(repeating: repeatedValue, count: count), usingMutex: false)
    }

    /// Creates a new synchronized array containing the specified number of a single, repeated value using the specified synchronization mechanism.
    public init(repeating repeatedValue: Element, count: Int, usingMutex: Bool) {
        storage = SynchronizedStorage(Array(repeating: repeatedValue, count: count), usingMutex: usingMutex)
    }

    /// Creates a new synchronized array from an array literal.
    public required init(arrayLiteral elements: Element...) {
        storage = SynchronizedStorage(elements, usingMutex: false)
    }

    /// Creates a new synchronized array by decoding from the given decoder.
    public required init(from decoder: Decoder) throws where Element: Decodable {
        storage = SynchronizedStorage(try Array(from: decoder), usingMutex: false)
    }
}

public extension SynchronizedArray {
    /// A thread-safe array containing the current elements.
    var synchronized: [Element] {
        get { storage.read { $0 } }
        set { storage.write { $0 = newValue } }
    }

    /// Performs the given closure on the array while holding exclusive access to its storage.
    func edit(_ edit: (inout [Element]) throws -> Void) rethrows {
        try storage.write(edit)
    }

    /// Returns the index that is the specified distance from the given index.
    func index(_ i: Int, offsetBy distance: Int) -> Int {
        storage.read { $0.index(i, offsetBy: distance) }
    }

    /// Returns the index that is the specified distance from the given index, unless that distance is beyond the given limiting index.
    func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        storage.read { $0.index(i, offsetBy: distance, limitedBy: limit) }
    }

    /// Increments the given index to the next consecutive index.
    func formIndex(after i: inout Int) {
        storage.read { $0.formIndex(after: &i) }
    }

    /// Decrements the given index to the previous consecutive index.
    func formIndex(before i: inout Int) {
        storage.read { $0.formIndex(before: &i) }
    }

    /// Returns the distance between two indices.
    func distance(from start: Int, to end: Int) -> Int {
        storage.read { $0.distance(from: start, to: end) }
    }

    /// Returns the index immediately before the given index.
    func index(before i: Int) -> Int {
        storage.read { $0.index(before: i) }
    }

    /// Returns the index immediately after the given index.
    func index(after i: Int) -> Int {
        storage.read { $0.index(after: i) }
    }

    /// The position of the first element in the array.
    var startIndex: Int {
        storage.read { $0.startIndex }
    }

    /// The array's past-the-end position.
    var endIndex: Int {
        storage.read { $0.endIndex }
    }

    /// The number of elements in the array.
    var count: Int {
        storage.read { $0.count }
    }

    /// Returns the first index where the specified element appears in the array.
    func firstIndex(of element: Element) -> Int? where Element: Equatable {
        storage.read { $0.firstIndex(of: element) }
    }

    /// Returns the first index where the specified predicate returns `true`.
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try storage.read { try $0.firstIndex(where: predicate) }
    }

    /// Returns the last index where the specified element appears in the array.
    func lastIndex(of element: Element) -> Int? where Element: Equatable {
        storage.read { $0.lastIndex(of: element) }
    }

    /// Returns the last index where the specified predicate returns `true`.
    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try storage.read { try $0.lastIndex(where: predicate) }
    }

    /// The first element of the array, or `nil` if the array is empty.
    var first: Element? {
        storage.read { $0.first }
    }

    /// The last element of the array, or `nil` if the array is empty.
    var last: Element? {
        storage.read { $0.last }
    }

    /// A Boolean value indicating whether the array has no elements.
    var isEmpty: Bool {
        storage.read { $0.isEmpty }
    }

    /// Accesses the element at the specified position.
    subscript(index: Int) -> Element {
        get { storage.read { $0[index] } }
        set { storage.write { $0[index] = newValue } }
    }

    /// Accesses a contiguous subrange of elements.
    subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { storage.read { $0[range] } }
        set { storage.write { $0[range] = newValue } }
    }

    /// Accesses a contiguous subrange of elements.
    subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { storage.read { $0[range] } }
        set { storage.write { $0[range] = newValue } }
    }

    /// Appends a new element at the end of the array.
    func append(_ element: Element) {
        storage.write { $0.append(element) }
    }

    /// Appends the elements of a sequence at the end of the array.
    func append<S>(contentsOf elements: S) where S: Sequence<Element> {
        storage.write { $0.append(contentsOf: elements) }
    }

    /// Inserts a new element at the specified index.
    func insert(_ element: Element, at index: Int) {
        storage.write { $0.insert(element, at: index) }
    }

    /// Inserts the elements of a collection at the specified index.
    func insert<C>(contentsOf newElements: C, at index: Int) where C: Collection<Element> {
        storage.write { $0.insert(contentsOf: newElements, at: index) }
    }

    /// Removes and returns the element at the specified position.
    @discardableResult
    func remove(at index: Int) -> Element {
        storage.write { $0.remove(at: index) }
    }

    /// Removes the first specified number of elements from the array.
    func removeFirst(_ count: Int) {
        storage.write { $0.removeFirst(count) }
    }

    /// Removes and returns the first element of the array.
    @discardableResult
    func removeFirst() -> Element {
        storage.write { $0.removeFirst() }
    }

    /// Removes and returns the first element that satisfies the given predicate, or `nil` if no element satisfies the predicate.
    @discardableResult
    func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try storage.write { try $0.removeFirst(where: predicate) }
    }

    /// Removes and returns the first element of the array, or `nil` if the array is empty.
    @discardableResult
    func removeFirstSafely() -> Element? {
        storage.write {
            guard !$0.isEmpty else { return nil }
            return $0.removeFirst()
        }
    }

    /// Removes and returns the last element of the array, or `nil` if the array is empty.
    @discardableResult
    func removeLastSafely() -> Element? {
        storage.write { $0.popLast() }
    }

    /// Removes the last specified number of elements from the array.
    func removeLast(_ count: Int) {
        storage.write { $0.removeLast(count) }
    }

    /// Removes and returns the last element of the array.
    @discardableResult
    func removeLast() -> Element {
        storage.write { $0.removeLast() }
    }

    /// Removes the elements at the specified offsets.
    func remove(atOffsets offsets: IndexSet) {
        storage.write { $0.remove(atOffsets: offsets) }
    }

    /// Removes the specified elements from the array and returns the removed elements.
    @discardableResult
    func remove<C>(_ elements: C) -> [Element] where Element: Equatable, C: Collection<Element> {
        storage.write { $0.remove(elements) }
    }

    /// Removes all elements that satisfy the given predicate.
    func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        try storage.write { try $0.removeAll(where: predicate) }
    }

    /// Removes all elements from the array.
    func removeAll(keepingCapacity keep: Bool = false) {
        storage.write { $0.removeAll(keepingCapacity: keep) }
    }

    /// Removes the elements in the specified subrange.
    func removeSubrange(_ bounds: Range<Index>) {
        storage.write { $0.removeSubrange(bounds) }
    }

    /// Replaces the elements in the specified subrange with the given collection of new elements.
    func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        storage.write { $0.replaceSubrange(subrange, with: newElements) }
    }

    /// Reserves enough space to store the specified number of elements.
    func reserveCapacity(_ minimumCapacity: Int) {
        storage.write { $0.reserveCapacity(minimumCapacity) }
    }
}

public extension SynchronizedArray {
    /// Appends a new element to the array.
    static func += (lhs: inout SynchronizedArray, rhs: Element) {
        lhs.append(rhs)
    }

    /// Appends the elements of a sequence to the array.
    static func += <S: Sequence<Element>>(lhs: inout SynchronizedArray, rhs: S) {
        lhs.append(contentsOf: rhs)
    }
}

public extension SynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate.
    func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.first(where: predicate) }
    }

    /// Returns the last element of the sequence that satisfies the given predicate.
    func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.last(where: predicate) }
    }

    /// Returns an array containing the elements that satisfy the given predicate.
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try storage.read { try $0.filter(isIncluded) }
    }

    /// Returns the elements of the collection sorted using the given predicate.
    func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        try storage.read { try $0.sorted(by: areInIncreasingOrder) }
    }

    /// Returns an array of the elements sorted by the given key path.
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) -> [Element] where Value: Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }

    /// Returns an array of the elements sorted by the given optional key path.
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) -> [Element] where Value: Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }

    /// Returns an array containing the results of mapping the given closure over the sequence's elements.
    func map<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult) rethrows -> [ElementOfResult] {
        try storage.read { try $0.map(transform) }
    }

    /// Returns an array containing the non-`nil` results of mapping the given closure over the sequence's elements.
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try storage.read { try $0.compactMap(transform) }
    }

    /// Returns the result of combining the elements of the sequence using the given closure.
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: (ElementOfResult, Element) throws -> ElementOfResult) rethrows -> ElementOfResult {
        try storage.read { try $0.reduce(initialResult, nextPartialResult) }
    }

    /// Returns the result of combining the elements of the sequence into the given initial result.
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: (inout ElementOfResult, Element) throws -> Void) rethrows -> ElementOfResult {
        try storage.read { try $0.reduce(into: initialResult, updateAccumulatingResult) }
    }

    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.read { try $0.forEach(body) }
    }

    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try storage.read { try $0.contains(where: predicate) }
    }

    /// Returns a Boolean value indicating whether every element of the sequence satisfies the given predicate.
    func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try storage.read { try $0.allSatisfy(predicate) }
    }

    /// Returns a sequence of pairs containing each element and its corresponding offset.
    func enumerated() -> EnumeratedSequence<Array<Element>> {
        storage.read { $0.enumerated() }
    }

    /// Exchanges the values at the specified indices of the collection.
    func swapAt(i: Index, j: Index) {
        storage.write { $0.swapAt(i, j) }
    }

    /// Returns the number of elements that satisfy the given predicate.
    func count<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int where E: Error {
        do {
            return try storage.read { try $0.count(where: predicate) }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Unexpected error type: \(error)")
        }
    }

    /// Shuffles the elements of the array in place.
    func shuffle() {
        storage.write { $0.shuffle() }
    }

    /// Returns a new array with the elements shuffled.
    func shuffled() -> [Element] {
        storage.read { $0.shuffled() }
    }

    /// Reverses the order of the elements of the array in place.
    func reverse() {
        storage.write { $0.reverse() }
    }

    /// Returns a new array with the elements in reverse order.
    func reversed() -> [Element] {
        storage.read { Array($0.reversed()) }
    }

    /// Returns a random element from the array, or `nil` if the array is empty.
    func randomElement() -> Element? {
        storage.read { $0.randomElement() }
    }

    /// Returns a random element from the array using the given random number generator, or `nil` if the array is empty.
    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        storage.read { $0.randomElement(using: &generator) }
    }
}

extension SynchronizedArray: Equatable where Element: Equatable {
    /// Returns a Boolean value indicating whether the array contains the specified element.
    public func contains(_ element: Element) -> Bool {
        storage.read { $0.contains(element) }
    }

    /// Returns a Boolean value indicating whether two synchronized arrays contain the same elements in the same order.
    public static func == (lhs: SynchronizedArray<Element>, rhs: SynchronizedArray<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

public extension SynchronizedArray where Element: Comparable {
    /// Returns the first index where the specified element appears in the array.
    func index(_ element: Element) -> Int? {
        storage.read { $0.firstIndex(of: element) }
    }

    /// Sorts the array in place using the `<` operator.
    func sort() {
        storage.write { $0.sort() }
    }

    /// Returns a new array with the elements sorted using the `<` operator.
    func sorted() -> [Element] {
        storage.read { $0.sorted() }
    }

    /// Sorts the array in place using the given predicate as the comparison between elements.
    func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
        try storage.write { try $0.sort(by: areInIncreasingOrder) }
    }

    /// Sorts the collection by the given key path.
    func sort<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) where Value: Comparable {
        storage.write { $0.sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse)) }
    }

    /// Sorts the collection by the given optional key path.
    func sort<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) where Value: Comparable {
        storage.write { $0.sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse)) }
    }

    /// Sorts the collection using the given comparator.
    func sort<Comparator>(using comparator: Comparator) where Comparator: SortComparator, Element == Comparator.Compared {
        storage.write { $0.sort(using: comparator) }
    }

    /// Returns the elements of the sequence sorted using the given comparator.
    func sorted<Comparator>(using comparator: Comparator) -> [Element] where Comparator: SortComparator, Element == Comparator.Compared {
        storage.read { $0.sorted(using: comparator) }
    }

    /// Returns the minimum element in the array.
    func min() -> Element? {
        storage.read { $0.min() }
    }

    /// Returns the minimum element in the array using the given predicate as the comparison.
    func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.min(by: areInIncreasingOrder) }
    }

    /// Returns the maximum element in the array.
    func max() -> Element? {
        storage.read { $0.max() }
    }

    /// Returns the maximum element in the array using the given predicate as the comparison.
    func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.max(by: areInIncreasingOrder) }
    }
}

extension SynchronizedArray: Hashable where Element: Hashable {
    /// Hashes the essential components of the array by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(synchronized)
    }
}

extension SynchronizedArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A mirror that reflects the underlying array.
    public var customMirror: Mirror {
        synchronized.customMirror
    }

    /// A textual representation of the array suitable for debugging.
    public var debugDescription: String {
        synchronized.debugDescription
    }

    /// A textual representation of the array.
    public var description: String {
        synchronized.description
    }
}

extension SynchronizedArray: @unchecked Sendable where Element: Sendable {}

extension SynchronizedArray: Decodable where Element: Decodable {}

extension SynchronizedArray: Encodable where Element: Encodable {
    /// Encodes the array into the given encoder.
    public func encode(to encoder: Encoder) throws {
        try synchronized.encode(to: encoder)
    }
}

extension SynchronizedArray: CVarArg {
    /// The array's C variable argument encoding.
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}

extension SynchronizedArray: _ObjectiveCBridgeable {
    /// Bridges the synchronized array to an Objective-C array.
    public func _bridgeToObjectiveC() -> NSArray {
        synchronized._bridgeToObjectiveC()
    }

    /// Forcefully bridges the specified Objective-C array to a synchronized array.
    public static func _forceBridgeFromObjectiveC(_ source: NSArray, result: inout SynchronizedArray?) {
        var array: [Element]?
        [Element]._forceBridgeFromObjectiveC(source, result: &array)
        result = array.map { .init($0) }
    }

    /// Conditionally bridges the specified Objective-C array to a synchronized array.
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSArray, result: inout SynchronizedArray?) -> Bool {
        var array: [Element]?
        guard [Element]._conditionallyBridgeFromObjectiveC(source, result: &array), let array else {
            result = nil
            return false
        }
        result = .init(array)
        return true
    }

    /// Unconditionally bridges the specified Objective-C array to a synchronized array.
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSArray?) -> SynchronizedArray {
        .init([Element]._unconditionallyBridgeFromObjectiveC(source))
    }
}
