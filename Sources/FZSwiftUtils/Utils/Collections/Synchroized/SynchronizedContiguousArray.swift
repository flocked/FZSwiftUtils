//
//  SynchronizedContiguousArray.swift
//
//  Parts taken from:
//  Created by Sherzod Khashimov on 10/4/19.
//  Copyright © 2019 Sherzod Khashimov. All rights reserved.
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation

/// A thread-safe, synchronized contiguously stored array.
public class SynchronizedContiguousArray<Element>: BidirectionalCollection, RandomAccessCollection, RangeReplaceableCollection, MutableCollection, ExpressibleByArrayLiteral {
    private let storage: SynchronizedStorage<ContiguousArray<Element>>

    /// Creates a new, empty synchronized contiguously stored array.
    public required init() {
        storage = SynchronizedStorage([])
    }

    /// Creates a new, empty synchronized contiguously stored array using the specified synchronization mechanism.
    public init(usingMutex: Bool = false) {
        storage = SynchronizedStorage([], usingMutex: usingMutex)
    }

    /// Creates a synchronized contiguously array from the specified array.
    public init(_ array: ContiguousArray<Element>, usingMutex: Bool = false) {
        storage = SynchronizedStorage(array, usingMutex: usingMutex)
    }
    
    /**
     Creates an synchronized contiguously stored array containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into an array.
     */
    public required init<S>(_ elements: S) where S : Sequence<Element> {
        storage = SynchronizedStorage(ContiguousArray(elements))
    }

    /// Creates a synchronized contiguously stored array containing the elements of a sequence using the specified synchronization mechanism.
    public init<S>(_ elements: S, usingMutex: Bool) where S: Sequence<Element> {
        storage = SynchronizedStorage(ContiguousArray(elements), usingMutex: usingMutex)
    }
    
    /**
     Creates a new synchronized contiguously stored array containing the specified number of a single, repeated value.

     - Parameters:
        - repeatedValue: The element to repeat.
        - count: The number of times to repeat the value passed in the repeating parameter. count must be zero or greater.
     */
    public required init(repeating repeatedValue: Element, count: Int) {
        storage = SynchronizedStorage(ContiguousArray(repeating: repeatedValue, count: count))
    }

    /// Creates a new synchronized contiguously stored array using the specified synchronization mechanism.
    public init(repeating repeatedValue: Element, count: Int, usingMutex: Bool) {
        storage = SynchronizedStorage(ContiguousArray(repeating: repeatedValue, count: count), usingMutex: usingMutex)
    }

    /**
     Creates a new synchronized contiguously stored array from a array literal with the elements.

     - Parameter elements: The elements to turn into an array.
     */
    public required init(arrayLiteral elements: Element...) {
        storage = SynchronizedStorage(ContiguousArray(elements))
    }
    
    /// Creates a new synchronized contiguous array by decoding from the given decoder.
    public required init(from decoder: Decoder) throws where Element: Decodable {
        storage = SynchronizedStorage(try ContiguousArray(from: decoder))
    }
}

public extension SynchronizedContiguousArray {
    /**
     A thread-safe array containing the current elements.
     
     Access is synchronized for both reads and writes.
     */
    var synchronized: ContiguousArray<Element> {
        get { storage.read { $0 } }
        set { storage.write { $0 = newValue } }
    }
    
    /**
     Performs the given closure on the array, allowing in-place modification.
     
     The closure is executed while holding exclusive access to the storage.
     
     - Parameter edit: A closure that takes an `inout` array of elements.
     */
    func edit(_ edit: (inout ContiguousArray<Element>) throws -> Void) rethrows {
        try storage.write(edit)
    }
    
    /**
     Returns the index that is the specified distance from the given index.
     
     - Parameters:
       - i: A valid index of the array.
       - distance: The distance to offset the index.
     - Returns: The index offset by the specified distance.
     */
    func index(_ i: Int, offsetBy distance: Int) -> Int {
        storage.read { $0.index(i, offsetBy: distance) }
    }
    
