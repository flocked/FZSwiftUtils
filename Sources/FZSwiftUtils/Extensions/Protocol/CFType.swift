//
//  CFType.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation
import CoreGraphics
import ImageIO

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
    
    /// A textual description of the objects.
    public static var cfDescription: CFString {
        CFCopyTypeIDDescription(typeID)
    }
    
    /// A textual description of the object.
    public var cfDescription: CFString {
        CFCopyDescription(self as AnyObject)
    }
    
    /// Determines whether two Core Foundation objects are considered equal.
    public func cfEqual(to v: CFTypeRef) -> Bool {
        CFEqual(self as AnyObject, v)
    }
    
    /// The hash value of the object.
    public var cfHash: CFHashCode {
        CFHash(self as AnyObject)
    }
    
    /// The reference count of the object.
    public var cfRetainCount: CFIndex {
        CFGetRetainCount(self as AnyObject)
    }
    
    /// The allocator used to allocate the object.
    public var cfAllocator: CFAllocator {
        CFGetAllocator(self as AnyObject)
    }
}

extension CGColor: CFType { }
extension CGColorConversionInfo: CFType {}
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
extension CGPDFDocument: CFType {}

#if os(macOS)
extension CGDisplayMode: CFType {}
extension CGDisplayStream: CFType {}
extension CGEvent: CFType { }
extension CGEventSource: CFType {}
extension CGPSConverter: CFType {}
extension CFUserNotification: CFType {
    public static let typeID = CFUserNotificationGetTypeID()
}
#endif

