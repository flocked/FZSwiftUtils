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
        let allClasses = UnsafeBufferPointer(start: classList, count: Int(count)).filter({
            return !Self._classesToSkip.contains(NSStringFromClass($0))
            return !Self.classesToSkip.contains(ObjectIdentifier($0))
        })
        defer { free(UnsafeMutableRawPointer(classList)) }
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
    
    /*
    public static func protocols(of cls: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = true) -> [Protocol] {
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
    */
    
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
    
    private static let _classesToSkip = Set([
        "__NSGenericDeallocHandler", "__NSAtom", "_NSZombie_", "__NSMessageBuilder", "CKSQLiteUnsetPropertySentinel", "JSExport", "Object"
    ])
    
    private static let classesToSkip = Set([
        "__NSGenericDeallocHandler", "__NSAtom", "_NSZombie_", "__NSMessageBuilder", "CKSQLiteUnsetPropertySentinel", "JSExport", "Object"
    ].compactMap({NSClassFromString($0)}).map({ObjectIdentifier($0)}))
}

extension ObjCRuntime {
    /**
     Returns the Objective-C classes whose name or members match the provided string.
     
     `searchString` examines the class name and the names of declared methods, properties, ivars, and adopted protocols. The default value is `nil` and returns all known classes.
     
     - Parameter searchString: A string used to filter classes by name or by the names of their methods, properties, ivars, or adopted protocols.
     - Returns: An array of `ObjCClassInfo` values representing classes that match the search.
     */
    public static func classes(containing searchString: String? = nil) -> [ObjCClassInfo] {
        guard let searchString = searchString?.lowercased(), !searchString.isEmpty else { return Cache.searchClasses.map(\.info) }
        return Cache.searchClasses.filter({$0.containsSearchString(searchString)}).map(\.info)
    }
    
    /**
     Returns the Objective-C classes grouped by protocol whose name or members match the provided search string.
     
     `searchString` examines the class name and the names of declared methods, properties, ivars, and adopted protocols. The default value is `nil` and returns all classes grouped by the protocols they adopt.
     
     - Parameter searchString: A string used to filter classes by name or by the names of their methods, properties, ivars, or adopted protocols.
     - Returns: An array of tuples where each element contains a protocol and the classes that adopt it and match the search.
     */
    public static func classesByProtocol(containing searchString: String? = nil) -> [(protocol: ObjCProtocolInfo, classes: [ObjCClassInfo])] {
        guard let searchString = searchString?.lowercased(), !searchString.isEmpty else {
            return Cache.classesByProtocol.map({ ($0.key, $0.value.map(\.info)) })
        }
        var result: [(protocol: ObjCProtocolInfo, classes: [ObjCClassInfo])] = []
        for val in Cache.classesByProtocol {
            let filtered = val.value.filter({ $0.containsSearchString(searchString) })
            guard !filtered.isEmpty else { continue }
            result += (val.key, filtered.map(\.info))
        }
        return result
    }
    
    /**
     Returns Objective-C classes grouped by the dynamic library image they originate from.
     
     `searchString` examines the class name and the names of declared methods, properties, ivars, and adopted protocols. The default value is `nil` and returns all classes grouped by their originating dynamic library image.
     
     - Parameter searchString: A string used to filter classes by name or by the names of their methods, properties, ivars, or adopted protocols.
     - Returns: An array of tuples where each element contains a dynamic library image and the classes originating from that image that match the search. The image may be `nil` if it cannot be determined.
     */
    public static func classesByImage(containing searchString: String? = nil) -> [(image: ObjcDynamicLibrary?, classes: [ObjCClassInfo])] {
        guard let searchString = searchString?.lowercased(), !searchString.isEmpty else {
            return Cache.classesByImage.map({ ($0.key, $0.value.map(\.info)) })
        }
        var result: [(image: ObjcDynamicLibrary?, classes: [ObjCClassInfo])] = []
        for val in Cache.classesByImage {
            let filtered = val.value.filter({ $0.containsSearchString(searchString) })
            guard !filtered.isEmpty else { continue }
            result += (val.key, filtered.map(\.info))
        }
        return result
    }
    
