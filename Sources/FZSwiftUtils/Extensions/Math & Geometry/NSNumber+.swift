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
    
    var isFloatingPoint: Bool {
        switch String(cString: objCType) {
        case "f", "d": return true
        default: return false
        }
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
    
    var typed: TypedValue {
        getAssociatedValue("typed", initialValue: .init(self))
    }
    
    struct TypedValue {
        private let number: NSNumber
        private let type: String

        init(_ number: NSNumber) {
            self.number = number
            self.type = String(cString: number.objCType)
        }

        /** Returns the value if the underlying Obj-C type is `"c"` (Int8). */
        public var int8: Int8? { type == "c" ? number.int8Value : nil }

        /** Returns the value if the underlying Obj-C type is `"s"` (Int16). */
        public var int16: Int16? { type == "s" ? number.int16Value : nil }

        /** Returns the value if the underlying Obj-C type is `"i"` (Int32). */
        public var int32: Int32? { type == "i" ? number.int32Value : nil }

        /** Returns the value if the underlying Obj-C type is `"l"` (Int / C long). */
        public var int: Int? { type == "l" ? number.intValue : nil }

        /** Returns the value if the underlying Obj-C type is `"q"` (Int64). */
        public var int64: Int64? { type == "q" ? number.int64Value : nil }

        /** Returns the value if the underlying Obj-C type is `"C"` (UInt8). */
        public var uInt8: UInt8? { type == "C" ? number.uint8Value : nil }

        /** Returns the value if the underlying Obj-C type is `"S"` (UInt16). */
        public var uInt16: UInt16? { type == "S" ? number.uint16Value : nil }

        /** Returns the value if the underlying Obj-C type is `"I"` (UInt32). */
        public var uInt32: UInt32? { type == "I" ? number.uint32Value : nil }

        /** Returns the value if the underlying Obj-C type is `"L"` (UInt / C unsigned long). */
        public var uInt: UInt? { type == "L" ? number.uintValue : nil }

        /** Returns the value if the underlying Obj-C type is `"Q"` (UInt64). */
        public var uInt64: UInt64? { type == "Q" ? number.uint64Value : nil }

        // MARK: - Floating Point

        /** Returns the value if the underlying Obj-C type is `"f"` (Float). */
        public var float: Float? { type == "f" ? number.floatValue : nil }

        /** Returns the value if the underlying Obj-C type is `"d"` (Double). */
        public var double: Double? { type == "d" ? number.doubleValue : nil }

        // MARK: - Boolean

        /** Returns the value if the underlying Obj-C type is `"B"` (Bool). */
        public var bool: Bool? { type == "B" ? number.boolValue : nil }
    }
    
    /// The value of the `NSNumber`.
    var value: Any {
        if let bool = safeBoolValue { return bool }
        switch String(cString: objCType) {
        case "c":  return boolValue
        case "C":  return uint8Value
        case "s":  return int16Value
        case "S":  return uint16Value
        case "i":  return int32Value
        case "I":  return uint32Value
        case "l":  return intValue
        case "L":  return uintValue
        case "q":  return int64Value
        case "Q":  return uint64Value
        case "f":  return floatValue
        case "d":  return doubleValue
        case "B":  return boolValue
        default:
            Swift.print("HERE",  String(cString: objCType) )
            return self
        }
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

extension NSNumber: Swift.Encodable, Swift.Decodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = safeBoolValue { try container.encode(value); return }
        switch Character(Unicode.Scalar(UInt8(objCType.pointee))) {
        case "B": try container.encode(boolValue)
        case "c": try container.encode(int8Value)
        case "C": try container.encode(uint8Value)
        case "s": try container.encode(int16Value)
        case "S": try container.encode(uint16Value)
        case "i": try container.encode(int32Value)
        case "I": try container.encode(uint32Value)
        case "l": try container.encode(Int(intValue))
        case "L": try container.encode(UInt(uintValue))
        case "q": try container.encode(int64Value)
        case "Q": try container.encode(uint64Value)
        case "f": try container.encode(floatValue)
        case "d": try container.encode(doubleValue)
        default:
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber uses an unsupported ObjC type: \(String(cString: objCType))"))
        }
    }
}

extension Decodable where Self: NSNumber {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self)        { self.init(value: value) }
        else if let value = try? container.decode(Double.self){ self.init(value: value) }
        else if let value = try? container.decode(Bool.self)  { self.init(value: value) }
        else if let value = try? container.decode(Float.self) { self.init(value: value) }
        else if let value = try? container.decode(Int8.self)  { self.init(value: value) }
        else if let value = try? container.decode(UInt8.self) { self.init(value: value) }
        else if let value = try? container.decode(Int16.self) { self.init(value: value) }
        else if let value = try? container.decode(UInt16.self){ self.init(value: value) }
        else if let value = try? container.decode(Int32.self) { self.init(value: value) }
        else if let value = try? container.decode(UInt32.self){ self.init(value: value) }
        else if let value = try? container.decode(Int64.self) { self.init(value: value) }
        else if let value = try? container.decode(UInt64.self){ self.init(value: value) }
        else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported NSNumber type")
        }
    }
}
