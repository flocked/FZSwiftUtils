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
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: Class Reflection

/// Reflection of a `NSObject` class.
public struct ClassReflection: CustomStringConvertible, CustomDebugStringConvertible {
    /// The type of the object.
    public let type: NSObject.Type
    /// The properties of the object.
    public let properties: [PropertyDescription]
    /// The methods of the object.
    public let methods: [MethodDescription]
    /// The ivars of the object.
    public let ivars: [PropertyDescription]
    /// The class properties of the object.
    public let classProperties: [PropertyDescription]
    /// The class methods of the object.
    public let classMethods: [MethodDescription]
    /// The class ivars of the object.
    public let classIvars: [PropertyDescription]
    /// The protocols adopted by the object.
    public let protocols: [ProtocolReflection]
    
    /// Description of a `NSObject` property.
    public struct PropertyDescription: CustomStringConvertible {
        /// The name of the property.
        public let name: String
        /// The type of the property.
        public let type: Any
        /// A Boolean value indicating whether the property is `readOnly`.
        public let isReadOnly: Bool
        /// The selector of the property.
        public var selector: Selector {
            NSSelectorFromString(name)
        }
        
        public var description: String {
            if let type = type as? Protocol {
                return isReadOnly ? "\(name) [readOnly]: \(NSStringFromProtocol(type))" : "\(name): \(NSStringFromProtocol(type))"
            }
            return isReadOnly ? "\(name) [readOnly]: \(String(describing: type))" : "\(name): \(String(describing: type))"
        }
        
        init(_ name: String, _ type: Any, _ isReadOnly: Bool) {
            self.name = name
            self.type = type
            self.isReadOnly = isReadOnly
        }
    }
    
    /// Description of a`NSObject` method.
    public struct MethodDescription: CustomStringConvertible, CustomDebugStringConvertible {
        /// The name of the method.
        public let name: String
        /// The argument types of the method.
        public let argumentTypes: [Any]
        /// The return type of the method, or `nil` if the method isn't returning anything.
        public let returnType: Any?
        /// The selector of the method.
        public var selector: Selector {
            NSSelectorFromString(name)
        }
        
        public var description: String {
            name
        }
        
        public var debugDescription: String {
            var string = ""
            var arguments = argumentTypes.compactMap({"("+String(describing: $0)+")"})
            if !arguments.isEmpty {
                var components = name.components(separatedBy: ":")
                if components.count == arguments.count+1 {
                    let lastComponent = components.removeLastSafetly() ?? ""
                    for component in components {
                        string += component + ":"
                        string += arguments.removeFirstSafetly() ?? ""
                        if !arguments.isEmpty {
                            string += " "
                        }
                    }
                    string += lastComponent
                }
            } else {
                string += name
            }
            if let returnType = returnType {
                string += "->\(String(describing: returnType))"
            }
            return string
        }
    }
    
