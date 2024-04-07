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

extension NSObject {
    /// Reflection of a class.
    public struct ClassReflection: CustomStringConvertible {
        /// The type of the class.
        public let type: NSObject.Type
        /// The properties of the class.
        public let properties: [PropertyDescription]
        /// The methods of the class.
        public let methods: [String]
        /// The ivars of the class.
        public let ivars: [String]
        
        public var description: String {
           var strings =  ["<\(String(describing: type))>("]
            if !properties.isEmpty {
                strings.append("\t- Properties:")
                strings.append(contentsOf: properties.compactMap({"\t\t" + $0.description}))
            }
            if !methods.isEmpty {
                strings.append("\t- Methods:")
                strings.append(contentsOf: methods.compactMap({"\t\t" + $0}))
            }
            if !ivars.isEmpty {
                strings.append("\t- Ivars:")
                strings.append(contentsOf: ivars.compactMap({"\t\t" + $0}))
            }
            strings.append(")")
            return strings.joined(separator: "\n")
        }
    }
    
    /// Description of a property.
    public struct PropertyDescription: CustomStringConvertible {
        /// The name of the property.
        public let name: String
        /// The type of the property.
        public let type: Any
        /// A Boolean value indicating whether the property is `readOnly`.
        public let isReadOnly: Bool
        
        public var description: String {
            isReadOnly ? "\(name) [readOnly]: \(type)" : "\(name): \(type)"
        }
        
        init(_ name: String, _ type: Any, _ isReadOnly: Bool) {
            self.name = name
            self.type = type
            self.isReadOnly = isReadOnly
        }
    }
    
    /// Returns a reflection of the class.
    public static func classReflection(includeSuperclass: Bool = false) -> ClassReflection {
        let properties = propertyReflection(includeSuperclass: includeSuperclass)
        let methods = methodReflection(includeSuperclass: includeSuperclass)
        let ivars = ivarReflection(includeSuperclass: includeSuperclass)
        return ClassReflection(type: self, properties: properties, methods: methods, ivars: ivars)
    }
    
