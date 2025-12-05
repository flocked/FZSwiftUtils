//
//  CFType.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import Foundation
import CoreGraphics
import ImageIO
import CoreText

/// A Core Foundation type.
public protocol CFType {
    /// The Core Foundation type identifier.
    static var typeID: CFTypeID { get }
    init?(_ value: Any)
    init?(_ value: Any?)
}

extension CFType {
    /// Returns the value as the specified `Swift` type.
    public func asSwift<T: _CFConvertible>() -> T where T._CFType == Self {
        T._bridgeFromCF(self)
    }
    
    /// Returns the value from the specified `Swift` value.
    public static func from<T: _CFConvertible>(_ v: T) -> Self where T._CFType == Self {
        v._bridgeToCF()
    }
    
    /// Creates the object from the specified `Swift` value.
    public init<T:_CFConvertible >(_ value: T)  where T._CFType == Self {
        self = value._bridgeToCF()
    }
    
    public init?(_ value: Any) {
        guard CFGetTypeID(value as AnyObject) == Self.typeID else { return nil }
        self = value as! Self
    }
    
    public init?(_ value: Any?) {
        guard let value = value as? AnyObject, CFGetTypeID(value) == Self.typeID else { return nil }
        self = value as! Self
    }
    
    public init?(_ value: Self?) {
        guard let value = value else { return nil }
        self = value
    }
}

extension CFType {
    /// Determines whether the object is equal to the specified other object.
    public func isEqual(to other: Self) -> Bool {
        CFEqual(self as AnyObject, other as AnyObject)
    }
    
    /// A textual description of the objects.
    public static var cfDescription: String {
        CFCopyTypeIDDescription(typeID) as String
    }
    
    /// A textual description of the object.
    public var cfDescription: String {
        CFCopyDescription(self as AnyObject) as String
    }
    
    /// The hash value of the object.
    public var cfHash: UInt {
        CFHash(self as AnyObject) as UInt
    }
    
    /// The reference count of the object.
    public var cfRetainCount: Int {
        CFGetRetainCount(self as AnyObject) as Int
    }
    
    /// The allocator used to allocate the object.
    public var cfAllocator: CFAllocator {
        CFGetAllocator(self as AnyObject)
    }
    
    /// The identifier of the object.
    public var objectID: ObjectIdentifier {
        ObjectIdentifier(self as AnyObject)
    }
}