    /**
     Returns a reflection for the specified `NSObject` class.
     
     - Parameters:
        - class: The class of the object to reflect.
        - includeSuperclass: A Boolean value indicating whether to include include reflection of the class's `superclass`.
     */
    public init(_ class: NSObject.Type, includeSuperclass: Bool = false) {
        self.type = `class`
        self.properties = `class`.propertiesReflection(includeSuperclass: includeSuperclass)
        self.methods = `class`.methodsReflection(includeSuperclass: includeSuperclass)
        self.ivars = `class`.ivarsReflection(includeSuperclass: includeSuperclass)
        self.classProperties = `class`.classPropertiesReflection(includeSuperclass: includeSuperclass)
        self.classMethods = `class`.classMethodsReflection(includeSuperclass: includeSuperclass)
        self.classIvars = `class`.classIvarsReflection(includeSuperclass: includeSuperclass)
        self.protocols = `class`.protocolReflections(includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns a reflection for a `NSObject` with the specified class name.
     
     - Parameters:
        - className: The name of the class to reflect.
        - includeSuperclass: A Boolean value indicating whether to include include reflection of the class's `superclass`.
     
     - Returns: The reflection for the class with the specified name, or `nil` if no class is found with the name.
     */
    public init?(_ className: String, includeSuperclass: Bool = false) {
        guard let type = NSClassFromString(className) as? NSObject.Type else { return nil }
        self = .init(type, includeSuperclass: includeSuperclass)
    }
    
    public var description: String {
        description()
    }
    
    public var debugDescription: String {
        description(isDebug: true)
    }
    
    private func description(isDebug: Bool = false) -> String {
        var strings =  ["<\(String(describing: type))>("]
        if !properties.isEmpty {
            strings.append("  Properties:")
            strings.append(contentsOf: properties.compactMap({"    " + $0.description}))
        }
        if !methods.isEmpty {
            strings.append("  Methods:")
            strings.append(contentsOf: methods.compactMap({"    " + (isDebug ? $0.debugDescription : $0.description)}))
        }
        if !ivars.isEmpty {
            strings.append("  Ivars:")
            strings.append(contentsOf: ivars.compactMap({"    " + $0.description}))
        }
        if !classProperties.isEmpty {
            strings.append("  Class Properties:")
            strings.append(contentsOf: classProperties.compactMap({"    " + $0.description}))
        }
        if !classMethods.isEmpty {
            strings.append("  Class Methods:")
            strings.append(contentsOf: classMethods.compactMap({"    " + (isDebug ? $0.debugDescription : $0.description)}))
        }
        if !classIvars.isEmpty {
            strings.append("  Class Ivars:")
            strings.append(contentsOf: classIvars.compactMap({"    " + $0.description}))
        }
        strings.append(")")
        return strings.joined(separator: "\n")
    }
}

extension NSObject {
    /// Returns a reflection of the class.
    public static func classReflection(includeSuperclass: Bool = false) -> ClassReflection {
        ClassReflection(self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all property descriptions of the class.
     
     - Parameters:
        - excludeReadOnly: A Boolean value indicating whether to exclude `readOnly` properties.
        - includeSuperclass: A Boolean value indicating whether to include properties of the class's `superclass`.
     */
    public static func propertiesReflection(excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        propertiesReflection(for: self, excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all method names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include method names of the class's `superclass`.
     */
    public static func methodsReflection(includeSuperclass: Bool = false) -> [ClassReflection.MethodDescription] {
        methodsReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all ivar names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include ivar names of the class's `superclass`.
     */
    public static func ivarsReflection(includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        ivarsReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all class property descriptions of the class.
     
     - Parameters:
        - excludeReadOnly: A Boolean value indicating whether to exclude `readOnly` properties.
        - includeSuperclass: A Boolean value indicating whether to include properties of the class's `superclass`.
     */
    public static func classPropertiesReflection(excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        metaClass?.propertiesReflection(excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass) ?? []
    }
    
    /**
     Returns all class method names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include method names of the class's `superclass`.
     */
    public static func classMethodsReflection(includeSuperclass: Bool = false) -> [ClassReflection.MethodDescription] {
        metaClass?.methodsReflection(includeSuperclass: includeSuperclass) ?? []
    }
    
    /**
     Returns all class ivar names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include ivar names of the class's `superclass`.
     */
    public static func classIvarsReflection(includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        metaClass?.ivarsReflection(includeSuperclass: includeSuperclass) ?? []
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
        propertiesReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name })
    }
    
    /**
     The value type for the property with the specified name.
     
     - Parameters:
        - name: The name of the property.
        - includeSuperclass: A Boolean value indicating whether to also check for properties of the class's `superclass`.
     */
    public static func propertyType(for name: String, includeSuperclass: Bool = false) -> Any? {propertiesReflection(includeSuperclass: includeSuperclass).first(where: {$0.name == name})?.type
    }
    
    /**
     Returns the protocol reflections of the protocols adopted by the class.
     
     - Parameters:
        - includeInherentProtocols: A Boolean value indicating whether to include inherent protocols.
        - includeSuperclass: A Boolean value indicating whether to include protocols of the superclasses.
     */
    public static func protocolReflections(includeSuperclass: Bool = false, includeInherentProtocols: Bool = false) -> [ProtocolReflection] {
        ProtocolReflection.protocols(for: self, includeSuperclass: includeSuperclass, includeInherentProtocols: includeInherentProtocols)
    }
    
    /**
     A Boolean value indicating whether the class has a property with the specified name.
     
     - Parameters:
        - name: The name of the property.
        - includeSuperclass: A Boolean value indicating whether to also check for properties of the class's `superclass`.
     */
    static func hasProperty(named name: String, includeSuperclass: Bool = false) -> Bool {
        propertiesReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name })
    }
    
    private static var metaClass: NSObject.Type? {
        objc_getMetaClass(NSStringFromClass(self)) as? NSObject.Type
    }
    
    private static func methodsReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [ClassReflection.MethodDescription] {
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(`class`, &methodCount)
        var methodDescriptions: [ClassReflection.MethodDescription] = (0..<Int(methodCount)).compactMap({ methods?.advanced(by: $0).pointee.methodDescription })
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            methodDescriptions += superclass.methodsReflection(includeSuperclass: includeSuperclass)
        }
        return methodDescriptions.uniqued(by: \.name).sorted(by: \.name)
    }
    
    private static func propertiesReflection(for class: NSObject.Type?, excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        var count: Int32 = 0
        let properties = class_copyPropertyList(`class`, &count)
        var descriptions: [ClassReflection.PropertyDescription] = (0..<Int(count)).compactMap({ properties?.advanced(by: $0).pointee.propertyDescription })
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            descriptions += superclass.propertiesReflection(excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
        }
        return descriptions.uniqued(by: \.name).sorted(by: \.name)
    }
    
    private static func ivarsReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [ClassReflection.PropertyDescription] {
        var count: Int32 = 0
        let ivars = class_copyIvarList(`class`, &count)
        var descriptions: [ClassReflection.PropertyDescription] = (0..<Int(count)).compactMap({ ivars?.advanced(by: $0).pointee.ivarDescription })
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            descriptions += superclass.ivarsReflection(includeSuperclass: includeSuperclass)
        }
        return descriptions.uniqued(by: \.name).sorted(by: \.name)
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
            names += superclass.protocolConformances(includeSuperclass: includeSuperclass)
        }
        return names.uniqued().sorted()
    }
}

// MARK: Protocol Reflection

/// Reflection of a `NSObjectProtocol` protocol.
public struct ProtocolReflection: CustomStringConvertible {
    /// The name of the protocol.
    public let name: String
    /// The method descriptions of the protocol.
    public let methods: [MethodDescription]
    /// The property descriptions of the protocol.
    public let properties: [PropertyDescription]
    
