//
//  CFType.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation
import CoreGraphics

/**
 Core Foundation / Core Graphics type.
 
 This protocol allows extending Core Foundation / Core Graphics with custom initalizers which is normally not allowed.
 */
public protocol CFType {
    static var typeID: CFTypeID { get }
}

// Core Graphics types
extension CGColor: CFType { }
extension CGColorSpace: CFType { }
extension CGGradient: CFType { }
extension CGPath: CFType { }
extension CGImage: CFType { }

#if os(macOS)
import Carbon
extension CGEvent: CFType { }
#endif

/*
// Core Foundation types
extension CFString: CFType { }
extension CFNumber: CFType { }
extension CFArray: CFType { }
extension CFDictionary: CFType { }
extension CFSet: CFType { }
extension CFDate: CFType { }
extension CFURL: CFType { }
extension CFBag: CFType { }
extension CFData: CFType { }
 */

/*
extension CGAffineTransform: CFType { }
extension CGPoint: CFType { }
extension CGSize: CFType { }
extension CGRect: CFType { }
extension CGVector: CFType { }
 */

extension CFType {
    public init?(_ value: Any) {
        guard let value = value as? AnyObject, CFGetTypeID(value) == Self.typeID else { return nil }
        self = value as! Self
    }
    
    public init?(_ value: Any?) {
        guard let value = value as? AnyObject, CFGetTypeID(value) == Self.typeID else { return nil }
        self = value as! Self
    }
}
