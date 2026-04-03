//
//  ObjCClassInfo.swift
//
//
//  Created by p-x9 on 2024/06/24
//  
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Represents information about an Objective-C class.
public struct ObjCClassInfo: Sendable, Equatable {
    /// The name of the class.
    public let name: String
    
    /// The version of the class.
    public let version: Int32
    
    /// The path of the dynamic library the class originated from.
    public let imagePath: String?

    /// The size of instances of the class.
    public let instanceSize: Int
    
    /// The superclass of the class.
    public var superclass: ObjCClassInfo? {
        _superclass.map({ ObjCClassInfo($0) })
    }
    let _superclass: AnyClass?
    
    /// The superclasses of the class.
    public var superclasses: [ObjCClassInfo] {
        Array(first: superclass, next: { $0.superclass })
    }

    /// The protocols to which the class conforms.
    public let protocols: [ObjCProtocolInfo]

    /// The instance variables held by the class.
    public let ivars: [ObjCIvarInfo]

    /// The class properties held by the class.
    public let classProperties: [ObjCPropertyInfo]
    
    /// The instance properties held by the class.
    public let properties: [ObjCPropertyInfo]

    /// The class methods held by the class.
    public let classMethods: [ObjCMethodInfo]
    /// The instance methods held by the class.
    public let methods: [ObjCMethodInfo]
    
    /*
    static var originCache: [String: (imagePath: String?, categoryName: String?, symbolName: String?)] = [:]
    
    public lazy var origin: (imagePath: String?, categoryName: String?, symbolName: String?) = {
        if let cache = Self.originCache[name] {
            return cache
        } else if let cls = NSClassFromString(name) {
            let origin = ObjCRuntime.origin(of: cls)
            Self.originCache[name] = origin
            return origin
        }
        Self.originCache[name] = (nil,nil,nil)
        return (nil,nil,nil)
    }()
     */

    /**
     Initializes a new instance of `ObjCClassInfo`.

     - Parameters:
       - name: Name of the class.
       - version: Version of the class.
       - imagePath: Path to the dynamic library the class originated from.
       - instanceSize: Size of instances of the class.
       - superclass: The superclass of the class.
       - protocols: List of protocols to which the class conforms.
       - ivars: List of instance variables held by the class.
       - classProperties: List of class properties held by the class.
       - properties: List of instance properties held by the class.
       - classMethods: List of class methods held by the class.
       - methods: List of instance methods held by the class.
     */
    public init(
        name: String,
        version: Int32,
        imagePath: String?,
        instanceSize: Int,
        superclass: AnyClass?,
        protocols: [ObjCProtocolInfo],
        ivars: [ObjCIvarInfo],
        classProperties: [ObjCPropertyInfo],
        properties: [ObjCPropertyInfo],
        classMethods: [ObjCMethodInfo],
        methods: [ObjCMethodInfo]
    ) {
        self.name = name
        self.version = version
        self.imagePath = imagePath
        self.instanceSize = instanceSize
        self._superclass = superclass
        self.protocols = protocols
        self.ivars = ivars
        self.classProperties = classProperties
        self.properties = properties
        self.classMethods = classMethods
        self.methods = methods
    }

    /**
     Initializes a new instance of `ObjCClassInfo` for the specified class.

     - Parameters:
        - class: The class of the target for which information is to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include properties, methods, protocols and ivars for the superclasses of `cls`.
        - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of `cls`.
     */
    public init(_ class: AnyClass) {
        if let info = Self.cache[`class`] {
            self = info
        } else {
           /*
            
            let objcClass = ObjCClass(`class`)
            let methods = objcClass.methods()
            let objcMethods = methods.compactMap({ ObjCMethodInfo($0)})
            let methodsByName = Dictionary(methods.map({ (key: method_getName($0).string, value: $0)}), retainLastOccurences: false)
            let classMethods = objcClass.methods()
            let classMethodsByName = Dictionary(classMethods.map({ (key: method_getName($0).string, value: $0)}), retainLastOccurences: false)
            let objcClassMethods = classMethods.compactMap({ ObjCMethodInfo($0) })
            
            
            let objcProperties = Self.properties(of: `class`)
            for property in objcProperties {
                let getterMethod = methodsByName[property.getterName ?? property.name]
                var setterMethod: Method?
                if let setterName = property.setter?.string {
                    setterMethod = methodsByName[setterName]
                }
            }
            */
            self.init(
                name: class_getName(`class`).string,
                version: class_getVersion(`class`),
                imagePath: class_getImageName(`class`).map({ $0.string }),
                instanceSize: class_getInstanceSize(`class`),
                superclass: class_getSuperclass(`class`),
                protocols: Self.protocols(of: `class`),
                ivars: Self.ivars(of: `class`),
                classProperties: Self.classProperties(of: `class`),
                properties: Self.properties(of: `class`),
                classMethods: Self.classMethods(of: `class`),
                methods: Self.methods(of: `class`)
            )
            Self.cache[`class`] = self
        }
    }
    