    public var description: String {
        var strings: [String] = ["<\(name)>("]
        let methods = methods
        var _methods = methods.filter({$0.isRequired && $0.isInstance})
        if !_methods.isEmpty {
            strings.append("\tMethods (required):")
            strings.append(contentsOf: _methods.compactMap({"\t\t" + $0.name}))
        }
        _methods = methods.filter({!$0.isRequired && $0.isInstance})
        if !_methods.isEmpty {
            strings.append("\tMethods (optional):")
            strings.append(contentsOf: _methods.compactMap({"\t\t" + $0.name}))
        }
        _methods = methods.filter({$0.isRequired && !$0.isInstance})
        if !_methods.isEmpty {
            strings.append("\tClass Methods (required):")
            strings.append(contentsOf: _methods.compactMap({"\t\t" + $0.name}))
        }
        _methods = methods.filter({!$0.isRequired && !$0.isInstance})
        if !_methods.isEmpty {
            strings.append("\tClass Methods (optional):")
            strings.append(contentsOf: _methods.compactMap({"\t\t" + $0.name}))
        }
        let properties = properties
        var _properties = properties.filter({$0.isRequired && $0.isInstance})
        if !_properties.isEmpty {
            strings.append("\tProperties (required):")
            strings.append(contentsOf: _properties.compactMap({"\t\t" + $0.description}))
        }
        _properties = properties.filter({!$0.isRequired && $0.isInstance})
        if !_properties.isEmpty {
            strings.append("\tProperties (optional):")
            strings.append(contentsOf: _properties.compactMap({"\t\t" + $0.description}))
        }
        _properties = properties.filter({$0.isRequired && !$0.isInstance})
        if !_properties.isEmpty {
            strings.append("\tClass Properties (required):")
            strings.append(contentsOf: _properties.compactMap({"\t\t" + $0.name}))
        }
        _properties = properties.filter({!$0.isRequired && !$0.isInstance})
        if !_properties.isEmpty {
            strings.append("\tClass Properties (optional):")
            strings.append(contentsOf: _properties.compactMap({"\t\t" + $0.name}))
        }
        strings.append(")")
        return strings.joined(separator: "\n")
    }
    
