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

extension NSObject {
    /// Reflection of an object.
    public struct ClassReflection: CustomStringConvertible, CustomDebugStringConvertible {
        /// The type of the object.
        public let type: NSObject.Type
        /// The properties of the object.
        public let properties: [PropertyDescription]
        /// The methods of the object.
        public let methods: [MethodDescription]
        /// The ivars of the object.
        public let ivars: [String]
        /// The class properties of the object.
        public let classProperties: [PropertyDescription]
        /// The class methods of the object.
        public let classMethods: [MethodDescription]
        /// The class ivars of the object.
        public let classIvars: [String]
        
        public var description: String {
            description(isDebug: false)
        }
        
        public var debugDescription: String {
            description(isDebug: true)
        }
        
        func description(isDebug: Bool) -> String {
           var strings =  ["<\(String(describing: type))>("]
            if !properties.isEmpty {
                strings.append("\tProperties:")
                strings.append(contentsOf: properties.compactMap({"\t\t" + $0.description}))
            }
            if !methods.isEmpty {
                strings.append("\tMethods:")
                strings.append(contentsOf: methods.compactMap({"\t\t" + (isDebug ? $0.debugDescription : $0.description)}))
            }
            if !ivars.isEmpty {
                strings.append("\tIvars:")
                strings.append(contentsOf: ivars.compactMap({"\t\t" + $0}))
            }
            if !classProperties.isEmpty {
                strings.append("\tClass Properties:")
                strings.append(contentsOf: classProperties.compactMap({"\t\t" + $0.description}))
            }
            if !classMethods.isEmpty {
                strings.append("\tClass Methods:")
                strings.append(contentsOf: classMethods.compactMap({"\t\t" + (isDebug ? $0.debugDescription : $0.description)}))
            }
            if !classIvars.isEmpty {
                strings.append("\tClass Ivars:")
                strings.append(contentsOf: classIvars.compactMap({"\t\t" + $0}))
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
            var argumentString: String?
            let argumentTypes = argumentTypes.compactMap({String(describing: $0)})
            if !argumentTypes.isEmpty {
                argumentString = "(\(argumentTypes.joined(separator: ", ")))"
            }

            if let argumentString = argumentString {
                return "\(name) \(argumentString) -> \(String(describing: returnType))"
            } else {
                if returnType is Void.Type {
                    return name
                }
                return "\(name) -> \(String(describing: returnType))"
            }
        }
    }
    
    /// Returns a reflection of the class.
    public static func classReflection(includeSuperclass: Bool = false) -> ClassReflection {
        let properties = propertiesReflection(includeSuperclass: includeSuperclass)
        let methods = methodsReflection(includeSuperclass: includeSuperclass)
        let ivars = ivarsReflection(includeSuperclass: includeSuperclass)
        let classProperties = classPropertiesReflection(includeSuperclass: includeSuperclass)
        let classMethods = classMethodsReflection(includeSuperclass: includeSuperclass)
        let classIvars = classIvarsReflection(includeSuperclass: includeSuperclass)
        return ClassReflection(type: self, properties: properties, methods: methods, ivars: ivars, classProperties: classProperties, classMethods: classMethods, classIvars: classIvars)
    }
    
