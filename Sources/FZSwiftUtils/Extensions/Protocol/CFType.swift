//
//  CFType.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation
import CoreGraphics

/**
 A Core Foundation type.
 
 This protocol allows extending Core Foundation types with custom initalizers which is normally not allowed.
 */
public protocol CFType {
    /// The Core Foundation type identifier.
    static var typeID: CFTypeID { get }
}

extension CGColor: CFType { }
extension CGColorSpace: CFType { }
extension CGGradient: CFType { }
extension CGPath: CFType { }
extension CGImage: CFType { }

#if os(macOS)
import Carbon
extension CGEvent: CFType { }
#endif

extension CFString: CFType {
    /// Returns the Core Foundation type identifier for a `CFString` type.
    public static var typeID: CFTypeID { CFStringGetTypeID() }
}
extension CFNumber: CFType {
    /// Returns the Core Foundation type identifier for a `CFNumber` type.
    public static var typeID: CFTypeID { CFNumberGetTypeID() }
}
extension CFArray: CFType {
    /// Returns the Core Foundation type identifier for a `CFArray` type.
    public static var typeID: CFTypeID { CFArrayGetTypeID() }
}
extension CFDictionary: CFType {
    /// Returns the Core Foundation type identifier for a `CFDictionary` type.
    public static var typeID: CFTypeID { CFDictionaryGetTypeID() }
}
extension CFSet: CFType {
    /// Returns the Core Foundation type identifier for a `CFSet` type.
    public static var typeID: CFTypeID { CFSetGetTypeID() }
}
extension CFDate: CFType {
    /// Returns the Core Foundation type identifier for a `CFDate` type.
    public static var typeID: CFTypeID { CFDateGetTypeID() }
}
extension CFURL: CFType {
    /// Returns the Core Foundation type identifier for a `CFURL` type.
    public static var typeID: CFTypeID { CFURLGetTypeID() }
}
extension CFBag: CFType {
    /// Returns the Core Foundation type identifier for a `CFBag` type.
    public static var typeID: CFTypeID { CFBagGetTypeID() }
}
extension CFData: CFType {
    /// Returns the Core Foundation type identifier for a `CFData` type.
    public static var typeID: CFTypeID { CFDataGetTypeID() }
}

extension CFType {
    public init?(_ value: Any) {
        guard CFGetTypeID(value as AnyObject) == Self.typeID else { return nil }
        self = value as! Self
    }
    
    public init?(_ value: Any?) {
        guard let value = value as? AnyObject, CFGetTypeID(value) == Self.typeID else { return nil }
        self = value as! Self
    }
}
