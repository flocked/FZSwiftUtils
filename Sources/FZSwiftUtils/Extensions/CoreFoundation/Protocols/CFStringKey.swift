//
//  CFStringKey.swift
//
//
//  Created by Florian Zand on 02.11.25.
//

import Foundation

/**
 A  type that can be represented by a `CFString`.
 
 Example usage:
 
 ```swift
 struct ImageProperty: CFStringKey {
    static let width = kCGImagePropertyPixelWidth as Self
    static let height = kCGImagePropertyPixelHeight as Self
    static let fileSize = kCGImagePropertyFileSize as Self
    static let hasAlpha = kCGImagePropertyHasAlpha as Self

     let rawValue: CFString
 
     init(rawValue: CFString) {
         self.rawValue = rawValue
     }
 }
 ```
 */
public protocol CFStringKey: RawRepresentable, ReferenceConvertible, ExpressibleByStringLiteral, _CFConvertible where RawValue == CFString, ReferenceType == NSString, _CFType == CFString {
    init(_ rawValue: CFString)
}

public extension CFStringKey {
    init(_ rawValue: CFString) {
        self.init(rawValue: rawValue)!
    }
    
    init(stringLiteral value: String) {
        self.init(.from(value))
    }
    
    var description: String {
        String._bridgeFromCF(rawValue)
    }
    
    var debugDescription: String {
        description
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue.isEqual(to: rhs.rawValue)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.cfHash)
    }
    
    func _bridgeToObjectiveC() -> NSString {
        rawValue._bridgeToNS()
    }
    
    static func _forceBridgeFromObjectiveC(_ source: NSString, result: inout Self?) {
        result = Self(CFString._bridgeFromNS(source))
    }
    
    static func _conditionallyBridgeFromObjectiveC(_ source: NSString, result: inout Self?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    static func _unconditionallyBridgeFromObjectiveC(_ source: NSString?) -> Self {
        var result: Self?
        _forceBridgeFromObjectiveC(source!, result: &result)
        return result!
    }
    
    func _bridgeToCF() -> CFString {
        rawValue
    }
    
    static func _bridgeFromCF(_ source: CFString) -> Self {
        Self(source)
    }
}
