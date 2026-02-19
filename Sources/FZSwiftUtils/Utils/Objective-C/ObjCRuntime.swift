//
//  ObjCRuntime.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation
import _FZSwiftUtilsObjC

/// Objective-C utilities.
public enum ObjCRuntime {
    /// Returns all classes.
    public static func classes() -> [AnyClass] {
        if let chachedClasses = Cache.classes {
            return chachedClasses
        }
        var count: UInt32 = 0
        guard let classList = objc_copyClassList(&count) else { return [] }
        let toSkip = Set(["__NSGenericDeallocHandler", "__NSAtom", "_NSZombie_", "__NSMessageBuilder", "CKSQLiteUnsetPropertySentinel", "JSExport", "Object"])
        let allClasses = UnsafeBufferPointer(start: classList, count: Int(count)).filter({ !toSkip.contains(String(cString: class_getName($0))) })
        Cache.classes = allClasses
        return allClasses
    }
    
    /// Returns all protocols.
    public static func protocols() -> [Protocol] {
        if let cachedProtocols = Cache.protocols {
            return cachedProtocols
        }
        var count: UInt32 = 0
        guard let protocolList = objc_copyProtocolList(&count) else { return [] }
        let allProtocols = Array(UnsafeBufferPointer(start: protocolList, count: Int(count)))
        Cache.protocols = allProtocols
        return allProtocols
    }
    
    /// Returns all clases implementing the specified protocol.
    public static func classes(implementing _protocol: Protocol) -> [AnyClass] {
        classes().filter({ class_conformsToProtocol($0, _protocol) })
    }
    
    /// Returns all superclasses of the specified class.
    public static func superclasses(of cls: AnyClass) -> [AnyClass] {
        Array(first: class_getSuperclass(cls), next: { class_getSuperclass($0) }).nonNil
    }
    
    /**
     Returns all subclasses for the specified class.
     
     - Parameters:
        - baseClass: The class for which to return its subclasses.
        - includeNested: A Boolean value indicating whether to include nested subclasses.
        - sorted: A Boolean value indicating whether the subclasses should be sorted by name.
     */
    public static func subclasses<T>(of baseClass: T, includeNested: Bool = false, sorted: Bool = false) -> [T] {
        func address(of object: Any?) -> UnsafeMutableRawPointer {
            Unmanaged.passUnretained(object as AnyObject).toOpaque()
        }
        let basePtr = address(of: baseClass)
        let subclasses = classes().compactMap { cls -> T? in
            var current: AnyClass? = cls
            while let superClass = class_getSuperclass(current) {
                if address(of: superClass) == basePtr {
                    return cls as? T
                }
                current = includeNested ? superClass : nil
            }
            return nil
        }
        if sorted {
            return subclasses.map({(class: $0, name: name(for: $0 as! AnyClass))}).sorted(by: \.name).map({$0.class})
        }
        return subclasses
    }
    
