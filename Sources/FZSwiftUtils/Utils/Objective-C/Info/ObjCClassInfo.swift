//
//  ObjCClassInfo.swift
//
//
//  Created by p-x9 on 2024/06/24
//  
//

import Foundation

/// Represents information about an Objective-C class.
public struct ObjCClassInfo: Sendable {
    /// Name of the class
    public let name: String
    /// Version of the class
    public let version: Int32
    /// Name of the dynamic library the class originated from.
    public let imageName: String?

    /// Size of instances of the class.
    public let instanceSize: Int

    /// Super class of the class.
    public let superClass: AnyClass?
    
    public var superClassInfo: ObjCClassInfo? {
        superClass.map({ ObjCClassInfo($0) })
    }

    /// List of protocols to which the class conforms.
    public let protocols: [ObjCProtocolInfo]

    /// List of instance variables held by the class.
    public let ivars: [ObjCIvarInfo]

    /// List of class properties held by the class.
    public let classProperties: [ObjCPropertyInfo]
    /// List of instance properties held by the class.
    public let properties: [ObjCPropertyInfo]

    /// List of class methods held by the class.
    public let classMethods: [ObjCMethodInfo]
    /// List of instance methods held by the class.
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
        - cls: The class of the target for which information is to be obtained.
        - includeSuperclasses: A Boolean value indicating whether to include properties, methods, protocols and ivars for the superclasses of `cls`.
        - includeInheritedProtocols: A Boolean value indicating whether to include protocols adopted by the protocols of `cls`.
     */
    public init(_ cls: AnyClass, includeSuperclasses: Bool = false, includeInheritedProtocols: Bool = false) {
        self.init(
            name: NSStringFromClass(cls),
            version: class_getVersion(cls),
            imageName: class_getImageName(cls).flatMap({ String(cString: $0) }),
            instanceSize: class_getInstanceSize(cls),
            superClass: class_getSuperclass(cls),
            protocols: Self.protocols(of: cls, includeSuperclasses: includeSuperclasses, includeInheritedProtocols: includeInheritedProtocols),
            ivars: Self.ivars(of: cls),
            classProperties: Self.properties(of: cls, isInstance: false, includeSuperclasses: includeSuperclasses),
            properties: Self.properties(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses),
            classMethods: Self.methods(of: cls, isInstance: false, includeSuperclasses: includeSuperclasses),
            methods: Self.methods(of: cls, isInstance: true, includeSuperclasses: includeSuperclasses)
        )
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
}

extension ObjCClassInfo: CustomStringConvertible, Equatable {
    /// Returns a string representing the class in a Objective-C header.
    public var headerString: String {
        var decl = "@interface \(name)"
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
            lines += "" + classProperties.map(\.headerString)
        }
        if !properties.isEmpty {
            lines += "" + properties.map(\.headerString)
        }
        if !classMethods.isEmpty {
            lines += "" + classMethods.map(\.headerString)
        }
        if !methods.isEmpty {
            lines += "" + methods.map(\.headerString)
        }
        lines += ["", "@end"]
        return lines.joined(separator: "\n")
    }
    
    public var description: String { headerString }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.version == rhs.version && lhs.imageName == rhs.imageName && lhs.instanceSize == rhs.instanceSize && lhs.protocols == rhs.protocols && lhs.ivars == rhs.ivars && lhs.classProperties == rhs.classProperties && lhs.properties == rhs.properties && lhs.classMethods == rhs.classMethods && lhs.methods == rhs.methods
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
        var visited = Set<ObjectIdentifier>()
        var protocols: [ObjCProtocolInfo] = []

        func check(_ proto: Protocol) {
            guard visited.insert(ObjectIdentifier(proto)).inserted else { return }
            protocols += ObjCProtocolInfo(proto)
            guard includeInheritedProtocols else { return }
            var count: UInt32 = 0
            guard let list = protocol_copyProtocolList(proto, &count) else { return }
            for i in 0..<Int(count) {
                check(list[i])
            }
        }
        
        for cls in classes(for: cls, isInstance: true, includeSuperclasses: includeSuperclasses) {
            var count: UInt32 = 0
            guard let list = class_copyProtocolList(cls, &count) else { continue }
            for i in 0..<Int(count) {
                check(list[i])
            }
        }
        return protocols
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
        var ivars: [ObjCIvarInfo] = []
        var seen: Set<String> = []
        for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
            var count: UInt32 = 0
            guard let start = class_copyIvarList(cls, &count) else { continue }
            defer { free(start) }
            ivars += UnsafeBufferPointer(start: start, count: Int(count)).compactMap {
                if let name = ivar_getName($0)?.string, seen.insert(name).inserted { return ObjCIvarInfo($0) } else { return nil } }
        }
        return ivars
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
        var properties: [ObjCPropertyInfo] = []
        var seen: Set<String> = []
        for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
            var count: UInt32 = 0
            guard let start = class_copyPropertyList(cls, &count) else { continue }
            defer { free(start) }
            properties += UnsafeBufferPointer(start: start, count: Int(count))
                .compactMap { seen.insert(property_getName($0).string).inserted ? ObjCPropertyInfo($0, isClassProperty: !isInstance) : nil }
        }
        return properties
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
        var methods: [ObjCMethodInfo] = []
        var seen: Set<Selector> = []
        for cls in classes(for: cls, isInstance: isInstance, includeSuperclasses: includeSuperclasses) {
            var count: UInt32 = 0
            guard let start = class_copyMethodList(cls, &count) else { continue }
            defer { free(start) }
            methods += UnsafeBufferPointer(start: start, count: Int(count)).compactMap({
                seen.insert(method_getName($0)).inserted ? ObjCMethodInfo($0, isClassMethod: !isInstance) : nil })
        }
        return methods
    }
    
    private static let skipClasses: Set<String> = ["__NSGenericDeallocHandler", "__NSAtom", "_NSZombie_", "__NSMessageBuilder", "CKSQLiteUnsetPropertySentinel", "JSExport"]
    
    private static func classes(for cls: AnyClass, isInstance: Bool, includeSuperclasses: Bool) -> [AnyClass] {
        var cls: AnyClass = cls
        if !isInstance {
            if skipClasses.contains(NSStringFromClass(cls)) { return [] }
            guard let metaclass = object_getClass(cls) else { return [] }
            cls = metaclass
        }
        var classes = [cls]
        if includeSuperclasses {
            classes += Array(first: cls.superclass(), next: {  $0?.superclass().map({ $0 != NSObject.self ? $0 : nil }) }).nonNil
        }
        return classes
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

/*
extension ObjCClassInfo {
    public func property(named name: String) -> ObjCPropertyInfo? {
        property(where: { $0.name == name })
    }
    
    public func property(for selector: Selector) -> ObjCPropertyInfo?  {
       property(where: { $0.getter == selector || $0.setter == selector })
    }
    
    public func property(where predicate: (ObjCPropertyInfo) throws -> Bool) rethrows -> ObjCPropertyInfo? {
        try properties.first(where: predicate) ?? superClassInfo?.property(where: predicate)
    }
    
    public func method(named name: String) -> ObjCMethodInfo? {
        method(where: { $0.name == name })
    }
    
    public func method(for selector: Selector) -> ObjCMethodInfo? {
        method(named: selector.string)
    }
    
    public func method(where predicate: (ObjCMethodInfo) throws -> Bool) rethrows -> ObjCMethodInfo? {
        try methods.first(where: predicate) ?? superClassInfo?.method(where: predicate)
    }
}
*/
