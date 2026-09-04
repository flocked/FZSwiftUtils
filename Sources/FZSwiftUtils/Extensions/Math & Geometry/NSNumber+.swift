//
//  NSNumber+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension NSNumber {
    /// Creates a new `NSNumber` object initialized to contain the specified Boolean value.
    convenience init(_ value: Bool) {
        self.init(value: value)
    }
    
    /// Creates a new `NSNumber` object initialized to contain the specified CChar value.
    convenience init(_ value: CChar) {
        self.init(value: value)
    }

    /// Creates a new `NSNumber` object initialized to contain the specified binary floating point value.
    convenience init<Value>(_ value: Value) where Value: BinaryFloatingPoint {
        self.init(value: Double(value))
    }

    /// Creates a new NSNumber object initialized to contain the specified `CGFloat` value.
    convenience init(_ value: CGFloat) {
        self.init(value: value)
    }
    
    /// Creates a new `NSNumber` object initialized to contain the specified binary integer point value.
    convenience init<Value>(_ value: Value) where Value: BinaryInteger {
        if Value.isSigned {
            self.init(value: Int64(value))
        } else {
            self.init(value: UInt64(value))
        }
    }
    
    /// Returns the number converted to the specified binary integer type.
    func binaryInteger<Value: BinaryInteger>(as: Value.Type = Value.self) -> Value {
        Value.isSigned ? Value(int64Value) : Value(uint64Value)
    }

    /// Returns the number converted to the specified binary floating-point type.
    func binaryFloatingPoint<Value: BinaryFloatingPoint>(as: Value.Type = Value.self) -> Value {
        Value(doubleValue)
    }
    
    /**
     A Boolean value indicating whether the number is a Boolean value.

     ```swift
     NSNumber(value: false).isBool // true
     NSNumber(value: 0).isBool // false
     ```
     */
    var isBool: Bool {
        CFGetTypeID(self) == CFBooleanGetTypeID()
    }
    
    /// A Boolean value indicating whether the number represents a floating-point value.
    var isFloatingPoint: Bool {
        switch objectiveCType {
        case .float, .double: return true
        default: return false
        }
    }
    
    /**
     Returns the Boolean value only if the represented value is a Boolean.
     
     ```swift
     NSNumber(value: false).safeBoolValue // false
     NSNumber(value: 1).safeBoolValue // nil
     ```
     */
    var safeBoolValue: Bool? {
        isBool ? boolValue : nil
    }
    
    /// A typed view of the number that exposes its underlying Objective-C numeric representation.
    var typed: TypedValue {
        getAssociatedValue("typed", initial: TypedValue(self))
    }
    
    /// A typed view of an `NSNumber` that exposes its underlying Objective-C numeric representation.
    struct TypedValue {
        private let number: NSNumber
        private let type: NumericType
        private let isBoolean: Bool

        fileprivate init(_ number: NSNumber) {
            self.number = number
            self.type = number.objectiveCType
            self.isBoolean = number.isBool
        }
        
        /// Returns the value if the underlying Objective-C type is `long`.
        public var int: Int? {
            type == .int ? number.intValue : nil
        }

        /// Returns the value if the underlying Objective-C type is `char`.
        public var int8: Int8? {
            type == .int8 && !isBoolean ? number.int8Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `short`.
        public var int16: Int16? {
            type == .int16 ? number.int16Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `int`.
        public var int32: Int32? {
            type == .int32 ? number.int32Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `long long`.
        public var int64: Int64? {
            type == .int64 ? number.int64Value : nil
        }
        
        /// Returns the value if the underlying Objective-C type is `unsigned long`.
        public var uInt: UInt? {
            type == .uInt ? number.uintValue : nil
        }

        /// Returns the value if the underlying Objective-C type is `unsigned char`.
        public var uInt8: UInt8? {
            type == .uInt8 ? number.uint8Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `unsigned short`.
        public var uInt16: UInt16? {
            type == .uInt16 ? number.uint16Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `unsigned int`.
        public var uInt32: UInt32? {
            type == .uInt32 ? number.uint32Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `unsigned long long`.
        public var uInt64: UInt64? {
            type == .uInt64 ? number.uint64Value : nil
        }

        /// Returns the value if the underlying Objective-C type is `float`.
        public var float: Float? {
            type == .float ? number.floatValue : nil
        }

        /// Returns the value if the underlying Objective-C type is `double` and the number is not decimal.
        public var double: Double? {
            type == .double && !(number is NSDecimalNumber) ? number.doubleValue : nil
        }
        
        /// Returns the value if the number is an `NSDecimalNumber`.
        public var decimal: Decimal? {
            (number as? NSDecimalNumber)?.decimalValue
        }

        /// Returns the value if the number is a Core Foundation Boolean.
        public var bool: Bool? {
            isBoolean ? number.boolValue : nil
        }
    }
    
    /// The Objective-C type of the number.
    var objectiveCType: NumericType {
        NumericType(rawValue: String(cString: objCType))
    }

    /// An Objective-C numeric type encoding used by a `NSNumber`.
    struct NumericType: RawRepresentable, Hashable, Sendable {
        /// `Int`.
        public static let int = Self(rawValue: "l")
        /// `Int8`.
        public static let int8 = Self(rawValue: "c")
        /// `Int16`.
        public static let int16 = Self(rawValue: "s")
        /// `Int32`.
        public static let int32 = Self(rawValue: "i")
        /// `Int64`.
        public static let int64 = Self(rawValue: "q")
        /// `UInt`.
        public static let uInt = Self(rawValue: "L")
        /// `UInt8`.
        public static let uInt8 = Self(rawValue: "C")
        /// `UInt16`.
        public static let uInt16 = Self(rawValue: "S")
        /// `UInt32`.
        public static let uInt32 = Self(rawValue: "I")
        /// `UInt64`.
        public static let uInt64 = Self(rawValue: "Q")
        /// `Float`.
        public static let float = Self(rawValue: "f")
        /// `Double`.
        public static let double = Self(rawValue: "d")
        /// `Bool`.
        public static let bool = Self(rawValue: "B")

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public let rawValue: String
    }
  
    
    /// The value represented by the number using its underlying Objective-C numeric type.
    var value: Any {
        if let bool = safeBoolValue { return bool }
        if let decimal = self as? NSDecimalNumber { return decimal.decimalValue }
        switch objectiveCType {
        case .int: return intValue
        case .int8: return int8Value
        case .int16: return int16Value
        case .int32: return int32Value
        case .int64: return int64Value
        case .uInt: return uintValue
        case .uInt8: return uint8Value
        case .uInt16: return uint16Value
        case .uInt32: return uint32Value
        case .uInt64: return uint64Value
        case .float: return floatValue
        case .double: return doubleValue
        case .bool: return boolValue
        default: return self
        }
    }
    
    /// Creates a `NSNumber`  object initialized to contain the specified value of the string.
    convenience init?(_ string: String, locale: Locale = .current) {
        if let value = Int64(string) {
            self.init(value: value)
        } else if let value = UInt64(string) {
            self.init(value: value)
        } else if let value = Bool(string) {
            self.init(value: value)
        } else if let number = NumberFormatter.decimal.locale(locale).number(from: string) {
            if number.isFloatingPoint {
                self.init(value: number.doubleValue)
            } else {
                self.init(value: number.int64Value)
            }
        } else {
            return nil
        }
    }
}

extension NSNumber: Swift.Encodable, Swift.Decodable { }