    /**
     Returns all property descriptions of the class.
     
     - Parameters:
        - excludeReadOnly: A Boolean value indicating whether to exclude `readOnly` properties.
        - includeSuperclass: A Boolean value indicating whether to include properties of the class's `superclass`.
     */
    public static func propertyReflection(excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [PropertyDescription] {
        propertyReflection(for: self, excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all method names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include method names of the class's `superclass`.
     */
    public static func methodReflection(includeSuperclass: Bool = false) -> [String] {
        methodReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all ivar names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include ivar names of the class's `superclass`.
     */
    public static func ivarReflection(includeSuperclass: Bool = false) -> [String] {
        ivarReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all names of the conforming protocols of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include the names of the conforming protocols of the class's `superclass`.
     */
    public static func protocolConformances(includeSuperclass: Bool = false) -> [String] {
        protocolConformances(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     A Boolean value indicating whether the class contains a property with the specified name.
     
     - Parameters:
        - name: The name of the property.
        - includeSuperclass: A Boolean value indicating whether to also check the properties of the class's `superclass`.
     */
    public static func containsProperty(_ name: String, includeSuperclass: Bool = false) -> Bool {
        propertyReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name })
    }
    
    /**
     Returns the value type for the property with the specified name.
     
     - Parameters:
        - name: The name of the property.
        - includeSuperclass: A Boolean value indicating whether to also check the properties of the class's `superclass`.
     */
    public static func propertyType(for name: String, includeSuperclass: Bool = false) -> Any? {propertyReflection(includeSuperclass: includeSuperclass).first(where: {$0.name == name})?.type
    }
    
    static func canGetValue(_ name: String, includeSuperclass: Bool = false) -> Bool {
        if propertyReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name }) {
            return true
        }
        return methodReflection(includeSuperclass: includeSuperclass).contains(name)
    }
    
    private static func methodReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [String] {
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(`class`, &methodCount)
        var names: [String] = []
        for i in 0..<Int(methodCount) {
            guard
                let method = methods?.advanced(by: i).pointee
            else { continue }
            let methodName = NSStringFromSelector(method_getName(method))
            names.append(methodName)
        }
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            names = names + superclass.methodReflection(includeSuperclass: includeSuperclass)
        }
        return names.uniqued().sorted()
    }
    
    private static func propertyReflection(for class: NSObject.Type?, excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [PropertyDescription] {
        var count: Int32 = 0
        let properties = class_copyPropertyList(`class`, &count)
        var names: [PropertyDescription] = []
        for i in 0..<Int(count) {
            guard let property = properties?.advanced(by: i).pointee else { continue }
            guard let propertyName = property.name else { continue }
            let isReadOnly = property.isReadOnly
            if excludeReadOnly, isReadOnly { continue }
            let propertyType = property.type
            names.append(.init(propertyName, propertyType, isReadOnly))
        }
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            names = names + superclass.propertyReflection(excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
        }
        return names.uniqued(by: \.name).sorted(by: \.name)
    }
    
    private static func ivarReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [String] {
        var count: Int32 = 0
        let ivars = class_copyIvarList(`class`, &count)
        var names: [String] = []
        for i in 0..<Int(count) {
            guard let ivar = ivars?.advanced(by: i).pointee else { continue }
            guard
                let ivarNameChars = ivar_getName(ivar),
                let ivarName = String(validatingUTF8: ivarNameChars)
                // let ivarEncodingChars = ivar_getTypeEncoding(ivar),
                // let ivarEncoding = String(validatingUTF8: ivarEncodingChars)
            else {
                print("missing info on \(ivar)")
                continue
            }
            names.append(ivarName)
            // print("\(ivarEncoding): \(ivarName)")
        }
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            names = names + superclass.ivarReflection(includeSuperclass: includeSuperclass)
        }
        return names.uniqued().sorted()
    }
    
    private static func protocolConformances(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [String] {
        var count: Int32 = 0
        let protocols = class_copyProtocolList(`class`, &count)
        var names: [String] = []
        for i in 0..<Int(count) {
            guard let prot = protocols?.advanced(by: i).pointee else { continue }
            let protNameChars = protocol_getName(prot)
            guard let protName = String(validatingUTF8: protNameChars) else { continue }
            names.append(protName)
        }
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            names = names + superclass.protocolConformances(includeSuperclass: includeSuperclass)
        }
        return names.uniqued().sorted()
    }
}

private extension objc_property_t {
    var name: String? {
        guard let name = NSString(utf8String: property_getName(self)) else { return nil }
        return name as String
    }
    
    var isReadOnly: Bool {
        guard let prop = property_getAttributes(self), let attributesAsNSString = NSString(utf8String: prop) else { return false }
        let attributes = attributesAsNSString as String
        return attributes.contains(",R,")
    }
    
    var type: Any {
        guard let prop = property_getAttributes(self), let attributesAsNSString = NSString(utf8String: prop) else { return Any.self }
        let attributes = attributesAsNSString as String
        let slices = attributes.components(separatedBy: "\"")
        guard slices.count > 1 else { return valueType(withAttributes: attributes) }
        let objectClassNameRaw = slices[1]
        let objectClassName = objectClassNameRaw.withoutBrackets

        guard let objectClass = NSClassFromString(objectClassName) else {
            if let nsObjectProtocol = NSProtocolFromString(objectClassName) {
                return nsObjectProtocol
            }
            // debugPrint("Failed to retrieve type from: `\(objectClassName)`")
            return Unknown.self
        }
        return objectClass
    }
}

struct Unknown { }

private func valueType(withAttributes attributes: String) -> Any {
    guard let letter = attributes[safe: 1] else { return Any.self }
    return valueTypesMap[String(letter)] ?? Any.self
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
    var withoutOptional: String {
        guard contains("Optional("), contains(")") else { return self }
        let afterOpeningParenthesis = components(separatedBy: "(")[1]
        let wihtoutOptional = afterOpeningParenthesis.components(separatedBy: ")")[0]
        return wihtoutOptional
    }
    
    var withoutBrackets: String {
        guard contains("<"), contains(">") else { return self }
        return String(dropFirst(1).dropLast(1))
    }
}

extension NSObject {
    /// Protocol reflection for the specified protocol.
    public static func protocolReclection<Object: NSObjectProtocol>(for protocol: Object.Type) -> ProtocolReflection? {
        let name = String(describing: Object.self)
        guard let proto = NSProtocolFromString(name) else { return nil }
        let methods = protocolMethods(for: proto)
        let properties = protocolProperties(for: proto)
        return ProtocolReflection(name: name, methods: methods, properties: properties)
    }
    
    /// Reflection of a protocol.
    public struct ProtocolReflection: CustomStringConvertible {
        /// The name of the protocol.
        public let name: String
        /// The method descriptions of the protocol.
        public let methods: [MethodDescription]
        /// The property descriptions of the protocol.
        public let properties: [PropertyDescription]
        
        public var description: String {
            var strings: [String] = ["<\(name)>("]
            let requiredInstanceMethods = methods.filter({$0.isRequired && $0.isInstance})
            let instanceMethods = methods.filter({!$0.isRequired && $0.isInstance})
            let requiredClassMethods = methods.filter({$0.isRequired && !$0.isInstance})
            let classMethods = methods.filter({!$0.isRequired && !$0.isInstance})
            if !requiredInstanceMethods.isEmpty {
                strings.append("\t- Instance methods (required):")
                strings.append(contentsOf: requiredInstanceMethods.compactMap({"\t\t" + $0.name}))
            }
            if !instanceMethods.isEmpty {
                strings.append("\t- Instance methods (optional):")
                strings.append(contentsOf: instanceMethods.compactMap({"\t\t" + $0.name}))
            }
            if !requiredClassMethods.isEmpty {
                strings.append("\t- Class methods (required):")
                strings.append(contentsOf: requiredClassMethods.compactMap({"\t\t" + $0.name}))
            }
            if !classMethods.isEmpty {
                strings.append("\t- Class methods (optional):")
                strings.append(contentsOf: classMethods.compactMap({"\t\t" + $0.name}))
            }
            if !properties.isEmpty {
                strings.append("\t- Properties:")
                strings.append(contentsOf: properties.compactMap({"\t\t" + $0.description}))
            }
            strings.append(")")
            return strings.joined(separator: "\n")
        }
        
        /// Description of a protocol method.
        public struct MethodDescription {
            /// The name of the method.
            public let name: String
            /// A Boolean value indicating whether the method is an instance method.
            public let isInstance: Bool
            /// A Boolean value indicating whether the method is required.
            public let isRequired: Bool
        }
    }
        
    private static func protocolMethods<Object: NSObjectProtocol>(for protocol: Object.Type) -> [ProtocolReflection.MethodDescription] {
        guard let proto = NSProtocolFromString(String(describing: Object.self)) else { return [] }
        return protocolMethods(for: proto)
    }
    
    private static func protocolProperties<Object: NSObjectProtocol>(for protocol: Object.Type) -> [NSObject.PropertyDescription] {
        guard let proto = NSProtocolFromString(String(describing: Object.self)) else { return [] }
        return protocolProperties(for: proto)
    }
    
    private static func protocolProperties(for protocol: Protocol) -> [NSObject.PropertyDescription] {
        var count: Int32 = 0
        let properties = protocol_copyPropertyList(`protocol`, &count)
        var names: [NSObject.PropertyDescription] = []
        for i in 0..<Int(count) {
            guard let property = properties?.advanced(by: i).pointee else { continue }
            guard let name = property.name else { continue }
            let propertyType = property.type
            let isReadOnly = property.isReadOnly
            names.append(.init(name, propertyType, isReadOnly))
        }
        return names
    }
    
    private static func protocolMethods(for protocol: Protocol) -> [ProtocolReflection.MethodDescription] {
        var count: Int32 = 0
        var symbols: [ProtocolReflection.MethodDescription] = []
        let variations: [(required: Bool, instance: Bool)] = [(false, false), (false, true), (true, true), (true, false)]
        for variation in variations {
            let methods = protocol_copyMethodDescriptionList(`protocol`, variation.required, variation.instance, &count)
            for i in 0..<Int(count) {
                let method = methods?.advanced(by: i).pointee
                guard let selector = method?.name else { continue }
                let name = NSStringFromSelector(selector)
                symbols.append(ProtocolReflection.MethodDescription(name: name, isInstance: variation.instance, isRequired: variation.required))
                // Swift.print(name)
                // guard let typesChars = method?.types, let types = String(validatingUTF8: typesChars)  else { continue }
                // print(types)
            }
        }
        return symbols
    }
}
