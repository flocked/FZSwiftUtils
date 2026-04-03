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
    /// The name of the category.
    public let name: String

    /// The name of the target class.
    public let className: String
    
    /// The path of the dynamic library the category originated from.
    public let imagePath: String?

    /// The protocols to which the category conforms.
    public let protocols: [ObjCProtocolInfo]

    /// The class properties held by the category.
    public let classProperties: [ObjCPropertyInfo]
    /// The instance properties held by the category.
    public let properties: [ObjCPropertyInfo]

    /// The class methods held by the category.
    public let classMethods: [ObjCMethodInfo]
    /// The instance methods held by the category.
    public let methods: [ObjCMethodInfo]

    /**
     Initializes a new instance of `ObjCCategoryInfo`.

     - Parameters:
        - name: The name of the category.
        - className: The name of the target class.
        - imagePath: The path of the dynamic library the category originated from.
        - protocols: The protocols to which the category conforms.
        - classProperties: The class properties held by the category.
        - properties: The instance properties held by the category.
        - classMethods: The class methods held by the category.
        - methods: The instance methods held by the category.
     */
    public init(
        name: String,
        className: String,
        imagePath: String?,
        protocols: [ObjCProtocolInfo],
        classProperties: [ObjCPropertyInfo],
        properties: [ObjCPropertyInfo],
        classMethods: [ObjCMethodInfo],
        methods: [ObjCMethodInfo]
    ) {
        self.name = name
        self.className = className
        self.imagePath = imagePath
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
    
    /**
     Returns an attributed string representing the category in a Objective-C header.
     
     - Parameter font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(font: NSUIFont? = nil) -> NSAttributedString {
        .objCHeader(for: headerString, protocols: protocols.map({$0.name}), font: font)
    }
    
    public var description: String { headerString }
}
