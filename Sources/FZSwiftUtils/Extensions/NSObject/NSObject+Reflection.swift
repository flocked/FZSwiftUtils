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

extension NSObject {
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
        
        /// Description of a `NSObject` property.
        public struct PropertyDescription: CustomStringConvertible {
            /// The name of the property.
            public let name: String
            /// The type of the property.
            public let type: Any
            /// A Boolean value indicating whether the property is `readOnly`.
            public let isReadOnly: Bool
            
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
            /// The return type of the method.
            public let returnType: Any
            
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
                        }
                        string += lastComponent
                    }
                } else {
                    string += name
                }
                if !(returnType is Void.Type) {
                    string += "->\(String(describing: returnType))"
                }
                return string
            }
        }
        
        /**
         Returns a reflection for the specified `NSObject` class.
         
         - Parameters:
         - `class`: The class.
         - includeSuperclass: A Boolean value indicating whether to include include reflection of the class's `superclass`.
         */
        public init(_ `class`: NSObject.Type, includeSuperclass: Bool = false) {
            self.type = `class`
            self.properties = `class`.propertiesReflection(includeSuperclass: includeSuperclass)
            self.methods = `class`.methodsReflection(includeSuperclass: includeSuperclass)
            self.ivars = `class`.ivarsReflection(includeSuperclass: includeSuperclass)
            self.classProperties = `class`.classPropertiesReflection(includeSuperclass: includeSuperclass)
            self.classMethods = `class`.classMethodsReflection(includeSuperclass: includeSuperclass)
            self.classIvars = `class`.classIvarsReflection(includeSuperclass: includeSuperclass)
        }
        
        /**
         Returns a reflection for a `NSObject` with the specified class name.
         
         - Parameters:
         - className: The name of the class..
         - includeSuperclass: A Boolean value indicating whether to include include reflection of the class's `superclass`.
         
         - Returns: The reflection for the class with the specified name, or `nil` if no class if found with the name.
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
     Returns the value type for the property with the specified name.
     
     - Parameters:
        - name: The name of the property.
        - includeSuperclass: A Boolean value indicating whether to also check the properties of the class's `superclass`.
     */
    public static func propertyType(for name: String, includeSuperclass: Bool = false) -> Any? {propertiesReflection(includeSuperclass: includeSuperclass).first(where: {$0.name == name})?.type
    }
    
    static func hasValue(_ name: String, includeSuperclass: Bool = false) -> Bool {
        if propertiesReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name }) {
            return true
        }
        return methodsReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name})
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

extension NSObject {
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
            
            public var description: String {
                isReadOnly ? "\(name) [readOnly]: \(type)" : "\(name): \(type)"
            }
        }
        
        /// Protocol method description.
        public struct MethodDescription {
            /// The name of the method.
            public let name: String
            /// A Boolean value indicating whether the method is an instance method.
            public let isInstance: Bool
            /// A Boolean value indicating whether the method is required.
            public let isRequired: Bool
        }
    }
    
    /// Protocol reflection for the specified protocol.
    public static func protocolReclection<Object: NSObjectProtocol>(for protocol: Object.Type) -> ProtocolReflection? {
        let name = String(describing: Object.self)
        guard let proto = NSProtocolFromString(name) else { return nil }
        let methods = protocolMethods(for: proto)
        let properties = protocolProperties(for: proto)
        return ProtocolReflection(name: name, methods: methods, properties: properties)
    }
        
    private static func protocolMethods<Object: NSObjectProtocol>(for protocol: Object.Type) -> [ProtocolReflection.MethodDescription] {
        guard let proto = NSProtocolFromString(String(describing: Object.self)) else { return [] }
        return protocolMethods(for: proto)
    }
    
    private static func protocolProperties<Object: NSObjectProtocol>(for protocol: Object.Type) -> [ProtocolReflection.PropertyDescription] {
        guard let proto = NSProtocolFromString(String(describing: Object.self)) else { return [] }
        return protocolProperties(for: proto)
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
    
    var methodDescription: NSObject.ClassReflection.MethodDescription? {
        let name = NSStringFromSelector(method_getName(self))
        let returnType = self.returnType.toType()
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
    
    var ivarDescription: NSObject.ClassReflection.PropertyDescription? {
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
    
    var propertyDescription: NSObject.ClassReflection.PropertyDescription? {
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
    var descriptions: [NSObject.ClassReflection.PropertyDescription] = []
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
    var descriptions: [NSObject.ClassReflection.PropertyDescription] = []
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

/*
 // Ref: http://nshipster.com/type-encodings/
             // c: A char                  v: A void
             // C: An unsigned char        B: A C++ bool or C99 _bool
             // i: An int                  @: An object (whether statically typed or typed id)
             // I: An unsigned int         #: A class object
             // s: A short                 :: A method selector (SEL)
             // S: An unsigned short       [array type]: An array
             // l: A long                  {name=type...}: A structure
             // L: An unsigned long        (name=type...): A union
             // q: A long long             bnum: A bit field of num bits
             // Q: An unsigned long long   ^type: A pointer to type
 */
