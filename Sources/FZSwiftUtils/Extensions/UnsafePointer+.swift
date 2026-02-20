//
//  UnsafePointer+.swift
//
//
//  Created by Florian Zand on 16.01.26.
//

import Foundation

public extension UnsafePointer {
    /**
     Returns an `UnsafeBufferPointer` containing the specified number of elements starting at this pointer.
     
     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeBufferPointer` of length `count`.
     */
    func buffer<I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> {
        UnsafeBufferPointer(start: self, count: Int(count))
    }
    

    /**
     Copies the specified amount of elements from the memory pointed to by this pointer into an array.
     
     - Parameter count: The number of elements to copy.
     - Returns: An array containing the elements.
     */
    func array<I: BinaryInteger>(count: I) -> [Pointee] {
        Array(buffer(count: count))
    }
}

public extension Optional {
    /**
     Returns an `UnsafeBufferPointer` for the optional pointer.
     
     If the pointer is `nil`, an empty buffer is returned.

     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeBufferPointer` of length `count`, or empty if the pointer is `nil`.
     */
    func buffer<Pointee, I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> where Wrapped == UnsafePointer<Pointee> {
        guard let ptr = self else { return UnsafeBufferPointer(start: nil, count: 0) }
        return ptr.buffer(count: count)
    }
    
    /**
     Copies the specified amount of elements from the optional pointer into an array.
     
     If the pointer is `nil`, an empty array is returned.

     - Parameter count: The number of elements to copy.
     - Returns: An array containing the elements, or empty if the pointer is `nil`.
     */
    func array<Pointee, I: BinaryInteger>(count: I) -> [Pointee] where Wrapped == UnsafePointer<Pointee> {
        Array(buffer(count: count))
    }
}

public extension UnsafeMutablePointer {
    /**
     Returns an `UnsafeBufferPointer` containing the specified number of elements starting at this pointer.
     
     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeBufferPointer` of length `count`.
     */
    func buffer<I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> {
        UnsafeBufferPointer(start: self, count: Int(count))
    }

    /**
     Returns an `UnsafeMutableBufferPointer` containing the specified number of elements starting at this pointer.
     
     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeMutableBufferPointer` of length `count`.
     */
    func mutableBuffer<I: BinaryInteger>(count: I) -> UnsafeMutableBufferPointer<Pointee> {
        UnsafeMutableBufferPointer(start: self, count: Int(count))
    }
    
    /**
     Copies the sepcified amount of elements from the memory pointed to by this pointer into an array.
     
     - Parameter count: The number of elements to copy.
     - Returns: An array containing the elements.
     */
    func array<I: BinaryInteger>(count: I) -> [Pointee] {
        Array(buffer(count: count))
    }
}

public extension AutoreleasingUnsafeMutablePointer {
    /**
     Returns an `UnsafeMutableBufferPointer` containing the specified number of elements starting at this pointer.
     
     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeMutableBufferPointer` of length `count`.
     */
    func buffer<I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> {
        UnsafeBufferPointer(start: self, count: Int(count))
    }
    
    /**
     Copies the sepcified amount of elements from the memory pointed to by this pointer into an array.
     
     - Parameter count: The number of elements to copy.
     - Returns: An array containing the elements.
     */
    func array<I: BinaryInteger>(count: I) -> [Pointee] {
        Array(buffer(count: count))
    }
}

public extension Optional {
    /**
     Returns an `UnsafeBufferPointer` for the optional mutable pointer.
     
     If the pointer is `nil`, an empty buffer is returned.

     - Parameters:
       - count: The number of elements in the buffer.
     - Returns: An `UnsafeBufferPointer` of length `count`, or empty if the pointer is `nil`.
     */
    func buffer<Pointee, I: BinaryInteger>(count: I) -> UnsafeBufferPointer<Pointee> where Wrapped == UnsafeMutablePointer<Pointee> {
        guard let ptr = self else { return UnsafeBufferPointer(start: nil, count: 0) }
        return ptr.buffer(count: count)
    }
    
    /**
     Returns an `UnsafeMutableBufferPointer` for the optional mutable pointer.
     
     If the pointer is `nil`, an empty buffer is returned.

     - Parameter count: The number of elements in the buffer.
     - Returns: An `UnsafeMutableBufferPointer` of length `count`, or empty if the pointer is `nil`.
     */
    func mutableBuffer<Pointee, I: BinaryInteger>(count: I) -> UnsafeMutableBufferPointer<Pointee> where Wrapped == UnsafeMutablePointer<Pointee> {
        guard let ptr = self else { return UnsafeMutableBufferPointer(start: nil, count: 0) }
        return ptr.mutableBuffer(count: count)
    }
    
    /**
     Copies the specified amount of elements from the optional mutable pointer into an array.
     
     If the pointer is `nil`, an empty array is returned.
     
     - Parameter count: The number of elements to copy.
     - Returns: An array containing the elements, or empty if the pointer is `nil`.
     */
    func array<Pointee, I: BinaryInteger>(count: I) -> [Pointee] where Wrapped == UnsafeMutablePointer<Pointee> {
        Array(buffer(count: count))
    }
}

extension UnsafePointer<CChar> {
    /// Creates a new string by copying the null-terminated UTF-8 data referenced by the pointer.
    public var string: String {
        String(cString: self)
    }
}

extension UnsafeMutablePointer<CChar> {
    /// Creates a new string by copying the null-terminated UTF-8 data referenced by the pointer and releasing the pointer.
    public var string: String {
        String(cString: self)
    }
    
    public func string(free: Bool) -> String {
        defer { if free { ObjectiveC.free(self) } }
        return String(cString: self)
    }
}

public extension  UnsafeMutablePointer {
    var asUnsafePointer: UnsafePointer<Pointee> {
        return UnsafePointer(self)
    }
}
