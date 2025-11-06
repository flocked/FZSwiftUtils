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
public class SynchronizedArray<Element>: BidirectionalCollection, RandomAccessCollection, RangeReplaceableCollection, MutableCollection, ExpressibleByArrayLiteral {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedArray", attributes: .concurrent)
    private var array = [Element]()

    /// Creates a new, empty synchronized array.
    public required init() {}
    
    /**
     Creates an synchronized array containing the elements of a sequence.
     
     - Parameter elements: The sequence of elements to turn into an array.
     */
    public required init<S>(_ elements: S) where S : Sequence<Element> {
        array = Array(elements)
    }
    
    /**
     Creates a new synchronized array containing the specified number of a single, repeated value.

     - Parameters:
        - repeatedValue: The element to repeat.
        - count: The number of times to repeat the value passed in the repeating parameter. count must be zero or greater.
     */
    public required init(epeating repeatedValue: Element,  count: Int) {
        array = Array(repeating: repeatedValue, count: count)
    }

    /**
     Creates a new synchronized array from a array literal with the elements.

     - Parameter elements: The elements to turn into an array.
     */
    public required init(arrayLiteral elements: Element...) {
        array = elements
    }
    
    public required init(from decoder: Decoder) throws where Element: Decodable {
        var container = try decoder.unkeyedContainer()
        array = try container.decode([Element].self)
    }
}

public extension SynchronizedArray {
    /**
     A thread-safe array containing the current elements.
     
     You can get the array synchronously or set it asynchronously using a barrier to ensure exclusive access.
     */
    var synchronized: [Element] {
        get { queue.sync { self.array } }
        set { queue.async(flags: .barrier) { [weak self] in self?.array = newValue } }
    }
    
    /**
     Performs the given closure on the array, allowing in-place modification.
     
     The closure is executed asynchronously with a barrier to ensure thread safety.
     
     - Parameter edit: A closure that takes an `inout` array of elements.
     */
    func edit(_ edit: @escaping (inout [Element]) -> Void) {
        queue.async(flags: .barrier) { edit(&self.array) }
    }
    
    /**
     Returns the index that is the specified distance from the given index.
     
     - Parameters:
       - i: A valid index of the array.
       - distance: The distance to offset the index.
     - Returns: The index offset by the specified distance.
     */
    func index(_ i: Int, offsetBy distance: Int) -> Int {
        queue.sync { self.array.index(i, offsetBy: distance) }
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
        queue.sync { self.array.index(i, offsetBy: distance, limitedBy: limit) }
    }
    
    /**
     Increments the given index to the next consecutive index.
     
     - Parameter i: The index to be incremented.
     */
    func formIndex(after i: inout Int) {
        queue.sync { self.array.formIndex(after: &i) }
    }
    
    /**
     Decrements the given index to the previous consecutive index.
     
     - Parameter i: The index to be decremented.
     */
    func formIndex(before i: inout Int) {
        queue.sync { self.array.formIndex(before: &i) }
    }
    
    /**
     Returns the distance between two indices.
     
     - Parameters:
       - start: The starting index.
       - end: The ending index.
     - Returns: The distance between `start` and `end`.
     */
    func distance(from start: Int, to end: Int) -> Int {
        queue.sync { self.array.distance(from: start, to: end) }
    }
    
    /**
     Returns the index immediately before the given index.
     
     - Parameter i: A valid index of the array.
     - Returns: The index before `i`.
     */
    func index(before i: Int) -> Int {
        queue.sync { array.index(before: i) }
    }
    
    /**
     Returns the index immediately after the given index.
     
     - Parameter i: A valid index of the array.
     - Returns: The index after `i`.
     */
    func index(after i: Int) -> Int {
        queue.sync { array.index(after: i) }
    }
    
    /**
     The position of the first element in the array.
     */
    var startIndex: Int {
        queue.sync { array.startIndex }
    }
    
    /**
     The array's "past the end" position—that is, the position one greater than the last valid subscript argument.
     */
    var endIndex: Int {
        queue.sync { array.endIndex }
    }
    
    /**
     The number of elements in the array.
     */
    var count: Int {
        queue.sync { self.array.count }
    }
    
    /**
     Returns the first index where the specified element appears in the array.
     
     - Parameter element: An element to find in the array.
     - Returns: The first index where `element` appears, or `nil` if `element` is not found.
     */
    func firstIndex(of element: Element) -> Int? where Element: Equatable {
        queue.sync { self.array.firstIndex(of: element) }
    }
    