    /**
     Initializes a new instance of `ObjCClassInfo` for the class with the specified name.

     - Parameters:
        - className: The class name of the target for which information is to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include properties, methods, protocols and ivars for the superclasses of the class.
        - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of the class.
     - Returns: The class info, or `nil` if there isn't a class with the specified name.
     */
    public init?(_ className: String) {
        guard let cls = NSClassFromString(className) else { return nil }
        self.init(cls)
    }
    
    
    private static var methods: SynchronizedDictionary<String, [String: Method]> = [:]
    private static var classMethods: SynchronizedDictionary<String, [String: Method]> = [:]
    private static var cache: SynchronizedDictionary<ObjectIdentifier, Self> = [:]
}

extension ObjCClassInfo: CustomStringConvertible {
    public var description: String {
        headerString
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.version == rhs.version && lhs.imagePath == rhs.imagePath && lhs.instanceSize == rhs.instanceSize && lhs.protocols == rhs.protocols && lhs.ivars == rhs.ivars && lhs.classProperties == rhs.classProperties && lhs.properties == rhs.properties && lhs.classMethods == rhs.classMethods && lhs.methods == rhs.methods
    }
    
    func containsSearchString(_ searchString: String) -> Bool {
        if name.lowercased().contains(searchString) {
            return true
        }
        if protocols.contains(where: { $0.name.lowercased().contains(searchString) }) {
            return true
        }
        if (methods + classMethods).contains(where: { $0.name.lowercased().contains(searchString) }) {
            return true
        }
        if (properties + classProperties).contains(where: { $0.name.lowercased().contains(searchString) }) {
            return true
        }
        if ivars.contains(where: { $0.name.lowercased().contains(searchString) }) {
            return true
        }
        return false
    }
}

extension ObjCClassInfo {
    /// Returns the instance property with the specified name.
    public func property(named name: String) -> ObjCPropertyInfo? {
        properties.first(where: { $0.name == name }) ?? superclass?.property(named: name)
    }
    
    /// Returns the class property with the specified name.
    public func classProperty(named name: String) -> ObjCPropertyInfo? {
        classProperties.first(where: { $0.name == name }) ?? superclass?.classProperty(named: name)
    }
    
    /// Returns the instance property for the specified getter or setter selector.
    public func property(for selector: Selector) -> ObjCPropertyInfo?  {
        properties.first(where: { $0.getter == selector || $0.setter == selector }) ?? superclass?.property(for: selector)
    }
    
    /// Returns the class property for the specified getter or setter selector.
    public func classProperty(for selector: Selector) -> ObjCPropertyInfo?  {
        classProperties.first(where: { $0.getter == selector || $0.setter == selector }) ?? superclass?.classProperty(for: selector)
    }
    
    /// Returns the instance method with the specified name.
    public func method(named name: String) -> ObjCMethodInfo? {
        methods.first(where: { $0.name == name }) ?? superclass?.method(named: name)
    }
    
    /// Returns the class method with the specified name.
    public func classMethod(named name: String) -> ObjCMethodInfo? {
        classMethods.first(where: { $0.name == name }) ?? superclass?.classMethod(named: name)
    }
    
    /// Returns the instance variable with the specified name.
    public func ivar(named name: String) -> ObjCIvarInfo? {
        ivars.first(where: { $0.name == name }) ?? superclass?.ivar(named: name)
    }
    
    /// Returns all instance properties held by the class and it's superclasses.
    public var allProperties: [ObjCPropertyInfo] {
        allClasses.flatMap({$0.properties}).uniqued(by: \.name)
    }
    
    /// Returns all class properties held by the class and it's superclasses.
    public var allClassProperties: [ObjCPropertyInfo] {
        allClasses.flatMap({$0.classProperties}).uniqued(by: \.name)
    }
    
    /// Returns all instance methods held by the class and it's superclasses.
    public var allMethods: [ObjCMethodInfo] {
        allClasses.flatMap({$0.methods}).uniqued(by: \.name)
    }
    
    /// Returns all class methods held by the class and it's superclasses.
    public var allClassMethods: [ObjCMethodInfo] {
        allClasses.flatMap({$0.classMethods}).uniqued(by: \.name)
    }
    
