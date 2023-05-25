//
//  File.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

import Foundation

public extension NumberFormatter {

    func value<C: LosslessStringConvertible>(from string: String) -> C? {
        let type = C.self
        if (type == Float.self) {  return floatValue(from: string) as? C }
        if (type == Double.self) {  return doubleValue(from: string) as? C }
        if (type == Bool.self) {  return doubleValue(from: string) as? C }
        if (type == Int.self) {  return intValue(from: string) as? C }
        if (type == Int8.self) {  return int8Value(from: string) as? C }
        if (type == Int16.self) {  return int16Value(from: string) as? C }
        if (type == Int32.self) {  return int32Value(from: string) as? C }
        if (type == Int64.self) {  return int64Value(from: string) as? C }
        if (type == UInt.self) {  return uintValue(from: string) as? C }
        if (type == UInt8.self) {  return uint8Value(from: string) as? C }
        if (type == UInt16.self) {  return uint16Value(from: string) as? C }
        if (type == UInt32.self) {  return uint32Value(from: string) as? C }
        if (type == UInt64.self) {  return uint64Value(from: string) as? C }
        return nil
    }
    
    func intValue(from string: String) -> Int? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.intValue ?? Int(str)
    }
    
    func int8Value(from string: String) -> Int8? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.int8Value ?? Int8(str)
    }
    
    func int16Value(from string: String) -> Int16? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.int16Value ?? Int16(str)
    }
    
    func int32Value(from string: String) -> Int32? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.int32Value ?? Int32(str)
    }
    
    func int64Value(from string: String) -> Int64? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.int64Value ?? Int64(str)
    }
    
    func uintValue(from string: String) -> UInt? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.uintValue ?? UInt(str)
    }
    
    func uint8Value(from string: String) -> UInt8? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.uint8Value ?? UInt8(str)
    }
    
    func uint16Value(from string: String) -> UInt16? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.uint16Value ?? UInt16(str)
    }
    
    func uint32Value(from string: String) -> UInt32? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.uint32Value ?? UInt32(str)
    }
    
    func uint64Value(from string: String) -> UInt64? {
        let str = strippingNonNumericCharacters(from: string)
        let formatter = NumberFormatter.forInteger()
        return formatter.number(from:str)?.uint64Value ?? UInt64(str)
    }
    
    func floatValue(from string: String) -> Float? {
        let str = strippingNonNumericCharacters(from: string)
        return self.floatingValue(Float.self, from: str) ?? self.number(from:str)?.floatValue ?? Float(str)
    }
    
    func doubleValue(from string: String) -> Double? {
        let str = strippingNonNumericCharacters(from: string)
        return self.floatingValue(Double.self, from: str) ?? self.number(from:str)?.doubleValue  ?? Double(str)
    }
    
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
    
    func timeInterval(from string: String) -> TimeInterval? {
        let allUnitStrings = Calendar.Component.allCases.flatMap({$0.stringRepresentations ?? []})
        let components = string.components(separatedBy: " ")
        var timeInterval: TimeInterval?
        
        for (index, component) in components.enumerated() {
            var found = false
            for unitString in allUnitStrings {
                if (component.lowercased().contains(unitString)) {
                    let component = component.lowercased().replacingOccurrences(of: unitString, with: "")
                    if let value = Double(component), let unitTimeInterval = Calendar.Component.allCases.first(where: {$0.stringRepresentations?.contains(unitString) ?? false})?.timeInterval {
                        timeInterval = (timeInterval ?? 0) + (unitTimeInterval*value)
                        found = true
                    }
                }
            }
            
            guard found == false else {
                break
            }
            
            let unitKind = Calendar.Component.allCases.first(where: {$0.stringRepresentations?.contains(component) ?? false})
            if(unitKind == nil || index == 0){
                continue
            }
            
            let value = Double(components[index-1])
            if(value == nil) {
                continue
            }
            
            if let unitTimeInterval = unitKind?.timeInterval, let value = value {
                timeInterval = (timeInterval ?? 0) + (unitTimeInterval*value)
            }
        }
        return timeInterval
    }
    
    internal func strippingNonNumericCharacters(from string: String) -> String {
        let numericCharacters = Set("0123456789.,+-")
        return string.filter { numericCharacters.contains($0) }
    }
    
    internal func floatingValue<F: FloatingPoint>(_ type: F.Type, from string: String) -> F? {
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
