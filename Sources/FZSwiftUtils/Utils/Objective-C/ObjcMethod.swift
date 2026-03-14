//
//  ObjcMethod.swift
//  
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

/// An Objective-C method.
public struct ObjCMethod {
    /// The method.
    public let method: Method
    
    public init(_ method: Method) {
        self.method = method
    }
    
    /// The name of the method.
    public var name: Selector {
        method_getName(method)
    }
    
    /// The return type of the method.
    public var returnType: String {
        method_copyReturnType(method).stringAndFree()
    }
    
    /// The number of arguments of the mthod.
    public var numberOfArguments: UInt32 {
        method_getNumberOfArguments(method)
    }
    
    /// The argument of the method at the specified index.
    public func argument(at index: UInt32) -> String? {
        method_copyArgumentType(method, index)?.stringAndFree()
    }
    
    /// The arguments of the mthod.
    public var arguments: [String] {
        (0..<numberOfArguments).compactMap({ argument(at: $0) })
    }
    
    /// The type encoding of the method.
    public var typeEncoding: String? {
        method_getTypeEncoding(method)?.string
    }
    
    /// The method description.
    public var description: objc_method_description {
        method_getDescription(method).pointee
    }
    
    /**
     Returns runtime origin information for the method.

     The returned `imagePath` is the path of the Mach-O image that contains the method.
     The returned `symbolName` is the symbol name associated with the method.
     The returned `categoryName` is the Objective-C category name when the symbol represents a category method.
     */
    public func origin() -> (imagePath: String?, symbolName: String?, categoryName: String?) {
        ObjCRuntime.origin(of: method)
    }
}

/// A key representing an Objective-C method.
public struct ObjCMethodKey: Hashable, RawRepresentable {
    public let rawValue: Method
    
    public init(rawValue: Method) {
        self.rawValue = rawValue
    }
    
    public init(_ method: Method) {
        self.rawValue = method
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(UInt(bitPattern: rawValue))
    }
}