    /// Returns all protocols to which the class and it's superclasses conform to.
    public var allProtocols: [ObjCProtocolInfo] {
        return allClasses.flatMap({$0.allProtocols}).uniqued(by: \.name)
    }
    
    /// Returns the Objective-C type of the instance prperty at the specified key path.
    public func propertyType(at keyPath: String) -> ObjCType? {
        propertyType(for: keyPath.components(separatedBy: "."), isInstance: true)
    }
    
    /// Returns the Objective-C type of the class prperty at the specified key path.
    public func classPropertyType(at keyPath: String) -> ObjCType? {
        propertyType(for: keyPath.components(separatedBy: "."), isInstance: false)
    }

    private func propertyType(for keys: [String], isInstance: Bool) -> ObjCType? {
        var keys = keys
        guard let key = keys.removeFirstSafetly() else { return nil }
        if let property = isInstance ? property(named: key) : classProperty(named: key) {
            return resolve(type: property.type.normalized, keys: keys, isInstance: isInstance)?.normalized
        }
        if (isInstance ? method(named: key) : classMethod(named: key)) != nil {
            return resolve(type: .unknown, keys: keys, isInstance: isInstance)
        }
        return nil
    }
    
    private func resolve(type: ObjCType, keys: [String], isInstance: Bool) -> ObjCType? {
        guard !keys.isEmpty else { return type }
        var keys = keys
        let key = keys.removeFirst()
        switch type {
        case .object(name: let name):
            guard let name = name, let classInfo = name == self.name ? self : ObjCClassInfo(name) else { return nil }
            return classInfo.propertyType(for: key + keys, isInstance: isInstance)
        case .struct(_, fields: let fields):
            guard let type = fields?.first(where: { $0.name == key })?.type else { return nil }
            return resolve(type: type.normalized, keys: keys, isInstance: isInstance)
        case .pointer(type: let type), .modified(_, type: let type):
            return resolve(type: type.normalized, keys: keys, isInstance: isInstance)
        default:
            return keys.isEmpty ? type : nil
        }
    }
    
    private var allClasses: [ObjCClassInfo] {
        Array(first: self, next: { $0._superclass.flatMap({ $0 != NSObject.self ? ObjCClassInfo($0) : nil }) })
    }
}

extension ObjCClassInfo {
    /**
     Returns information about tthe protocols adopted by the specified class.

     - Parameters:
       - cls: The class for which the protocols are to be obtained.
       - includeSuperclasses: A Boolean value indicating whether to include protocols adopted by the superclasses of `cls`.
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of `cls`.
     - Returns: An array of `ObjCProtocolInfo` objects representing the protocols adopted by the class.
     */
    public static func protocols(of cls: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) -> [ObjCProtocolInfo] {
        var protocols: [ObjCProtocolInfo] = []
        do {
            return try ObjCRuntime.catchException {
                var visited = Set<ObjectIdentifier>()
                var count: UInt32 = 0
                func check(_ proto: Protocol) {
                    guard visited.insert(ObjectIdentifier(proto)).inserted else { return }
                    protocols += ObjCProtocolInfo(proto)
                    guard includeInheritedProtocols else { return }
                    guard let list = protocol_copyProtocolList(proto, &count) else { return }
                    defer { free(UnsafeMutableRawPointer(list)) }
                    for prot in list.buffer(count: count) {
                        check(prot)
                    }
                }
                for cls in classes(for: cls, isInstance: true, includeSuperclasses: includeSuperclasses) {
                    guard let list = class_copyProtocolList(cls, &count) else { continue }
                    defer { free(UnsafeMutableRawPointer(list)) }
                    for proto in list.buffer(count: count) {
                        check(proto)
                    }
                }
                return protocols.sorted(by: \.name)
            }
        } catch {
            return protocols
        }
    }

    /**
     Returns information about the instance variables of the specified class.

     - Parameters:
        - cls: The class for which instance variables are to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include variables for the superclasses of `cls`.
     - Returns: An array of `ObjCIvarInfo` objects representing the instance variables of the class.
     */
    public static func ivars(of cls: AnyClass, includeSuperclasses: Bool = false) -> [ObjCIvarInfo] {
        do {
            return try ObjCRuntime.catchException {
                var ivars: [ObjCIvarInfo] = []
                var seen: Set<String> = ["_?"]
                for cls in classes(for: cls, isInstance: true, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyIvarList(cls, &count) else { continue }
                    defer { free(list) }
                    for ivar in list.buffer(count: count) {
                        guard let name = ivar_getName(ivar)?.string, seen.insert(name).inserted else { continue }
                        ivars += ObjCIvarInfo(ivar)
                    }
                }
                return ivars.sorted(by: \.name)
            }
        } catch {
            return []
        }
    }
    
