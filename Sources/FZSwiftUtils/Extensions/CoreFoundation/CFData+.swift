//
//  CFData+.swift
//
//
//  Created by Florian Zand on 31.10.25.
//

import Foundation

extension CFData: Swift.Collection, Swift.BidirectionalCollection, Swift.RandomAccessCollection, Swift.Sequence {
    /// The position of the first byte in the CFData.
    public var startIndex: CFIndex { 0 }

    /// The position one greater than the last valid subscript argument.
    public var endIndex: CFIndex { count }

    /**
     Accesses the byte at the specified position.
     
     - Parameter position: The index of the byte to access.
     */
    public subscript(position: CFIndex) -> UInt8 {
        precondition(position >= 0 && position < endIndex, "Index out of bounds")
        guard let ptr = bytes() else { fatalError("CFData has no bytes") }
        return ptr[position]
    }
    
    /**
     Accesses the byte at the specified position.
     
     - Parameter position: The index of the byte to access.
     */
    public subscript(safe position: CFIndex) -> UInt8? {
        guard position >= 0 && position < endIndex, let ptr = bytes() else { return nil }
        return ptr[position]
    }
        
    /// Returns a new copy of the data in the specified range.
    public subscript(range: Range<CFIndex>) -> CFData {
        subdata(in: range)
    }
    
    /// Returns a new copy of the data in the specified range.
    public subscript(safe range: Range<CFIndex>) -> CFData? {
        guard range.lowerBound >= 0 && range.upperBound <= count, let ptr = bytes() else { return nil }
        return CFDataCreate(.default, ptr + range.lowerBound, range.count)
    }
    
    /// Returns the index immediately after the given index.
    public func index(after i: CFIndex) -> CFIndex { i + 1 }
    
    /// Returns the index immediately before the given index.
    public func index(before i: CFIndex) -> CFIndex { i - 1 }

    /// The number of bytes in the data.
    public var count: Int {
        CFDataGetLength(self)
    }

    /// A Boolean value indicating whether the data is empty.
    public var isEmpty: Bool {
        count == 0
    }
    
    /**
     Returns a new copy of the data in the specified range.
     
     - Parameter range: The range to copy.
     */
    public func subdata(in range: Range<Index>) -> CFData {
        precondition(range.lowerBound >= 0 && range.upperBound <= count, "Range out of bounds")
        guard let ptr = bytes() else { fatalError("CFData has no bytes") }
        return CFDataCreate(.default, ptr + range.lowerBound, range.count)
    }
    
    /**
     Provides a typed pointer to the data bytes for use within a closure.
     
     The pointer is only valid for the duration of the closure call, ensuring memory safety.
     
     - Note: If the data has no bytes, this method triggers a runtime fatal error.
     
     - Parameter body: A closure that takes an `UnsafePointer<UInt8>` pointing to the bytes of the data.
     - Returns: The result of the closure.
     */
    public func withBytes<R>(_ body: (UnsafePointer<UInt8>) -> R) -> R {
        guard let ptr = bytes() else { fatalError("CFData has no bytes") }
        return body(ptr)
    }
    
    /// Accesses the raw bytes in the data’s buffer.
    public func withUnsafeBytes<ContentType, ResultType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType {
        guard let ptr = bytes() else { fatalError("CFData has no bytes") }
        let typedPtr = ptr.withMemoryRebound(to: ContentType.self, capacity: count / MemoryLayout<ContentType>.stride) {
            $0
        }
        return try body(typedPtr)
    }
    
    /// Returns a read-only pointer to the bytes of a CFData object.
    public func bytes() -> UnsafePointer<UInt8>! {
        CFDataGetBytePtr(self)
    }
}
