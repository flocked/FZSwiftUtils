//
//  BufferCollection.swift
//  
//
//  Created by Florian Zand on 18.09.26.
//

import Foundation

/// A random-access collection backed by a buffer.
public struct BufferCollection<Element>: RandomAccessCollection, CustomDebugStringConvertible {
    private let storage: Storage
    
    /**
     Creates a collection that takes ownership of the specified buffer.

     The buffer's base address must refer to memory that can be released using `free`.

     - Parameter buffer: The buffer whose storage the collection takes ownership of.
     */
    public init(owned buffer: UnsafeBufferPointer<Element>?) {
        storage = Storage(buffer)
    }
    
    /**
     Creates a collection that borrows the specified buffer without taking ownership of its memory.

     The buffer must remain valid for the lifetime of the collection.
     */
    public init(borrowed buffer: UnsafeBufferPointer<Element>?) {
        storage = Storage(buffer, isOwned: false)
    }

    /**
     Creates a collection from an allocated pointer and its element count.

     The returned pointer must refer to memory that can be released using `free`. The closure writes the number of initialized elements to the supplied count pointer.

     - Parameter buffer: A closure that receives a pointer to the element count and returns an allocated pointer to the elements.
     */
    public init<C: BinaryInteger>(_ buffer: (UnsafeMutablePointer<C>?) -> UnsafeMutablePointer<Element>?) {
        var count: C = .zero
        storage = Storage(buffer(&count)?.buffer(count: count))
    }

    /**
     Creates a collection from an allocated autoreleasing pointer and its element count.

     The returned pointer must refer to memory that can be released using `free`. The closure writes the number of initialized elements to the supplied count pointer.

     - Parameter buffer: A closure that receives a pointer to the element count and returns an allocated autoreleasing pointer to the elements.
     */
    public init<C: BinaryInteger>(_ buffer: (UnsafeMutablePointer<C>?) -> AutoreleasingUnsafeMutablePointer<Element>?) {
        var count: C = .zero
        storage = Storage(buffer(&count)?.buffer(count: count))
    }
        
    public var startIndex: Int {
        storage.buffer.startIndex
    }

    public var endIndex: Int {
        storage.buffer.endIndex
    }

    public subscript(index: Int) -> Element {
        storage.buffer[index]
    }
    
    public func makeIterator() -> UnsafeBufferPointer<Element>.Iterator {
        storage.buffer.makeIterator()
    }
    
    public func filter<E>(_ isIncluded: (Element) throws(E) -> Bool) throws(E) -> [Element] where E: Error {
        try storage.buffer.filter(isIncluded)
    }
    
    public func map<T, E: Error>(_ transform: (Element) throws(E) -> T) throws(E) -> [T] {
        try storage.buffer.map(transform)
    }
    
    public func compactMap<ElementOfResult>(_ transform: (Self.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try storage.buffer.compactMap(transform)
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult: Sequence {
        try storage.buffer.flatMap(transform)
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.buffer.forEach(body)
    }
    
    public var debugDescription: String {
        "\(Self.self)(start: \(nil: storage.buffer.baseAddress), count: \(count))"
    }
    
    /// The collection as `Array`.
    public var asArray: [Element] {
        Array(storage.buffer)
    }
    
    private final class Storage {
        let buffer: UnsafeBufferPointer<Element>
        let isOwned: Bool

        init(_ buffer: UnsafeBufferPointer<Element>?, isOwned: Bool = true) {
            self.buffer = buffer ?? .init(start: nil, count: 0)
            self.isOwned = isOwned
        }

        deinit {
            guard isOwned else { return }
            free(UnsafeMutableRawPointer(mutating: buffer.baseAddress))
        }
    }
}

extension BufferCollection: Copyable where Element: Copyable & Escapable { }
extension BufferCollection: Escapable where Element: Copyable & Escapable { }
extension BufferCollection: ContiguousBytes where Element == UInt8 {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try storage.buffer.withUnsafeBytes(body)
    }
}
