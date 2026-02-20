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
    public func properties() -> [objc_property_t] {
        properties(isRequired: true, isInstance: true)
    }
    
    /// The optional instance properties of the protocol.
    public func optionalProperties() -> [objc_property_t] {
        properties(isRequired: false, isInstance: true)
    }
    
    /// The required class properties of the protocol.
    public func classProperties() -> [objc_property_t] {
        properties(isRequired: true, isInstance: false)
    }
    
    /// The optional class properties of the protocol.
    public func optionalClassProperties() -> [objc_property_t] {
        properties(isRequired: false, isInstance: false)
    }
    
    private func properties(isRequired: Bool, isInstance: Bool) -> [objc_property_t] {
        var count: UInt32 = 0
        guard let list = protocol_copyPropertyList2(self, &count, isRequired, isInstance) else { return [] }
        defer { free(list) }
        return list.array(count: count)
    }
    
    /// Defines an Objective-C method.
    public struct MethodDescription {
        /// The name of the method.
        public let name: Selector?
        /// The types of the method arguments.
        public let types: String?
        
        init?(_ description: objc_method_description?) {
            guard let description = description else { return nil }
            self.name = description.name
            self.types = description.types?.string
        }
    }
    
    /// The required instance methods of the protocol.
    public func methods() -> [MethodDescription] {
        methods(isRequired: true, isInstance: true)
    }
    
    /// The optional instance methods of the protocol.
    public func optionalMethods() -> [MethodDescription] {
        methods(isRequired: false, isInstance: true)
    }
    
    /// The required class methods of the protocol.
    public func classMethods() -> [MethodDescription] {
        methods(isRequired: true, isInstance: false)
    }
    
    /// The optional class methods of the protocol.
    public func optionalClassMethods() -> [MethodDescription] {
        methods(isRequired: false, isInstance: false)
    }
    
    private func methods(isRequired: Bool, isInstance: Bool) -> [MethodDescription] {
        var count: UInt32 = 0
        guard let list = protocol_copyMethodDescriptionList(self, isRequired, isInstance, &count) else { return [] }
        defer { free(list) }
        return list.buffer(count: count).compactMap({ MethodDescription($0) })
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
     
     - Parameter includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.
     */
    public func protocols(includeInheritedProtocols: Bool = true) -> [Protocol] {
        var seen = Set<String>()
        var protocols: [Protocol] = []
        func collect(_ proto: Protocol) {
            guard seen.insert(proto.name).inserted else { return }
            protocols.append(proto)
            guard includeInheritedProtocols else { return }
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
        return protocols(includeInheritedProtocols: false).lazy.compactMap( { $0.methodDescription(for: selector, isInstanceMethod: isInstanceMethod) }).first
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
