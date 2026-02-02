//
//  CFType+CFTollFreeSwiftBridgeable.swift
//  
//
//  Created by Florian Zand on 02.02.26.
//

import Foundation

/// A Core Foundation type that can be converted to a `NSObject` type.
public protocol _CFTollFreeSwiftBridgeable: CFType, AnyObject {
    associatedtype BridgedSwiftType
}

public extension _CFTollFreeSwiftBridgeable {
    /// Returns the `NSObject` based representation of the value.
    var asSwift: BridgedSwiftType {
        _bridgeToSwift()
    }
    
    /// Returns the value from the specified `NSObject` value.
    static func from(_ v: BridgedSwiftType) -> Self {
        ._bridgeFromSwift(v)
    }
    
    @inlinable
    static func _bridgeFromSwift(_ source: BridgedSwiftType) -> Self {
        cast(source)
    }
    
    @inlinable
    func _bridgeToSwift() -> BridgedSwiftType {
        cast(self)
    }
}

extension CFType where Self: _CFTollFreeSwiftBridgeable {
    /// Creates the object from the specified `NSObject` value.
    public init(_ value: BridgedSwiftType)  {
        self = Self._bridgeFromSwift(value)
    }
}

extension CFBundle: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Bundle
}

extension CFCalendar: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Calendar
}

extension CFCharacterSet: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = CharacterSet
}

extension CFData: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Data
}

extension CFDate: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Date
}

extension CFDateFormatter: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = DateFormatter
}

extension CFError: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Error
}

extension CFLocale: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Locale
}

extension CFMutableCharacterSet {
    public typealias BridgedSwiftType = CharacterSet
}

extension CFMutableData {
    public typealias BridgedSwiftType = Data
}

extension CFMutableString {
    public typealias BridgedSwiftType = String
}

extension CFReadStream: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = InputStream
}

extension CFRunLoopTimer: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = Timer
}

extension CFString: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = String
}

extension CFTimeZone: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = TimeZone
}

extension CFURL: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = URL
}

extension CFWriteStream: _CFTollFreeSwiftBridgeable {
    public typealias BridgedSwiftType = OutputStream
}
