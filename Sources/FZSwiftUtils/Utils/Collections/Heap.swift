//
//  Heap.swift
//
//
//  Created by Florian Zand on 10.11.25.
//

import Foundation

/**
 A heap data structure that maintains a collection of elements in a partially ordered structure.

 The `Heap` uses a ``SortingComparator`` to determine the ordering of its elements, allowing for flexible sorting criteria such as ascending, descending, or custom key path comparisons.

 Elements can be efficiently inserted, removed, and accessed while maintaining the heap property.
 
 The heap can function as a min-heap, max-heap, or any custom order based on the provided comparator.

 - Note: The heap does not enforce uniqueness; duplicate elements are allowed.
 */
public struct Heap<Element>: Sequence, Collection {
    
    // MARK: - Stored Properties
    
    /// The elements of the heap in array order.
    public internal(set) var elements: [Element]
    
    /**
     The comparator defining the heap’s priority order.
     
     Changing the comparator rebuilds the heap from its current elements.
     */
    public var comparator: SortingComparator<Element> {
        didSet { heapify() }
    }
    
    // MARK: - Initialization
    
    /// Creates an empty heap using the given comparator.
    public init(comparator: SortingComparator<Element>) {
        self.elements = []
        self.comparator = comparator
    }
    
    /// Creates a heap from a sequence of elements, rebuilding the heap as needed.
    public init<S: Sequence>(comparator: SortingComparator<Element>, elements: S)
    where S.Element == Element {
        self.elements = Array(elements)
        self.comparator = comparator
        heapify()
    }
    
    // MARK: - Heap Operations
    
    /// Rebuilds the heap from its current elements.
    public mutating func heapify() {
        guard !elements.isEmpty else { return }
        for i in (0..<(elements.count / 2)).reversed() {
            siftDown(from: i)
        }
    }
    
    /// Inserts a new element into the heap.
    public mutating func insert(_ element: Element) {
        elements.append(element)
        siftUp(from: elements.count - 1)
    }
    
    /// Removes and returns the root element (the highest-priority element) of the heap.
    @discardableResult
    public mutating func pop() -> Element? {
        guard !elements.isEmpty else { return nil }
        elements.swapAt(0, elements.count - 1)
        let removed = elements.removeLast()
        if !elements.isEmpty {
            siftDown(from: 0)
        }
        return removed
    }
    
    /// Returns the root element without removing it.
    public var peek: Element? { elements.first }
    
    /// Removes all elements from the heap.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }
    
    // MARK: - Internal Heap Mechanics
    
