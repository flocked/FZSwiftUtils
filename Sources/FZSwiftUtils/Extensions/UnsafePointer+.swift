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
    
    /// Converts the pointer to an immutable pointer.
    var asUnsafePointer: UnsafePointer<Pointee> {
        return UnsafePointer(self)
    }
    
    /// Converts the pointer to an autoreleasing mutable pointer.
    var asAutoreleasingPointer: AutoreleasingUnsafeMutablePointer<Pointee> {
        AutoreleasingUnsafeMutablePointer(self)
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

extension UnsafePointer<CChar> {
    /// Creates a new string by copying the null-terminated UTF-8 data referenced by the pointer.
    public var string: String {
        String(cString: self)
    }
}

extension UnsafeMutablePointer<CChar> {
    /// Creates a new string by copying the null-terminated UTF-8 data referenced by the pointer.
    public var string: String {
        String(cString: self)
    }
    
    /// Creates a new string by copying the null-terminated UTF-8 data referenced by the pointer and releasing the pointer.
    public func stringAndFree() -> String {
        defer { free(self) }
        return String(cString: self)
    }
}
