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
        let allClasses = classList.buffer(count: count).filter({
            !Self.classNamesToSkip.contains(NSStringFromClass($0))
        })
        defer { free(UnsafeMutableRawPointer(classList)) }
        Cache.classes = allClasses
        return allClasses
    }
    
    static func classNames() -> Set<String> {
        if let cached = Cache.classNames {
            return cached
        }
        let names = Set(classes().map({ class_getName($0).string }))
        Cache.classNames = names
        return names
    }
    
    /// Returns all protocols.
    public static func protocols() -> [Protocol] {
        if let cachedProtocols = Cache.protocols {
            return cachedProtocols
        }
        var count: UInt32 = 0
        guard let protocolList = objc_copyProtocolList(&count) else { return [] }
        defer { free(UnsafeMutableRawPointer(protocolList)) }
        let allProtocols = protocolList.array(count: count)
        Cache.protocols = allProtocols
        return allProtocols
    }
    
    static func protocolNames() -> Set<String> {
        if let cached = Cache.protocolNames {
            return cached
        }
        let names = Set(protocols().map({ protocol_getName($0).string }))
        Cache.protocolNames = names
        return names
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
     */
    public static func subclasses<T: AnyObject>(of baseClass: T.Type, includeNested: Bool = false) -> [T.Type] {
        func address(of object: Any?) -> UnsafeMutableRawPointer {
            Unmanaged.passUnretained(object as AnyObject).toOpaque()
        }
        let basePtr = address(of: baseClass)
        let subclasses: [T.Type] = classes().compactMap { cls in
            var current: AnyClass? = cls
            while let superClass = class_getSuperclass(current) {
                if address(of: superClass) == basePtr {
                    return cls as? T.Type
                }
                current = includeNested ? superClass : nil
            }
            return nil
        }
        return subclasses.map { (type: $0, name: name(for: $0)) }.sorted(by: \.name).map { $0.type }
    }
    
    /**
     Returns all subclasses for the specified class.
     
     - Parameters:
        - baseClass: The class for which to return its subclasses.
        - includeNested: A Boolean value indicating whether to include nested subclasses.
     */
    @_disfavoredOverload
    public static func subclasses(of baseClass: AnyClass, includeNested: Bool = false) -> [AnyClass] {
        func address(of object: Any?) -> UnsafeMutableRawPointer {
            Unmanaged.passUnretained(object as AnyObject).toOpaque()
        }
        let basePtr = address(of: baseClass)
        return classes().filter({
            var current: AnyClass? = $0
            while let superClass = class_getSuperclass(current) {
                if address(of: superClass) == basePtr { return true }
                current = includeNested ? superClass : nil
            }
            return false
        }).map({(class: $0 as AnyClass, name: name(for: $0))}).sorted(by: \.name).map({$0.class})
    }
    
    /**
     Returns all subclasses for the class with the specified name.
     
     - Parameters:
        - className: The name of the class for which to return its subclasses.
        - includeNested: A Boolean value indicating whether to include nested subclasses.
     */
    public static func subclasses(of className: String, includeNested: Bool = false) -> [AnyClass] {
        guard let cls = NSClassFromString(className) else { return [] }
        return subclasses(of: cls, includeNested: includeNested)
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
    
    /**
     Returns runtime origin information for the specified method.
     
     - Parameter method: The method to retrive runtime origin information.

     The returned `imagePath` is the path of the Mach-O image that contains the method.
     The returned `symbolName` is the symbol name associated with the method.
     The returned `categoryName` is the Objective-C category name when the symbol represents a category method.
     */
    public static func origin(of method: Method) -> (imagePath: String?, symbolName: String?, categoryName: String?) {
        let key = ObjCMethodKey(method)
        if let origin = Cache.methodOrigins[key] {
            return origin
        }
        let origin = origin(of: unsafeBitCast(method_getImplementation(method), to: UnsafeRawPointer.self))
        Cache.methodOrigins[key] = origin
        return origin
    }
    
    /**
     Returns runtime origin information for the specified class.
     
     - Parameter class: The class to retrive runtime origin information.

     The returned `imagePath` is the path of the Mach-O image that contains the class.
     The returned `symbolName` is the symbol name associated with the class.
     The returned `categoryName` is the Objective-C category name when the symbol represents a category method.
     */
    public static func origin(of class: AnyClass) -> (imagePath: String?, symbolName: String?, categoryName: String?) {
        if let origin = Cache.classOrigins[`class`] {
            return origin
        }
        let origin = origin(of: unsafeBitCast(`class`, to: UnsafeRawPointer.self))
        Cache.classOrigins[`class`] = origin
        return origin
    }
    
    /**
     Returns runtime origin information for the specified address.
     
     - Parameter pointer: The address of a class object or method implementation.
     
     The returned `imagePath` is the path of the Mach-O image that contains the address.
     The returned `symbolName` is the symbol name associated with the address.
     The returned `categoryName` is the Objective-C category name when the symbol represents a category method.
     */
    public static func origin(of pointer: UnsafeRawPointer) -> (imagePath: String?, symbolName: String?, categoryName: String?) {
        var info = Dl_info()
        let result = dladdr(pointer, &info)
        guard result != 0 else {
            return (nil, nil, nil)
        }
        let imagePath = info.dli_fname.map { String(cString: $0) }
        let symbolName = info.dli_sname.map { String(cString: $0) }
        let categoryName: String?
        if let symbolName, let start = symbolName.firstIndex(of: "("), let end = symbolName.firstIndex(of: ")"), start < end {
            categoryName = String(symbolName[symbolName.index(after: start)..<end])
        } else {
            categoryName = nil
        }
        return (imagePath, symbolName, categoryName)
    }
    
    /// Returns the names of all the loaded Objective-C frameworks and dynamic libraries.
    public static func imageNames() -> [String] {
        var count: UInt32 = 0
        let list = objc_copyImageNames(&count)
        defer { free(list) }
        return list.buffer(count: count).map({$0.string})
    }
    
    /// Returns the names of all the classes within the specified library or framework.
    public static func classNames(forImage image: String) -> [String]? {
        var count: UInt32 = 0
        guard let list = objc_copyClassNamesForImage(image, &count) else { return nil }
        defer { free(list) }
        return list.buffer(count: count).map({$0.string})
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
    
    static let classNamesToSkip = Set([
        "__NSGenericDeallocHandler", "__NSAtom", "_NSZombie_", "__NSMessageBuilder", "CKSQLiteUnsetPropertySentinel", "JSExport", "Object"
    ])
    
    private static let classesToSkip = Set(classNamesToSkip.compactMap({NSClassFromString($0)}).map({ObjectIdentifier($0)}))
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
    
    /// Returns the bridged Objective-C type for the specified type.
    public static func objcType(for swiftType: Any.Type) -> AnyClass? {
        (swiftType as? (any _ObjectiveCBridgeable.Type))?._ObjectiveCClass ?? swiftType as? AnyClass
    }
}

fileprivate extension ObjCRuntime {
    class Cache: NSObject {
        static var classes: [AnyClass]?
        static var classNames: Set<String>?
        static var protocolNames: Set<String>?
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
                let clsByImg = searchClasses.grouped(by: { ObjcDynamicLibrary($0.info.imagePath) })
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
        
        static var methodOrigins: [ObjCMethodKey: (imagePath: String?, symbolName: String?, categoryName: String?)] = [:]
        
        static var classOrigins: [ObjectIdentifier: (imagePath: String?, symbolName: String?, categoryName: String?)] = [:]

                
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
        /// Internal class to manage unsafe buffer memory
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