   private mutating func siftUp(from index: Int) {
        var child = index
        var parent = (child - 1) / 2
        while child > 0 && comparator.compare(elements[child], elements[parent]) == .orderedAscending {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = 2 * parent + 2
            var candidate = parent
            
            if left < elements.count,
               comparator.compare(elements[left], elements[candidate]) == .orderedAscending {
                candidate = left
            }
            if right < elements.count,
               comparator.compare(elements[right], elements[candidate]) == .orderedAscending {
                candidate = right
            }
            if candidate == parent { return }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
    
    public func makeIterator() -> IndexingIterator<[Element]> {
        elements.makeIterator()
    }
    
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    
    public subscript(position: Int) -> Element {
        elements[position]
    }
    
    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Heap: Equatable where Element: Equatable { }
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Heap: Hashable where Element: Hashable { }

/*
 
 /**
  A heap data structure that maintains a collection of elements in a partially ordered structure.

  The `Heap` uses a ``SortingComparator`` to determine the ordering of its elements, allowing for flexible sorting criteria such as ascending, descending, or custom key path comparisons.

  Elements can be efficiently inserted, removed, and accessed while maintaining the heap property.
  
  The heap can function as a min-heap, max-heap, or any custom order based on the provided comparator.

  - Note: The heap does not enforce uniqueness; duplicate elements are allowed.
  */
 public class Heap<Element>: Sequence, Collection {
     
     // MARK: - Stored Properties
     
     /// The elements of the heap in array order.
     public internal(set) var elements: [Element]
     
     /**
      The comparator defining the heap’s priority order.
      
      Changing the comparator rebuilds the heap from its current elements.
      */
     public var comparator: SortingComparator<Element> {
         didSet { heapify() }
     }
     
     private var kvoSetupHandler: ((Element)->())?
     private var kvoObservations: [ObjectIdentifier: KeyValueObservation] = [:]
     
     // MARK: - Initialization
     
     /// Creates an empty heap using the given comparator.
     public init(comparator: SortingComparator<Element>) {
         self.elements = []
         self.comparator = comparator
     }
     
     /// Creates a heap from a sequence of elements, rebuilding the heap as needed.
     public init<S: Sequence>(comparator: SortingComparator<Element>, elements: S)
     where S.Element == Element {
         self.elements = Array(elements)
         self.comparator = comparator
         heapify()
     }
     
     public init<V: Comparable>(orderedBy keyPath: KeyPath<Element, V>) {
         self.elements = []
         self.comparator = .ascending(keyPath)
     }
     
     public init<V: Comparable>(orderedBy keyPath: KeyPath<Element, V>, observeChanges: Bool = false) where Element: NSObject {
         self.elements = []
         self.comparator = .ascending(keyPath)
         
         guard observeChanges else { return }
         self.kvoSetupHandler = {
             self.kvoObservations[ObjectIdentifier($0)] = $0.observeChanges(for: keyPath) { [weak self] oldValue, newValue in
                 self?.heapify()
             }
         }
     }
     
     // MARK: - Heap Operations
     
     /// Rebuilds the heap from its current elements.
     public func heapify() {
         guard !elements.isEmpty else { return }
         for i in (0..<(elements.count / 2)).reversed() {
             siftDown(from: i)
         }
     }
     
     /// Inserts a new element into the heap.
     public func insert(_ element: Element) {
         elements.append(element)
         siftUp(from: elements.count - 1)
         kvoSetupHandler?(element)
     }
     
     /// Inserts new elements into the heap.
     public func insert<S: Sequence<Element>>(_ elements: S) {
         elements.forEach({ insert($0) })
     }
     
     /// Removes and returns the root element (the highest-priority element) of the heap.
     @discardableResult
     public func pop() -> Element? {
         guard !elements.isEmpty else { return nil }
         elements.swapAt(0, elements.count - 1)
         let removed = elements.removeLast()
         if !elements.isEmpty {
             siftDown(from: 0)
         }
         if let object = removed as? NSObject {
             kvoObservations.removeValue(forKey: ObjectIdentifier(object))
         }
         return removed
     }
     
     /// Returns the root element without removing it.
     public var peek: Element? { elements.first }
     
     /// Removes all elements from the heap.
     public func removeAll(keepingCapacity keepCapacity: Bool = false) {
         kvoObservations = [:]
         elements.removeAll(keepingCapacity: keepCapacity)
     }
     
     // MARK: - Internal Heap Mechanics
     
    private func siftUp(from index: Int) {
         var child = index
         var parent = (child - 1) / 2
         while child > 0 && comparator.compare(elements[child], elements[parent]) == .orderedAscending {
             elements.swapAt(child, parent)
             child = parent
             parent = (child - 1) / 2
         }
     }
     
     private func siftDown(from index: Int) {
         var parent = index
         while true {
             let left = 2 * parent + 1
             let right = 2 * parent + 2
             var candidate = parent
             
             if left < elements.count,
                comparator.compare(elements[left], elements[candidate]) == .orderedAscending {
                 candidate = left
             }
             if right < elements.count,
                comparator.compare(elements[right], elements[candidate]) == .orderedAscending {
                 candidate = right
             }
             if candidate == parent { return }
             elements.swapAt(parent, candidate)
             parent = candidate
         }
     }
     
     public func makeIterator() -> IndexingIterator<[Element]> {
         elements.makeIterator()
     }
     
     public var startIndex: Int { elements.startIndex }
     public var endIndex: Int { elements.endIndex }
     
     public subscript(position: Int) -> Element {
         elements[position]
     }
     
     public func index(after i: Int) -> Int {
         elements.index(after: i)
     }
 }

 extension Heap where Element: Equatable {
     public static func == (lhs: Heap<Element>, rhs: Heap<Element>) -> Bool {
         lhs.elements == rhs.elements && lhs.comparator == rhs.comparator
     }
 }

 extension Heap where Element: Hashable {
     public func hash(into hasher: inout Hasher) {
         hasher.combine(elements)
         hasher.combine(comparator)
     }
 }

 */
