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
public struct ObjCClassInfo: Sendable {
    /// The name of the class.
    public let name: String
    /// The version of the class.
    public let version: Int32
    /// The name of the dynamic library the class originated from.
    public let imageName: String?

    /// The size of instances of the class.
    public let instanceSize: Int

    /// The super class of the class.
    public let superClass: AnyClass?
    
    /// The class information of the super class.
    public var superClassInfo: ObjCClassInfo? {
        superClass.map({ ObjCClassInfo($0) })
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
    
    /**
     Initializes a new instance of `ObjCClassInfo`.

     - Parameters:
       - name: Name of the class.
       - version: Version of the class.
       - imageName: Name of the dynamic library the class originated from.
       - instanceSize: Size of instances of the class.
       - superClassName: Superclass name of the class.
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
        imageName: String?,
        instanceSize: Int,
        superClass: AnyClass?,
        protocols: [ObjCProtocolInfo],
        ivars: [ObjCIvarInfo],
        classProperties: [ObjCPropertyInfo],
        properties: [ObjCPropertyInfo],
        classMethods: [ObjCMethodInfo],
        methods: [ObjCMethodInfo]
    ) {
        self.name = name
        self.version = version
        self.imageName = imageName
        self.instanceSize = instanceSize
        self.superClass = superClass
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
    public init(_ class: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) {
        let key = Key(`class`, includeSuperclasses, includeInheritedProtocols)
        if let info = Self.cache[key] {
            self = info
        } else {
            self.init(
                name: NSStringFromClass(`class`),
                version: class_getVersion(`class`),
                imageName: class_getImageName(`class`).flatMap({ String(cString: $0) }),
                instanceSize: class_getInstanceSize(`class`),
                superClass: class_getSuperclass(`class`),
                protocols: Self.protocols(of: `class`, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols),
                ivars: Self.ivars(of: `class`, includeSuperclasses: includeSuperclasses),
                classProperties: Self.properties(of: `class`, isInstance: false, includeSuperclasses: includeSuperclasses),
                properties: Self.properties(of: `class`, isInstance: true, includeSuperclasses: includeSuperclasses),
                classMethods: Self.methods(of: `class`, isInstance: false, includeSuperclasses: includeSuperclasses),
                methods: Self.methods(of: `class`, isInstance: true, includeSuperclasses: includeSuperclasses)
            )
            Self.cache[key] = self
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
    public init?(_ className: String, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) {
        guard let cls = NSClassFromString(className) else { return nil }
        self.init(cls, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols)
    }
    
    private struct Key: Hashable {
        let id: ObjectIdentifier
        let includeSuperclasses: Bool
        let includeInheritedProtocols: Bool
        init(_ cls: AnyClass, _ includeSuperclasses: Bool, _ includeInheritedProtocols: Bool) {
            self.id = ObjectIdentifier(cls)
            self.includeSuperclasses = includeSuperclasses
            self.includeInheritedProtocols = includeInheritedProtocols
        }
    }
    
    private static var cache: SynchronizedDictionary<Key, Self> = [:]
}

extension ObjCClassInfo: CustomStringConvertible, Equatable {
    /// Options for the header string.
    public struct HeaderStringOptions: OptionSet {
        /**
         Properties include attributes that are normally implicit.
                  
         This adds attributes that Objective-C omits by default:
         - `readwrite` for writable properties
         - `atomic` for properties that are not `nonatomic`
         
         For example:
         
         ```objc
         @property(readWrite, atomic) CGSize itemSize;
         ```
         */
        public static let includeImplicitPropertyAttributes = Self(rawValue: 1 << 0)
        
        /**
         Include inline comments for properties implemented using `@dynamic` and/or `@synthesize`.
                  
         For example:

         ```objc
         @property BOOL usesAutomaticRowHeights; // @dynamic usesAutomaticRowHeights
         ```
         */
        public static let includePropertyImplementationComments = Self(rawValue: 1 << 1)
        
        /// Groups methods by library and category and add comments for each.
        public static let groupMethodsByOrigin = Self(rawValue: 1 << 2)
        
        /**
         Includes methods defined in images other than the class's primary image.
         
         This exposes methods implemented in linked frameworks or libraries.
         */
        public static let includeMethodsFromOtherImages = Self(rawValue: 1 << 3)
        
        /// Includes methods declared in Objective-C categories.
        public static let includeCategoryMethods = Self(rawValue: 1 << 4)
        
        /// Includes Objective-C type encodings as comments for methods.
        public static let includeMethodTypeEncodings = Self(rawValue: 1 << 5)
        
        /*
        /// Include instance variables of the class.
        public static let includeIvars = Self(rawValue: 1 << 6)
        /// Include protocols to which the class conforms.
        public static let includeProtocols = Self(rawValue: 1 << 7)
       /// Include class properties of the class.
        public static let includeClassProperties = Self(rawValue: 1 << 8)
        /// Include instance properties of the class.
        public static let includeInstanceProperties = Self(rawValue: 1 << 9)
        /// Include class and instance properties of the class.
        public static let includeProperties: Self = [.includeClassProperties, .includeInstanceProperties]
        /// Include class methods of the class.
        public static let includeClassMethods = Self(rawValue: 1 << 10)
        /// Include instance methods of the class.
        public static let includeInstanceMethods = Self(rawValue: 1 << 11)
        /// Include class and instance methods of the class.
        public static let includeMethods: Self = [.includeClassMethods, .includeInstanceMethods]
        */
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    /// Returns a string representing the class in a Objective-C header.
    public var headerString: String {
        headerString()
    }
    
    /// Returns a string representing the class in a Objective-C header.
    public func headerString(options: HeaderStringOptions = [.groupMethodsByOrigin, .includeMethodsFromOtherImages, .includeCategoryMethods, .includePropertyImplementationComments]) -> String {
        var decl = "@interface \(name)"
        if options.contains(.groupMethodsByOrigin), let imageName = imageName {
            decl = "// Image: \(imageName)\n\n" + decl
        }
        
        if let superClass {
            decl += " : \(NSStringFromClass(superClass))"
        }
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        var lines = [decl]
        if !ivars.isEmpty {
            lines[0] += " {"
            lines += ivars.map { $0.headerString.components(separatedBy: .newlines).map { "    \($0)" }.joined(separator: "\n") }
            lines += "}"
        }
        if !classProperties.isEmpty {
            lines += "" + classProperties.map({$0.headerString(includeDefaultAttributes: options.contains(.includeImplicitPropertyAttributes), includeComments: options.contains(.includePropertyImplementationComments))})
        }
        if !properties.isEmpty {
            lines += "" + properties.map({$0.headerString(includeDefaultAttributes: options.contains(.includeImplicitPropertyAttributes), includeComments: options.contains(.includePropertyImplementationComments))})
        }
        lines += methodHeaderLines(options: options)
        lines += ["", "@end"]
        return lines.joined(separator: "\n")
    }
    
    /**
    Returns an attributed string representing the class in a Objective-C header.
          
     - Parameters:
        - options: The header string options.
        - font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(options: HeaderStringOptions = [], font: NSUIFont? = nil) -> NSAttributedString {
        .objCHeader(for: headerString(options: options), protocols: protocols.map(\.name), font: font)
    }
    
    public var description: String {
        headerString
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.version == rhs.version && lhs.imageName == rhs.imageName && lhs.instanceSize == rhs.instanceSize && lhs.protocols == rhs.protocols && lhs.ivars == rhs.ivars && lhs.classProperties == rhs.classProperties && lhs.properties == rhs.properties && lhs.classMethods == rhs.classMethods && lhs.methods == rhs.methods
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
        properties.first(where: { $0.name == name }) ?? superClassInfo?.property(named: name)
    }
    
    /// Returns the class property with the specified name.
    public func classProperty(named name: String) -> ObjCPropertyInfo? {
        classProperties.first(where: { $0.name == name }) ?? superClassInfo?.classProperty(named: name)
    }
    
    /// Returns the instance property for the specified getter or setter selector.
    public func property(for selector: Selector) -> ObjCPropertyInfo?  {
        properties.first(where: { $0.getter == selector || $0.setter == selector }) ?? superClassInfo?.property(for: selector)
    }
    
    /// Returns the class property for the specified getter or setter selector.
    public func classProperty(for selector: Selector) -> ObjCPropertyInfo?  {
        classProperties.first(where: { $0.getter == selector || $0.setter == selector }) ?? superClassInfo?.classProperty(for: selector)
    }
    
    /// Returns the instance method with the specified name.
    public func method(named name: String) -> ObjCMethodInfo? {
        methods.first(where: { $0.name == name }) ?? superClassInfo?.method(named: name)
    }
    
    /// Returns the class method with the specified name.
    public func classMethod(named name: String) -> ObjCMethodInfo? {
        classMethods.first(where: { $0.name == name }) ?? superClassInfo?.classMethod(named: name)
    }
    
    /// Returns the instance variable with the specified name.
    public func ivar(named name: String) -> ObjCIvarInfo? {
        ivars.first(where: { $0.name == name }) ?? superClassInfo?.ivar(named: name)
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
        allClasses.flatMap({$0.protocols}).uniqued(by: \.name)
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
        Array(first: self, next: { $0.superClass.flatMap({ $0 != NSObject.self ? ObjCClassInfo($0) : nil }) })
    }
}

extension ObjCClassInfo {
    /**
     Returns tthe protocols adopted by the specified class.

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
                func check(_ proto: Protocol) {
                    guard visited.insert(ObjectIdentifier(proto)).inserted else { return }
                    protocols += ObjCProtocolInfo(proto)
                    guard includeInheritedProtocols else { return }
                    var count: UInt32 = 0
                    guard let list = protocol_copyProtocolList(proto, &count) else { return }
                    defer { free(UnsafeMutableRawPointer(list)) }
                    for i in 0..<Int(count) {
                        check(list[i])
                    }
                }
                
                for cls in classes(for: cls, isInstance: true, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyProtocolList(cls, &count) else { continue }
                    defer { free(UnsafeMutableRawPointer(list)) }
                    for i in 0..<Int(count) {
                        check(list[i])
                    }
                }
                return protocols.sorted(by: \.name)
            }
        } catch {
            return protocols
        }
    }

    /**
     Returns the instance or class variables of the specified class.

     - Parameters:
        - cls: The class for which instance variables are to be obtained.
        - isInstance: A Boolean value indicating whether to return instance variables (`true`) or class variables (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include variables for the superclasses of `cls`.
     - Returns: An array of `ObjCIvarInfo` objects representing the instance variables of the class.
     */
    public static func ivars(of cls: AnyClass, isInstance: Bool = true, includeSuperclasses: Bool = false) -> [ObjCIvarInfo] {
        do {
            return try ObjCRuntime.catchException {
                var ivars: [ObjCIvarInfo] = []
                var seen: Set<String> = ["_?"]
                for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyIvarList(cls, &count) else { continue }
                    defer { free(list) }
                    ivars += list.buffer(count: count).compactMap {
                        guard let name = ivar_getName($0)?.string, seen.insert(name).inserted else { return nil }
                        return ObjCIvarInfo($0)
                    }
                }
                return ivars.sorted(by: \.name)
            }
        } catch {
            return []
        }
    }
    
