//
//  UnsafeRawBufferPointer+.swift
//  
//
//  Created by Florian Zand on 29.11.25.
//

import Foundation

public extension UnsafeRawBufferPointer {
    /**
     Returns a new instance of the given type, read from the buffer pointer’s raw memory at the specified byte offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The buffer pointer plus offset must be properly aligned for accessing an instance of type `T`.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func load<T>(fromByteOffset offset: Int = 0) -> T {
        load(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T {
            loadUnaligned(fromByteOffset: offset, as: T.self)
    }
    
    /**
     Returns a new instance of the given type, constructed from the raw memory at the specified offset.
     
     - Parameter offset: The offset, in bytes, into the buffer pointer’s memory at which to begin reading data for the new instance. The default is zero.
     - Returns: A new instance of type `T`, copied from the buffer pointer’s memory.
     */
    func loadUnaligned<T>(fromByteOffset offset: Int = 0) -> T where T : BitwiseCopyable {
            loadUnaligned(fromByteOffset: offset, as: T.self)
    }
}