    /// Protocol property description.
    public struct PropertyDescription: CustomStringConvertible {
        /// The name of the method.
        public let name: String
        /// The type of the property.
        public let type: Any
        /// A Boolean value indicating whether the property is `readOnly`.
        public let isReadOnly: Bool
        /// A Boolean value indicating whether the property is an instance property.
        public let isInstance: Bool
        /// A Boolean value indicating whether the property is required.
        public let isRequired: Bool
        /// The selector of the property.
        public var selector: Selector {
            NSSelectorFromString(name)
        }
        
        public var description: String {
            isReadOnly ? "\(name) [readOnly]: \(type)" : "\(name): \(type)"
        }
    }
    
    /// Protocol method description.
    public struct MethodDescription: CustomStringConvertible {
        /// The name of the method.
        public let name: String
        /// A Boolean value indicating whether the method is an instance method.
        public let isInstance: Bool
        /// A Boolean value indicating whether the method is required.
        public let isRequired: Bool
        /// The selector of the method.
        public var selector: Selector {
            NSSelectorFromString(name)
        }
        
        public var description: String {
            name
        }
    }
    
    /**
     Returns a protocol reflection for the specified `NSObjectProtocol` protocol.
     
     - Parameter protocol: The protocol to reflect.
     - Returns: The reflection for the protocol, or `nil` if the reflection couldn't be created.
     */
    public init(_ protocol: Protocol) {
        self = ProtocolReflection(name: NSStringFromProtocol(`protocol`), methods: Self.protocolMethods(for: `protocol`), properties: Self.protocolProperties(for: `protocol`))
    }
    
    /**
     Returns a protocol reflection for a `NSObjectProtocol` with the specified protocol name.
     
     - Parameter protocolName: The name of the protocol to reflect.
     
     - Returns: The reflection for the protocol with the specified name, or `nil` if no protocol is found with the name.
     */
    public init?(_ protocolName: String) {
        guard let proto = NSProtocolFromString(protocolName) else { return nil }
        self.init(proto)
    }
    
    private init(name: String, methods: [MethodDescription], properties: [PropertyDescription]) {
        self.name = name
        self.methods = methods
        self.properties = properties
    }
    
    /**
     Returns the protocol reflections of the protocols adopted by the specified class.
     
     - Parameters:
        - class: The class.
        - includeSuperclass: A Boolean value indicating whether to include protocols of the superclasses.
        - includeInherentProtocols: A Boolean value indicating whether to include inherent protocols.
     */
    public static func protocols(for class: AnyClass, includeSuperclass: Bool = false, includeInherentProtocols: Bool = false) -> [ProtocolReflection] {
        var reflections: [ProtocolReflection] = []
        var protocolCount: UInt32 = 0
        if let protocols = class_copyProtocolList(`class`, &protocolCount) {
            for i in 0..<Int(protocolCount) {
                reflections += ProtocolReflection(protocols[i])
                if includeInherentProtocols {
                    var inheritedCount: UInt32 = 0
                    if let inheritedProtocols = protocol_copyProtocolList(protocols[i], &inheritedCount) {
                        reflections += (0..<Int(inheritedCount)).compactMap({ ProtocolReflection(inheritedProtocols[$0]) })
                    }
                }
            }
        }
        if includeSuperclass, let superclass = `class`.superclass(), superclass != NSObject.self {
            reflections += protocols(for: superclass, includeSuperclass: includeSuperclass, includeInherentProtocols: includeInherentProtocols)
        }
        reflections = reflections.uniqued(by: \.name)
        return reflections
    }
    
