//
//  ObjCClass.swift
//  
//
//  Created by Florian Zand on 20.02.26.
//

import Foundation

public struct ObjCClass {
    let cls: AnyClass
    
    public init(_ cls: AnyClass) {
        self.cls = cls
    }
    
    public var name: String {
        ObjCRuntime.name(for: cls)
    }
    
    public var superclass: AnyClass? {
        class_getSuperclass(cls)
    }
    
    public var rootSuperclass: AnyClass? {
        superclasses().last
    }
    
    /// Returns all superclasses of the specified class.
    public func superclasses() -> [AnyClass] {
        Array(first: class_getSuperclass(cls), next: { class_getSuperclass($0) }).nonNil
    }
    
    public func subclasses(includeNested: Bool = false, sorted: Bool = false) -> [AnyClass] {
        ObjCRuntime.subclasses(of: cls, includeNested: includeNested, sorted: sorted)
    }
    
    public func isSubclass(of class: AnyClass) -> Bool {
        var currentClass: AnyClass? = cls
        while let cls = currentClass {
            if cls === `class` {
                return true
            }
            currentClass = class_getSuperclass(cls)
        }
        return false
    }
    
    public func isSuperclass(of class: AnyClass) -> Bool {
        ObjCClass(`class`).isSubclass(of: cls)
    }
    
    public func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) -> [Protocol] {
        var visited = Set<ObjectIdentifier>()
        var result: [Protocol] = []
        func visit(_ proto: Protocol) {
            guard visited.insert(proto).inserted else { return }
            result.append(proto)
            guard includeInheritedProtocols else { return }
            var count: UInt32 = 0
            if let list = protocol_copyProtocolList(proto, &count) {
                for i in 0..<Int(count) {
                    visit(list[i])
                }
            }
        }
        var currentClass: AnyClass? = cls
        while let current = currentClass {
            var count: UInt32 = 0
            if let list = class_copyProtocolList(current, &count) {
                for i in 0..<Int(count) {
                    visit(list[i])
                }
            }
            currentClass = includeSuperclasses ? current.superclass() : nil
        }
        return result
    }
    
    public func conforms(to protocol: Protocol) -> Bool {
        class_conformsToProtocol(cls, `protocol`)
    }
    
    public func responds(to selector: Selector, isInstance: Bool = true) -> Bool {
        class_respondsToSelector(isInstance ? cls : object_getClass(cls), selector)
    }
    
    public func property(named name: String, isInstance: Bool = true) -> objc_property_t? {
        class_getProperty(isInstance ? cls : object_getClass(cls), name)
    }
    
    public func variable(named name: String, isInstance: Bool = true) -> Ivar? {
        isInstance ? class_getInstanceVariable(cls, name) : class_getClassVariable(cls, name)
    }
        
    public func method(for selector: Selector, isInstance: Bool = true, declaredOnly: Bool = false) -> Method? {
        if !declaredOnly { return isInstance ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector) }
        var methodCount: UInt32 = 0
        guard let methodList = class_copyMethodList(isInstance ? cls : object_getClass(cls), &methodCount) else { return nil }
        defer { free(methodList) }
        for index in 0..<Int(methodCount) {
            let method = methodList[index]
            if method_getName(method) == selector {
                return method
            }
        }
        return nil
    }
    
    public func overrides(_ selector: Selector, isInstance: Bool = true) -> Bool {
        guard let method = method(for: selector, isInstance: isInstance) else { return false }
        var currentClass: AnyClass? = class_getSuperclass(cls)
        while let superClass = currentClass {
            let superMethod = isInstance ? class_getInstanceMethod(superClass, selector) : class_getClassMethod(superClass, selector)
            if let superMethod = superMethod, superMethod != method {
                return true
            }
            currentClass = class_getSuperclass(superClass)
        }
        return false
    }
    
    func `protocol`(for selector: Selector, isInstanceMethod: Bool) throws -> Protocol? {
        guard let cls = isInstanceMethod ? cls : class_isMetaClass(cls) ? cls : object_getClass(cls) else { return nil }
        var protocolBySignature: [String: Protocol] = [:]
        for proto in ObjCClass(cls).protocols(includeSuperclasses: true, includeInheritedProtocols: true) {
            guard let types = proto.methodDescription(for: selector, isInstanceMethod: isInstanceMethod)?.types else {
                continue
            }
            let signature = String(cString: types)
            if protocolBySignature[signature] == nil {
                protocolBySignature[signature] = proto
            }
        }
        if protocolBySignature.isEmpty {
            return nil
        }
        if protocolBySignature.count == 1 {
            return protocolBySignature.first?.value
        }
        let signatures = protocolBySignature.map {
            "\"\(NSStringFromProtocol($0.value))\" => \($0.key)"
        }.sorted().joined(separator: ", ")
        throw HookError.inferredProtocolMethodAmbiguous("Auto-discovery found multiple protocol signatures for selector `\(NSStringFromSelector(selector))`: \(signatures).")
    }
}
