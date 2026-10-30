//
//  Collection+Indexed.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

extension Collection {
    /**
     Returns a collection of pairs *(i, x)*, where *i* represents an index of the collection, and *x* represents an element.
     
     The `indexed()` method is similar to `enumerated()` method, but provides the index with each element instead of a zero-based counter.
     
     This example iterates over the indices and elements of a set, building an array consisting of indices of names with five or fewer letters.
     
     ```swift
     let names = ["Noah", "Jameson", "Lea", "Jonathan", "Mat", "Nicolás"]
     var shortNameIndexes: [Int] = []
     
     for (i, name) in names.indexed() {
        if name.count <= 5 {
            shortNameIndexes.append(i)
        }
     }
     
     // [0, 2, 4]
     shortNameIndexes
     ```
     - Returns: A collection of paired indices and elements of this collection.
     */
    @inlinable
    public func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}

extension Collection where Element: Comparable {
    /// Returns the index of the minimum element in the collection or `nil` if the collection is empty.
    public var minIndex: Index? {
        indexed().min(by: \.element)?.index
    }
    
    /// Returns the index of the maximum element in the collection or `nil` if the collection is empty.
    public var maxIndex: Index? {
        indexed().max(by: \.element)?.index
    }
    
    @warn_unqualified_access
    func minIndex(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Index? {
        try indexed().min(by: { try areInIncreasingOrder($0.element, $1.element) })?.index
    }
    
    @inlinable
    public func minIndex<Value: Comparable>(by value: (Element) -> Value) -> Index? {
        indexed().min(by: { value($0.element) })?.index
    }
    
    @inlinable
    public func minIndex<Value: Comparable>(by value: (Element) -> Value?) -> Index? {
        indexed().min(by: { value($0.element) })?.index
    }
    
    /// Returns the element whose transformed value is the largest.
    @inlinable
    public func maxIndex<Value: Comparable>(by value: (Element) -> Value) -> Index? {
        indexed().max(by: { value($0.element) })?.index
    }
}

/// A collection wrapper that iterates over the indices and elements of a collection together.
public struct IndexedCollection<Base: Collection> {
    /// The base collection.
    @usableFromInline
    internal let base: Base
    
    @inlinable
    internal init(base: Base) {
        self.base = base
    }
    
    public struct IndexedElement: CustomStringConvertible, CustomDebugStringConvertible {
        let index: Base.Index
        let element: Base.Element
        
        public var description: String {
            "(\(index), \(element))"
        }
        
        public var debugDescription: String {
            "(\(reflecting: index), \(reflecting: element))"
        }
    }
}

extension IndexedCollection.IndexedElement: Equatable where Base.Element: Equatable { }
extension IndexedCollection.IndexedElement: Hashable where Base.Index: Hashable, Base.Element: Hashable { }
extension IndexedCollection.IndexedElement: Sendable where Base.Index: Sendable, Base.Element: Sendable { }

extension IndexedCollection: Collection {
    
    /// The element type for an `IndexedCollection` collection.
    public typealias Element = (index: Base.Index, element: Base.Element)
    
    @inlinable
    public var startIndex: Base.Index {
        base.startIndex
    }
    
    @inlinable
    public var endIndex: Base.Index {
        base.endIndex
    }
    
    @inlinable
    public subscript(position: Base.Index) -> Element {
        (index: position, element: base[position])
    }
    
    @inlinable
    public func index(after i: Base.Index) -> Base.Index {
        base.index(after: i)
    }
    
    @inlinable
    public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
        base.index(i, offsetBy: distance)
    }
    
    @inlinable
    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
        base.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    @inlinable
    public func distance(from start: Base.Index, to end: Base.Index) -> Int {
        base.distance(from: start, to: end)
    }
    
    @inlinable
    public var indices: Base.Indices {
        base.indices
    }
}

extension IndexedCollection: BidirectionalCollection where Base: BidirectionalCollection {
    @inlinable
    public func index(before i: Base.Index) -> Base.Index {
        base.index(before: i)
    }
}

extension IndexedCollection: Equatable where Base: Equatable { }
extension IndexedCollection: Hashable where Base: Hashable { }
extension IndexedCollection: Sendable where Base: Sendable { }
extension IndexedCollection: RandomAccessCollection where Base: RandomAccessCollection { }
extension IndexedCollection: LazySequenceProtocol, LazyCollectionProtocol where Base: LazySequenceProtocol { }