    private static func protocolProperties(for protocol: Protocol) -> [ProtocolReflection.PropertyDescription] {
        var count: Int32 = 0
        var propertyDescriptions: [ProtocolReflection.PropertyDescription] = []
        let variations: [(required: Bool, instance: Bool)] = [(false, false), (false, true), (true, true), (true, false)]
        for variation in variations {
            let properties = protocol_copyPropertyList2(`protocol`, &count, variation.required, variation.instance)
            for i in 0..<Int(count) {
                guard let property = properties?.advanced(by: i).pointee else { continue }
                guard let name = property.name else { continue }
                let propertyType = property.type
                let isReadOnly = property.isReadOnly
                let description = ProtocolReflection.PropertyDescription(name: name, type: propertyType, isReadOnly: isReadOnly, isInstance: variation.instance, isRequired: variation.required)
                propertyDescriptions.append(description)
            }
        }
        return propertyDescriptions
    }
    
    private static func protocolMethods(for protocol: Protocol) -> [ProtocolReflection.MethodDescription] {
        var count: Int32 = 0
        var descriptions: [ProtocolReflection.MethodDescription] = []
        let variations: [(required: Bool, instance: Bool)] = [(false, false), (false, true), (true, true), (true, false)]
        for variation in variations {
            let methods = protocol_copyMethodDescriptionList(`protocol`, variation.required, variation.instance, &count)
            for i in 0..<Int(count) {
                let method = methods?.advanced(by: i).pointee
                guard let selector = method?.name else { continue }
                let name = NSStringFromSelector(selector)
                
                if let types = method?.types {
                    let typeEncoding = String(cString: types)
                    print(name + ", encoding: \(typeEncoding)")
                    let methodTypes = getMethodTypes(from: typeEncoding)
                    for type in methodTypes {
                        print("\t\(type)")
                    }
                }
                
                descriptions.append(ProtocolReflection.MethodDescription(name: name, isInstance: variation.instance, isRequired: variation.required))
                // guard let typesChars = method?.types, let types = String(validatingUTF8: typesChars)  else { continue }
            }
        }
        return descriptions
    }
}

fileprivate extension Method {
    var methodName: String {
        NSStringFromSelector(method_getName(self))
    }
    
    var numberOfArguments: Int {
        Int(method_getNumberOfArguments(self)) - 2
    }
    
    func argumentType(at index: Int) -> String {
        let index = index + 2
        let len = 3000
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        ObjectiveC.method_getArgumentType(self, UInt32(index), buf, len)
        return String(validatingUTF8: UnsafePointer<CChar>(buf))!
    }
    
    var returnType: String {
        let len = 3000
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: len)
        ObjectiveC.method_getReturnType(self, buf, len)
        return String(validatingUTF8: UnsafePointer<CChar>(buf))!
    }
    
    var methodDescription: ClassReflection.MethodDescription? {
        let name = NSStringFromSelector(method_getName(self))
        let _returnType = self.returnType.toType()
        let returnType = _returnType is Void.Type ? nil : _returnType
        var argumentTypes: [Any] = []
        for index in 0..<self.numberOfArguments.clamped(min: 0) {
            argumentTypes.append(self.argumentType(at: index).toType())
        }
        return .init(name: name, argumentTypes: argumentTypes, returnType: returnType)
    }
}