    /**
     Returns the instance or class properties of the specified class.

     - Parameters:
        - cls: The class for which properties are to be obtained.
        - isInstance: A Boolean value indicating whether to return instance properties (`true`) or class properties (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include properties for the superclasses of `cls`.
     - Returns: An array of `ObjCPropertyInfo` objects representing the properties of the class.
     */
    public static func properties(of cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCPropertyInfo] {
        do {
            return try ObjCRuntime.catchException {
                var properties: [ObjCPropertyInfo] = []
                var seen: Set<String> = []
                for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyPropertyList(cls, &count) else { continue }
                    defer { free(list) }
                    properties += list.buffer(count: count).compactMap { seen.insert(property_getName($0).string).inserted ? ObjCPropertyInfo($0, isClassProperty: !isInstance) : nil
                    }
                }
                return properties.sorted(by: \.name)
            }
        } catch {
            return []
        }
    }
    
    /**
     Returns the instance or class methods of the specified class.

     - Parameters:
        - cls: The class for which methods are to be obtained.
        - isInstance: A Boolean value indicating whether to return instance methods (`true`) or class methods (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include methods for the superclasses of `cls`.
     - Returns: An array of `ObjCMethodInfo` objects representing the methods of the class.
     */
    public static func methods(of cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCMethodInfo] {
        do {
            return try ObjCRuntime.catchException {
                var methods: [ObjCMethodInfo] = []
                var seen: Set<Selector> = []
                for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
                    var count: UInt32 = 0
                    guard let list = class_copyMethodList(cls, &count) else { continue }
                    defer { free(list) }
                    methods += list.buffer(count: count).compactMap({
                        seen.insert(method_getName($0)).inserted ? ObjCMethodInfo($0, isClassMethod: !isInstance) : nil })
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
    /**
     Returns information of the class.
     
     - Parameters:
        - includeSuperclasses: A Boolean value indicating whether to include properties, methods, protocols and ivars for the superclasses of the class.
        - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of the class.
     */
    public static func classInfo(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) -> ObjCClassInfo {
        ObjCClassInfo(self, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols)
    }
    
    /**
     Returns tthe protocols adopted by the the class.

     - Parameters:
       - includeSuperclasses: A Boolean value indicating whether to include protocols adopted by the superclasses of the class.
       - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of the class.
     - Returns: An array of `ObjCProtocolInfo` objects representing the protocols adopted by the class.
     */
    public static func protocolInfo(includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) -> [ObjCProtocolInfo] {
        ObjCClassInfo.protocols(of: self, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols)
    }

    /**
     Returns the instance or class variables of the the class.

     - Parameters:
        - isInstance: A Boolean value indicating whether to return instance variables (`true`) or class variables (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include variables for the superclasses of the class.
     - Returns: An array of `ObjCIvarInfo` objects representing the instance variables of the class.
     */
    public static func ivarInfo(isInstance: Bool = true, includeSuperclasses: Bool = false) -> [ObjCIvarInfo] {
        ObjCClassInfo.ivars(of: self, isInstance: isInstance, includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns the instance or class properties of the the class.

     - Parameters:
        - isInstance: A Boolean value indicating whether to return instance properties (`true`) or class properties (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include properties for the superclasses of the class.
     - Returns: An array of `ObjCPropertyInfo` objects representing the properties of the class.
     */
    public static func propertyInfo(isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCPropertyInfo] {
        ObjCClassInfo.properties(of: self, isInstance: isInstance, includeSuperclasses: includeSuperclasses)
    }
    
    /**
     Returns the instance or class methods of the the class.

     - Parameters:
        - isInstance: A Boolean value indicating whether to return instance methods (`true`) or class methods (`false`).
        - includeSuperclasses: A Boolean value indicating whether to include methods for the superclasses of the class.
     - Returns: An array of `ObjCMethodInfo` objects representing the methods of the class.
     */
    public static func methodInfo(isInstance: Bool, includeSuperclasses: Bool = false) -> [ObjCMethodInfo] {
        ObjCClassInfo.methods(of: self, isInstance: isInstance, includeSuperclasses: includeSuperclasses)
    }
}

fileprivate extension ObjCClassInfo {
    func methodHeaderLines(options: HeaderStringOptions) -> [String] {
        var lines: [String] = []
        let includeMethodTypeEncodings = options.contains(.includeMethodTypeEncodings)
        guard options.contains(.groupMethodsByOrigin) || !options.contains(.includeCategoryMethods) || !options.contains(.includeMethodsFromOtherImages), var sections = methodHeaderSections else {
            if !classMethods.isEmpty {
                lines += "" + classMethods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
            }
            if !methods.isEmpty {
                lines += "" + methods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
            }
            return lines
        }
        
        sections = options.contains(.includeMethodsFromOtherImages) ? sections : sections.filter({ $0.imagePath == imageName ?? "" })
        sections = options.contains(.includeCategoryMethods) ? sections : sections.filter({ $0.categoryName.isEmpty })
        
        if !options.contains(.groupMethodsByOrigin) {
            let classMethods = sections.flatMap({$0.classMethods}).sorted(by: \.name)
            if !classMethods.isEmpty {
                lines += "" + classMethods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
            }
            let instanceMethods = sections.flatMap({$0.instanceMethods}).sorted(by: \.name)
            if !instanceMethods.isEmpty {
                lines += "" + instanceMethods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
            }
            return lines
        }
        
        let hasMethodsFromMoreThanOneImage: Bool = {
            guard let firstImagePath = sections.first?.imagePath else { return false }
            return sections.contains { $0.imagePath != firstImagePath }
        }()
        var imagePath: String?
        for (index, section) in sections.enumerated() {
            if index > 0 {
                lines += ""
            }
            if hasMethodsFromMoreThanOneImage, imagePath != section.imagePath {
                imagePath = section.imagePath
                lines += "// Image: \(section.imagePath)"
                lines += ""
            }
            if !section.categoryName.isEmpty {
                lines += "// \(name) (\(section.categoryName))"
                lines += ""
            }
            lines += section.classMethods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
            if !section.classMethods.isEmpty && !section.instanceMethods.isEmpty {
                lines += ""
            }
            lines += section.instanceMethods.map({$0.headerString(includeTypeEncoding: includeMethodTypeEncodings)})
        }
        return !lines.isEmpty ? "" + lines : lines
    }
        
    var methodHeaderSections: [HeaderSection]? {
        if let cached = Self.cachedHeaderSections[name] {
            return cached
        }
        guard let objcClass = ObjCClass(name) else { return nil }
        
        var bucketsByImage: [String: [String: CategoryBucket]] = .init(
            minimumCapacity: classMethods.count + methods.count)
        
        func append(_ method: Method, isClassMethod: Bool) {
            guard let info = ObjCMethodInfo(method, isClassMethod: isClassMethod) else { return }
            let origin = ObjCRuntime.origin(of: method)
            let keyPath: WritableKeyPath<CategoryBucket, [ObjCMethodInfo]> = isClassMethod ? \.classMethods : \.instanceMethods
            bucketsByImage[origin.imagePath ?? "", default: [:]][origin.categoryName ?? "", default: CategoryBucket()][keyPath: keyPath] += info
        }
        for method in objcClass.classMethods() {
            append(method, isClassMethod: true)
        }
        for method in objcClass.methods() {
            append(method, isClassMethod: false)
        }
        
        var sortedImagePaths = bucketsByImage.sorted(by: \.key)
        let imageName = imageName ?? ""
        if let index = sortedImagePaths.firstIndex(where: { $0.key == imageName }) {
            sortedImagePaths.insert(sortedImagePaths.remove(at: index), at: 0)
        }
        let headerSections = sortedImagePaths.flatMap({ element in
            element.value.sorted(by: \.key).map({ $0.value.headerSeaction(imagePath: element.key, categoryName: $0.key) })
        })
        Self.cachedHeaderSections[name] = headerSections
        return headerSections
    }
    
    static var cachedHeaderSections: [String: [HeaderSection]] = [:]
    
    struct CategoryBucket {
        var classMethods: [ObjCMethodInfo] = []
        var instanceMethods: [ObjCMethodInfo] = []
        
        func headerSeaction(imagePath: String, categoryName: String) -> HeaderSection {
            .init(imagePath: imagePath, categoryName: categoryName, classMethods: classMethods, instanceMethods: instanceMethods)
        }
    }
    
    struct HeaderSection {
        let imagePath: String
        let categoryName: String
        let classMethods: [ObjCMethodInfo]
        let instanceMethods: [ObjCMethodInfo]
        
        struct HeaderMethod: Comparable {
            let name: String
            let headerString: String
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.name == rhs.name
            }
            static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.name < rhs.name
            }
        }
    }
}