    /**
     Returns the first index where the specified predicate returns `true`.
     
     - Parameter predicate: A closure that takes an element of the array as its argument and returns a Boolean value.
     - Returns: The first index where `predicate` returns `true`, or `nil` if no element satisfies `predicate`.
     */
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try queue.sync { try self.array.firstIndex(where: predicate) }
    }
    
    /**
     Returns the last index where the specified element appears in the array.
     
     - Parameter element: An element to find in the array.
     - Returns: The last index where `element` appears, or `nil` if `element` is not found.
     */
    func lastIndex(of element: Element) -> Int? where Element: Equatable {
        queue.sync { self.array.lastIndex(of: element) }
    }
    
    /**
     Returns the last index where the specified predicate returns `true`.
     
     - Parameter predicate: A closure that takes an element of the array as its argument and returns a Boolean value.
     - Returns: The last index where `predicate` returns `true`, or `nil` if no element satisfies `predicate`.
     */
    func lastIndex(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        try queue.sync { try self.array.lastIndex(where: predicate) }
    }
    
    /**
     The first element of the array, or `nil` if the array is empty.
     */
    var first: Element? {
        queue.sync { self.array.first }
    }
    
    /**
     The last element of the array, or `nil` if the array is empty.
     */
    var last: Element? {
        queue.sync { self.array.last }
    }
    
    /**
     A Boolean value indicating whether the array has no elements.
     */
    var isEmpty: Bool {
        queue.sync { self.array.isEmpty }
    }
    
    /**
     Accesses the element at the specified position.
     
     - Parameter index: The position of the element to access.
     */
    subscript(index: Int) -> Element {
        get { queue.sync { self.array[index] } }
        set { queue.async(flags: .barrier) { [weak self] in self?.array[index] = newValue } }
    }
    
    /**
     Accesses a contiguous subrange of elements.
     
     - Parameter range: The range of elements to access.
     */
    subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { queue.sync { self.array[range] } }
        set { queue.async(flags: .barrier) { [weak self] in self?.array[range] = newValue } }
    }
    
    /**
     Accesses a contiguous subrange of elements.
     
     - Parameter range: The range of elements to access.
     */
    subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { queue.sync { self.array[range] } }
        set { queue.async(flags: .barrier) { [weak self] in self?.array[range] = newValue } }
    }
    
    /**
     Appends a new element at the end of the array.
     
     - Parameter element: The element to append.
     */
    func append(_ element: Element) {
        queue.async(flags: .barrier) { [weak self] in self?.array.append(element) }
    }
    
    /**
     Appends a new element at the end of the array and optionally executes a completion closure.
     
     - Parameters:
       - element: The element to append.
       - completion: An optional closure executed on the main queue after the append.
     */
    @_disfavoredOverload
    func append(_ element: Element, completion: (() -> ())? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.append(element)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /**
     Appends the elements of a sequence at the end of the array.
     
     - Parameter elements: A sequence of elements to append.
     */
    func append<S>(contentsOf elements: S) where S: Sequence<Element> {
        queue.async(flags: .barrier) { [weak self] in self?.array.append(contentsOf: elements) }
    }

    /**
     Appends the elements of a sequence at the end of the array and optionally executes a completion closure.
     
     - Parameters:
       - elements: A sequence of elements to append.
       - completion: An optional closure executed on the main queue after the append.
     */
    @_disfavoredOverload
    func append<S>(contentsOf elements: S, completion: (() -> ())? = nil) where S: Sequence<Element> {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array += elements
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
        queue.async(flags: .barrier) { [weak self] in self?.array.insert(element, at: index) }
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.insert(element, at: index)
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
        queue.async(flags: .barrier) { [weak self] in self?.array.insert(contentsOf: newElements, at: index) }
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.insert(contentsOf: newElements, at: index)
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let element = self.array.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }

    /**
     Removes the first `k` elements from the array.
     
     - Parameter k: The number of elements to remove.
     */
    func removeFirst(_ k: Int) {
        queue.async(flags: .barrier) { [weak self] in self?.array.removeFirst(k) }
    }

    /**
     Removes the first `k` elements from the array and optionally executes a completion closure.
     
     - Parameters:
       - k: The number of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeFirst(_ k: Int, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.removeFirst(k)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes and returns the first element of the array.
     
     - Parameter completion: An optional closure executed on the main queue with the removed element.
     */
    func removeFirst(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let element = self.array.removeFirst()
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let element = self.array.removeFirst(where: predicate)
            DispatchQueue.main.async { completion?(element) }
        }
    }

    /**
     Removes the last `k` elements from the array.
     
     - Parameter k: The number of elements to remove.
     */
    func removeLast(_ k: Int) {
        queue.async(flags: .barrier) { [weak self] in self?.array.removeLast(k) }
    }

    /**
     Removes the last `k` elements from the array and optionally executes a completion closure.
     
     - Parameters:
       - k: The number of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeLast(_ k: Int, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.removeLast(k)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes and returns the last element of the array.
     
     - Parameter completion: An optional closure executed on the main queue with the removed element.
     */
    func removeLast(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let element = self.array.removeLast()
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    /**
     Removes the elements at the specified offsets.
     
     - Parameter offsets: The indices of the elements to remove.
     */
    func remove(atOffsets offsets: IndexSet) {
        queue.async(flags: .barrier) { [weak self] in self?.array.remove(atOffsets: offsets) }
    }

    /**
     Removes the elements at the specified offsets and optionally executes a completion closure.
     
     - Parameters:
       - offsets: The indices of the elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func remove(atOffsets offsets: IndexSet, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.remove(atOffsets: offsets)
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let removedElements = self.array.remove(elements)
            DispatchQueue.main.async { completion?(removedElements) }
        }
    }

    /**
     Removes all elements that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be removed.
     */
    func removeAll(where predicate: @escaping (Element) -> Bool) {
        queue.async(flags: .barrier) { [weak self] in self?.array.removeAll(where: predicate) }
    }

    /**
     Removes all elements that satisfy the given predicate and optionally executes a completion closure.
     
     - Parameters:
       - predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be removed.
       - completion: An optional closure executed on the main queue after removal.
     */
    func removeAll(where predicate: @escaping (Element) -> Bool, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.removeAll(where: predicate)
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes all elements from the array.
     */
    func removeAll() {
        queue.async(flags: .barrier) { [weak self] in self?.array.removeAll() }
    }

    /**
     Removes all elements from the array and optionally executes a completion closure.
     
     - Parameter completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeAll(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.removeAll()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Removes the elements in the specified subrange.
     
     - Parameter bounds: The range of elements to remove.
     */
    func removeSubrange(_ bounds: Range<Index>) {
        queue.async(flags: .barrier) { [weak self] in self?.array.removeSubrange(bounds) }
    }

    /**
     Removes the elements in the specified subrange and optionally executes a completion closure.
     
     - Parameters:
       - bounds: The range of elements to remove.
       - completion: An optional closure executed on the main queue after removal.
     */
    @_disfavoredOverload
    func removeSubrange(_ bounds: Range<Index>, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.removeSubrange(bounds)
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
        queue.async(flags: .barrier) { [weak self] in self?.array.replaceSubrange(subrange, with: newElements) }
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
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.replaceSubrange(subrange, with: newElements)
            DispatchQueue.main.async { completion?() }
        }
    }
}

