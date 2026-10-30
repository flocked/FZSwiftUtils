//
//  ObjCProtocol.swift
//
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

public extension Protocol {
    /// Returns a the protocol with the specified name.
    static func named(_ name: String) -> Protocol? {
        NSProtocolFromString(name)
    }
    
    /// The name of the protocol.
    var name: String {
        protocol_getName(self).string
    }
    
    /// The identifier of the protocol.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
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
        protocols(recursive: recursive, includeSelf: true).flatMap({ proto in
            BufferCollection({ protocol_copyPropertyList2(proto, $0, isRequired, isInstance) }).map(ObjCProperty.init)
        }).uniqued(by: \.name)
    }
    
    /// A description of a method declared by an Objective-C protocol.
    struct MethodDescription: Hashable, Codable {
        /// The selector of the method.
        public let name: Selector
        /// The type encoding of the method.
        public let typeEncoding: String
        
        init(name: Selector, typeEncoding: String) {
            self.name = name
            self.typeEncoding = typeEncoding
        }
        
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
        protocols(recursive: recursive, includeSelf: true).flatMap({ proto in
            BufferCollection({ protocol_copyMethodDescriptionList(proto, isRequired, isInstance, $0) }).compactMap(MethodDescription.init)
        }).uniqued(by: \.name)
    }
    
    /// Returns the required instance property with the specififed name.
    func property(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
        first(declaredOnly, of: { protocol_getProperty($0, name, true, true).map(ObjCProperty.init) })
    }
    
    /// Returns the optional instance property with the specififed name.
    func optionalProperty(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
       first(declaredOnly, of: { protocol_getProperty($0, name, false, true).map(ObjCProperty.init) })
    }
    
    /// Returns the required class property with the specififed name.
    func classProperty(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
        first(declaredOnly, of: { protocol_getProperty($0, name, true, false).map(ObjCProperty.init) })
    }
    
    /// Returns the optional class property with the specififed name.
    func optionalClassProperty(named name: String, declaredOnly: Bool = false) -> ObjCProperty? {
        first(declaredOnly, of: { protocol_getProperty($0, name, false, false).map(ObjCProperty.init) })
    }
    
    /// Returns the required instance method with the specififed name.
    func method(for selector: Selector, declaredOnly: Bool = false) -> MethodDescription? {
        first(declaredOnly, of: { $0.method(selector) })
    }
    
    /// Returns the optional instance method with the specififed name.
    func optionalMethod(for selector: Selector, declaredOnly: Bool = false) -> MethodDescription? {
        first(declaredOnly, of: { $0.method(selector, isOptional: true) })
    }
    
    /// Returns the required class method with the specififed name.
    func classMethod(for selector: Selector, declaredOnly: Bool = false) -> MethodDescription? {
        first(declaredOnly, of: { $0.method(selector, isInstance: false) })
    }
    
    /// Returns the optional class method with the specififed name.
    func optionalClassMethod(for selector: Selector, declaredOnly: Bool = false) -> MethodDescription? {
        first(declaredOnly, of: { $0.method(selector, isInstance: false, isOptional: true) })
    }
    
    private func method(_ selector: Selector, isInstance: Bool = true, isOptional: Bool = false) -> MethodDescription? {
        MethodDescription(protocol_getMethodDescription(self, selector, !isOptional, isInstance))
    }
    
    private func first<T>(_ declaredOnly: Bool = false, of predicate: (Protocol)->T?) -> T? {
        if declaredOnly {
            return predicate(self)
        }
        var checked: Set<ObjectIdentifier> = []
        func check(_ proto: Protocol) -> T? {
            guard checked.insert(ObjectIdentifier(proto)).inserted else { return nil }
            if let value = predicate(proto) {
                return value
            }
            for proto in BufferCollection({ protocol_copyProtocolList(proto, $0) }) {
                guard let value = check(proto) else { continue }
                return value
            }
            return nil
        }
        return check(self)
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
        protocols(recursive: recursive, includeSelf: false)
    }
    
    private func protocols(recursive: Bool, includeSelf: Bool) -> [Protocol] {
        var result = includeSelf ? [self] : []
        var seen: Set<ObjectIdentifier> = [id]
        func collect(_ proto: Protocol) {
            for proto in BufferCollection({ protocol_copyProtocolList(proto, $0) }) {
                guard seen.insert(proto.id).inserted else { continue }
                result += proto
                guard recursive else { continue }
                collect(proto)
            }
        }
        collect(self)
        return result
    }
    
    internal func methodTypeEncoding(for selector: Selector, isInstance: Bool) throws -> String {
        for proto in protocols(recursive: false, includeSelf: true) {
            guard let typeEncoding = proto.method(selector, isInstance: isInstance, isOptional: true)?.typeEncoding else { continue }
            return typeEncoding
        }
        throw HookError.noRespondSelector
    }
}

extension Protocol: Swift.Equatable, Swift.Hashable, Swift.Identifiable {
    public static func == (lhs: borrowing Protocol, rhs: borrowing Protocol) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