fileprivate extension Ivar {
    var ivarName: String? {
        guard let nameChars = ivar_getName(self) else { return nil }
        return String(validatingUTF8: nameChars)
    }
    
    var ivarType: Any? {
        guard let typeChars = ivar_getTypeEncoding(self) else { return nil }
        return String(validatingUTF8: typeChars)?.toType()
    }
    
    var ivarDescription: ClassReflection.PropertyDescription? {
        guard let name = ivarName, let type = ivarType else { return nil }
        return .init(name, type, false)
    }
}

fileprivate extension objc_property_t {
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
        guard let _attributes = property_getAttributes(self) else { return Any.self }
        let attributes = String(cString: _attributes)
        let slices = String(cString: _attributes).components(separatedBy: "\"")
        return slices.count > 1 ? slices[1].toType() : (valueTypesMap[String(attributes[safe: 1] ?? "_")] ?? attributes.toType())
    }
    
    var propertyDescription: ClassReflection.PropertyDescription? {
        guard let name = name else { return nil }
        return .init(name, type, isReadOnly)
    }
}

fileprivate let valueTypesMap: [String: Any] = [
    "q": Int.self, // also: Int64, NSInteger, only true on 64 bit platforms
    "c": Int8.self,
    "s": Int16.self,
    "i": Int32.self,
    "#": AnyClass.self,
    ":": Selector.self,
    "Q": UInt.self, // also UInt64, only true on 64 bit platforms
    "C": UInt8.self,
  //  "C": UInt.self, // for ivar
    "S": UInt16.self,
    "I": UInt32.self,
    "B": Bool.self,
    "d": Double.self,
    "f": Float.self,
 //   "{": Decimal.self,
    "@?": "Block", // ()->()).self,
    "b1": Bool.self, // for ivar
    "*": String.self,
]

