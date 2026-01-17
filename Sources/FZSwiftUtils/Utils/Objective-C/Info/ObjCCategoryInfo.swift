//
//  ObjCCategoryInfo.swift
//  ObjCDump
//
//  Created by p-x9 on 2024/12/11
//
//

import Foundation

/// Represents information about an Objective-C category.
public struct ObjCCategoryInfo: Sendable, Equatable, Codable {
    /// Name of the category
    public let name: String

    /// Name of the target class name
    public let className: String

    /// List of protocols to which the class conforms.
    public let protocols: [ObjCProtocolInfo]

    /// List of class properties held by the category.
    public let classProperties: [ObjCPropertyInfo]
    /// List of instance properties held by the category.
    public let properties: [ObjCPropertyInfo]

    /// List of class methods held by the category.
    public let classMethods: [ObjCMethodInfo]
    /// List of instance methods held by the category.
    public let methods: [ObjCMethodInfo]

    /**
     Initializes a new instance of `ObjCCategoryInfo`.

     - Parameters:
       - name: Name of the category.
       - className: Name of the target class.
       - protocols: List of protocols to which the class conforms.
       - classProperties: List of class properties held by the category.
       - properties: List of instance properties held by the category.
       - classMethods: List of class methods held by the category.
       - methods: List of instance methods held by the category.
     */
    public init(
        name: String,
        className: String,
        protocols: [ObjCProtocolInfo],
        classProperties: [ObjCPropertyInfo],
        properties: [ObjCPropertyInfo],
        classMethods: [ObjCMethodInfo],
        methods: [ObjCMethodInfo]
    ) {
        self.name = name
        self.className = className
        self.protocols = protocols
        self.classProperties = classProperties
        self.properties = properties
        self.classMethods = classMethods
        self.methods = methods
    }
}

extension ObjCCategoryInfo: CustomStringConvertible {
    /// Returns a string representing the category in a Objective-C header.
    public var headerString: String {
        var decl = "@interface \(className) (\(name))"
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        var lines = [decl]
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
}
