//
//  ObjCClass.swift
//
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

/// An Objective-C class.
public struct ObjCClass {
    /// The class.
    public let cls: AnyClass
    
    public init(_ class: AnyClass) {
        self.cls = `class`
    }
    
    public init?(_ className: String) {
        guard let cls = NSClassFromString(className) else { return nil }
        self.cls = cls
    }
    
    /// The name of the class.
    public var name: String {
        class_getName(cls).string
    }
    
    /// The version of the class.
    public var version: Int32 {
        class_getVersion(cls)
    }
    
    /// The size of an instance of the class.
    public var instanceSize: Int {
        class_getInstanceSize(cls)
    }
    
    /// The path of the dynamic library / framework the class originated from.
    public var imagePath: String? {
        class_getImageName(cls)?.string
    }
    
    /// The superclass of the class.
    public var superclass: AnyClass? {
        class_getSuperclass(cls)
    }
    
    /// The root superclass of the class.
    public var rootSuperclass: AnyClass? {
        superclasses.last
    }
    
    /// Returns all superclasses of the class.
    public var superclasses: [AnyClass] {
        Array(first: superclass, next: { class_getSuperclass($0) })
    }
    
    /// The subclasses of the class.
    public var subclasses: [AnyClass] {
        subclasses(includeNested: false)
    }
    
    /**
     Returns the subclasses of the class.
     
     - Parameter includeNested: A Boolean value indicating whether to include nested subclasses.
     */
    public func subclasses(includeNested: Bool) -> [AnyClass] {
        ObjCRuntime.subclasses(of: cls, includeNested: includeNested)
    }
    
    /// A Boolean value indicating whether the class is a subclass of the specified other class.
    public func isSubclass(of class: AnyClass) -> Bool {
        ObjCRuntime.addressToSkip.contains(name) ? false : cls.isSubclass(of: `class`)
    }
    
    /// A Boolean value indicating whether the class is a superclass of the specified other class.
    public func isSuperclass(of class: AnyClass) -> Bool {
        `class`.isSubclass(of: cls)
    }
    
    /// A Boolean value indicating whether the class is a meta class.
    public var isMetaClass: Bool {
        skipMetaClass ? false : class_isMetaClass(cls)
    }
    
    /// The meta class for the class.
    public var metaClass: AnyClass {
        isMetaClass || skipMetaClass ? cls : object_getClass(cls)!
    }
    
    /// The instance methods of the class.
    public var methods: [ObjCMethod] {
        methods(includeSuperclasses: false)
    }
    
    /**
     Returns the instance methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance methods declared by the superclasses.
     */
    public func methods(includeSuperclasses: Bool) -> [ObjCMethod] {
        var count: UInt32 = 0
        var methods: [Method] = []
        var seen: Set<Selector> = []
        for cls in classes(includeSuperclasses) {
            guard let list = class_copyMethodList(cls, &count) else { continue }
            defer { free(list) }
            methods += includeSuperclasses ? list.buffer(count: count).filter { seen.insert(method_getName($0)).inserted } : list.array(count: count)
        }
        return methods.map(ObjCMethod.init)
    }
    
    /// The class methods of the class.
    public var classMethods: [ObjCMethod] {
        classMethods(includeSuperclasses: false)
    }
    
    /**
     Returns the class methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class methods declared by the superclasses.
     */
    public func classMethods(includeSuperclasses: Bool) -> [ObjCMethod] {
        skipMetaClass ? [] : ObjCClass(metaClass).methods(includeSuperclasses: includeSuperclasses)
    }
    
    private var skipMetaClass: Bool {
        ObjCRuntime.classNamesToSkip.contains(name)
    }
    
    /// The instance properties of the class.
    public var properties: [ObjCProperty] {
        properties(includeSuperclasses: false)
    }
    
    /**
     Returns the instance properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance properties declared by the superclasses.
     */
    public func properties(includeSuperclasses: Bool) -> [ObjCProperty] {
        var count: UInt32 = 0
        var properties: [objc_property_t] = []
        var seen: Set<String> = []
        for cls in classes(includeSuperclasses) {
            guard let list = class_copyPropertyList(cls, &count) else { continue }
            defer { free(list) }
            properties += includeSuperclasses ? list.buffer(count: count).filter { seen.insert(property_getName($0).string).inserted } : list.array(count: count)
        }
        return properties.map(ObjCProperty.init)
    }
    
    /// The class properties of the class.
    public var classProperties: [ObjCProperty] {
        classProperties(includeSuperclasses: false)
    }
    
    /**
     Returns the class properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class properties declared by the superclasses.
     */
    public func classProperties(includeSuperclasses: Bool) -> [ObjCProperty] {
        skipMetaClass ? [] : ObjCClass(metaClass).properties(includeSuperclasses: includeSuperclasses)
    }
    
    /// The instance variables of the class.
    public var ivars: [ObjCIvar] {
        ivars(includeSuperclasses: false)
    }
    
    /**
     Returns the instance variables of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance variables declared by the superclasses.
     */
    public func ivars(includeSuperclasses: Bool) -> [ObjCIvar] {
        var ivars: [Ivar] = []
        for cls in classes(includeSuperclasses) {
            var count: UInt32 = 0
            guard let list = class_copyIvarList(cls, &count) else { continue }
            defer { free(list) }
            ivars += list.buffer(count: count)
        }
        return ivars.map(ObjCIvar.init)
    }
    
    /// The protocols the class conforms to.
    public var protocols: [Protocol] {
        protocols(includeSuperclasses: false)
    }
    