public extension SynchronizedArray {
    /**
     Appends a new element to the array.
     
     - Parameters:
        - lhs: The array to append to.
        - rhs: The element to append to the array.
     */
    static func += (lhs: inout SynchronizedArray, rhs: Element) {
        lhs.append(rhs)
    }
    
    /**
     Appends the elements of a sequence to the array.
     
     - Parameters:
        - lhs: The array to append to.
        - rhs: A collection or finite sequence.
     */
    static func += <S: Sequence<Element>>(lhs: inout SynchronizedArray, rhs: S) {
        lhs.append(contentsOf: rhs)
    }
}

public extension SynchronizedArray {
    /**
     Returns the first element of the sequence that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     - Returns: The first element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
     */
    func first(where predicate: (Element) -> Bool) -> Element? {
        queue.sync { self.array.first(where: predicate) }
    }

    /**
     Returns the last element of the sequence that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     - Returns: The last element of the sequence that satisfies predicate, or `nil` if there is no element that satisfies predicate.
     */
    func last(where predicate: (Element) -> Bool) -> Element? {
        queue.sync { self.array.last(where: predicate) }
    }

    /**
     Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
     
     - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
     - Returns: An array of the elements that includeElement allowed.
     */
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        queue.sync { self.array.filter(isIncluded) }
    }

    /**
     Returns the first index in which an element of the collection satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: The index of the first element for which predicate returns `true`. If no elements in the collection satisfy the given predicate, returns `nil`.
     */
    func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        queue.sync { self.array.firstIndex(where: predicate) }
    }

    /**
     Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
     - Returns: A sorted array of the collection’s elements.
     */
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

    /**
     Returns an array containing the results of mapping the given closure over the sequence’s elements.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: An array of the non-`nil` results of calling transform with each element of the sequence.
     */
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        queue.sync { self.array.map(transform) }
    }

    /**
     Returns an array containing the non-`nil` results of calling the given transformation with each element of this sequence.
     
     - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
     - Returns: An array of the non-`nil` results of calling transform with each element of the sequence.
     */
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        queue.sync {
            Swift.print("compactMap")
            return self.array.compactMap(transform)
        }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value. initialResult is passed to nextPartialResult the first time the closure is executed.
       - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: @escaping (ElementOfResult, Element) -> ElementOfResult) -> ElementOfResult {
        queue.sync { self.array.reduce(initialResult, nextPartialResult) }
    }

    /**
     Returns the result of combining the elements of the sequence using the given closure.
     
     - Parameters:
       - initialResult: The value to use as the initial accumulating value.
       - updateAccumulatingResult: A closure that updates the accumulating value with an element of the sequence.
     - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
     */
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: @escaping (inout ElementOfResult, Element) -> Void) -> ElementOfResult {
        queue.sync { self.array.reduce(into: initialResult, updateAccumulatingResult) }
    }

    /**
     Calls the given closure on each element in the sequence in the same order as a for-in loop.
     
     - Parameter body: A closure that takes an element of the sequence as a parameter.
     */
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }

    /**
     Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element represents a match.
     - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
     */
    func contains(where predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.array.contains(where: predicate) }
    }

    /**
     Returns a Boolean value indicating whether every element of a sequence satisfies a given predicate.
     
     - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the passed element satisfies a condition.
     - Returns: true if the sequence contains only elements that satisfy predicate; otherwise, false.
     */
    func allSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        queue.sync { self.array.allSatisfy(predicate) }
    }
    
    /// Returns a sequence of pairs (n, x), where n represents a consecutive integer starting at zero and x represents an element of the sequence.
    func enumerated() -> EnumeratedSequence<Array<Element>> {
        queue.sync { self.array.enumerated() }
    }
    
    /**
     Exchanges the values at the specified indices of the collection.
     
     - Parameters:
        - i: The index of the first value to swap.
        - j: The index of the second value to swap.
     */
    func swapAt(i: Index, j: Index) {
        queue.async(flags: .barrier) { [weak self] in self?.array.swapAt(i, j) }
    }
    
    /**
     Returns the number of elements that satisfy the given predicate.
     
     - Parameter predicate: A closure that takes an element of the array and returns a Boolean value indicating whether the element should be counted.
     - Throws: Rethrows any error thrown by the predicate.
     - Returns: The number of elements in the array that satisfy the predicate.
     */
    func count<E>(where predicate: (Element) throws(E) -> Bool) throws(E) -> Int where E : Error {
        do {
            return try queue.sync { try self.array.count(where: predicate) }
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
        queue.async(flags: .barrier) { [weak self] in self?.array.shuffle() }
    }
    
    /**
     Shuffles the elements of the array in place using the system's random number generator and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after the shuffle is complete.
     */
    @_disfavoredOverload
    func shuffle(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.shuffle()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements shuffled, using the system's random number generator.
     
     - Returns: A new array with the elements in a random order.
     */
    func shuffled() -> [Element] {
        queue.sync { self.array.shuffled() }
    }

    /// Reverses the order of the elements of the array in place.
    func reverse() {
        queue.async(flags: .barrier) { [weak self] in self?.array.reverse() }
    }
    
    /**
     Reverses the order of the elements of the array in place and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after the reversal is complete.
     */
    @_disfavoredOverload
    func reverse(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.reverse()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements in reverse order.
     
     - Returns: A new array with the elements in reverse order.
     */
    func reversed() -> [Element] {
        queue.sync { self.array.reversed() }
    }

    /**
     Returns a random element from the array, or `nil` if the array is empty.
     
     - Returns: A random element, or `nil` if the array is empty.
     */
    func randomElement() -> Element? {
        queue.sync { self.array.randomElement() }
    }

    /**
     Returns a random element from the array, or `nil` if the array is empty, using the given random number generator.
     
     - Parameter generator: The random number generator to use.
     - Returns: A random element, or `nil` if the array is empty.
     */
    func randomElement<T>(using generator: inout T) -> Element? where T: RandomNumberGenerator {
        queue.sync { self.array.randomElement(using: &generator) }
    }
}

extension SynchronizedArray: Equatable where Element: Equatable {
    public func contains(_ element: Element) -> Bool {
        queue.sync { self.array.contains(element) }
    }
    
    public static func == (lhs: SynchronizedArray<Element>, rhs: SynchronizedArray<Element>) -> Bool {
        lhs.synchronized == rhs.synchronized
    }
}

public extension SynchronizedArray where Element: Comparable {
    /**
     Returns the first index where the specified element appears in the array.
     
     - Parameter element: The element to find.
     - Returns: The first index of the element if it exists in the array; otherwise, `nil`.
     */
    func index(_ element: Element) -> Int? {
        queue.sync { self.array.firstIndex(where: { $0 == element }) }
    }

    /**
     Sorts the array in place using the `<` operator.
     */
    func sort() {
        queue.async(flags: .barrier) { [weak self] in self?.array.sort() }
    }

    /**
     Sorts the array in place using the `<` operator and optionally executes a completion closure on the main queue.
     
     - Parameter completion: An optional closure executed on the main queue after sorting.
     */
    @_disfavoredOverload
    func sort(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.array.sort()
            DispatchQueue.main.async { completion?() }
        }
    }

    /**
     Returns a new array with the elements of the array sorted using the `<` operator.
     
     - Returns: A sorted array.
     */
    func sorted() -> [Element] {
        queue.sync { self.array.sorted() }
    }

    /**
     Sorts the array in place, using the given predicate as the comparison between elements.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     */
    func sort(by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool) rethrows {
        queue.async(flags: .barrier) { [weak self] in try? self?.array.sort(by: areInIncreasingOrder) }
    }

    /**
     Sorts the array in place, using the given predicate as the comparison between elements, and optionally executes a completion closure on the main queue.
     
     - Parameters:
       - areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
       - completion: An optional closure executed on the main queue after sorting.
     */
    @_disfavoredOverload
    func sort(by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool, completion: (() -> Void)? = nil) rethrows {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            try? self.array.sort(by: areInIncreasingOrder)
            DispatchQueue.main.async { completion?() }
        }
    }
    
    /*
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        queue.sync { self.array.sorted(by: keyPath, order) }
    }
    
    /**
     An array of the elements sorted by the given keypath.

      - Parameters:
         - compare: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
      */
    func sorted<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) -> [Element] where Value: Comparable {
        queue.sync { self.array.sorted(by: keyPath, order) }
    }
    */
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    func sort<Value>(by keyPath: KeyPath<Element, Value>, _ order: SequenceSortOrder = .ascending) where Value: Comparable {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                self.array.sort(using: KeyPathComparator(keyPath, order: order.sortOrder))
            } else {
                self.array = self.array.sorted(by: keyPath, order)
            }
        }
    }
    
    /**
     Sorts the collection by the given key path.

      - Parameters:
         - keyPath: The keypath to compare the elements.
         - order: The order of sorting. The default value is `ascending`.
    */
    func sort<Value>(by keyPath: KeyPath<Element, Value?>, _ order: SequenceSortOrder = .ascending) where Value: Comparable {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                self.array.sort(using: KeyPathComparator(keyPath, order: order.sortOrder))
            } else {
                self.array = self.array.sorted(by: keyPath, order)
            }
        }
    }
    
    /**
     Sorts the collection using the given comparator to compare elements.
     
     - Parameter comparator: The sort comparator used to compare elements.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func sort<Comparator>(using comparator: Comparator) where Comparator : SortComparator, Element == Comparator.Compared {
        queue.async(flags: .barrier) { [weak self] in self?.array.sort(using: comparator) }
    }
    
    /**
     Returns the elements of the sequence, sorted using the given comparator to compare elements.
     
     - Parameter comparator: The comparator to use in ordering elements
     - Returns: An array of the elements sorted using `comparator`.
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func sorted<Comparator>(using comparator: Comparator) -> [Element] where Comparator : SortComparator, Element == Comparator.Compared {
        queue.sync { self.array.sorted(using: comparator) }
    }

    /**
     Returns the minimum element in the array.
     
     - Returns: The minimum element, or `nil` if the array is empty.
     */
    func min() -> Element? {
        queue.sync { self.array.min() }
    }

    /**
     Returns the minimum element in the array, using the given predicate as the comparison.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     - Returns: The minimum element, or `nil` if the array is empty.
     */
    func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try queue.sync { try self.array.min(by: areInIncreasingOrder) }
    }

    /**
     Returns the maximum element in the array.
     
     - Returns: The maximum element, or `nil` if the array is empty.
     */
    func max() -> Element? {
        queue.sync { self.array.max() }
    }

    /**
     Returns the maximum element in the array, using the given predicate as the comparison.
     
     - Parameter areInIncreasingOrder: A closure that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
     - Returns: The maximum element, or `nil` if the array is empty.
     */
    func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        try queue.sync { try self.array.max(by: areInIncreasingOrder) }
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

extension SynchronizedArray: @unchecked Sendable where Element: Sendable {}

extension SynchronizedArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: synchronized)
    }
}

extension SynchronizedArray: Decodable where Element: Decodable { }

extension SynchronizedArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        synchronized._cVarArgEncoding
    }
}