    /**
     Returns information about the instance properties of the specified class.

     - Parameters:
        - cls: The class for which properties are to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include properties for the superclasses of `cls`.
     - Returns: An array of `ObjCPropertyInfo` objects representing the instance properties of the class.
     */
    public static func properties(of cls: AnyClass, includeSuperclasses: Bool = false) -> [ObjCPropertyInfo] {
        properties(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns information about the class properties of the specified class.

     - Parameters:
        - cls: The class for which properties are to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include properties for the superclasses of `cls`.
     - Returns: An array of `ObjCPropertyInfo` objects representing the class properties of the class.
     */
    public static func classProperties(of cls: AnyClass, includeSuperclasses: Bool = false) -> [ObjCPropertyInfo] {
        properties(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses)
    }
    
    private static func properties(of cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCPropertyInfo] {
        do {
            return try ObjCRuntime.catchException {
                var properties: [ObjCPropertyInfo] = []
                var seen: Set<String> = []
                for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyPropertyList(cls, &count) else { continue }
                    defer { free(list) }
                    for property in list.buffer(count: count) {
                        guard seen.insert(property_getName(property).string).inserted else { continue }
                        properties += ObjCPropertyInfo(property, isClassProperty: !isInstance)
                    }
                }
                return properties.sorted(by: \.name)
            }
        } catch {
            return []
        }
    }
    
    /**
     Returns information about the instance methods of the specified class.

     - Parameters:
        - cls: The class for which methods are to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include methods for the superclasses of `cls`.
     - Returns: An array of `ObjCMethodInfo` objects representing the instance methods of the class.
     */
    public static func methods(of cls: AnyClass, includeSuperclasses: Bool = false) -> [ObjCMethodInfo] {
        methods(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns information about the class methods of the specified class.

     - Parameters:
        - cls: The class for which methods are to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include methods for the superclasses of `cls`.
     - Returns: An array of `ObjCMethodInfo` objects representing the class methods of the class.
     */
    public static func classMethods(of cls: AnyClass, includeSuperclasses: Bool = false) -> [ObjCMethodInfo] {
        methods(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses)
    }
    
    private static func methods(of cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCMethodInfo] {
        do {
            return try ObjCRuntime.catchException {
                var methods: [ObjCMethodInfo] = []
                var seen: Set<Selector> = []
                for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyMethodList(cls, &count) else { continue }
                    defer { free(list) }
                    for method in list.buffer(count: count) {
                        guard seen.insert(method_getName(method)).inserted else { continue }
                        methods += ObjCMethodInfo(method, isClassMethod: !isInstance)
                    }
                }
                return methods.sorted(by: \.name)
            }
        } catch {
            return []
        }
    }
        
    private static func classes(for cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool) -> [AnyClass] {
        var cls: AnyClass = cls
        if !isInstance {
            if ObjCRuntime.classNamesToSkip.contains(NSStringFromClass(cls)) { return [] }
            guard let metaclass = object_getClass(cls) else { return [] }
            cls = metaclass
        }
        guard includeSuperclasses else { return [cls] }
        return Array(first: cls, next: { $0.superclass().flatMap({ $0 != NSObject.self ? $0 : nil }) })
    }
}

extension ObjCClassInfo {
    static var cachedTypeNames: [String: (types: Set<String>, fields: Set<String>)] = [:]
    
    public func typeNames() -> (types: Set<String>, fields: Set<String>) {
        if let cached = Self.cachedTypeNames[name] {
            return cached
        }
        var types: Set<String> = []
        var fields: Set<String> = []
        func addNames(_ names: (types: Set<String>, fields: Set<String>)) {
            types.insert(names.types)
            fields.insert(names.fields)
        }
        
        properties.forEach({ addNames($0.type.names()) })
        classProperties.forEach({ addNames($0.type.names()) })
        // methods.forEach({ addNames($0.typeNames()) })
       // classMethods.forEach({ addNames($0.typeNames()) })
        ivars.forEach({
            if let names = $0.type?.names() {
                addNames(names)
            }
        })
        Self.cachedTypeNames[name] = (types, fields)
        return (types, fields)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// Returns information about the class.
    public static func classInfo() -> ObjCClassInfo {
        ObjCClassInfo(self)
    }
}