    public static func protocols(of cls: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
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
            cls = includeSuperclasses ? current.superclass() : nil
        }
        return result
    }
    
    /**
      Executes the specified block that may throw an Objective-C `NSException` and catches it.

      This method enables safer bridging of Objective-C code into Swift, where exceptions cannot be caught using `do-try-catch`.

      - Parameter tryBlock: A closure containing Objective-C code that may throw an exception.
     - Returns: The value returned from the given callback.

      Example usage:

     ```swift
     let object: NSObject // …

     do {
         let value = try ObjCRuntime.catch {
             object.value(forKey: "someProperty")
         }
         print("Value:", value)
     } catch {
         print("Error:", error.localizedDescription)
         //=> Error: The operation couldn’t be completed. [valueForUndefinedKey:]: this class is not key value coding-compliant for the key nope.
     }
     ```
     */
    @_disfavoredOverload
    @discardableResult
    public static func catchException<T>(_ tryBlock: @autoclosure () throws -> T) throws -> T {
        try catchException(tryBlock)
    }
    
    /**
      Executes the specified block that may throw an Objective-C `NSException` and catches it.

      This method enables safer bridging of Objective-C code into Swift, where exceptions cannot be caught using `do-try-catch`.

      - Parameter tryBlock: A closure containing Objective-C code that may throw an exception.
     - Returns: The value returned from the given callback.

      Example usage:

     ```swift
     let object: NSObject // …

     do {
         let value = try ObjCRuntime.catch {
             object.value(forKey: "someProperty")
         }
         print("Value:", value)
     } catch {
         print("Error:", error.localizedDescription)
         //=> Error: The operation couldn’t be completed. [valueForUndefinedKey:]: this class is not key value coding-compliant for the key nope.
     }
     ```
     */
    @discardableResult
    public static func catchException<T>(_ tryBlock: () throws -> T) throws -> T {
        var result: Result<T, Error>!
        try NSObject._catchException {
            do {
                result = .success(try tryBlock())
            } catch {
                result = .failure(error)
            }
        }
        return try result.get()
    }
    
    /// Returns the actual size and the aligned size of the specified encoded type.
    public static func sizeAndAlignment(for typeEncoding: String) -> (size: Int, alignment: Int)? {
        var alignment = 0
        var size: Int = 0
        do {
            try ObjCRuntime.catchException {
                NSGetSizeAndAlignment(typeEncoding, &size, &alignment)
            }
            return (size, alignment)
        } catch {
            Swift.print(error)
            return nil
        }
    }
    
    static func name(for class: AnyClass) -> String {
        if let name = Cache.cachedName[`class`] {
            return name
        }
        let name = NSStringFromClass(`class`)
        Cache.cachedName[`class`] = name
        return name
    }
    
    static func name(for protocol: Protocol) -> String {
        if let name = Cache.cachedName[`protocol`] {
            return name
        }
        let name = NSStringFromProtocol(`protocol`)
        Cache.cachedName[`protocol`] = name
        return name
    }
}

fileprivate extension ObjCRuntime {
    class Cache: NSObject {
        static var classes: [AnyClass]? {
            get { getAssociatedValue("classes") }
            set { setAssociatedValue(newValue, key: "classes") }
        }
        
        static var protocols: [Protocol]? {
            get { getAssociatedValue("protocols") }
            set { setAssociatedValue(newValue, key: "protocols") }
        }
        
        static var cachedName: [ObjectIdentifier: String] {
            get { getAssociatedValue("cachedName") ?? [:] }
            set { setAssociatedValue(newValue, key: "cachedName") }
        }
    }
}

extension Protocol {
    /// The name of the protocol.
    public var name: String {
        ObjCRuntime.name(for: self)
    }
    
    /// Returns all classes impelementing the protocol.
    public func conformingClasses() -> [AnyClass] {
        ObjCRuntime.classes(implementing: self)
    }
    
    /// Returns a the protocol with the specfiiec name.
    public static func named(_ name: String) -> Protocol? {
        NSProtocolFromString(name)
    }
    
    func containsSelector(_ selector: Selector) -> Bool {
        if protocol_getMethodDescription(self, selector, true, true).name != nil || protocol_getMethodDescription(self, selector, false, true).name != nil {
            return true
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return false }
        if (0..<Int(protocolCount)).contains(where: { superProtocols[$0].containsSelector(selector) }) {
            return true
        }
        return false
    }

    func typeEncoding(for selector: Selector, optionalOnly: Bool = false) -> UnsafePointer<CChar>? {
        var methodDesc: objc_method_description!
        if optionalOnly {
            methodDesc = protocol_getMethodDescription(self, selector, false, true)
        } else {
            methodDesc = protocol_getMethodDescription(self, selector, true, true)
            if methodDesc.types == nil {
                methodDesc = protocol_getMethodDescription(self, selector, false, true)
            }
        }
        if let types = methodDesc.types {
            return withUnsafePointer(to: &types.pointee) { pointer in
                return pointer
            }
        }
        var protocolCount: UInt32 = 0
        guard let superProtocols = protocol_copyProtocolList(self, &protocolCount) else { return nil }
        for i in 0..<Int(protocolCount) {
            if let typeEncoding = superProtocols[i].typeEncoding(for: selector, optionalOnly: optionalOnly) {
                return typeEncoding
            }
        }
        return nil
    }
    