    /**
     Returns the index that is the specified distance from the given index, unless that distance is beyond a given limiting index.
     
     - Parameters:
       - i: A valid index of the array.
       - distance: The distance to offset the index.
       - limit: The limiting index.
     - Returns: The index offset by the specified distance, or `nil` if the limit is reached.
     */
    func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        storage.read { $0.index(i, offsetBy: distance, limitedBy: limit) }
    }
    
    /**
     Increments the given index to the next consecutive index.
     
     - Parameter i: The index to be incremented.
     */
    func formIndex(after i: inout Int) {
        storage.read { $0.formIndex(after: &i) }
    }
    
    /**
     Decrements the given index to the previous consecutive index.
     
     - Parameter i: The index to be decremented.
     */
    func formIndex(before i: inout Int) {
        storage.read { $0.formIndex(before: &i) }
    }
    
    /**
     Returns the distance between two indices.
     
     - Parameters:
       - start: The starting index.
       - end: The ending index.
     - Returns: The distance between `start` and `end`.
     */
    func distance(from start: Int, to end: Int) -> Int {
        storage.read { $0.distance(from: start, to: end) }
    }
    
    /**
     Returns the index immediately before the given index.
     
     - Parameter i: A valid index of the array.
     - Returns: The index before `i`.
     */
    func index(before i: Int) -> Int {
        storage.read { $0.index(before: i) }
    }
    
    /**
     Returns the index immediately after the given index.
     
     - Parameter i: A valid index of the array.
     - Returns: The index after `i`.
     */
    func index(after i: Int) -> Int {
        storage.read { $0.index(after: i) }
    }
    
    /**
     The position of the first element in the array.
     */
    var startIndex: Int {
        storage.read { $0.startIndex }
    }
    
    /**
     The array's "past the end" position—that is, the position one greater than the last valid subscript argument.
     */
    var endIndex: Int {
        storage.read { $0.endIndex }
    }
    
    /**
     The number of elements in the array.
     */
    var count: Int {
        storage.read { $0.count }
    }
    
    /**
     Returns the first index where the specified element appears in the array.
     
     - Parameter element: An element to find in the array.
     - Returns: The first index where `element` appears, or `nil` if `element` is not found.
     */
    func firstIndex(of element: Element) -> Int? where Element: Equatable {
        storage.read { $0.firstIndex(of: element) }
    }
    
    /**
     Returns the first index where the specified predicate returns `true`.
     
     - Parameter predicate: A closure that takes an element of the array as its argument and returns a Boolean value.
     - Returns: The first index where `predicate` returns `true`, or `nil` if no element satisfies `predicate`.
     */
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try storage.read { try $0.firstIndex(where: predicate) }
    }
    
    /**
     Returns the last index where the specified element appears in the array.
     
     - Parameter element: An element to find in the array.
     - Returns: The last index where `element` appears, or `nil` if `element` is not found.
     */
    func lastIndex(of element: Element) -> Int? where Element: Equatable {
        storage.read { $0.lastIndex(of: element) }
    }
    
    /**
     Returns the last index where the specified predicate returns `true`.
     
     - Parameter predicate: A closure that takes an element of the array as its argument and returns a Boolean value.
     - Returns: The last index where `predicate` returns `true`, or `nil` if no element satisfies `predicate`.
     */
    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try storage.read { try $0.lastIndex(where: predicate) }
    }
    
    /**
     The first element of the array, or `nil` if the array is empty.
     */
    var first: Element? {
        storage.read { $0.first }
    }
    
    /**
     The last element of the array, or `nil` if the array is empty.
     */
    var last: Element? {
        storage.read { $0.last }
    }
    
    /**
     A Boolean value indicating whether the array has no elements.
     */
    var isEmpty: Bool {
        storage.read { $0.isEmpty }
    }
    
    /**
     Accesses the element at the specified position.
     
     - Parameter index: The position of the element to access.
     */
    subscript(index: Int) -> Element {
        get { storage.read { $0[index] } }
        set { storage.write { $0[index] = newValue } }
    }
    
    /**
     Accesses a contiguous subrange of elements.
     
     - Parameter range: The range of elements to access.
     */
    subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { storage.read { $0[range] } }
        set { storage.write { $0[range] = newValue } }
    }
    
    /**
     Accesses a contiguous subrange of elements.
     
     - Parameter range: The range of elements to access.
     */
    subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { storage.read { $0[range] } }
        set { storage.write { $0[range] = newValue } }
    }
    
    /**
     Appends a new element at the end of the array.
     
     - Parameter element: The element to append.
     */
    func append(_ element: Element) {
        storage.write { $0.append(element) }
    }
    
    /**
     Appends a new element at the end of the array and optionally executes a completion closure.
     
     - Parameters:
       - element: The element to append.
       - completion: An optional closure executed on the main queue after the append.
     */
    @_disfavoredOverload
    func append(_ element: Element, completion: (() -> ())? = nil) {
        storage.write {
            $0.append(element)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /**
     Appends the elements of a sequence at the end of the array.
     
     - Parameter elements: A sequence of elements to append.
     */
    func append<S>(contentsOf elements: S) where S: Sequence<Element> {
        storage.write { $0.append(contentsOf: elements) }
    }

    /**
     Appends the elements of a sequence at the end of the array and optionally executes a completion closure.
     
     - Parameters:
       - elements: A sequence of elements to append.
       - completion: An optional closure executed on the main queue after the append.
     */
    @_disfavoredOverload
    func append<S>(contentsOf elements: S, completion: (() -> ())? = nil) where S: Sequence<Element> {
        storage.write {
            $0 += elements
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /**
     Inserts a new element at the specified index.
     
     - Parameters:
       - element: The element to insert.
       - index: The position at which to insert the new element. `index` must be a valid index of the array or equal to `endIndex`.
     */
    func insert(_ element: Element, at index: Int) {
        storage.write { $0.insert(element, at: index) }
    }

    /**
     Inserts a new element at the specified index and optionally executes a completion closure.
     
     - Parameters:
       - element: The element to insert.
       - index: The position at which to insert the new element. `index` must be a valid index of the array or equal to `endIndex`.
       - completion: An optional closure executed on the main queue after the insertion.
     */
    @_disfavoredOverload
    func insert(_ element: Element, at index: Int, completion: (() -> ())? = nil) {
        storage.write {
            $0.insert(element, at: index)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Inserts the elements of a collection at the specified index.
     
     - Parameters:
       - newElements: The elements to insert.
       - index: The position at which to insert the new elements. `index` must be a valid index of the array or equal to `endIndex`.
     */
    func insert<C>(contentsOf newElements: C, at index: Int) where C: Collection<Element> {
        storage.write { $0.insert(contentsOf: newElements, at: index) }
    }

    /**
     Inserts the elements of a collection at the specified index and optionally executes a completion closure.
     
     - Parameters:
       - newElements: The elements to insert.
       - index: The position at which to insert the new elements. `index` must be a valid index of the array or equal to `endIndex`.
       - completion: An optional closure executed on the main queue after the insertion.
     */
    @_disfavoredOverload
    func insert<C>(contentsOf newElements: C, at index: Int, completion: (() -> ())? = nil) where C: Collection<Element> {
        storage.write {
            $0.insert(contentsOf: newElements, at: index)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes and returns the element at the specified position.
     
     - Parameters:
       - index: The position of the element to remove. `index` must be a valid index of the array.
       - completion: An optional closure executed on the main queue with the removed element.
     */
    func remove(at index: Int, completion: ((_ removed: Element) -> Void)? = nil) {
        storage.write {
            let element = $0.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }

    /**
     Removes the first `k` elements from the array.
     
     - Parameter k: The number of elements to remove.
     */
    func removeFirst(_ k: Int) {
        storage.write { $0.removeFirst(k) }
    }

    /**
     Removes the first `k` elements from the array and optionally executes a completion closure.
     
     - Parameters:
       - k: The number of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeFirst(_ k: Int, completion: (() -> Void)? = nil) {
        storage.write {
            $0.removeFirst(k)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes and returns the first element of the array.
     
     - Parameter completion: An optional closure executed on the main queue with the removed element.
     */
    func removeFirst(completion: ((Element) -> Void)? = nil) {
        storage.write {
            let element = $0.removeFirst()
            DispatchQueue.main.async { completion?(element) }
        }
    }

    /**
     Removes and returns the first element of the array that satisfies the given predicate.
     
     - Parameters:
       - predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be removed.
       - completion: An optional closure executed on the main queue with the removed element, or `nil` if no element was removed.
     */
    func removeFirst(where predicate: @escaping (Element) -> Bool, completion: ((Element?) -> Void)? = nil) {
        storage.write {
            let element = $0.removeFirst(where: predicate)
            DispatchQueue.main.async { completion?(element) }
        }
    }

    /**
     Removes the last `k` elements from the array.
     
     - Parameter k: The number of elements to remove.
     */
    func removeLast(_ k: Int) {
        storage.write { $0.removeLast(k) }
    }

    /**
     Removes the last `k` elements from the array and optionally executes a completion closure.
     
     - Parameters:
       - k: The number of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeLast(_ k: Int, completion: (() -> Void)? = nil) {
        storage.write {
            $0.removeLast(k)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes and returns the last element of the array.
     
     - Parameter completion: An optional closure executed on the main queue with the removed element.
     */
    func removeLast(completion: ((Element) -> Void)? = nil) {
        storage.write {
            let element = $0.removeLast()
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    /**
     Removes the elements at the specified offsets.
     
     - Parameter offsets: The indices of the elements to remove.
     */
    func remove(atOffsets offsets: IndexSet) {
        storage.write { $0.remove(atOffsets: offsets) }
    }

    /**
     Removes the elements at the specified offsets and optionally executes a completion closure.
     
     - Parameters:
       - offsets: The indices of the elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func remove(atOffsets offsets: IndexSet, completion: (() -> Void)? = nil) {
        storage.write {
            $0.remove(atOffsets: offsets)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes the specified elements from the array.
     
     - Parameters:
       - elements: A collection of elements to remove. Elements must be `Equatable`.
       - completion: An optional closure executed on the main queue with the removed elements.
     */
    func remove<C>(_ elements: C, completion: (([Element])->())? = nil) where Element: Equatable, C: Collection<Element> {
        storage.write {
            let removedElements = $0.remove(elements)
            DispatchQueue.main.async { completion?(removedElements) }
        }
    }

    /**
     Removes all elements that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be removed.
     */
    func removeAll(where predicate: @escaping (Element) -> Bool) {
        storage.write { $0.removeAll(where: predicate) }
    }

    /**
     Removes all elements that satisfy the given predicate and optionally executes a completion closure.
     
     - Parameters:
       - predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be removed.
       - completion: An optional closure executed on the main queue after removal.
     */
    func removeAll(where predicate: @escaping (Element) -> Bool, completion: (() -> Void)? = nil) {
        storage.write {
            $0.removeAll(where: predicate)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes all elements from the array.
     */
    func removeAll(keepingCapacity keep: Bool = false) {
        storage.write { $0.removeAll(keepingCapacity: keep) }
    }

    /**
     Removes all elements from the array and optionally executes a completion closure.
     
     - Parameter completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeAll(completion: (() -> Void)? = nil) {
        storage.write {
            $0.removeAll()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes the elements in the specified subrange.
     
     - Parameter bounds: The range of elements to remove.
     */
    func removeSubrange(_ bounds: Range<Index>) {
        storage.write { $0.removeSubrange(bounds) }
    }

    /**
     Removes the elements in the specified subrange and optionally executes a completion closure.
     
     - Parameters:
       - bounds: The range of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeSubrange(_ bounds: Range<Index>, completion: (() -> Void)? = nil) {
        storage.write {
            $0.removeSubrange(bounds)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Replaces the elements in the specified subrange with the given collection of new elements.
     
     - Parameters:
       - subrange: The range of elements to replace.
       - newElements: The elements to insert into the array in place of the specified subrange.
     */
    func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        storage.write { $0.replaceSubrange(subrange, with: newElements) }
    }

    /**
     Replaces the elements in the specified subrange with the given collection of new elements and optionally executes a completion closure.
     
     - Parameters:
       - subrange: The range of elements to replace.
       - newElements: The elements to insert into the array in place of the specified subrange.
       - completion: An optional closure executed on the main queue after replacement.
     */
    @_disfavoredOverload
    func replaceSubrange<C, R>(_ subrange: R, with newElements: C, completion: (() -> Void)? = nil)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound {
        storage.write {
            $0.replaceSubrange(subrange, with: newElements)
            DispatchQueue.main.async { completion?() }
        }
    }
}

public extension SynchronizedContiguousArray {
    /**
     Appends a new element to the array.
     
     - Parameters:
        - lhs: The $0 to append to.
        - rhs: The element to append to the array.
     */
    static func += (lhs: inout SynchronizedContiguousArray, rhs: Element) {
        lhs.append(rhs)
    }
    
    /**
     Appends the elements of a sequence to the array.
     
     - Parameters:
        - lhs: The $0 to append to.
        - rhs: A collection or finite sequence.
     */
    static func += <S: Sequence<Element>>(lhs: inout SynchronizedContiguousArray, rhs: S) {
        lhs.append(contentsOf: rhs)
    }
}

public extension SynchronizedContiguousArray {
    /**
     Returns the first element of the sequence that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     - Returns: The first element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
     */
    func first(where predicate: (Element) -> Bool) -> Element? {
        storage.read { $0.first(where: predicate) }
    }

    /**
     Returns the last element of the sequence that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     - Returns: The last element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
     */
    func last(where predicate: (Element) -> Bool) -> Element? {
        storage.read { $0.last(where: predicate) }
    }

    /**
     Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
     
     - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned $0.
     - Returns: An $0 of the elements that includeElement allowed.
     */
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        storage.read { $0.filter(isIncluded) }
    }

    /**
     Returns the first index in which an element of the collection satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: The index of the first element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        storage.read { $0.firstIndex(where: predicate) }
    }

    /**
     Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
     - Returns: A sorted $0 of the collection’s elements.
     */
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        storage.read { $0.sorted(by: areInIncreasingOrder) }
    }
    
    /// An $0 of the elements sorted by the given keypath.
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) -> [Element] where Value : Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }
    
    /// An $0 of the elements sorted by the given keypath.
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) -> [Element] where Value : Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }

    /**
     Returns an array containing the results of mapping the given closure over the sequence’s elements.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: An $0 of the non-`nil` results of calling transform with each element of the sequence.
     */
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        storage.read { $0.map(transform) }
    }

    /**
     Returns an array containing the non-`nil` results of calling the given transformation with each element of this sequence.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: An $0 of the non-`nil` results of calling transform with each element of the sequence.
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
    func enumerated() -> EnumeratedSequence<ContiguousArray<Element>> {
        storage.read { $0.enumerated() }
    }
    
    /**
     Exchanges the values at the specified indices of the collection.
     
     - Parameters:
        - i: The index of the first value to swap.
        - j: The index of the second value to swap.
     */
    func swapAt(i: Index, j: Index) {
        storage.write { $0.swapAt(i, j) }
    }
    
    /**
     Returns the number of elements that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be counted.
     - Throws: Rethrows any error thrown by the predicate.
     - Returns: The number of elements in the array that satisfy the predicate.
     */
    func count<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int where E : Error {
        do {
            return try storage.read { try $0.count(where: predicate) }
        } catch let error as E {
            throw error
        } catch {
            fatalError("Unexpected error type: \(error)")
        }
    }

    /**
     Shuffles the elements of the array in place, using the system's random number generator.
     */
    func shuffle() {
        storage.write { $0.shuffle() }
    }
    
    /**
     Shuffles the elements of the array in place using the system's random number generator and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after the shuffle is complete.
     */
    @_disfavoredOverload
    func shuffle(completion: (() -> Void)? = nil) {
        storage.write {
            $0.shuffle()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements shuffled, using the system's random number generator.
     
     - Returns: A new array with the elements in a random order.
     */
    func shuffled() -> [Element] {
        storage.read { $0.shuffled() }
    }

    /// Reverses the order of the elements of the array in place.
    func reverse() {
        storage.write { $0.reverse() }
    }
    
    /**
     Reverses the order of the elements of the array in place and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after the reversal is complete.
     */
    @_disfavoredOverload
    func reverse(completion: (() -> Void)? = nil) {
        storage.write {
            $0.reverse()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements in reverse order.
     
     - Returns: A new array with the elements in reverse order.
     */
    func reversed() -> [Element] {
        storage.read { $0.reversed() }
    }

    /**
     Returns a random element from the array, or `nil` if the array is empty.
     
     - Returns: A random element, or `nil` if the array is empty.
     */
    func randomElement() -> Element? {
        storage.read { $0.randomElement() }
    }

    /**
     Returns a random element from the array, or `nil` if the array is empty, using the given random number generator.
     
     - Parameter generator: The random number generator to use.
     - Returns: A random element, or `nil` if the array is empty.
     */
    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        storage.read { $0.randomElement(using: &generator) }
    }
    
    /// Reserves enough space to store the specified number of elements.
    func reserveCapacity(_ minimumCapacity: Int) {
        storage.write { $0.reserveCapacity(minimumCapacity) }
    }
}

extension SynchronizedContiguousArray: Equatable where Element: Equatable {
    public func contains(_ element: Element) -> Bool {
        storage.read { $0.contains(element) }
    }
    
    public static func == (lhs: SynchronizedContiguousArray<Element>, rhs: SynchronizedContiguousArray<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

public extension SynchronizedContiguousArray where Element: Comparable {
    /**
     Returns the first index where the specified element appears in the array.
     
     - Parameter element: The element to find.
     - Returns: The first index of the element if it exists in the array; otherwise, `nil`.
     */
    func index(_ element: Element) -> Int? {
        storage.read { $0.firstIndex(where: { $0 == element }) }
    }

    /**
     Sorts the array in place using the `<` operator.
     */
    func sort() {
        storage.write { $0.sort() }
    }

    /**
     Sorts the array in place using the `<` operator and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after sorting.
     */
    @_disfavoredOverload
    func sort(completion: (() -> Void)? = nil) {
        storage.write {
            $0.sort()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements of the array sorted using the `<` operator.
     
     - Returns: A sorted $0.
     */
    func sorted() -> [Element] {
        storage.read { $0.sorted() }
    }

    /**
     Sorts the array in place, using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     */
    func sort(by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool) rethrows {
        storage.write { try? $0.sort(by: areInIncreasingOrder) }
    }

    /**
     Sorts the array in place, using the given predicate as the comparison between elements, and optionally executes a completion closure on the main queue.
     
     - Parameters:
       - areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
       - completion: An optional closure executed on the main queue after sorting.
     */
    @_disfavoredOverload
    func sort(by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool, completion: (() -> Void)? = nil) rethrows {
        storage.write {
            try? $0.sort(by: areInIncreasingOrder)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /*
    /**
     An $0 of the elements sorted by the given keypath.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) -> [Element] where Value: Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }
    
    /**
     An $0 of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) -> [Element] where Value: Comparable {
        storage.read { $0.sorted(by: keyPath, order) }
    }
    */
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    func sort<Value>(by keyPath: KeyPath<Element, Value>, _ order: SortOrder = .ascending) where Value: Comparable {
        storage.write {
            $0.sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
        }
    }
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    func sort<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SortOrder = .ascending) where Value: Comparable {
        storage.write {
            $0.sort(using: KeyPathComparator(keyPath, order: order == .ascending ? .forward : .reverse))
        }
    }
    
    /**
     Sorts the collection using the given comparator to compare elements.
     
     - Parameter comparator: The sort comparator used to compare elements.
     */
    func sort<Comparator>(using comparator: Comparator) where Comparator : SortComparator, Element == Comparator.Compared {
        storage.write { $0.sort(using: comparator) }
    }
    
    /**
     Returns the elements of the sequence, sorted using the given comparator to compare elements.
     
     - Parameter comparator: The comparator to use in ordering elements
     - Returns: An $0 of the elements sorted using `comparator`.
     */
    func sorted<Comparator>(using comparator: Comparator) -> [Element] where Comparator : SortComparator, Element == Comparator.Compared {
        storage.read { $0.sorted(using: comparator) }
    }

    /**
     Returns the minimum element in the array.
     
     - Returns: The minimum element, or `nil` if the array is empty.
     */
    func min() -> Element? {
        storage.read { $0.min() }
    }

    /**
     Returns the minimum element in the array, using the given predicate as the comparison.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     - Returns: The minimum element, or `nil` if the array is empty.
     */
    func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.min(by: areInIncreasingOrder) }
    }

    /**
     Returns the maximum element in the array.
     
     - Returns: The maximum element, or `nil` if the array is empty.
     */
    func max() -> Element? {
        storage.read { $0.max() }
    }

    /**
     Returns the maximum element in the array, using the given predicate as the comparison.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     - Returns: The maximum element, or `nil` if the array is empty.
     */
    func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try storage.read { try $0.max(by: areInIncreasingOrder) }
    }
}

extension SynchronizedContiguousArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(synchronized)
    }
}

extension SynchronizedContiguousArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
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

extension SynchronizedContiguousArray: @unchecked Sendable where Element: Sendable {}

extension SynchronizedContiguousArray: Decodable where Element: Decodable { }
extension SynchronizedContiguousArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        try synchronized.encode(to: encoder)
    }
}
