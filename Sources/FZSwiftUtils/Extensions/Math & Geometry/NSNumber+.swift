//
//  NSNumber+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension NSNumber {
    /**
     Returns an NSNumber object initialized to contain the specified value.

     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: Bool) { self.init(value: value) }

    /**
     Returns an NSNumber object initialized to contain the specified value.

     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: CChar) { self.init(value: value) }

    /**
     Returns an NSNumber object initialized to contain the specified value.

     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init<Value>(_ value: Value) where Value: BinaryFloatingPoint { self.init(value: Double(value)) }

    /**
     Returns an `NSNumber object initialized to contain the specified value.

     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: CGFloat) { self.init(value: value) }
    
    /**
     Returns an `NSNumber` object initialized to contain the specified value.

     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init<Value>(_ value: Value) where Value: BinaryInteger {
        if Value.isSigned {
            self.init(value: Int64(value))
        } else {
            self.init(value: UInt64(value))
        }
    }
    
    /// Returns the number as the specified binary integer.
    func binaryInteger<Value: BinaryInteger>() -> Value {
        Value.isSigned ? Value(int64Value) : Value(uint64Value)
    }

    /// Returns the number as the specified binary floating point.
    func binaryFloatingPoint<Value: BinaryFloatingPoint>() -> Value {
        Value(doubleValue)
    }
    
    /**
     Checks if the value represents a Boolean.
     
     ```swift
     NSNumber(value: false).isBool // true
     NSNumber(value: true).isBool // true
     
     NSNumber(value: 0).isBool // false
     NSNumber(value: 1).isBool // false
     ```
     */
    var isBool: Bool {
        CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    /**
     Returns the Boolean value only if the represented value is a Boolean.
     
     ```swift
     NSNumber(value: false).safeBoolValue // false
     NSNumber(value: true).safeBoolValue // true
     
     NSNumber(value: 0).safeBoolValue // nil
     NSNumber(value: 1).safeBoolValue // nil
     ```
     */
    var safeBoolValue: Bool? {
        guard isBool else { return nil }
        return boolValue
    }

    /**
     Returns an `NSNumber` object initialized to contain the specified value of the string.

     - Parameter value: The value of the string for the new number.
     - Returns: An `NSNumber` object containing the value of the string, or `nil` if the string doesn't contain a value.
     */
    convenience init?(_ string: String) {
        let formatter = NumberFormatter()
        if let value: Float = formatter.value(from: string) {
            self.init(value)
        } else if let value: Int = formatter.value(from: string) {
            self.init(value)
        } else if let value: Bool = formatter.value(from: string) {
            self.init(value)
        } else {
            return nil
        }
    }
}

extension NSNumber: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = safeBoolValue {
            try container.encode(value)
            return
        }
        switch Character(Unicode.Scalar(UInt8(objCType.pointee))) {
        case "B":
            try container.encode(boolValue)
        case "c":
            try container.encode(int8Value)
        case "s":
            try container.encode(int16Value)
        case "i", "l":
            try container.encode(int32Value)
        case "q":
            try container.encode(int64Value)
        case "C":
            try container.encode(uint8Value)
        case "S":
            try container.encode(uint16Value)
        case "I", "L":
            try container.encode(uint32Value)
        case "Q":
            try container.encode(uint64Value)
        case "f":
            try container.encode(floatValue)
        case "d":
            try container.encode(doubleValue)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled")
            throw EncodingError.invalidValue(self, .init(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled"))
        }
    }
}

extension Decodable where Self: NSNumber {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int8.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int16.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int32.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Int64.self) {
            self.init(value: value)
        } else if let value = try? container.decode(UInt.self) {
            self.init(value: value)
        } else if let value = try? container.decode(UInt8.self) {
            self.init(value: value)
        } else if let value = try? container.decode(UInt16.self) {
            self.init(value: value)
        } else if let value = try? container.decode(UInt32.self) {
            self.init(value: value)
        } else if let value = try? container.decode(UInt64.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Float.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Double.self) {
            self.init(value: value)
        } else if let value = try? container.decode(Bool.self) {
            self.init(value: value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported NSNumber type.")
        }
    }
}
