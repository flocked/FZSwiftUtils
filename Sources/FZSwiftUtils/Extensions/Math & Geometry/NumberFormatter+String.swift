//
//  File.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

import Foundation

public extension NumberFormatter {
    /**
     Returns a value of a specified number type  extracted from the given string.
     
     - Parameters:
        - string: The string from which to extract the value.
     
     - Returns: The extracted value of the specified type, or `nil` if the extraction fails.
     */
    func value<C: LosslessStringConvertible>(from string: String) -> C? {
        let type = C.self
        if type == Float.self { return floatValue(from: string) as? C }
        if type == Double.self { return doubleValue(from: string) as? C }
        if type == Bool.self { return doubleValue(from: string) as? C }
        if type == Int.self { return intValue(from: string) as? C }
        if type == Int8.self { return int8Value(from: string) as? C }
        if type == Int16.self { return int16Value(from: string) as? C }
        if type == Int32.self { return int32Value(from: string) as? C }
        if type == Int64.self { return int64Value(from: string) as? C }
        if type == UInt.self { return uintValue(from: string) as? C }
        if type == UInt8.self { return uint8Value(from: string) as? C }
        if type == UInt16.self { return uint16Value(from: string) as? C }
        if type == UInt32.self { return uint32Value(from: string) as? C }
        if type == UInt64.self { return uint64Value(from: string) as? C }
        return nil
    }

    /**
     Extracts an `Int` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Int` value.
     
     - Returns: The extracted `Int` value, or `nil` if the extraction fails.
     */
    func intValue(from string: String) -> Int? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.intValue ?? Int(str)
    }

    /**
     Extracts an `Int8` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Int8` value.
     
     - Returns: The extracted `Int8` value, or `nil` if the extraction fails.
     */
    func int8Value(from string: String) -> Int8? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.int8Value ?? Int8(str)
    }

    /**
     Extracts an `Int16` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Int16` value.
     
     - Returns: The extracted `Int16` value, or `nil` if the extraction fails.
     */
    func int16Value(from string: String) -> Int16? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.int16Value ?? Int16(str)
    }

    /**
     Extracts an `Int32` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Int32` value.
     
     - Returns: The extracted `Int32` value, or `nil` if the extraction fails.
     */
    func int32Value(from string: String) -> Int32? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.int32Value ?? Int32(str)
    }

    /**
     Extracts an `Int64` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Int64` value.
     
     - Returns: The extracted `Int64` value, or `nil` if the extraction fails.
     */
    func int64Value(from string: String) -> Int64? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.int64Value ?? Int64(str)
    }

    /**
     Extracts an `UInt` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `UInt` value.
     
     - Returns: The extracted `UInt` value, or `nil` if the extraction fails.
     */
    func uintValue(from string: String) -> UInt? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.uintValue ?? UInt(str)
    }

    /**
     Extracts an `UInt8` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `UInt8` value.
     
     - Returns: The extracted `UInt8` value, or `nil` if the extraction fails.
     */
    func uint8Value(from string: String) -> UInt8? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.uint8Value ?? UInt8(str)
    }

    /**
     Extracts an `UInt16` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `UInt16` value.
     
     - Returns: The extracted `UInt16` value, or `nil` if the extraction fails.
     */
    func uint16Value(from string: String) -> UInt16? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.uint16Value ?? UInt16(str)
    }

    /**
     Extracts an `UInt32` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `UInt32` value.
     
     - Returns: The extracted `UInt32` value, or `nil` if the extraction fails.
     */
    func uint32Value(from string: String) -> UInt32? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.uint32Value ?? UInt32(str)
    }

    /**
     Extracts an `UInt64` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `UInt64` value.
     
     - Returns: The extracted `UInt64` value, or `nil` if the extraction fails.
     */
    func uint64Value(from string: String) -> UInt64? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from: str)?.uint64Value ?? UInt64(str)
    }

    /**
     Extracts an `Float` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Float` value.
     
     - Returns: The extracted `Float` value, or `nil` if the extraction fails.
     */
    func floatValue(from string: String) -> Float? {
        let str = strippingNonNumericCharacters(from: string)
        return floatingValue(Float.self, from: str) ?? number(from: str)?.floatValue ?? Float(str)
    }

    /**
     Extracts an `Double` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Double` value.
     
     - Returns: The extracted `Double` value, or `nil` if the extraction fails.
     */
    func doubleValue(from string: String) -> Double? {
        let str = strippingNonNumericCharacters(from: string)
        return floatingValue(Double.self, from: str) ?? number(from: str)?.doubleValue ?? Double(str)
    }

    /**
     Extracts an `Bool` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `Bool` value.
     
     - Returns: The extracted `Bool` value, or `nil` if the extraction fails.
     */
    func boolValue(from string: String) -> Bool? {
        switch string.lowercased() {
        case "no", "0", "false", "n", "+":
            return false
        case "yes", "1", "true", "y", "-":
            return true
        default:
            return nil
        }
    }

    /**
     Extracts an `TimeInterval` value from the given string.
     
     - Parameters:
        - string: The string from which to extract the `TimeInterval` value.
     
     - Returns: The extracted `TimeInterval` value, or `nil` if the extraction fails.
     */
    func timeInterval(from string: String) -> TimeInterval? {
        let allUnitStrings = Calendar.Component.allCases.flatMap { $0.stringRepresentations ?? [] }
        let components = string.components(separatedBy: " ")
        var timeInterval: TimeInterval?

        for (index, component) in components.enumerated() {
            var found = false
            for unitString in allUnitStrings {
                if component.lowercased().contains(unitString) {
                    let component = component.lowercased().replacingOccurrences(of: unitString, with: "")
                    if let value = Double(component), let unitTimeInterval = Calendar.Component.allCases.first(where: { $0.stringRepresentations?.contains(unitString) ?? false })?.timeInterval {
                        timeInterval = (timeInterval ?? 0) + (unitTimeInterval * value)
                        found = true
                    }
                }
            }

            guard found == false else {
                break
            }

            let unitKind = Calendar.Component.allCases.first(where: { $0.stringRepresentations?.contains(component) ?? false })
            if unitKind == nil || index == 0 {
                continue
            }

            let value = Double(components[index - 1])
            if value == nil {
                continue
            }

            if let unitTimeInterval = unitKind?.timeInterval, let value = value {
                timeInterval = (timeInterval ?? 0) + (unitTimeInterval * value)
            }
        }
        return timeInterval
    }

    internal func strippingNonNumericCharacters(from string: String) -> String {
        let numericCharacters = Set("0123456789.,+-")
        return string.filter { numericCharacters.contains($0) }
    }

    internal func floatingValue<F: FloatingPoint>(_: F.Type, from string: String) -> F? {
        switch string {
        case ".inf", ".Inf", ".INF", "+.inf", "+.Inf", "+.INF":
            return .infinity
        case "-.inf", "-.Inf", "-.INF":
            return -.infinity
        case ".nan", ".NaN", ".NAN":
            return .nan
        default:
            return nil
        }
    }
}
