//
//  CFType.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation
import CoreGraphics

/**
 A Core Foundation / Core Graphics type.
 
 This protocol allows extending Core Foundation / Core Graphics with custom initalizers which is normally not allowed.
 */
public protocol CFType {
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
    public static var typeID: CFTypeID { CFStringGetTypeID() }
}
extension CFNumber: CFType {
    public static var typeID: CFTypeID { CFNumberGetTypeID() }
}
extension CFArray: CFType {
    public static var typeID: CFTypeID { CFArrayGetTypeID() }
}
extension CFDictionary: CFType {
    public static var typeID: CFTypeID { CFDictionaryGetTypeID() }
}
extension CFSet: CFType {
    public static var typeID: CFTypeID { CFSetGetTypeID() }
}
extension CFDate: CFType {
    public static var typeID: CFTypeID { CFDateGetTypeID() }
}
extension CFURL: CFType {
    public static var typeID: CFTypeID { CFURLGetTypeID() }
}
extension CFBag: CFType {
    public static var typeID: CFTypeID { CFBagGetTypeID() }
}
extension CFData: CFType {
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