fileprivate struct AnyObjectType: CustomStringConvertible {
    let type: Any

    init?(_ string: String) {
        guard let type = string.matches(pattern: #"(?<=NSObject<)([^>]+)(?=>)"#).first?.string.toType() else { return nil }
        self.type = type
    }
    var description: String {
        if let type = type as? Protocol {
            return "NSObject<\(NSStringFromProtocol(type))>"
        }
        return "NSObject<\(String(describing: type))>"
    }
}

fileprivate struct WFlagsType: CustomStringConvertible {
    var descriptions: [ClassReflection.PropertyDescription] = []
    let flagType: String
    
    var description: String {
        (flagType + descriptions.compactMap({"\t" + $0.description})).joined(separator: "\n")
    }
    
    init?(_ string: String) {
        guard (string.hasPrefix("{__wFlags=") || string.hasPrefix("{__VFlags="))  && string.hasSuffix("}") else { return nil }
        var string = string
        flagType = string.hasPrefix("{__wFlags=") ? "WFlags" : "VFlags"
        string = string.removingPrefix("{__wFlags=").removingPrefix("{__VFlags=").removingSuffix("}")
        let _matches = string.matches(pattern: #""([^"]+)"|(\\b\w+\b)"#)
        guard !_matches.isEmpty else { return nil }
        let matches = _matches.compactMap({ $0.string + $0.groups.compactMap({$0.string}) }).flattened()
        descriptions = matches.chunked(size: 2).compactMap({.init($0[0], $0[1].toType(), true) }).sorted(by: \.name)
    }
}

fileprivate struct StructType: CustomStringConvertible {
    var descriptions: [ClassReflection.PropertyDescription] = []
    var _description: String  = ""
    init?(_ string: String) {
        guard string.hasPrefix("{?=") else { return nil }
        let string = String(string.dropFirst(3).dropLast(1))
        let _matches = string.matches(pattern: #""([^"]+)"|(\\b\w+\b)"#)
        let matches = _matches.compactMap({ $0.string + $0.groups.compactMap({$0.string}) }).flattened()
        if !matches.isEmpty && (matches.count % 2 == 0) {
            descriptions = matches.chunked(size: 2).compactMap({.init($0[0], $0[1].toType(), true) }).sorted(by: \.name)
        } else {
            _description = string
        }
    }
    
    var description: String {
        if !descriptions.isEmpty {
            return ("Struct" + descriptions.compactMap({"\t" + $0.description})).joined(separator: "\n")
        } else {
            return "Struct\n\t\(_description)"
        }
    }
}

fileprivate extension String {
    func toType() -> Any {
        var string = self
        if string.hasPrefix("@\"") {
            string.replacePrefix("@", with: "")
        }
        string = string.withoutBrackets
        if string == "@" {
            return AnyObject.self
        }  else if string == "<NSObject>" {
            return NSObject.self
        } else if string.contains("T@,") {
            return Optional<AnyObject>.self
        } else if string.contains("@?,") {
            return "Optional<Block>"
        } else if string == "v" || string == "Vv"{
            return Void.self
        } else if let type = valueTypesMap[string] {
           return type
        } else if string.isMatching(pattern: "^b\\d+$") {
            return Int.self
        }
        if string.contains("CGRect") {
            return CGRect.self
        } else if string.contains("CGPoint") {
            return CGPoint.self
        } else if string.contains("CGSize") {
            return CGSize.self
        } else if string.contains("NSRange") {
            return NSRange.self
        } else if string.contains("CGColor") {
            return CGColor.self
        }  else if string.contains("CGAffineTransform") {
            return CGAffineTransform.self
        } else if string.contains("CGPath") {
            return CGPath.self
        }
        #if os(macOS) || os(iOS) || os(tvOS)
        if string.contains("CALayer") {
            return CALayer.self
        } else if string.contains("CATransform3D") {
            return CATransform3D.self
        } else if string.hasPrefix("{") && string.hasSuffix("}") {
            let content = string.dropFirst().dropLast()
            if let equalIndex = content.firstIndex(of: "=") {
                let name = content[..<equalIndex]
                let fields = content[content.index(after: equalIndex)...]

                let fieldDescriptions = fields.map { "\(String($0).toType())" }.joined(separator: ", ")
                return "\(name)(\(fieldDescriptions))"
            }
        } else if string.hasPrefix("[") && string.hasSuffix("]") {
            let content = self.dropFirst().dropLast()
            var countString = ""
            var typeEncoding = ""
            var isAddingNumber = true
            for char in content {
                if isAddingNumber, char.isNumber {
                    countString.append(char)
                } else {
                    isAddingNumber = false
                    typeEncoding.append(char)
                }
            }
            let elementType = typeEncoding.toType()
            if let count = Int(countString), !countString.isEmpty {
                return "[\(elementType)](\(count))"
            } else {
                return "[\(elementType)]"
            }
        } else if string.hasPrefix("^") {
            let pointedType = String(string.dropFirst()).toType()
            return "UnsafePointer<\(pointedType)>"
        } else if string.hasPrefix("(") && string.hasSuffix(")") {
            let content = string.dropFirst().dropLast()
            if let equalIndex = content.firstIndex(of: "=") {
                let name = content[..<equalIndex]
                let fields = content[content.index(after: equalIndex)...]

                let fieldDescriptions = fields.map { "\(String($0).toType())" }.joined(separator: ", ")
                return "union \(name)(\(fieldDescriptions))"
            }
        }
        #endif
        #if os(macOS)
        if string.contains("NSEdgeInsets") {
            return NSEdgeInsets.self
        }
        #elseif canImport(UIKit)
        if string.contains("UIEdgeInsets") {
            return UIEdgeInsets.self
        }
        #endif
        if let type = NSClassFromString(string) {
            return type
        } else if let type = NSProtocolFromString(string) {
            return type
        } else if string.contains("os_unfair_lock") {
            return "Lock"
        } else if let anyObjectType = AnyObjectType(string) {
            return anyObjectType
        } else if let wFlagsType = WFlagsType(string) {
            return wFlagsType
        } else {
            let matches = string.matches(pattern: #"\{(.*?)=\w*\}"#).compactMap({$0.string})
            if matches.count == 2, let match = matches.last {
                return match.toType()
            }
            return "Unknown<\(string)>"
        }
    }
    
    var withoutBrackets: String {
        guard (hasPrefix("<") || hasPrefix("\"")) && (hasSuffix(">") || hasPrefix("\"")) else { return self }
        return String(dropFirst(1).dropLast(1))
    }
}


// Objective-C type encoding to Swift mapping (only single-character keys)
let typeEncodingMap: [Character: String] = [
    "v": "Void",
    "@": "AnyObject", // Objects (NSString, NSArray, etc.)
    "#": "AnyClass",  // Class type
    ":": "Selector",
    "c": "Bool",      // char (C) / Bool (Swift)
    "i": "Int",       // int
    "s": "Int16",     // short
    "l": "Int32",     // long (always 32-bit in Obj-C)
    "q": "Int64",     // long long
    "C": "UInt8",     // unsigned char
    "I": "UInt32",    // unsigned int
    "S": "UInt16",    // unsigned short
    "L": "UInt32",    // unsigned long
    "Q": "UInt64",    // unsigned long long
    "f": "Float",     // float
    "d": "Double",    // double
    "B": "Bool",      // _Bool (C99)
    "*": "UnsafePointer<CChar>", // C-string (char *)
    "?": "UnknownBlock" // Block / unknown type
]

// Function to extract complex types (Structs, Arrays, Unions)
func extractComplexType(from encoding: inout String) -> String? {
    guard let startChar = encoding.first else { return nil }
    var stack: [Character] = [startChar]
    var result = ""

    encoding.removeFirst()
    
    while let char = encoding.first {
        result.append(char)
        encoding.removeFirst()
        
        if char == stack.last {
            stack.removeLast()
            if stack.isEmpty { break }
        } else if char == "{" || char == "(" || char == "[" {
            stack.append(char)
        }
    }

    return result
}

// Function to map object encoding to specific class types dynamically
func mapObjectType(from encoding: String) -> String {
    guard encoding.hasPrefix("@\"") && encoding.hasSuffix("\"") else {
        return "AnyObject" // Default for unknown types
    }
    
    let className = encoding.dropFirst(2).dropLast(1) // Strip @" and "
    return String(className)
}

// Function to parse type encoding into an array of Swift types
func parseTypeEncoding(_ encoding: String) -> [String] {
    var components: [String] = []
    var remainingEncoding = encoding

    while let typeChar = remainingEncoding.first {
        remainingEncoding.removeFirst()

        if typeChar == "{" || typeChar == "(" || typeChar == "[" { // Struct, Union, or Array
            if let complexType = extractComplexType(from: &remainingEncoding) {
                components.append("\(typeChar)\(complexType)")
            }
        } else if typeChar == "^" { // Pointer types (multi-character)
            if let nextChar = remainingEncoding.first {
                remainingEncoding.removeFirst()
                let pointerType = typeEncodingMap[nextChar] ?? String(nextChar)
                components.append("UnsafePointer<\(pointerType)>")
            } else {
                components.append("UnsafeRawPointer") // Default for `^` without a known type
            }
        } else if typeChar == "@" { // Object types
            let objectType = mapObjectType(from: remainingEncoding)
            components.append(objectType)
        } else {
            if let mappedType = typeEncodingMap[typeChar] {
                components.append(mappedType)
            } else {
                components.append(String(typeChar)) // For unexpected characters
            }
        }

        // Skip over offsets (like 0:8, 16:32) in the encoding
        remainingEncoding = String(remainingEncoding.drop(while: { $0.isNumber || $0 == ":" || $0 == "@" }))

    }

    return components
}

// Function to extract method types (return type + parameters)
func getMethodTypes(from encoding: String) -> [String] {
    let parsedTypes = parseTypeEncoding(encoding)

    guard parsedTypes.count >= 3 else { return [] } // Must have return type + at least `self` & `_cmd`

    let returnType = parsedTypes[0] // First element is the return type
    let parameterTypes = Array(parsedTypes.dropFirst(2)) // Drop `self` and `_cmd`

    return [returnType] + parameterTypes
}
