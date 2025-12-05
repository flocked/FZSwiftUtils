//
//  CFAllocator+.swift
//
//
//  Created by Florian Zand on 29.11.25.
//

import Foundation

public extension CFAllocator {
    /**
     The default allocator.
     
     If none has been set, it returns `kCFAllocatorDefault` which is a synonym for `NULL`.
     */
    static var `default`: CFAllocator {
        get { CFAllocatorGetDefault().takeUnretainedValue() }
        set { CFAllocatorSetDefault(newValue) }
    }
    
    /**
     Default system allocator.
     
     You rarely need to use this.
     */
    static let systemDefault = kCFAllocatorSystemDefault!
    
    /**
     This allocator uses `malloc()`, `realloc()`, and `free()`.
     
     Typically you should not use this allocator, use ``CoreFoundation/CFAllocator/default`` instead. This allocator is useful as the `bytesDeallocator` in `CFData` or `contentsDeallocator` in `CFString` where the memory was obtained as a result of malloc type functions.
     */
    static let malloc = kCFAllocatorMalloc!
    
    /**
     This allocator explicitly uses the default malloc zone, returned by `malloc_default_zone()`.
     
     You should only use this when an object is safe to be allocated in non-scanned memory.
     */
    static let mallocZone = kCFAllocatorMallocZone!
    
    /**
     This allocator does nothing—it allocates no memory.
     
     This allocator is useful as the `bytesDeallocator` in `CFData` or `contentsDeallocator` in `CFString` where the memory should not be freed.
     */
    static let null = kCFAllocatorNull!
    
    /// Special allocator argument to `CFAllocatorCreate(_:_:)`—it uses the functions given in the context to allocate the allocator.
    static let useContext = kCFAllocatorUseContext!
}
