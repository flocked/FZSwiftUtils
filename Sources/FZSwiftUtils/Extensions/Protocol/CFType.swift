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
    init?(_ value: Any)
    init?(_ value: Any?)
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

extension CGColor: CFType { }
extension CGColorSpace: CFType { }
extension CGGradient: CFType { }
extension CGPath: CFType { }
extension CGImage: CFType { }
extension CGFont: CFType { }
extension CGLayer: CFType { }
extension CGContext: CFType { }
extension CGShading: CFType { }
extension CGFunction: CFType { }
extension CGPattern: CFType { }
extension CGDataProvider: CFType { }
extension CGDataConsumer: CFType { }
extension CGPDFPage: CFType { }

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
extension CFBoolean: CFType {
    /// Returns the Core Foundation type identifier for a `CFBoolean` type.
    public static var typeID: CFTypeID { CFBooleanGetTypeID() }
}
extension CFAllocator: CFType {
    /// Returns the Core Foundation type identifier for a `CFAllocator` type.
    public static var typeID: CFTypeID { CFAllocatorGetTypeID() }
}
extension CFAttributedString: CFType {
    /// Returns the Core Foundation type identifier for a `CFAttributedString` type.
    public static var typeID: CFTypeID { CFAttributedStringGetTypeID() }
}
extension CFBinaryHeap: CFType {
    /// Returns the Core Foundation type identifier for a `CFBinaryHeap` type.
    public static var typeID: CFTypeID { CFBinaryHeapGetTypeID() }
}
extension CFBitVector: CFType {
    /// Returns the Core Foundation type identifier for a `CFBitVector` type.
    public static var typeID: CFTypeID { CFBitVectorGetTypeID() }
}
extension CFBundle: CFType {
    /// Returns the Core Foundation type identifier for a `CFBundle` type.
    public static var typeID: CFTypeID { CFBundleGetTypeID() }
}
extension CFCalendar: CFType {
    /// Returns the Core Foundation type identifier for a `CFCalendar` type.
    public static var typeID: CFTypeID { CFCalendarGetTypeID() }
}
extension CFCharacterSet: CFType {
    /// Returns the Core Foundation type identifier for a `CFCharacterSet` type.
    public static var typeID: CFTypeID { CFCharacterSetGetTypeID() }
}
extension CFDateFormatter: CFType {
    /// Returns the Core Foundation type identifier for a `CFDateFormatter` type.
    public static var typeID: CFTypeID { CFDateFormatterGetTypeID() }
}
extension CFError: CFType {
    /// Returns the Core Foundation type identifier for a `CFError` type.
    public static var typeID: CFTypeID { CFErrorGetTypeID() }
}
extension CFFileDescriptor: CFType {
    /// Returns the Core Foundation type identifier for a `CFFileDescriptor` type.
    public static var typeID: CFTypeID { CFFileDescriptorGetTypeID() }
}
extension CFFileSecurity: CFType {
    /// Returns the Core Foundation type identifier for a `CFFileSecurity` type.
    public static var typeID: CFTypeID { CFFileSecurityGetTypeID() }
}
extension CFLocale: CFType {
    /// Returns the Core Foundation type identifier for a `CFLocale` type.
    public static var typeID: CFTypeID { CFLocaleGetTypeID() }
}
extension CFMachPort: CFType {
    /// Returns the Core Foundation type identifier for a `CFMachPort` type.
    public static var typeID: CFTypeID { CFMachPortGetTypeID() }
}
extension CFMessagePort: CFType {
    /// Returns the Core Foundation type identifier for a `CFMessagePort` type.
    public static var typeID: CFTypeID { CFMessagePortGetTypeID() }
}
extension CFNotificationCenter: CFType {
    /// Returns the Core Foundation type identifier for a `CFNotificationCenter` type.
    public static var typeID: CFTypeID { CFNotificationCenterGetTypeID() }
}
extension CFNull: CFType {
    /// Returns the Core Foundation type identifier for a `CFNull` type.
    public static var typeID: CFTypeID { CFNullGetTypeID() }
}
extension CFNumberFormatter: CFType {
    /// Returns the Core Foundation type identifier for a `CFNumberFormatter` type.
    public static var typeID: CFTypeID { CFNumberFormatterGetTypeID() }
}
extension CFPlugIn: CFType {
    /// Returns the Core Foundation type identifier for a `CFPlugIn` type.
    public static var typeID: CFTypeID { CFPlugInGetTypeID() }
}
extension CFPlugInInstance: CFType {
    /// Returns the Core Foundation type identifier for a `CFPlugInInstance` type.
    public static var typeID: CFTypeID { CFPlugInInstanceGetTypeID() }
}
extension CFReadStream: CFType {
    /// Returns the Core Foundation type identifier for a `CFReadStream` type.
    public static var typeID: CFTypeID { CFReadStreamGetTypeID() }
}
extension CFRunLoop: CFType {
    /// Returns the Core Foundation type identifier for a `CFRunLoop` type.
    public static var typeID: CFTypeID { CFRunLoopGetTypeID() }
}
extension CFRunLoopObserver: CFType {
    /// Returns the Core Foundation type identifier for a `CFRunLoopObserver` type.
    public static var typeID: CFTypeID { CFRunLoopObserverGetTypeID() }
}
extension CFRunLoopSource: CFType {
    /// Returns the Core Foundation type identifier for a `CFRunLoopSource` type.
    public static var typeID: CFTypeID { CFRunLoopSourceGetTypeID() }
}
extension CFRunLoopTimer: CFType {
    /// Returns the Core Foundation type identifier for a `CFRunLoopTimer` type.
    public static var typeID: CFTypeID { CFRunLoopTimerGetTypeID() }
}
extension CFSocket: CFType {
    /// Returns the Core Foundation type identifier for a `CFSocket` type.
    public static var typeID: CFTypeID { CFSocketGetTypeID() }
}
extension CFStringTokenizer: CFType {
    /// Returns the Core Foundation type identifier for a `CFStringTokenizer` type.
    public static var typeID: CFTypeID { CFStringTokenizerGetTypeID() }
}
extension CFTimeZone: CFType {
    /// Returns the Core Foundation type identifier for a `CFTimeZone` type.
    public static var typeID: CFTypeID { CFTimeZoneGetTypeID() }
}
extension CFURLEnumerator: CFType {
    /// Returns the Core Foundation type identifier for a `CFURLEnumerator` type.
    public static var typeID: CFTypeID { CFURLEnumeratorGetTypeID() }
}
extension CFUUID: CFType {
    /// Returns the Core Foundation type identifier for a `CFUUID` type.
    public static var typeID: CFTypeID { CFUUIDGetTypeID() }
}
extension CFWriteStream: CFType {
    /// Returns the Core Foundation type identifier for a `CFWriteStream` type.
    public static var typeID: CFTypeID { CFWriteStreamGetTypeID() }
}
