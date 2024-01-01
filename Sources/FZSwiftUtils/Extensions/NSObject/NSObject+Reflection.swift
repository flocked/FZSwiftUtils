//
//  NSObject+Reflection.swift
//  
//
//  Adopted from:
//  Cyon Alexander (Ext. Netlight) on 01/09/16.
//  Copyright © 2016 com.cyon. All rights reserved.
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSObject {
    static func classReflection(includeSuperclass: Bool = false, excludeReadOnlyProperties: Bool = false) -> [String: Any]? {
        return getTypesOfProperties(in: self, includeSuperclass: includeSuperclass, excludeReadOnlyProperties: excludeReadOnlyProperties)
    }

    static func typeOfProperty(_ propertyName: String) -> Any? {
        return typeOf(property: propertyName, in: self)
    }

    static func containsProperty(_ propertyName: String) -> Bool {
        return typeOfProperty(propertyName) != nil
    }

    func classReflection() -> [String: Any]? {
        return getTypesOfProperties(ofObject: self)
    }

    func typeOfProperty(named propertyName: String) -> Any? {
        return typeOf(property: propertyName, for: self)
    }

    func containsProperty(named propertyName: String) -> Bool {
        return typeOfProperty(named: propertyName) != nil
    }
}

func getTypesOfProperties(in clazz: NSObject.Type, includeSuperclass: Bool = false, excludeReadOnlyProperties _: Bool = false) -> [String: Any]? {
    let types: [String: Any] = [:]
    return getTypesOfProperties(in: clazz, types: types, includeSuperclass: includeSuperclass)
}

func getTypesOfProperties(in clazz: NSObject.Type, types: [String: Any], includeSuperclass: Bool, excludeReadOnlyProperties: Bool = false) -> [String: Any]? {
    var count = UInt32()
    guard let properties = class_copyPropertyList(clazz, &count) else { return nil }
    var types = types
    for i in 0 ..< Int(count) {
        let property: objc_property_t = properties[i]
        guard let name = getNameOf(property: property)
        else { continue }
        let isReadOnlyProperty = isReadOnly(property: property)
        if excludeReadOnlyProperties && isReadOnlyProperty { continue }
        let type = getTypeOf(property: property)
        types[name] = type
    }
    free(properties)

    if includeSuperclass, let superclazz = clazz.superclass() as? NSObject.Type, superclazz != NSObject.self {
        return getTypesOfProperties(in: superclazz, types: types, includeSuperclass: true)
    } else {
        return types
    }
}

func getTypesOfProperties(ofObject object: NSObject) -> [String: Any]? {
    let clazz: NSObject.Type = type(of: object)
    return getTypesOfProperties(in: clazz)
}

func typeOf(property propertyName: String, for object: NSObject) -> Any? {
    let type = type(of: object)
    return typeOf(property: propertyName, in: type)
}

func typeOf(property propertyName: String, in clazz: NSObject.Type) -> Any? {
    guard let propertyTypes = getTypesOfProperties(in: clazz), let type = propertyTypes[propertyName] else { return nil }
    return type
}

func isProperty(named propertyName: String, ofType targetType: Any, for object: NSObject) -> Bool {
    let type = type(of: object)
    return isProperty(named: propertyName, ofType: targetType, in: type)
}

func isProperty(named propertyName: String, ofType targetType: Any, in clazz: NSObject.Type) -> Bool {
    if let propertyType = typeOf(property: propertyName, in: clazz) {
        let match = propertyType == targetType
        return match
    }
    return false
}

private func == (rhs: Any, lhs: Any) -> Bool {
    let rhsType = "\(rhs)".withoutOptional
    let lhsType = "\(lhs)".withoutOptional
    let same = rhsType == lhsType
    return same
}

private func == (rhs: NSObject.Type, lhs: Any) -> Bool {
    let rhsType = "\(rhs)".withoutOptional
    let lhsType = "\(lhs)".withoutOptional
    let same = rhsType == lhsType
    return same
}

private func == (rhs: Any, lhs: NSObject.Type) -> Bool {
    let rhsType = "\(rhs)".withoutOptional
    let lhsType = "\(lhs)".withoutOptional
    let same = rhsType == lhsType
    return same
}

struct Unknown {}

private func removeBrackets(_ className: String) -> String {
    guard className.contains("<") && className.contains(">") else { return className }
    let removed = String(className.dropFirst(1).dropLast(1))
    return removed
}

private func getTypeOf(property: objc_property_t) -> Any {
    guard let prop = property_getAttributes(property), let attributesAsNSString = NSString(utf8String: prop) else { return Any.self }

    let attributes = attributesAsNSString as String
    let slices = attributes.components(separatedBy: "\"")
    guard slices.count > 1 else { return valueType(withAttributes: attributes) }
    let objectClassNameRaw = slices[1]
    let objectClassName = removeBrackets(objectClassNameRaw)

    guard let objectClass = NSClassFromString(objectClassName) else {
        if let nsObjectProtocol = NSProtocolFromString(objectClassName) {
            return nsObjectProtocol
        }
        print("Failed to retrieve type from: `\(objectClassName)`")
        return Unknown.self
    }
    return objectClass
}

private func isReadOnly(property: objc_property_t) -> Bool {
    guard let prop = property_getAttributes(property), let attributesAsNSString = NSString(utf8String: prop) else { return false }
    let attributes = attributesAsNSString as String
    return attributes.contains(",R,")
}

private func valueType(withAttributes attributes: String) -> Any {
    guard let letter = attributes.substring(from: 1, to: 2), let type = valueTypesMap[letter] else { return Any.self }
    return type
}

private func getNameOf(property: objc_property_t) -> String? {
    guard
        let name = NSString(utf8String: property_getName(property))
    else { return nil }
    return name as String
}

private let valueTypesMap: [String: Any] = [
    "c": Int8.self,
    "s": Int16.self,
    "i": Int32.self,
    "q": Int.self, // also: Int64, NSInteger, only true on 64 bit platforms
    "S": UInt16.self,
    "I": UInt32.self,
    "Q": UInt.self, // also UInt64, only true on 64 bit platforms
    "B": Bool.self,
    "d": Double.self,
    "f": Float.self,
    "{": Decimal.self,
]

private extension String {
    func substring(from fromIndex: Int, to toIndex: Int) -> String? {
        let substring = self[index(startIndex, offsetBy: fromIndex) ..< index(startIndex, offsetBy: toIndex)]
        return String(substring)
    }

    /// Extracts "NSDate" from the string "Optional(NSDate)"
    var withoutOptional: String {
        guard contains("Optional(") && contains(")") else { return self }
        let afterOpeningParenthesis = components(separatedBy: "(")[1]
        let wihtoutOptional = afterOpeningParenthesis.components(separatedBy: ")")[0]
        return wihtoutOptional
    }
}