extension CFString: CFType {
    /// The Core Foundation type identifier for `CFString`.
    public static var typeID: CFTypeID { CFStringGetTypeID() }
}
extension CFNumber: CFType {
    /// The Core Foundation type identifier for `CFNumber`.
    public static var typeID: CFTypeID { CFNumberGetTypeID() }
}
extension CFArray: CFType {
    /// The Core Foundation type identifier for `CFArray`.
    public static var typeID: CFTypeID { CFArrayGetTypeID() }
}
extension CFDictionary: CFType {
    /// The Core Foundation type identifier for `CFDictionary`.
    public static var typeID: CFTypeID { CFDictionaryGetTypeID() }
}
extension CFSet: CFType {
    /// The Core Foundation type identifier for `CFSet`.
    public static var typeID: CFTypeID { CFSetGetTypeID() }
}
extension CFDate: CFType {
    /// The Core Foundation type identifier for `CFDate`.
    public static var typeID: CFTypeID { CFDateGetTypeID() }
}
extension CFTree: CFType {
    /// The Core Foundation type identifier for `CFTree`.
    public static let typeID = CFTreeGetTypeID()
}
extension CFURL: CFType {
    /// The Core Foundation type identifier for `CFURL`.
    public static var typeID: CFTypeID { CFURLGetTypeID() }
}
extension CFBag: CFType {
    /// The Core Foundation type identifier for `CFBag`.
    public static var typeID: CFTypeID { CFBagGetTypeID() }
}
extension CFData: CFType {
    /// The Core Foundation type identifier for `CFData`.
    public static var typeID: CFTypeID { CFDataGetTypeID() }
}
extension CFBoolean: CFType {
    /// The Core Foundation type identifier for `CFBoolean`.
    public static var typeID: CFTypeID { CFBooleanGetTypeID() }
}
extension CFAllocator: CFType {
    /// The Core Foundation type identifier for `CFAllocator`.
    public static var typeID: CFTypeID { CFAllocatorGetTypeID() }
}
extension CFAttributedString: CFType {
    /// The Core Foundation type identifier for `CFAttributedString`.
    public static var typeID: CFTypeID { CFAttributedStringGetTypeID() }
}
extension CFBinaryHeap: CFType {
    /// The Core Foundation type identifier for `CFBinaryHeap`.
    public static var typeID: CFTypeID { CFBinaryHeapGetTypeID() }
}
extension CFBitVector: CFType {
    /// The Core Foundation type identifier for `CFBitVector`.
    public static var typeID: CFTypeID { CFBitVectorGetTypeID() }
}
extension CFBundle: CFType {
    /// The Core Foundation type identifier for `CFBundle`.
    public static var typeID: CFTypeID { CFBundleGetTypeID() }
}
extension CFCalendar: CFType {
    /// The Core Foundation type identifier for `CFCalendar`.
    public static var typeID: CFTypeID { CFCalendarGetTypeID() }
}
extension CFCharacterSet: CFType {
    /// The Core Foundation type identifier for `CFCharacterSet`.
    public static var typeID: CFTypeID { CFCharacterSetGetTypeID() }
}
extension CFDateFormatter: CFType {
    /// The Core Foundation type identifier for `CFDateFormatter`.
    public static var typeID: CFTypeID { CFDateFormatterGetTypeID() }
}
extension CFError: CFType {
    /// The Core Foundation type identifier for `CFError`.
    public static var typeID: CFTypeID { CFErrorGetTypeID() }
}
extension CFFileDescriptor: CFType {
    /// The Core Foundation type identifier for `CFFileDescriptor`.
    public static var typeID: CFTypeID { CFFileDescriptorGetTypeID() }
}
extension CFFileSecurity: CFType {
    /// The Core Foundation type identifier for `CFFileSecurity`.
    public static var typeID: CFTypeID { CFFileSecurityGetTypeID() }
}
extension CFLocale: CFType {
    /// The Core Foundation type identifier for `CFLocale`.
    public static var typeID: CFTypeID { CFLocaleGetTypeID() }
}
extension CFMachPort: CFType {
    /// The Core Foundation type identifier for `CFMachPort`.
    public static var typeID: CFTypeID { CFMachPortGetTypeID() }
}
extension CFMessagePort: CFType {
    /// The Core Foundation type identifier for `CFMessagePort`.
    public static var typeID: CFTypeID { CFMessagePortGetTypeID() }
}
extension CFNotificationCenter: CFType {
    /// The Core Foundation type identifier for `CFNotificationCenter`.
    public static var typeID: CFTypeID { CFNotificationCenterGetTypeID() }
}
extension CFNull: CFType {
    /// The Core Foundation type identifier for `CFNull`.
    public static var typeID: CFTypeID { CFNullGetTypeID() }
}
extension CFNumberFormatter: CFType {
    /// The Core Foundation type identifier for `CFNumberFormatter`.
    public static var typeID: CFTypeID { CFNumberFormatterGetTypeID() }
}
extension CFPlugIn: CFType {
    /// The Core Foundation type identifier for `CFPlugIn`.
    public static var typeID: CFTypeID { CFPlugInGetTypeID() }
}
extension CFPlugInInstance: CFType {
    /// The Core Foundation type identifier for `CFPlugInInstance`.
    public static var typeID: CFTypeID { CFPlugInInstanceGetTypeID() }
}
extension CFReadStream: CFType {
    /// The Core Foundation type identifier for `CFReadStream`.
    public static var typeID: CFTypeID { CFReadStreamGetTypeID() }
}
extension CFRunLoop: CFType {
    /// The Core Foundation type identifier for `CFRunLoop`.
    public static var typeID: CFTypeID { CFRunLoopGetTypeID() }
}
extension CFRunLoopObserver: CFType {
    /// The Core Foundation type identifier for `CFRunLoopObserver`.
    public static var typeID: CFTypeID { CFRunLoopObserverGetTypeID() }
}
extension CFRunLoopSource: CFType {
    /// The Core Foundation type identifier for `CFRunLoopSource`.
    public static var typeID: CFTypeID { CFRunLoopSourceGetTypeID() }
}
extension CFRunLoopTimer: CFType {
    /// The Core Foundation type identifier for `CFRunLoopTimer`.
    public static var typeID: CFTypeID { CFRunLoopTimerGetTypeID() }
}
extension CFSocket: CFType {
    /// The Core Foundation type identifier for `CFSocket`.
    public static var typeID: CFTypeID { CFSocketGetTypeID() }
}
extension CFStringTokenizer: CFType {
    /// The Core Foundation type identifier for `CFStringTokenizer`.
    public static var typeID: CFTypeID { CFStringTokenizerGetTypeID() }
}
extension CFTimeZone: CFType {
    /// The Core Foundation type identifier for `CFTimeZone`.
    public static var typeID: CFTypeID { CFTimeZoneGetTypeID() }
}
extension CFURLEnumerator: CFType {
    /// The Core Foundation type identifier for `CFURLEnumerator`.
    public static var typeID: CFTypeID { CFURLEnumeratorGetTypeID() }
}
extension CFUUID: CFType {
    /// The Core Foundation type identifier for `CFUUID`.
    public static var typeID: CFTypeID { CFUUIDGetTypeID() }
}
extension CFWriteStream: CFType {
    /// The Core Foundation type identifier for `CFWriteStream`.
    public static var typeID: CFTypeID { CFWriteStreamGetTypeID() }
}

extension CGImageSource: CFType {
    /// The Core Foundation type identifier for `CGImageSource`.
    public static var typeID: CFTypeID { CGImageSourceGetTypeID() }
}

extension CGImageDestination: CFType {
    /// The Core Foundation type identifier for `CGImageDestination`.
    public static var typeID: CFTypeID { CGImageDestinationGetTypeID() }
}
