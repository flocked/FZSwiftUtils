//
//  ObjCIvar.swift
//  
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

/// An Objective-C insttance variable.
public struct ObjCIvar {
    /// The instance variable.
    public let ivar: Ivar
    
    public init(_ ivar: Ivar) {
        self.ivar = ivar
    }
    
    /// The name of the instance variable.
    public var name: String? {
        ivar_getName(ivar)?.string
    }
    
    /// The offset of the instance variable.
    public var offset: Int {
        ivar_getOffset(ivar)
    }
    
    /// The type encoding of the instance variable.
    public var typeEncoding: String? {
        ivar_getTypeEncoding(ivar)?.string
    }
}
