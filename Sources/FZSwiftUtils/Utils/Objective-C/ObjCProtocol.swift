//
//  ObjCProtocol.swift
//  
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

extension Protocol {
    /// Returns a the protocol with the specfiiec name.
    public static func named(_ name: String) -> Protocol? {
        NSProtocolFromString(name)
    }
    
    /// The name of the protocol.
    public var name: String {
        ObjCRuntime.name(for: self)
    }
    
    /// A Boolean value indicating whether the protocol conforms to the specified other protocol.
    public func conforms(to protocol: Protocol) -> Bool {
        protocol_conformsToProtocol(self, `protocol`)
    }
    
    /// Returns all classes impelementing the protocol.
    public func conformingClasses() -> [AnyClass] {
        ObjCRuntime.classes(implementing: self)
    }
    
    /// The required instance properties of the protocol.
    public func properties(recursive: Bool = false) -> [objc_property_t] {
        properties(isRequired: true, isInstance: true, includeProtocols: recursive)
    }
    
    /// The optional instance properties of the protocol.
    public func optionalProperties(recursive: Bool = false) -> [objc_property_t] {
        properties(isRequired: false, isInstance: true, includeProtocols: recursive)
    }
    
    /// The required class properties of the protocol.
    public func classProperties(recursive: Bool = false) -> [objc_property_t] {
        properties(isRequired: true, isInstance: false, includeProtocols: recursive)
    }
    
    /// The optional class properties of the protocol.
    public func optionalClassProperties(recursive: Bool = false) -> [objc_property_t] {
        properties(isRequired: false, isInstance: false, includeProtocols: recursive)
    }
    
    private func properties(isRequired: Bool, isInstance: Bool, includeProtocols: Bool) -> [objc_property_t] {
        var properties: [objc_property_t] = []
        var seen: Set<String> = []
        for proto in includeProtocols ? [self] + protocols(recursive: true) : [self] {
            var count: UInt32 = 0
            guard let list = protocol_copyPropertyList2(proto, &count, isRequired, isInstance) else { continue }
            defer { free(list) }
            properties += list.buffer(count: count).filter({ seen.insert(property_getName($0).string).inserted })
        }
        return properties
    }
    
    /// Defines an Objective-C method.
    public struct MethodDescription: Hashable {
        /// The name of the method.
        public let name: Selector
        /// The types of the method arguments.
        public let types: String?
        
        init?(_ description: objc_method_description?) {
            guard let name = description?.name else { return nil }
            self.name = name
            self.types = description?.types?.string
        }
    }
    
    /// The required instance methods of the protocol.
    public func methods(recursive: Bool = false) -> [MethodDescription] {
        methods(isRequired: true, isInstance: true, includeProtocols: recursive)
    }
    
    /// The optional instance methods of the protocol.
    public func optionalMethods(recursive: Bool = false) -> [MethodDescription] {
        methods(isRequired: false, isInstance: true, includeProtocols: recursive)
    }
    
    /// The required class methods of the protocol.
    public func classMethods(recursive: Bool = false) -> [MethodDescription] {
        methods(isRequired: true, isInstance: false, includeProtocols: recursive)
    }
    
    /// The optional class methods of the protocol.
    public func optionalClassMethods(recursive: Bool = false) -> [MethodDescription] {
        methods(isRequired: false, isInstance: false, includeProtocols: recursive)
    }
    
    private func methods(isRequired: Bool, isInstance: Bool, includeProtocols: Bool) -> [MethodDescription] {
        var methods: [MethodDescription] = []
        for proto in includeProtocols ? [self] + protocols(recursive: true) : [self] {
            var count: UInt32 = 0
            guard let list = protocol_copyMethodDescriptionList(proto, isRequired, isInstance, &count) else { continue }
            defer { free(list) }
            methods += list.buffer(count: count).compactMap({ MethodDescription($0) })
        }
        return methods.uniqued()
    }
    
    /// Returns the required instance property with the specififed name.
    public func property(named name: String) -> objc_property_t? {
        protocol_getProperty(self, name, true, true)
    }
    
    /// Returns the optional instance property with the specififed name.
    public func optionalProperty(named name: String) -> objc_property_t? {
        protocol_getProperty(self, name, false, true)
    }
    
    /// Returns the required class property with the specififed name.
    public func classProperty(named name: String) -> objc_property_t? {
        protocol_getProperty(self, name, true, false)
    }
    
    /// Returns the optional class property with the specififed name.
    public func optionalClassProperty(named name: String) -> objc_property_t? {
        protocol_getProperty(self, name, false, false)
    }
    
    /// Returns the required instance method with the specififed name.
    public func method(for selector: Selector) -> MethodDescription? {
        .init(protocol_getMethodDescription(self, selector, true, true))
    }
    
    /// Returns the optional instance method with the specififed name.
    public func optionalMethod(for selector: Selector) -> MethodDescription? {
        .init(protocol_getMethodDescription(self, selector, false, true))
    }
    
    /// Returns the required class method with the specififed name.
    public func classMethod(for selector: Selector) -> MethodDescription? {
        .init(protocol_getMethodDescription(self, selector, true, false))
    }
    
    /// Returns the optional class method with the specififed name.
    public func optionalClassMethod(for selector: Selector) -> MethodDescription? {
        .init(protocol_getMethodDescription(self, selector, false, false))
    }
    
    /**
     Returns all protocols this protocol conforms to.
     
     - Parameter recursive: A Boolean value indicating whether to include protocols inherited by each protocol recursively.
     */
    public func protocols(recursive: Bool = true) -> [Protocol] {
        var seen = Set<String>()
        var protocols: [Protocol] = []
        func collect(_ proto: Protocol) {
            guard seen.insert(proto.name).inserted else { return }
            protocols.append(proto)
            guard recursive else { return }
            var count: UInt32 = 0
            guard let list = protocol_copyProtocolList(proto, &count) else { return }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach({ collect($0) })
        }
        var count: UInt32 = 0
        guard let list = protocol_copyProtocolList(self, &count) else { return [] }
        defer { free(UnsafeMutableRawPointer(list)) }
        list.buffer(count: count).forEach({ collect($0) })
        return protocols
    }

    func methodDescription(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> objc_method_description? {
        if let description = methodDescriptionWithoutSearchingInheritedProtocols(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly) {
            return description
        }
        return protocols(recursive: false).lazy.compactMap( { $0.methodDescription(for: selector, isInstanceMethod: isInstanceMethod) }).first
    }
    
    func methodTypeEncoding(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> String? {
        methodDescription(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly)?.types?.stringAndFree()
    }
    
    func methodSignature(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) throws -> Signature {
        guard let types = methodDescription(for: selector, isInstanceMethod: isInstanceMethod, optionalOnly: optionalOnly)?.types else {
            throw HookError.noRespondSelector
        }
        return try Signature(typeEncoding: types)
    }
    
    private func methodDescriptionWithoutSearchingInheritedProtocols(for selector: Selector, isInstanceMethod: Bool, optionalOnly: Bool = false) -> objc_method_description? {
        let optionalDescription = protocol_getMethodDescription(self, selector, false, isInstanceMethod)
        if optionalDescription.name != nil, optionalDescription.types != nil {
            return optionalDescription
        }
        guard !optionalOnly else { return nil }
        let requiredDescription = protocol_getMethodDescription(self, selector, true, isInstanceMethod)
        if requiredDescription.name != nil, requiredDescription.types != nil {
            return requiredDescription
        }
        return nil
    }
}
