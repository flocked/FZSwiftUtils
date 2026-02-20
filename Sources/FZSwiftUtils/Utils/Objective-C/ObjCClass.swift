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
    public let `class`: AnyClass
    
    public init(_ class: AnyClass) {
        self.`class` = `class`
    }
    
    /// The name of the class.
    public var name: String {
        ObjCRuntime.name(for: `class`)
    }
    
    /// The version of the class.
    public var version: Int32 {
        class_getVersion(`class`)
    }
    
    /// The size of an instance of the class.
    public var instanceSize: Int {
        class_getInstanceSize(`class`)
    }
    
    public var imageName: String? {
        class_getImageName(`class`)?.string
    }
    
    /// The superclass of the class.
    public var superclass: AnyClass? {
        `class`.superclass()
    }
    
    /// The root superclass of the class.
    public var rootSuperclass: AnyClass? {
        superclasses.last
    }
    
    /// Returns all superclasses of the class.
    public var superclasses: [AnyClass] {
        Array(first: superclass, next: { class_getSuperclass($0) })
    }
    
    /**
     Returns all subclasses of the class.
     
     - Parameters:
        - includeNested: A Boolean value indicating whether to include nested subclasses.
        - sorted: A Boolean value indicating whether the subclasses should be sorted by name.
     */
    public func subclasses(includeNested: Bool = false, sorted: Bool = false) -> [AnyClass] {
        ObjCRuntime.subclasses(of: `class`, includeNested: includeNested, sorted: sorted)
    }
    
    /// A Boolean value indicating whether the class is a subclass of the specified other class.
    public func isSubclass(of class: AnyClass) -> Bool {
        self.class.isSubclass(of: `class`)
    }
    
    /// A Boolean value indicating whether the class is a superclass of the specified other class.
    public func isSuperclass(of class: AnyClass) -> Bool {
        `class`.isSubclass(of: self.class)
    }
    
    /// A Boolean value indicating whether the class is a meta class.
    public var isMetaClass: Bool {
        class_isMetaClass(`class`)
    }
    
    /// Returns the meta class for the class.
    public var metaClass: AnyClass {
        isMetaClass ? `class` : object_getClass(`class`)!
    }
    
    /**
     Returns all instance methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance methods of the superclasses.
     */
    public func methods(includeSuperclasses: Bool = false) -> [Method] {
        var methods: [Method] = []
        var seen: Set<Selector> = []
        var current: AnyClass? = `class`
        while let cls = current {
            current = includeSuperclasses ? class_getSuperclass(cls) : nil
            var count: UInt32 = 0
            guard let list = class_copyMethodList(cls, &count) else { continue }
            defer { free(list) }
            methods += list.buffer(count: count).filter({ seen.insert(method_getName($0)).inserted })
        }
        return methods
    }
    
    /**
     Returns all class methods of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class methods of the superclasses.
     */
    public func classMethods(includeSuperclasses: Bool = false) -> [Method] {
        ObjCClass(metaClass).methods(includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns all instance properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance properties of the superclasses.
     */
    public func properties(includeSuperclasses: Bool = false) -> [objc_property_t] {
        var properties: [objc_property_t] = []
        var seen: Set<String> = []
        for cls in classes(includeSuperclasses) {
            var count: UInt32 = 0
            guard let list = class_copyPropertyList(cls, &count) else { continue }
            defer { free(list) }
            properties += list.buffer(count: count).filter({ seen.insert(property_getName($0).string).inserted })
        }
        return properties
    }
    
    /**
     Returns all class properties of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class properties of the superclasses.
     */
    public func classProperties(includeSuperclasses: Bool = false) -> [objc_property_t] {
        ObjCClass(metaClass).properties(includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns all instance variables of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include instance variables of the superclasses.
     */
    public func variables(includeSuperclasses: Bool = false) -> [Ivar] {
        var ivars: [Ivar] = []
        for cls in classes(includeSuperclasses) {
            var count: UInt32 = 0
            guard let list = class_copyIvarList(cls, &count) else { continue }
            defer { free(list) }
            ivars += list.array(count: count)
        }
        return ivars
    }
    
    /**
     Returns all class variables of the class.

     - Parameter includeSuperclasses: A Boolean value indicating whether to include class variables of the superclasses.
     */
    public func classVariables(includeSuperclasses: Bool = false) -> [Ivar] {
        ObjCClass(metaClass).variables(includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns all protocols the class conforms to.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols that the superclasses are conforming to.
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols inherited by each protocol recursively.
     */
    public func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) -> [Protocol] {
        var visited = Set<ObjectIdentifier>()
        var protocols: [Protocol] = []
        func visit(_ proto: Protocol) {
            guard visited.insert(proto).inserted else { return }
            protocols.append(proto)
            guard includeInheritedProtocols else { return }
            var count: UInt32 = 0
            guard let list = protocol_copyProtocolList(proto, &count) else { return }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach({ visit($0) })
        }
        for cls in classes(includeSuperclasses) {
            var count: UInt32 = 0
            guard let list = class_copyProtocolList(cls, &count) else { continue }
            defer { free(UnsafeMutableRawPointer(list)) }
            list.buffer(count: count).forEach({ visit($0) })
        }
        return protocols
    }
    
    private func classes(_ includeSuperclasses: Bool) -> [AnyClass] {
        includeSuperclasses ? `class` + superclasses : [`class`]
    }
    
    /// A Boolean value indicating whether the class conforms to the specified protocol.
    public func conforms(to protocol: Protocol) -> Bool {
        class_conformsToProtocol(`class`, `protocol`)
    }
    
    /// Returns a Boolean value indicating whether instances of this class respond to the specified selector.
    public func responds(to selector: Selector) -> Bool {
        class_respondsToSelector(`class`, selector)
    }
    
    /// Returns a Boolean value indicating whether the class responds to the specified selector.
    public func classResponds(to selector: Selector) -> Bool {
        class_respondsToSelector(metaClass, selector)
    }
    
    /// Returns the instance property of the class with the specified name.
    public func property(named name: String) -> objc_property_t? {
        class_getProperty(`class`, name)
    }
    
    /// Returns the class property of the class with the specified name.
    public func classProperty(named name: String) -> objc_property_t? {
        class_getProperty(metaClass, name)
    }
    
    /// Returns the instance variable of the class with the specified name.
    public func variable(named name: String) -> Ivar? {
        class_getInstanceVariable(`class`, name)
    }
    
    /// Returns the class variable of the class with the specified name.
    public func classVariable(named name: String) -> Ivar? {
        class_getClassVariable(`class`, name)
    }
    
    /**
     Returns the instance method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching instance method, or `nil` if no such method exists.
     */
    public func method(for selector: Selector, declaredOnly: Bool = false) -> Method? {
        declaredOnly ? declaredMethod(for: `class`, selector) : class_getInstanceMethod(`class`, selector)
    }
    
    /**
     Returns the class method of the class corresponding to the specified selector.
     
     - Parameters:
        - selector: The selector identifying the method.
        - declaredOnly: If `true`, only methods declared directly by this class are considered; otherwise, methods declared by superclasses are also considered.
     - Returns: The matching class method, or `nil` if no such method exists.
     */
    public func classMethod(for selector: Selector, declaredOnly: Bool = false) -> Method? {
        declaredOnly ? declaredMethod(for: metaClass, selector) : class_getClassMethod(`class`, selector)
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
        class_getMethodImplementation(`class`, selector)
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
        guard let method = method(for: selector) else { return false }
        var currentClass: AnyClass? = superclass
        while let superClass = currentClass {
            if let superMethod = class_getInstanceMethod(superClass, selector), superMethod != method {
                return true
            }
            currentClass = class_getSuperclass(superClass)
        }
        return false
    }
    
    /// Returns a Boolean value indicating whether this class overrides the specified class method.
    public func classOverrides(_ selector: Selector) -> Bool {
        guard let method = classMethod(for: selector) else { return false }
        var currentClass: AnyClass? = superclass
        while let superClass = currentClass {
            if let superMethod = class_getClassMethod(superClass, selector), superMethod != method {
                return true
            }
            currentClass = class_getSuperclass(superClass)
        }
        return false
    }
    
    func `protocol`(for selector: Selector, isInstanceMethod: Bool) throws -> Protocol? {
        var protocolBySignature: [String: Protocol] = [:]
        for proto in ObjCClass(isInstanceMethod ? `class` : metaClass).protocols(includeSuperclasses: true, includeInheritedProtocols: true) {
            guard let typeEncoding = proto.methodTypeEncoding(for: selector, isInstanceMethod: isInstanceMethod) else { continue }
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