    /**
     Returns class hierarchy nodes for Objective-C classes whose name or members match the provided search string.
     
     `searchString` examines the class name and the names of declared methods, properties, ivars, and adopted protocols. The default value is `nil` and returns the hierarchy includes all classes.
     
     - Parameter searchString: A string used to filter classes by name or by the names of their methods, properties, ivars, or adopted protocols.
     - Returns: An array of `ObjCClassNode` values representing the hierarchy of matching classes.
     */
    public static func classNodes(containing searchString: String? = nil) -> [ObjCClassNode] {
        Cache.classNodes.compactMap({ $0.node(containing: searchString) })
    }
    
    /**
     Parses all known Objective-C classes.
     
     - Parameter completion: The handler that is called after parsing has been finished.
     */
    public static func parseClasses(completion: (()->())? = nil) {
        Cache.reset()
        DispatchQueue.background.async {
            Cache.parseIfNeeded()
            completion?()
        }
    }
}

fileprivate extension ObjCRuntime {
    class Cache: NSObject {
        static var classes: [AnyClass]?
        static var protocols: [Protocol]?
        static var cachedName: [ObjectIdentifier: String] = [:]
        
        static var searchClasses: [SearchClass] {
            if _searchClasses.isEmpty {
                _searchClasses = ObjCRuntime.classes().map({ SearchClass($0) })
            }
            return _searchClasses
        }
        static var _searchClasses: [SearchClass] = []
        
        static var classesByImage: OrderedDictionary<ObjcDynamicLibrary?, [SearchClass]> {
            if _classesByImage.isEmpty {
                let clsByImg = searchClasses.grouped(by: { ObjcDynamicLibrary($0.info.imageName) })
                _classesByImage = OrderedDictionary(uniqueKeysWithValues: clsByImg.keys.sorted().map({($0, clsByImg[$0]!)}))
            }
            return _classesByImage
        }
        static var _classesByImage: OrderedDictionary<ObjcDynamicLibrary?, [SearchClass]> = [:]
        
        static var classesByProtocol: OrderedDictionary<ObjCProtocolInfo, [SearchClass]> {
            if _classesByProtocol.isEmpty {
                let proToCls = searchClasses.groupedByEach(by: \.info.allProtocols)
                _classesByProtocol = OrderedDictionary(uniqueKeysWithValues: proToCls.keys.sorted(by: \.name).map({ ($0, proToCls[$0]!) }))
            }
            return _classesByProtocol
        }
        static var _classesByProtocol: OrderedDictionary<ObjCProtocolInfo, [SearchClass]> = [:]

        static var classNodes: [ObjCClassNode] {
            if _classNodes.isEmpty {
                _classNodes = ObjCClassNode.rootNodes(for: searchClasses)
            }
            return _classNodes
        }
        static var _classNodes: [ObjCClassNode] = []
                
        static func reset() {
            _classNodes.removeAll()
            _searchClasses.removeAll()
            _classesByImage.removeAll()
            _classesByProtocol.removeAll()
        }
        
        static func parseIfNeeded() {
            _ = searchClasses
            _ = classesByImage
            _ = classesByProtocol
            _ = classNodes
        }
    }
}

/*


 private func methodDescription(protocol proto: Protocol, selector: Selector, isInstanceMethod: Bool) -> objc_method_description? {
     if let description = methodDescriptionWithoutSearchingInheritedProtocols(protocol: proto, selector: selector, isInstanceMethod: isInstanceMethod) {
         return description
     }
     var protocolsCount: UInt32 = 0
     guard let protocolsPointer = protocol_copyProtocolList(proto, &protocolsCount) else {
         return nil
     }
     defer {
         free(UnsafeMutableRawPointer(protocolsPointer))
     }
     for inheritedProtocol in protocolsPointer.buffer(count: protocolsCount) {
         if let description = methodDescription(protocol: inheritedProtocol, selector: selector, isInstanceMethod: isInstanceMethod) {
             return description
         }
     }
     return nil
 }
 */

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