extension CGColor: CFType { }
extension CGColorConversionInfo: CFType { }
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
extension CGPDFDocument: CFType { }
extension CFString: CFType {
    /// The Core Foundation type identifier for `CFString`.
    public static let typeID = CFStringGetTypeID()
}
extension CFNumber: CFType {
    /// The Core Foundation type identifier for `CFNumber`.
    public static let typeID = CFNumberGetTypeID()
}
extension CFArray: CFType {
    /// The Core Foundation type identifier for `CFArray`.
    public static let typeID = CFArrayGetTypeID()
}
extension CFDictionary: CFType {
    /// The Core Foundation type identifier for `CFDictionary`.
    public static let typeID = CFDictionaryGetTypeID()
}
extension CFSet: CFType {
    /// The Core Foundation type identifier for `CFSet`.
    public static let typeID = CFSetGetTypeID()
}
extension CFDate: CFType {
    /// The Core Foundation type identifier for `CFDate`.
    public static let typeID = CFDateGetTypeID()
}
extension CFTree: CFType {
    /// The Core Foundation type identifier for `CFTree`.
    public static let typeID = CFTreeGetTypeID()
}
extension CFURL: CFType {
    /// The Core Foundation type identifier for `CFURL`.
    public static let typeID = CFURLGetTypeID()
}
extension CFBag: CFType {
    /// The Core Foundation type identifier for `CFBag`.
    public static let typeID = CFBagGetTypeID()
}
extension CFData: CFType {
    /// The Core Foundation type identifier for `CFData`.
    public static let typeID = CFDataGetTypeID()
}
extension CFBoolean: CFType {
    /// The Core Foundation type identifier for `CFBoolean`.
    public static let typeID = CFBooleanGetTypeID()
}
extension CFAllocator: CFType {
    /// The Core Foundation type identifier for `CFAllocator`.
    public static let typeID = CFAllocatorGetTypeID()
}
extension CFAttributedString: CFType {
    /// The Core Foundation type identifier for `CFAttributedString`.
    public static let typeID = CFAttributedStringGetTypeID()
}
extension CFBinaryHeap: CFType {
    /// The Core Foundation type identifier for `CFBinaryHeap`.
    public static let typeID = CFBinaryHeapGetTypeID()
}
extension CFBitVector: CFType {
    /// The Core Foundation type identifier for `CFBitVector`.
    public static let typeID = CFBitVectorGetTypeID()
}
extension CFBundle: CFType {
    /// The Core Foundation type identifier for `CFBundle`.
    public static let typeID = CFBundleGetTypeID()
}
extension CFCalendar: CFType {
    /// The Core Foundation type identifier for `CFCalendar`.
    public static let typeID = CFCalendarGetTypeID()
}
extension CFCharacterSet: CFType {
    /// The Core Foundation type identifier for `CFCharacterSet`.
    public static let typeID = CFCharacterSetGetTypeID()
}
extension CFDateFormatter: CFType {
    /// The Core Foundation type identifier for `CFDateFormatter`.
    public static let typeID = CFDateFormatterGetTypeID()
}
extension CFError: CFType {
    /// The Core Foundation type identifier for `CFError`.
    public static let typeID = CFErrorGetTypeID()
}
extension CFFileDescriptor: CFType {
    /// The Core Foundation type identifier for `CFFileDescriptor`.
    public static let typeID = CFFileDescriptorGetTypeID()
}
extension CFFileSecurity: CFType {
    /// The Core Foundation type identifier for `CFFileSecurity`.
    public static let typeID = CFFileSecurityGetTypeID()
}
extension CFLocale: CFType {
    /// The Core Foundation type identifier for `CFLocale`.
    public static let typeID = CFLocaleGetTypeID()
}
extension CFMachPort: CFType {
    /// The Core Foundation type identifier for `CFMachPort`.
    public static let typeID = CFMachPortGetTypeID()
}
extension CFMessagePort: CFType {
    /// The Core Foundation type identifier for `CFMessagePort`.
    public static let typeID = CFMessagePortGetTypeID()
}
extension CFNotificationCenter: CFType {
    /// The Core Foundation type identifier for `CFNotificationCenter`.
    public static let typeID = CFNotificationCenterGetTypeID()
}
extension CFNull: CFType {
    /// The Core Foundation type identifier for `CFNull`.
    public static let typeID = CFNullGetTypeID()
}
extension CFNumberFormatter: CFType {
    /// The Core Foundation type identifier for `CFNumberFormatter`.
    public static let typeID = CFNumberFormatterGetTypeID()
}
extension CFPlugIn: CFType {
    /// The Core Foundation type identifier for `CFPlugIn`.
    public static let typeID = CFPlugInGetTypeID()
}
extension CFPlugInInstance: CFType {
    /// The Core Foundation type identifier for `CFPlugInInstance`.
    public static let typeID = CFPlugInInstanceGetTypeID()
}
extension CFReadStream: CFType {
    /// The Core Foundation type identifier for `CFReadStream`.
    public static let typeID = CFReadStreamGetTypeID()
}
extension CFRunLoop: CFType {
    /// The Core Foundation type identifier for `CFRunLoop`.
    public static let typeID = CFRunLoopGetTypeID()
}
extension CFRunLoopObserver: CFType {
    /// The Core Foundation type identifier for `CFRunLoopObserver`.
    public static let typeID = CFRunLoopObserverGetTypeID()
}
extension CFRunLoopSource: CFType {
    /// The Core Foundation type identifier for `CFRunLoopSource`.
    public static let typeID = CFRunLoopSourceGetTypeID()
}
extension CFRunLoopTimer: CFType {
    /// The Core Foundation type identifier for `CFRunLoopTimer`.
    public static let typeID = CFRunLoopTimerGetTypeID()
}
extension CFSocket: CFType {
    /// The Core Foundation type identifier for `CFSocket`.
    public static let typeID = CFSocketGetTypeID()
}
extension CFStringTokenizer: CFType {
    /// The Core Foundation type identifier for `CFStringTokenizer`.
    public static let typeID = CFStringTokenizerGetTypeID()
}
extension CFTimeZone: CFType {
    /// The Core Foundation type identifier for `CFTimeZone`.
    public static let typeID = CFTimeZoneGetTypeID()
}
extension CFURLEnumerator: CFType {
    /// The Core Foundation type identifier for `CFURLEnumerator`.
    public static let typeID = CFURLEnumeratorGetTypeID()
}
extension CFUUID: CFType {
    /// The Core Foundation type identifier for `CFUUID`.
    public static let typeID = CFUUIDGetTypeID()
}
extension CFWriteStream: CFType {
    /// The Core Foundation type identifier for `CFWriteStream`.
    public static let typeID = CFWriteStreamGetTypeID()
}
extension CTFont: CFType {
    /// The Core Foundation type identifier for Core Text font.
    public static let typeID = CTFontGetTypeID()
}
extension CTFontCollection: CFType {
    /// The Core Foundation type identifier for Core Text font collection.
    public static let typeID = CTFontCollectionGetTypeID()
}
extension CTFontDescriptor: CFType {
    /// The Core Foundation type identifier for Core Text font descriptor.
    public static let typeID = CTFontDescriptorGetTypeID()
}
extension CTFrame: CFType {
    /// The Core Foundation type identifier Core Text frame.
    public static let typeID = CTFrameGetTypeID()
}
extension CTFramesetter: CFType {
    /// The Core Foundation type identifier for Core Text frame setter.
    public static let typeID = CTFramesetterGetTypeID()
}
extension CTGlyphInfo: CFType {
    /// The Core Foundation type identifier for Core Text glyph info.
    public static let typeID = CTGlyphInfoGetTypeID()
}
extension CTLine: CFType {
    /// The Core Foundation type identifier of the line object.
    public static let typeID = CTLineGetTypeID()
}
extension CTParagraphStyle: CFType {
    /// The Core Foundation type identifier of the paragraph style object.
    public static let typeID = CTParagraphStyleGetTypeID()
}
extension CTRubyAnnotation: CFType {
    /// The Core Foundation type identifier of the ruby annotation object.
    public static let typeID = CTRubyAnnotationGetTypeID()
}
extension CTRun: CFType {
    /// The Core Foundation type identifier of the run object.
    public static let typeID = CTRunGetTypeID()
}
extension CTTextTab: CFType {
    /// The Core Foundation type identifier of the text tab object.
    public static let typeID = CTTextTabGetTypeID()
}
extension CTTypesetter: CFType {
    /// The Core Foundation type identifier of the typesetter object.
    public static let typeID = CTTypesetterGetTypeID()
}
extension CGImageDestination: CFType {
    /// The Core Foundation type identifier of an image destination opaque type.
    public static let typeID = CGImageDestinationGetTypeID()
}
extension CGImageSource: CFType {
    /// The Core Foundation type identifier for an image source.
    public static let typeID = CGImageSourceGetTypeID()
}
extension CGImageMetadata: CFType {
    /// The Core Foundation type identifier for metadata objects.
    public static let typeID = CGImageMetadataGetTypeID()
}
extension CGImageMetadataTag: CFType {
    /// The Core Foundation type identifier for the image metadata tag opaque type
    public static let typeID = CGImageMetadataTagGetTypeID()
}

