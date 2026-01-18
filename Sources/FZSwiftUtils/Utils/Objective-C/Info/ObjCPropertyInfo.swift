//
//  ObjCPropertyInfo.swift
//
//
//  Created by p-x9 on 2024/06/24
//  
//

import Foundation

/// Represents information about an Objective-C property.
public struct ObjCPropertyInfo: Sendable, Equatable, Codable {
    /// Name of the property
    public let name: String
    
    /// Attribute list of the property
    public let attributes: [Attribute]
    
    /// A Boolean value that indicates whatever the property is class property or not.
    public let isClassProperty: Bool
        
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
    public init?(_ property: objc_property_t, isClassProperty: Bool) {
        guard let attributes = Self.attributes(for: property) else { return nil }
        self.init(
            name: String(cString: property_getName(property)),
            attributes: attributes,
            isClassProperty: isClassProperty
        )
    }
}

public extension ObjCPropertyInfo {
    /// The Objective-C type of the property.
    var type: ObjCType {
        attributes.lazy.compactMap(\.type).first ?? .unknown
    }

    /// The name of the backing instance variable for the property.
    var ivarName: String? {
        attributes.lazy.compactMap(\.ivarName).first
    }

    /// The custom getter name of the property.
    var getterName: String? {
        attributes.lazy.compactMap(\.getterName).first
    }

    /// The custom setter name of the property.
    var setterName: String? {
        attributes.lazy.compactMap(\.setterName).first
    }

    /// The getter selector for the property.
    var getter: Selector {
        .string(getterName ?? name)
    }

    /// The setter selector for the property.
    var setter: Selector? {
        guard !isReadOnly else { return nil }
        if let setterName { return .string(setterName) }
        return .string("set\(name.uppercasedFirst()):")
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
        let typeString = type.decodedStringForArgument

        var _attributes: [String] = []
        if isClassProperty {
            _attributes.append("class")
        }
        if let getterName = getterName {
            _attributes.append("getter=\(getterName)")
        }
        if let setterName = setterName {
            _attributes.append("setter=\(setterName)")
        }
        if isReadOnly {
            _attributes.append("readonly")
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
        for comment in comments {
            result += " // \(comment)"
        }
        return result
    }
    
    public var description: String { headerString }
}
