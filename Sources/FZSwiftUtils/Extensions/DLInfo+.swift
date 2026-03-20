//
//  DLInfo+.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 14.03.26.
//

import Foundation

extension Dl_info {
    /**
     Initializes a `Dl_info` structure describing the dynamic loader information for the specified address.
         
     If the dynamic loader cannot resolve the address to a loaded image, this initializer throws an error.
     
     - Parameter ptr: A pointer to an address within a loaded image, such as a function pointer or symbol address.
     */
    public init(_ ptr: UnsafeRawPointer) throws {
        var info = Dl_info()
        guard dladdr(ptr, &info) != 0 else {
            throw Error(errorDescription: dlerror().map { String(cString: $0) })
        }
        self = info
    }
    
    struct Error: LocalizedError {
        public let errorDescription: String?
    }
}
