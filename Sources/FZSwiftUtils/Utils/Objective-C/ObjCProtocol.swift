//
//  ObjCProtocol.swift
//
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

public extension Protocol {
    /// Returns a the protocol with the specfiiec name.
    static func named(_ name: String) -> Protocol? {
        NSProtocolFromString(name)
    }
    
    /// The name of the protocol.
    var name: String {
        protocol_getName(self).string
    }
    
    /// A Boolean value indicating whether the protocol conforms to the specified other protocol.
    func conforms(to protocol: Protocol) -> Bool {
        protocol_conformsToProtocol(self, `protocol`)
    }
    
    /// Returns all classes impelementing the protocol.
    func conformingClasses() -> [AnyClass] {
        ObjCRuntime.classes(implementing: self)
    }
    
    /// The required instance properties of the protocol.
    var properties: [ObjCProperty] {
        properties(recursive: false)
    }
    
    /**
     Returns the required instance properties of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include properties declared by inherited protocols.
     */
    func properties(recursive: Bool) -> [ObjCProperty] {
        properties(isRequired: true, isInstance: true, recursive: recursive)
    }
    
    /// The optional instance properties of the protocol.
    var optionalProperties: [ObjCProperty] {
        optionalProperties(recursive: false)
    }
    
    /**
     Returns the optional instance properties of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include properties declared by inherited protocols.
     */
    func optionalProperties(recursive: Bool) -> [ObjCProperty] {
        properties(isRequired: false, isInstance: true, recursive: recursive)
    }
    
    /// The required class properties of the protocol.
    var classProperties: [ObjCProperty] {
        classProperties(recursive: false)
    }
    
    /**
     Returns the required class properties of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include properties declared by inherited protocols.
     */
    func classProperties(recursive: Bool) -> [ObjCProperty] {
        properties(isRequired: true, isInstance: false, recursive: recursive)
    }
    
    /// The optional class properties of the protocol.
    var optionalClassProperties: [ObjCProperty] {
        optionalClassProperties(recursive: false)
    }
    
    /**
     Returns the optional class properties of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include properties declared by inherited protocols.
     */
    func optionalClassProperties(recursive: Bool) -> [ObjCProperty] {
        properties(isRequired: false, isInstance: false, recursive: recursive)
    }
    
    private func properties(isRequired: Bool, isInstance: Bool, recursive: Bool) -> [ObjCProperty] {
        var properties: [objc_property_t] = []
        for proto in recursive ? [self] + protocols(recursive: true) : [self] {
            var count: UInt32 = 0
            guard let list = protocol_copyPropertyList2(proto, &count, isRequired, isInstance) else { continue }
            defer { free(list) }
            properties += list.buffer(count: count)
        }
        return properties.map(ObjCProperty.init).uniqued(by: \.name)
    }
    
    /// A description of a method declared by an Objective-C protocol.
    struct MethodDescription: Hashable, Codable {
        /// The selector of the method.
        public let name: Selector
        /// The type encoding of the method.
        public let typeEncoding: String
        
        init?(_ description: objc_method_description) {
            guard let name = description.name, let types = description.types?.string else { return nil }
            self.name = name
            self.typeEncoding = types
        }
    }
    
    /// The required instance methods of the protocol.
    var methods: [MethodDescription] {
        methods(recursive: false)
    }
    
    /**
     Returns the required instance methods of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include methods declared by inherited protocols.
     */
    func methods(recursive: Bool) -> [MethodDescription] {
        methods(isRequired: true, isInstance: true, recursive: recursive)
    }
    
    /// The optional instance methods of the protocol.
    var optionalMethods: [MethodDescription] {
        optionalMethods(recursive: false)
    }
    
    /**
     Returns the optional instance methods of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include methods declared by inherited protocols.
     */
    func optionalMethods(recursive: Bool) -> [MethodDescription] {
        methods(isRequired: false, isInstance: true, recursive: recursive)
    }
    
    /// The required class methods of the protocol.
    var classMethods: [MethodDescription] {
        classMethods(recursive: false)
    }
    