    static func typeEncoding(for selector: Selector, class: AnyClass, optionalOnly: Bool = false) -> UnsafePointer<CChar>? {
        var protocolCount: UInt32 = 0
        if let protocols = class_copyProtocolList(`class`, &protocolCount) {
            for i in 0..<Int(protocolCount) {
                if let typeEncoding = protocols[i].typeEncoding(for: selector, optionalOnly: optionalOnly) {
                    return typeEncoding
                }
            }
        }
        if let superclass = class_getSuperclass(`class`), superclass != `class` {
            return typeEncoding(for: selector, class: superclass, optionalOnly: optionalOnly)
        }
       return nil
    }

    static func typeEncoding(for selector: Selector, protocol proto: Protocol) -> UnsafePointer<CChar>? {
        // Check required methods
        var methodDesc = protocol_getMethodDescription(proto, selector, true, true)
        if methodDesc.name != nil, let types = methodDesc.types {
            return UnsafePointer(types)
        }

        // Check optional methods
        methodDesc = protocol_getMethodDescription(proto, selector, false, true)
        if methodDesc.name != nil, let types = methodDesc.types {
            return UnsafePointer(types)
        }

        // Recursively check inherited protocols
        var inheritedCount: UInt32 = 0
        if let inherited = protocol_copyProtocolList(proto, &inheritedCount) {
            for i in 0..<Int(inheritedCount) {
                if let typeEncoding = typeEncoding(for: selector, protocol: inherited[i]) {
                    return typeEncoding
                }
            }
        }

        return nil
    }
}

extension ObjCRuntime {
    /// Property sequence wrapper
    struct PropertySequence: Sequence {
        let cls: AnyClass
        let includeSuperclasses: Bool
        let isInstance: Bool

        func makeIterator() -> ObjCIterator<objc_property_t> {
            ObjCIterator(cls: cls, includeSuperclasses: includeSuperclasses, isInstance: isInstance) { cls in
                var count: UInt32 = 0
                let ptr = class_copyPropertyList(cls, &count)
                return (ptr, Int(count))
            }
        }
    }

    /// Method sequence wrapper
    struct MethodSequence: Sequence {
        let cls: AnyClass
        let includeSuperclasses: Bool
        let isInstance: Bool

        func makeIterator() -> ObjCIterator<Method> {
            ObjCIterator(cls: cls, includeSuperclasses: includeSuperclasses, isInstance: isInstance) { cls in
                var count: UInt32 = 0
                let ptr = class_copyMethodList(cls, &count)
                return (ptr, Int(count))
            }
        }
    }
    
    /// Generic iterator for Objective-C runtime buffers.
    struct ObjCIterator<Element>: IteratorProtocol {
        private class BufferOwner {
            let pointer: UnsafeMutablePointer<Element>?
            let count: Int
            init(pointer: UnsafeMutablePointer<Element>?, count: Int) {
                self.pointer = pointer
                self.count = count
            }
            deinit { if let ptr = pointer { free(ptr) } }
        }

        var currentClass: AnyClass?
        let includeSuperclasses: Bool
        let isInstance: Bool
        private let bufferLoader: (AnyClass) -> (UnsafeMutablePointer<Element>?, Int)

        private var bufferOwner: BufferOwner?
        private var index: Int = 0

        init(cls: AnyClass, includeSuperclasses: Bool, isInstance: Bool,
             bufferLoader: @escaping (AnyClass) -> (UnsafeMutablePointer<Element>?, Int)) {
            self.currentClass = isInstance ? cls : object_getClass(cls)
            self.includeSuperclasses = includeSuperclasses
            self.isInstance = isInstance
            self.bufferLoader = bufferLoader
            loadBuffer()
        }

        private mutating func loadBuffer() {
            guard let cls = currentClass else {
                bufferOwner = nil
                index = 0
                return
            }
            let (ptr, count) = bufferLoader(cls)
            bufferOwner = BufferOwner(pointer: ptr, count: count)
            index = 0
        }

        mutating func next() -> Element? {
            guard let owner = bufferOwner, let ptr = owner.pointer, index < owner.count else {
                if includeSuperclasses, let superclass = currentClass.flatMap({ class_getSuperclass($0) }) {
                    currentClass = superclass
                    loadBuffer()
                    return next()
                }
                return nil
            }
            defer { index += 1 }
            return ptr[index]
        }
    }
}

