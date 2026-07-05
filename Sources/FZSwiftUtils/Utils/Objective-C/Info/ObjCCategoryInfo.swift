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
        headerString()
    }

    /// Returns a string representing the category in an Objective-C header.
    public func headerString(options: HeaderStringOptions = [.addPropertyAttributesComments]) -> String {
        _headerString(options: options).string
    }

    private func _headerString(options: HeaderStringOptions) -> (string: String, declarations: [(line: String, key: NSAttributedString.Key, value: Any)]) {
        let includeFields = options.contains(.includeStructAndUnionFields)
        let includeDefaultAttributes = options.contains(.addImplicitPropertyAttributes)
        let includePropertyComments = options.contains(.addPropertyAttributesComments)
        let includeTypeEncoding = options.contains(.addMethodTypeEncodingComments)
        let renameArguments = options.contains(.renameMethodArguments)
        let includeTypeModifiers = options.contains(.includeTypeModifiers)
        var declarations: [(line: String, key: NSAttributedString.Key, value: Any)] = []

        func propertyLines(_ properties: [ObjCPropertyInfo]) -> [String] {
            properties.map { property in
                let line = property.headerString(
                    includeFields: includeFields,
                    includeTypeModifiers: includeTypeModifiers,
                    includeDefaultAttributes: includeDefaultAttributes,
                    includeComments: includePropertyComments
                )
                declarations.append((line, property.isClassProperty ? .objcClassProperty : .objcProperty, property))
                return line
            }
        }

        func methodLines(_ methods: [ObjCMethodInfo]) -> [String] {
            methods.map { method in
                let line = method.headerString(
                    includeArgumentFields: includeFields,
                    includeTypeModifiers: includeTypeModifiers,
                    includeTypeEncoding: includeTypeEncoding,
                    renameArguments: renameArguments
                )
                declarations.append((line, method.isClassMethod ? .objcClassMethod : .objcMethod, method))
                return line
            }
        }

        var decl = "@interface \(className) (\(name))"
        if !protocols.isEmpty {
            decl += " <\(protocols.map(\.name).joined(separator: ", "))>"
        }

        var lines = [decl]
        if !classProperties.isEmpty {
            lines += "" + propertyLines(classProperties)
        }
        if !properties.isEmpty {
            lines += "" + propertyLines(properties)
        }
        if !classMethods.isEmpty {
            lines += "" + methodLines(classMethods)
        }
        if !methods.isEmpty {
            lines += "" + methodLines(methods)
        }
        lines += ["", "@end"]
        return (lines.joined(separator: "\n"), declarations)
    }
    
    /**
     Returns an attributed string representing the category in a Objective-C header.
     
     - Parameters:
       - options: The header string options.
       - font: The font of the attributed string, or `nil` to use the default font.
     */
    public func attributedHeaderString(options: HeaderStringOptions = [.addPropertyAttributesComments], font: NSUIFont? = nil) -> NSAttributedString {
        let value = _headerString(options: options)
        let attributed = NSMutableAttributedString(
            attributedString: .objCHeader(for: value.string, font: font)
        )
        attributed.addObjCDeclarationAttributes(value.declarations)
        return attributed
    }
    
    public var description: String { headerString }
}
