//
//  ObjCPropertyInfo.swift
//
//
//  Created by p-x9 on 2024/06/24
//  
//

import Foundation

/// Represents information about an Objective-C property.
public struct ObjCPropertyInfo: Sendable, Equatable, Codable, Hashable {
    /// The name of the property.
    public let name: String
    
    /// The attributes of the property.
    public let attributes: [Attribute]
    
    /// A Boolean value indicating whatever the property is a class property.
    public let isClassProperty: Bool
    
    /*
    var className: String?
    
    var origin: (imagePath: String?, categoryName: String?, symbolName: String?) {
        guard let clsName = className, let objcClass = ObjCClass(clsName), let property = objcClass.property(named: name, isClass: isClassProperty) else { return (nil, nil, nil ) }
        return objcClass.origin(for: property, isClassProperty: isClassProperty)
    }
     */
    
   // public var getterMethod: ObjCMethodInfo
        
    /**
     Initializes a new instance of `ObjCPropertyInfo`.

     - Parameters:
       - name: Name of the property.
       - attributes: Attributes string of the property.
       - isClassProperty: A Boolean value that indicates whether the property is a class property.
     */
    public init(name: String, attributes: [Attribute], isClassProperty: Bool) {
        self.name = name
        self.attributes = attributes
        self.isClassProperty = isClassProperty
    }

    /**
     Initializes a new instance of `ObjCPropertyInfo` for the specified property.

     - Parameters:
       - property: The property of the target for which information is to be obtained.
       - isClassProperty: A Boolean value that indicates whether the property is a class property.
     */
    public init?(_ property: objc_property_t, isClassProperty: Bool = false) {
        if let cache = Self.cache[property] {
            self.init(name: cache.name, attributes: cache.attributes, isClassProperty: isClassProperty)
        } else {
            guard let attributes = Self.attributes(for: property) else { return nil }
            self.init(
                name: property_getName(property).string,
                attributes: attributes,
                isClassProperty: isClassProperty
            )
            Self.cache[property] = (name, attributes)
        }
    }
    
    private static var cache: [objc_property_t: (name: String, attributes: [Attribute])] = [:]
}

public extension ObjCPropertyInfo {
    /// The Objective-C type of the property.
    var type: ObjCType {
        attributes.lazy.compactMap(\.type).first ?? .unknown
    }
    
    /// The size of the property.
    var size: Int? {
        attributes.lazy.compactMap(\.size).first
    }

    /// The name of the backing instance variable for the property.
    var ivarName: String? {
        attributes.lazy.compactMap(\.ivarName).first
    }

    /// The getter name of the property.
    var getterName: String {
        customGetterName ?? name
    }
    
    /// The getter selector for the property.
    var getter: Selector {
        .string(getterName)
    }
    
    /// The setter name of the property.
    var setterName: String? {
        guard !isReadOnly else { return nil }
        return customSetterName ?? "set\(name.uppercasedFirst()):"
    }
    
    /// The setter selector for the property.
    var setter: Selector? {
        setterName.map({ .string($0) })
    }
    
    private var customGetterName: String? {
        attributes.lazy.compactMap(\.getterName).first
    }
    
    private var customSetterName: String? {
        attributes.lazy.compactMap(\.setterName).first
    }

    // MARK: - Access Semantics

    /// A Boolean value indicating whether the property is declared as `dynamic`.
    var isDynamic: Bool {
        attributes.contains(.dynamic)
    }

    /// A Boolean value indicating whether the property is read-only.
    var isReadOnly: Bool {
        attributes.contains(.readonly)
    }

    /// A Boolean value indicating whether the property is nonatomic.
    var isNonatomic: Bool {
        attributes.contains(.nonatomic)
    }

    // MARK: - Memory Semantics

    /// A Boolean value indicating whether the property holds a weak reference.
    var isWeak: Bool {
        attributes.contains(.weak)
    }

    /// A Boolean value indicating whether the property uses copy semantics.
    var usesCopySemantics: Bool {
        attributes.contains(.copy)
    }

    /// A Boolean value indicating whether the property is retained.
    var isRetained: Bool {
        attributes.contains(.retain)
    }
}

extension ObjCPropertyInfo: CustomStringConvertible {
    /// Returns a string representing the property in a Objective-C header.
    public var headerString: String {
        headerString(includeDefaultAttributes: false)
    }
    
    /**
     Returns a string representing the property in a Objective-C header.
     
     - Parameter includeDefaultAttributes: A Boolean value indicating whether to include attributes that are normally implicit:  Writable properties include `readwrite` and properties that are not `nonatomic` include `atomic`.
     */
    public func headerString(includeFields: Bool = false, includeDefaultAttributes: Bool, includeComments: Bool = true) -> String {
        let typeString = type.decodedStringForArgument(includeFields: includeFields)

        var _attributes: [String] = []
        if isClassProperty {
            _attributes.append("class")
        }
        if let getterName = customGetterName {
            _attributes.append("getter=\(getterName)")
        }
        if let setterName = customSetterName {
            _attributes.append("setter=\(setterName)")
        }
        if isReadOnly {
            _attributes.append("readonly")
        } else if includeDefaultAttributes {
            _attributes.append("readwrite")
        }
        if isWeak {
            _attributes.append("weak")
        }
        if usesCopySemantics {
            _attributes.append("copy")
        }
        if isRetained {
            _attributes.append("retain")
        }
        if isNonatomic {
            _attributes.append("nonatomic")
        } else if includeDefaultAttributes {
            _attributes.append("atomic")
        }

        var comments: [String] = []
        if isDynamic {
            comments.append("@dynamic \(name)")
        }
        if let ivarName = ivarName {
            if ivarName == name {
                comments.append("@synthesize \(ivarName)")
            } else {
                comments.append("@synthesize \(name)=\(ivarName)")
            }
        }
        var result = "@property"
        if !_attributes.isEmpty {
            result += "(" + _attributes.joined(separator: ", ") + ")"
        }
        result += " \(typeString)"
        if typeString.last == "*" {
            result += "\(name);"
        } else {
            result += " \(name);"
        }
        if includeComments {
            for comment in comments {
                result += " // \(comment)"
            }
        }
        return result
    }
    
    var methodNames: [String] {
        guard let setterName = setterName else { return [getterName] }
        return [getterName, setterName]
    }
    
    public var description: String { headerString }
}