    /**
     Returns the required class methods of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include methods declared by inherited protocols.
     */
    func classMethods(recursive: Bool) -> [MethodDescription] {
        methods(isRequired: true, isInstance: false, recursive: recursive)
    }
    
    /// The optional class methods of the protocol.
    var optionalClassMethods: [MethodDescription] {
        optionalClassMethods(recursive: false)
    }
    
    /**
     Returns the optional class methods of the protocol.

     - Parameter recursive: A Boolean value indicating whether to include methods declared by inherited protocols.
     */
    func optionalClassMethods(recursive: Bool) -> [MethodDescription] {
        methods(isRequired: false, isInstance: false, recursive: recursive)
    }

    private func methods(isRequired: Bool, isInstance: Bool, recursive: Bool) -> [MethodDescription] {
        var methods: [MethodDescription] = []
        for proto in recursive ? [self] + protocols(recursive: true) : [self] {
            var count: UInt32 = 0
            guard let list = protocol_copyMethodDescriptionList(proto, isRequired, isInstance, &count) else { continue }
            defer { free(list) }
            methods += list.buffer(count: count).compactMap { MethodDescription($0) }
        }
        return methods.uniqued(by: \.name)
    }
    
    /// Returns the required instance property with the specififed name.
    func property(named name: String) -> ObjCProperty? {
        protocol_getProperty(self, name, true, true).map(ObjCProperty.init)
    }
    
    /// Returns the optional instance property with the specififed name.
    func optionalProperty(named name: String) -> ObjCProperty? {
        protocol_getProperty(self, name, false, true).map(ObjCProperty.init)
    }
    
    /// Returns the required class property with the specififed name.
    func classProperty(named name: String) -> ObjCProperty? {
        protocol_getProperty(self, name, true, false).map(ObjCProperty.init)
    }
    
    /// Returns the optional class property with the specififed name.
    func optionalClassProperty(named name: String) -> ObjCProperty? {
        protocol_getProperty(self, name, false, false).map(ObjCProperty.init)
    }
    
    /// Returns the required instance method with the specififed name.
    func method(for selector: Selector) -> MethodDescription? {
        method(selector)
    }
    
    /// Returns the optional instance method with the specififed name.
    func optionalMethod(for selector: Selector) -> MethodDescription? {
        method(selector, isOptional: true)
    }
    
    /// Returns the required class method with the specififed name.
    func classMethod(for selector: Selector) -> MethodDescription? {
        method(selector, isInstance: false)
    }
    
    /// Returns the optional class method with the specififed name.
    func optionalClassMethod(for selector: Selector) -> MethodDescription? {
        method(selector, isInstance: false, isOptional: true)
    }
    
    private func method(_ selector: Selector, isInstance: Bool = true, isOptional: Bool = false) -> MethodDescription? {
        MethodDescription(protocol_getMethodDescription(self, selector, !isOptional, isInstance))
    }
    
    /// All protocols this protocol conforms to.
    var protocols: [Protocol] {
        protocols(recursive: false)
    }
    
    /**
     Returns all protocols this protocol conforms to.
     
     - Parameter recursive: A Boolean value indicating whether to recursively include inherited protocols.
     */
    func protocols(recursive: Bool) -> [Protocol] {
        var seen = Set<ObjectIdentifier>()
        var result: [Protocol] = []
        func collect(_ proto: Protocol) {
            if proto !== self {
                guard seen.insert(ObjectIdentifier(proto)).inserted else { return }
                result.append(proto)
                guard recursive else { return }
            }
            var count: UInt32 = 0
            guard let list = protocol_copyProtocolList(proto, &count) else { return }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach(collect)
        }
        collect(self)
        return result
    }
    
    internal func methodTypeEncoding(for selector: Selector, isInstance: Bool) throws -> String {
        try ([self] + protocols).lazy.compactMap {
            $0.method(selector, isInstance: isInstance, isOptional: true)?.typeEncoding ?? $0.method(selector, isInstance: isInstance)?.typeEncoding
         }.first.unwrap(or: HookError.noRespondSelector)
    }
}