#if os(macOS)
extension CGDisplayMode: CFType { }
extension CGDisplayStream: CFType { }
extension CGEvent: CFType { }
extension CGEventSource: CFType { }
extension CGPSConverter: CFType { }
extension CFUserNotification: CFType {
    /// The Core Foundation type identifier for `CFUserNotification`.
    public static let typeID = CFUserNotificationGetTypeID()
}
extension MDQuery: CFType {
    /// The Core Foundation type identifier for `MDQuery`.
    public static let typeID = MDQueryGetTypeID()
}
extension MDItem: CFType {
    /// The Core Foundation type identifier for `MDItem`.
    public static let typeID = MDItemGetTypeID()
}
extension ColorSyncProfile: CFType {
    /// The Core Foundation type identifier for `ColorSyncProfile`.
    public static let typeID = ColorSyncProfileGetTypeID()
}
#endif

#if canImport(IOKit)
import IOKit.hid

extension IOHIDQueue: CFType {
    /// The Core Foundation type identifier of all IOHIDQueue instances.
    public static let typeID = IOHIDQueueGetTypeID()
}
extension IOHIDDevice: CFType {
    /// The Core Foundation type identifier of all IOHIDQueue instances.
    public static let typeID = IOHIDDeviceGetTypeID()
}
extension IOHIDElement: CFType {
    /// The Core Foundation type identifier of all IOHIDElement instances.
    public static let typeID = IOHIDElementGetTypeID()
}
extension IOHIDManager: CFType {
    /// The Core Foundation type identifier of all IOHIDManager instances.
    public static let typeID = IOHIDManagerGetTypeID()
}
extension IOHIDValue: CFType {
    /// The Core Foundation type identifier of all IOHIDValue instances.
    public static let typeID = IOHIDValueGetTypeID()
}
extension IOHIDTransaction: CFType {
    /// The Core Foundation type identifier of all IOHIDTransaction instances.
    public static let typeID = IOHIDTransactionGetTypeID()
}
#endif

#if canImport(ApplicationServices)
import ApplicationServices

extension AXUIElement: CFType {
    /// The Core Foundation type identifier for `AXUIElement`.
    public static let typeID = AXUIElementGetTypeID()
}
extension AXObserver: CFType {
    /// The Core Foundation type identifier for `AXObserver`.
    public static let typeID = AXObserverGetTypeID()
}
extension AXValue: CFType {
    /// The Core Foundation type identifier for `AXValue`.
    public static let typeID = AXValueGetTypeID()
}
#endif

/*
 @inlinable public func cfCast<Source, Target: CFType>(_ v: Source, to type: Target.Type = Target.self) -> Target? {
     let ref = v as CFTypeRef
     if CFGetTypeID(ref) == type.typeID {
         return (ref as! Target)
     } else {
         return nil
     }
 }

 @inlinable public func cfCast<T, Result: _CFTollFreeBridgeable>(_ v: T, to type: Result.Type = Result.self) -> Result? {
     if let nsValue = v as? Result.BridgedNSType {
         return (nsValue as! Result)
     } else {
         return nil
     }
 }

 public extension CFType {
     @inlinable static func cast<Source>(_ v: Source) -> Self? {
         return cfCast(v, to: Self.self)
     }
 }

 public extension _CFTollFreeBridgeable {
     @inlinable static func cast<Source>(_ v: Source) -> Self? {
         return cfCast(v, to: Self.self)
     }
 }
 */