extension ObjCRuntime {
    /// Public API for protocol methods
    struct ProtocolMethodSequence: Sequence {
        let proto: Protocol
        let isRequired: Bool
        let isInstance: Bool
        let includeInherentProtocols: Bool
        let includeSuperProtocols: Bool

        func makeIterator() -> ObjCProtocolIterator<objc_method_description> {
            ObjCProtocolIterator(
                startingProtocol: proto,
                includeInherentProtocols: includeInherentProtocols,
                includeSuperProtocols: includeSuperProtocols
            ) { proto in
                var count: UInt32 = 0
                let ptr = protocol_copyMethodDescriptionList(proto, isRequired, isInstance, &count)
                return (ptr, Int(count))
            }
        }
    }

    /// Public API for protocol properties
    struct ProtocolPropertySequence: Sequence {
        let proto: Protocol
        let includeInherentProtocols: Bool
        let includeSuperProtocols: Bool

        func makeIterator() -> ObjCProtocolIterator<objc_property_t> {
            ObjCProtocolIterator(startingProtocol: proto, includeInherentProtocols: includeInherentProtocols, includeSuperProtocols: includeSuperProtocols) { proto in
                var count: UInt32 = 0
                let ptr = protocol_copyPropertyList(proto, &count)
                return (ptr, Int(count))
            }
        }
    }
    
    /// Generic iterator over Objective-C protocol buffers (methods or properties)
    struct ObjCProtocolIterator<Element>: IteratorProtocol {
        // Internal class to manage unsafe buffer memory
        private class BufferOwner {
            let pointer: UnsafeMutablePointer<Element>?
            let count: Int
            init(pointer: UnsafeMutablePointer<Element>?, count: Int) {
                self.pointer = pointer
                self.count = count
            }
            deinit { if let ptr = pointer { free(ptr) } }
        }

        // Stack of protocols to process
        private var protocolStack: [Protocol] = []
        private var visited: Set<String> = []

        private let bufferLoader: (Protocol) -> (UnsafeMutablePointer<Element>?, Int)
        private let includeInherentProtocols: Bool
        private let includeSuperProtocols: Bool

        private var bufferOwner: BufferOwner?
        private var index: Int = 0

        init(startingProtocol: Protocol,
             includeInherentProtocols: Bool,
             includeSuperProtocols: Bool,
             bufferLoader: @escaping (Protocol) -> (UnsafeMutablePointer<Element>?, Int)) {

            self.bufferLoader = bufferLoader
            self.includeInherentProtocols = includeInherentProtocols
            self.includeSuperProtocols = includeSuperProtocols

            self.protocolStack = [startingProtocol]
            self.visited = []
            loadNextProtocolBuffer()
        }

        private mutating func loadNextProtocolBuffer() {
            bufferOwner = nil
            index = 0
            while !protocolStack.isEmpty {
                let proto = protocolStack.removeLast()
                let protoName = String(cString: protocol_getName(proto))
                if visited.contains(protoName) { continue }
                visited.insert(protoName)

                // Add adopted protocols if flags are set
                if includeSuperProtocols || includeInherentProtocols {
                    var adoptedCount: UInt32 = 0
                    if let adoptedProtocols = protocol_copyProtocolList(proto, &adoptedCount) {
                        for i in 0..<Int(adoptedCount) {
                            let adopted = adoptedProtocols[i]
                            let name = String(cString: protocol_getName(adopted))
                            if !visited.contains(name) {
                                protocolStack.append(adopted)
                            }
                        }
                    }
                }

                // Only load this protocol’s buffer if we want it
                if bufferLoader(proto).0 != nil {
                    let (ptr, count) = bufferLoader(proto)
                    bufferOwner = BufferOwner(pointer: ptr, count: count)
                    return
                }
            }
        }

        mutating func next() -> Element? {
            guard let owner = bufferOwner, let ptr = owner.pointer, index < owner.count else {
                loadNextProtocolBuffer()
                guard let owner2 = bufferOwner, let ptr2 = owner2.pointer, index < owner2.count else {
                    return nil
                }
                defer { index += 1 }
                return ptr2[index]
            }
            defer { index += 1 }
            return ptr[index]
        }
    }
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