    /**
     Returns all property descriptions of the class.
     
     - Parameters:
        - excludeReadOnly: A Boolean value indicating whether to exclude `readOnly` properties.
        - includeSuperclass: A Boolean value indicating whether to include properties of the class's `superclass`.
     */
    public static func propertiesReflection(excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [PropertyDescription] {
        propertiesReflection(for: self, excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all method names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include method names of the class's `superclass`.
     */
    public static func methodsReflection(includeSuperclass: Bool = false) -> [MethodDescription] {
        methodsReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all ivar names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include ivar names of the class's `superclass`.
     */
    public static func ivarsReflection(includeSuperclass: Bool = false) -> [String] {
        ivarsReflection(for: self, includeSuperclass: includeSuperclass)
    }
    
    /**
     Returns all class property descriptions of the class.
     
     - Parameters:
        - excludeReadOnly: A Boolean value indicating whether to exclude `readOnly` properties.
        - includeSuperclass: A Boolean value indicating whether to include properties of the class's `superclass`.
     */
    public static func classPropertiesReflection(excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [PropertyDescription] {
        metaClass?.propertiesReflection(excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass) ?? []
    }
    
    /**
     Returns all class method names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include method names of the class's `superclass`.
     */
    public static func classMethodsReflection(includeSuperclass: Bool = false) -> [MethodDescription] {
        metaClass?.methodsReflection(includeSuperclass: includeSuperclass) ?? []
    }
    
    /**
     Returns all class ivar names of the class.
     
     - Parameter includeSuperclass: A Boolean value indicating whether to include ivar names of the class's `superclass`.
     */
    public static func classIvarsReflection(includeSuperclass: Bool = false) -> [String] {
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
    
    static func canGetValue(_ name: String, includeSuperclass: Bool = false) -> Bool {
        if propertiesReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name }) {
            return true
        }
        return methodsReflection(includeSuperclass: includeSuperclass).contains(where: {$0.name == name})
    }
    
    private static var metaClass: NSObject.Type? {
        objc_getMetaClass(NSStringFromClass(self)) as? NSObject.Type
    }
    
    private static func methodsReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [MethodDescription] {
        var methodCount: UInt32 = 0
        let methods = class_copyMethodList(`class`, &methodCount)
        var methodDescriptions: [MethodDescription] = []
        for i in 0..<Int(methodCount) {
            guard let method = methods?.advanced(by: i).pointee else { continue }
            let name = NSStringFromSelector(method_getName(method))
            let returnType = method.returnType.toType()
            var argumentTypes: [Any] = []
            for index in 0..<method.numberOfArguments {
                argumentTypes.append(method.argumentType(at: index).toType())
            }
            let description = MethodDescription(name: name, argumentTypes: argumentTypes, returnType: returnType)
            methodDescriptions.append(description)
        }
        return methodDescriptions.sorted(by: \.name)
    }
    
    private static func propertiesReflection(for class: NSObject.Type?, excludeReadOnly: Bool = false, includeSuperclass: Bool = false) -> [PropertyDescription] {
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
            names = names + superclass.propertiesReflection(excludeReadOnly: excludeReadOnly, includeSuperclass: includeSuperclass)
        }
        return names.uniqued(by: \.name).sorted(by: \.name)
    }
    
    private static func ivarsReflection(for class: NSObject.Type?, includeSuperclass: Bool = false) -> [String] {
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
        //    Swift.print(ivarName, ivar.ivarType ?? "nil")
            names.append(ivarName)
        }
        if includeSuperclass, let superclass = `class`?.superclass() as? NSObject.Type, superclass != NSObject.self {
            names = names + superclass.ivarsReflection(includeSuperclass: includeSuperclass)
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

extension Ivar {
    var ivarType: String? {
        guard let typeEncoding = ObjectiveC.ivar_getTypeEncoding(self) else { return nil }
        return String(cString: typeEncoding)
    }
}

extension Method {
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
        guard let _attributes = property_getAttributes(self) else { return Any.self }
        let attributes = String(cString: _attributes)
        let slices = String(cString: _attributes).components(separatedBy: "\"")
        return slices.count > 1 ? slices[1].toType() : (valueTypesMap[String(attributes[safe: 1] ?? "_")] ?? attributes.toType())
    }
}

var valueTypesMap: [String: Any] {
    #if os(macOS) || canImport(UIKit)
    _valueTypesMap + 
    ["CGAffineTransform": CGAffineTransform.self,
    "{CATransform3D=dddddddddddddddd}": CATransform3D.self,
    "r^{CGPath=}": CGPath.self,
    "CATransform3D": CATransform3D.self,
    "CGPath": CGPath.self,]
    #else
     _valueTypesMap
    #endif
}

private let _valueTypesMap: [String: Any] = [
    "c": Int8.self,
    "s": Int16.self,
    "#": AnyClass.self,
    ":": Selector.self,
    "i": Int32.self,
    "q": Int.self, // also: Int64, NSInteger, only true on 64 bit platforms
    "S": UInt16.self,
    "I": UInt32.self,
    "Q": UInt.self, // also UInt64, only true on 64 bit platforms
    "B": Bool.self,
    "d": Double.self,
    "f": Float.self,
    "{": Decimal.self,
    "@?": (()->()).self,
    "{CGSize=dd}": CGSize.self,
    "{CGPoint=dd}": CGPoint.self,
    "{_NSRange=QQ}": _NSRange.self,
    "{NSEdgeInsets=dddd}": NSEdgeInsets.self,
    "{CGRect={CGPoint=dd}{CGSize=dd}}": CGRect.self,
    "{CGAffineTransform=dddddd}": CGAffineTransform.self,
    "CGSize": CGSize.self,
    "CGPoint": CGPoint.self,
    "_NSRange": _NSRange.self,
    "NSEdgeInsets": NSEdgeInsets.self,
    "CGRect": CGRect.self,
]


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
                
                if let typesChars = method?.types, let types = String(cString: typesChars, encoding: .utf8) {
                    Swift.print(name, types)

                }
                // guard let typesChars = method?.types, let types = String(validatingUTF8: typesChars)  else { continue }
            }
        }
        return descriptions
    }
}

private struct Unknown: CustomStringConvertible {
    let type: String
    init(_ type: String) {
        self.type = type
    }
    var description: String {
        "Unknown<\(type)>"
    }
}

private struct StructType: CustomStringConvertible {
    public let values: [Any]
    init(_ string: String) {
        let string = String(string.dropFirst(3).dropLast(3))
        let matches = string.matches(regex: #"\{(.*?)=\w+\}"#).compactMap({$0.string}).filter({!$0.hasPrefix("{") && !$0.hasSuffix("}")})
        values = matches.compactMap({$0.toType()})
    }
    
    var description: String {
        "Struct[\(values.compactMap({ String(describing: $0) }).joined(separator: ", "))]"
    }
}

private extension String {
    func toType() -> Any {
        if hasPrefix("{?=") {
            return StructType(self)
        } else if self == "@" {
            return AnyObject.self
        } else if self == "v" || self == "Vv"{
            return Void.self
        } else if let type = valueTypesMap[self] {
           return type
        } else if let type = NSClassFromString(self.withoutBrackets) {
            return type
        } else if let type = NSProtocolFromString(self.withoutBrackets) {
            return type
        } else {
            let matches = self.matches(regex: #"\{(.*?)=\w*\}"#).compactMap({$0.string})
            if matches.count == 2, let match = matches.last {
                return match.toType()
            }
            return Unknown(self)
        }
    }
    
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
