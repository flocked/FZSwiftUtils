//
//  ObjC.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation
import AppKit

/// Objective-C utilities.
public struct ObjC {
    /// Returns the type string of an instance variable.
    public static func typeEncoding(for ivar: Ivar) -> String? {
        ivar_getTypeEncoding(ivar).map { String(cString: $0) }
    }
    
    /*
    public struct ObjcProtocol {
        public let proto: Protocol
        
        public var name: String {
            NSStringFromProtocol(proto)
        }
        
        public init(_ proto: Protocol) {
            self.proto = proto
        }
        
        public init?(_ name: String) {
            guard let proto = NSProtocolFromString(name) else { return nil }
            self.proto = proto
        }
    }
    
    public struct ObjcMethod {
        public let method: Method
        
        public var name: String {
            NSStringFromSelector(method_getName(method))
        }
        
        public var typeEncoding: String? {
            method_getTypeEncoding(method)?.string
        }
        
        public var argumentTypes: [String] {
            (0..<numberOfArguments).compactMap({ method_copyArgumentType(method, $0+2)?.string })
        }
        
        public var returnType: String {
            method_copyReturnType(method).string
        }
        
        public var numberOfArguments: UInt32 {
            method_getNumberOfArguments(method)-2
        }
        
        public var implementation: IMP {
            method_getImplementation(method)
        }
        
        public func exchangeImplementation(with method: Self) {
            method_exchangeImplementations(self.method, method.method)
        }
    }
    
    public struct ObjcClass {
        let cls: AnyClass
                
        public init(_ cls: AnyClass) {
            self.cls = cls
        }
        
        public init?(_ name: String) {
            guard let cls = NSClassFromString(name) else { return nil }
            self.cls = cls
        }
        
        public var name: String {
            NSStringFromClass(cls)
        }
        
        public var superclass: ObjcClass? {
            guard let superclass = class_getSuperclass(cls), superclass != cls else { return nil }
            return ObjcClass(superclass)
        }
        
        public var superclasses: [ObjcClass] {
            var classes: [ObjcClass] = []
            var cls = superclass
            while var supercls = cls {
                classes.append(supercls)
                cls = supercls.superclass
            }
            return classes
        }
        
        public var rootSuperclass: ObjcClass? {
            superclasses.last
        }
        
        public func protocols(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
            var visited = Set<ObjectIdentifier>()
            var result: [Protocol] = []

            func visit(_ proto: Protocol) {
                guard visited.insert(ObjectIdentifier(proto)).inserted else { return }
                result.append(proto)
                guard includeInheritedProtocols else { return }
                var count: UInt32 = 0
                if let list = protocol_copyProtocolList(proto, &count) {
                    for i in 0..<Int(count) {
                        visit(list[i])
                    }
                }
            }

            var cls: AnyClass? = cls
            while let current = cls {
                var count: UInt32 = 0
                if let list = class_copyProtocolList(current, &count) {
                    for i in 0..<Int(count) {
                        visit(list[i])
                    }
                }
                cls = includeSuperclasses ? class_getSuperclass(current) : nil
            }
            return result
        }
        
        public func ivar(named name: String) -> ObjCIvar? {
            guard let ivar = class_getInstanceVariable(cls, name) else { return nil }
            return ObjCIvar(ivar)
        }
        
        public func classIvar(named name: String) -> ObjCIvar? {
            guard let ivar = class_getClassVariable(cls, name) else { return nil }
            return ObjCIvar(ivar)
        }
                        
        public func method(selector: Selector) -> IMP? {
            class_getMethodImplementation(cls, selector)
        }
        
        public func classMethod(selector: Selector) -> IMP? {
            class_getClassMethod(cls, selector)
        }
    }
    
    public static func protocols(for cls: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
        var visited = Set<ObjectIdentifier>()
        var result: [Protocol] = []

        func visit(_ proto: Protocol) {
            guard visited.insert(ObjectIdentifier(proto)).inserted else { return }
            result.append(proto)
            guard includeInheritedProtocols else { return }
            var count: UInt32 = 0
            if let list = protocol_copyProtocolList(proto, &count) {
                for i in 0..<Int(count) {
                    visit(list[i])
                }
            }
        }

        var cls: AnyClass? = cls
        while let current = cls {
            var count: UInt32 = 0
            if let list = class_copyProtocolList(current, &count) {
                for i in 0..<Int(count) {
                    visit(list[i])
                }
            }
            cls = includeSuperclasses ? superclass(for: current) : nil
        }
        return result
    }
    
    public static func superclass(for cls: AnyClass) -> AnyClass? {
        class_getSuperclass(cls)
    }
    
  /*
    public struct Class {
        let cls: AnyClass

        static func all() -> [AnyClass] {
            if let allClasses = allClasses {
                return allClasses
            }
            var count: UInt32 = 0
            guard let classList = objc_copyClassList(&count) else { return [] }
            let allClasses = Array(UnsafeBufferPointer(start: classList, count: Int(count)))
            self.allClasses = allClasses
            return allClasses
        }
        
        static var allClasses: [AnyClass]?
        
        public var name: String {
            NSStringFromClass(cls)
        }
    }
    */
     */
}