    /**
     Returns the protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols that the superclasses are conforming to.
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.
     */
    public func protocols(includeSuperclasses: Bool, includeInheritedProtocols: Bool = false) -> [Protocol] {
        var visited = Set<ObjectIdentifier>()
        var protocols: [Protocol] = []
        var count: UInt32 = 0
        func visit(_ proto: Protocol) {
            guard visited.insert(proto).inserted else { return }
            protocols.append(proto)
            guard includeInheritedProtocols else { return }
            guard let list = protocol_copyProtocolList(proto, &count) else { return }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach { visit($0) }
        }
        for cls in classes(includeSuperclasses) {
            guard let list = class_copyProtocolList(cls, &count) else { continue }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach { visit($0) }
        }
        return protocols
    }
    
    private func classes(_ includeSuperclasses: Bool) -> [AnyClass] {
        includeSuperclasses ? cls + superclasses : [cls]
    }
    
    /// A Boolean value indicating whether the class conforms to the specified protocol.
    public func conforms(to protocol: Protocol) -> Bool {
        class_conformsToProtocol(cls, `protocol`)
    }
    
    /// Returns a Boolean value indicating whether instances of this class respond to the specified selector.
    public func responds(to selector: Selector) -> Bool {
        class_respondsToSelector(cls, selector)
    }
    
    /// Returns a Boolean value indicating whether the class responds to the specified selector.
    public func classResponds(to selector: Selector) -> Bool {
        class_respondsToSelector(metaClass, selector)
    }
    
    /// Returns the instance property of the class with the specified name.
    public func property(named name: String) -> ObjCProperty? {
        class_getProperty(cls, name).map(ObjCProperty.init)
    }
    
    /// Returns the class property of the class with the specified name.
    public func classProperty(named name: String) -> ObjCProperty? {
        skipMetaClass ? nil : class_getProperty(metaClass, name).map(ObjCProperty.init)
    }
    
    /// Returns the instance variable of the class with the specified name.
    public func variable(named name: String) -> ObjCIvar? {
        class_getInstanceVariable(cls, name).map(ObjCIvar.init)
    }
    
    /**
     Returns the instance method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching instance method, or `nil` if no such method exists.
     */
    public func method(for selector: Selector, declaredOnly: Bool = false) -> ObjCMethod? {
        (declaredOnly ? declaredMethod(for: cls, selector) : class_getInstanceMethod(cls, selector)).map(ObjCMethod.init)
    }
    
    /**
     Returns the class method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching class method, or `nil` if no such method exists.
     */
    public func classMethod(for selector: Selector, declaredOnly: Bool = false) -> ObjCMethod? {
        (declaredOnly ? declaredMethod(for: metaClass, selector) : class_getClassMethod(cls, selector)).map(ObjCMethod.init)
    }
    
    private func declaredMethod(for cls: AnyClass, _ selector: Selector) -> Method? {
        var count: UInt32 = 0
        guard let list = class_copyMethodList(cls, &count) else { return nil }
        defer { free(list) }
        return list.buffer(count: count).first(where: { method_getName($0) == selector })
    }
    
    /**
     Returns the implementation pointer for the instance method corresponding to the specified selector.
     
     - Parameter selector: The selector identifying the instance method.
     - Returns: The implementation pointer (`IMP`) that would be invoked if the selector were sent to an instance of this class, or `nil` if no implementation can be resolved.
     */
    public func methodImplementation(for selector: Selector) -> IMP? {
        class_getMethodImplementation(cls, selector)
    }
    
    /**
     Returns the implementation pointer for the class method corresponding to the specified selector.
     
     - Parameter selector: The selector identifying the class method.
     - Returns: The implementation pointer (`IMP`) that would be invoked if the selector were sent to the class object itself, or nil if no implementation can be resolved.
     */
    public func classMethodImplementation(for selector: Selector) -> IMP? {
        class_getMethodImplementation(metaClass, selector)
    }
    
    /// Returns a Boolean value indicating whether this class overrides the specified instance method.
    public func overrides(_ selector: Selector) -> Bool {
        guard declaredMethod(for: cls, selector) != nil, let superclass else { return false }
        return class_getInstanceMethod(superclass, selector) != nil
    }
    
    /// Returns a Boolean value indicating whether this class overrides the specified class method.
    public func classOverrides(_ selector: Selector) -> Bool {
        guard !skipMetaClass, declaredMethod(for: metaClass, selector) != nil, let superclass else { return false }
        return class_getClassMethod(superclass, selector) != nil
    }
    
    func `protocol`(for selector: Selector, isInstanceMethod: Bool) throws -> Protocol? {
        var protocolBySignature: [String: Protocol] = [:]
        for proto in ObjCClass(isInstanceMethod ? cls : metaClass).protocols(includeSuperclasses: true, includeInheritedProtocols: true) {
            guard let typeEncoding = try? proto.methodTypeEncoding(for: selector, isInstance: isInstanceMethod) else { continue }
            if protocolBySignature[typeEncoding] == nil {
                protocolBySignature[typeEncoding] = proto
            }
        }
        if protocolBySignature.isEmpty {
            return nil
        }
        if protocolBySignature.count == 1 {
            return protocolBySignature.first?.value
        }
        let signatures = protocolBySignature.map { "\"\($0.value.name)\" => \($0.key)"
        }.sorted().joined(separator: ", ")
        throw HookError.inferredProtocolMethodAmbiguous("Found multiple protocol signatures for selector `\(selector.string)`: \(signatures).")
    }
}
