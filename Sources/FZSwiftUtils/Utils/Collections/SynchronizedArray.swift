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

public class SynchronizedArray<Element>: BidirectionalCollection {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedArray", attributes: .concurrent)
    private var array = [Element]()

    public init() {}
    
    public convenience init(_ array: [Element]) {
        self.init()
        self.array = array
    }
}

public extension SynchronizedArray {
    var sync: [Element] {
        var array: [Element] = []
        queue.sync {
            array = self.array
        }
        return array
    }
    
    func index(_ i: Int, offsetBy distance: Int) -> Int {
        queue.sync {
            self.array.index(i, offsetBy: distance)
        }
    }

    func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        queue.sync {
            self.array.index(i, offsetBy: distance, limitedBy: limit)
        }
    }

    func formIndex(after i: inout Int) {
        queue.sync {
            self.array.formIndex(after: &i)
        }
    }

    func formIndex(before i: inout Int) {
        queue.sync {
            self.array.formIndex(before: &i)
        }
    }

    func distance(from start: Int, to end: Int) -> Int {
        queue.sync {
            self.array.distance(from: start, to: end)
        }
    }

    func index(before i: Int) -> Int {
        queue.sync {
            array.index(before: i)
        }
    }

    func index(after i: Int) -> Int {
        queue.sync {
            array.index(after: i)
        }
    }

    var startIndex: Int {
        queue.sync {
            array.startIndex
        }
    }

    var endIndex: Int {
        queue.sync {
            array.endIndex
        }
    }

    var count: Int {
        queue.sync {
            self.array.count
        }
    }

    func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func append(contentsOf elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    func insert(_ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }

    func remove(at index: Int, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            DispatchQueue.main.async { completion?(element) }
        }
    }
    
    func remove(where predicate: @escaping (Element) -> Bool, completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            var elements = [Element]()
            
            while let index = self.array.firstIndex(where: predicate) {
                elements.append(self.array.remove(at: index))
            }
            
            DispatchQueue.main.async { completion?(elements) }
        }
    }

    func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            DispatchQueue.main.async { completion?(elements) }
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }
    
    var first: Element? {
        queue.sync { return self.array.first }
    }
    
    var last: Element? {
        queue.sync { return self.array.last }
    }
    
    var isEmpty: Bool {
        queue.sync { return self.array.isEmpty }
    }
    
    var description: String {
        queue.sync { return self.array.description }
    }

    subscript(index: Int) -> Element {
        queue.sync {
            self.array[index]
        }
    }
}

public extension SynchronizedArray {
    
    /// Adds a new element at the end of the array.
    ///
    /// - Parameters:
    ///   - left: The collection to append to.
    ///   - right: The element to append to the array.
    static func +=(left: inout SynchronizedArray, right: Element) {
        left.append(right)
    }
    
    /// Adds new elements at the end of the array.
    ///
    /// - Parameters:
    ///   - left: The collection to append to.
    ///   - right: The elements to append to the array.
    static func +=(left: inout SynchronizedArray, right: [Element]) {
        left.append(contentsOf: right)
    }
}

public extension SynchronizedArray {
    
    /// Returns the first element of the sequence that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first element of the sequence that satisfies predicate, or nil if there is no element that satisfies predicate.
    func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }
    
    /// Returns the last element of the sequence that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The last element of the sequence that satisfies predicate, or nil if there is no element that satisfies predicate.
    func last(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.last(where: predicate) }
        return result
    }
    
    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> SynchronizedArray {
        var result: SynchronizedArray?
        
        queue.sync { result = SynchronizedArray(self.array.filter(isIncluded)) }
        return result!
    }
    
    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
    
    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> SynchronizedArray {
        var result: SynchronizedArray?
        queue.sync { result = SynchronizedArray(self.array.sorted(by: areInIncreasingOrder)) }
        return result!
    }
    
    /// Returns an array containing the results of mapping the given closure over the sequence’s elements.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func map<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        queue.sync { result = self.array.map(transform) }
        return result
    }
    
    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func compactMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        queue.sync { result = self.array.compactMap(transform) }
        return result
    }
    
    /// Returns the result of combining the elements of the sequence using the given closure.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value. initialResult is passed to nextPartialResult the first time the closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
    func reduce<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: @escaping (ElementOfResult, Element) -> ElementOfResult) -> ElementOfResult {
        var result: ElementOfResult?
        queue.sync { result = self.array.reduce(initialResult, nextPartialResult) }
        return result ?? initialResult
    }
    
    /// Returns the result of combining the elements of the sequence using the given closure.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: A closure that updates the accumulating value with an element of the sequence.
    /// - Returns: The final accumulated value. If the sequence has no elements, the result is initialResult.
    func reduce<ElementOfResult>(into initialResult: ElementOfResult, _ updateAccumulatingResult: @escaping (inout ElementOfResult, Element) -> ()) -> ElementOfResult {
        var result: ElementOfResult?
        queue.sync { result = self.array.reduce(into: initialResult, updateAccumulatingResult) }
        return result ?? initialResult
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
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
    
    /// Returns a Boolean value indicating whether every element of a sequence satisfies a given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element satisfies a condition.
    /// - Returns: true if the sequence contains only elements that satisfy predicate; otherwise, false.
    func allSatisfy(_ predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.allSatisfy(predicate) }
        return result
    }
}

public extension SynchronizedArray where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        queue.sync {
            self.array.contains(element)
        }
    }
}

public extension SynchronizedArray where Element: Comparable {
    func index(_ element: Element) -> Int? {
        queue.sync {
            self.array.firstIndex(where: { $0 == element })
        }
    }
}
