//
//  ObjCProtocolInfo.swift
//
//
//  Created by p-x9 on 2024/06/26
//  
//

import Foundation

/// Represents information about an Objective-C protocol.
public struct ObjCProtocolInfo: Sendable, Equatable, Codable {
    /// Name of the protocol
    public let name: String

    /// List of protocols to which the protocol conforms.
    public let protocols: [ObjCProtocolInfo]

    /// List of required class properties.
    public let classProperties: [ObjCPropertyInfo]
    /// List of required instance properties.
    public let properties: [ObjCPropertyInfo]
    /// List of required class methods.
    public let classMethods: [ObjCMethodInfo]
    /// List of required instance methods.
    public let methods: [ObjCMethodInfo]

    /// List of optional class properties.
    public let optionalClassProperties: [ObjCPropertyInfo]
    /// List of optional instance properties.
    public let optionalProperties: [ObjCPropertyInfo]
    /// List of optional class methods.
    public let optionalClassMethods: [ObjCMethodInfo]
    /// List of optional instance methods.
    public let optionalMethods: [ObjCMethodInfo]
    
    /**
     Initializes a new instance of `ObjCProtocolInfo`.

     - Parameters:
       - name: Name of the protocol.
       - protocols: List of protocols to which the protocol conforms.
       - classProperties: List of required class properties.
       - properties: List of required instance properties.
       - classMethods: List of required class methods.
       - methods: List of required instance methods.
       - optionalClassProperties: List of optional class properties.
       - optionalProperties: List of optional instance properties.
       - optionalClassMethods: List of optional class methods.
       - optionalMethods: List of optional instance methods.
     */
    public init(
        name: String,
        protocols: [ObjCProtocolInfo],
        classProperties: [ObjCPropertyInfo],
        properties: [ObjCPropertyInfo],
        classMethods: [ObjCMethodInfo],
        methods: [ObjCMethodInfo],
        optionalClassProperties: [ObjCPropertyInfo] = [],
        optionalProperties: [ObjCPropertyInfo] = [],
        optionalClassMethods: [ObjCMethodInfo],
        optionalMethods: [ObjCMethodInfo]
    ) {
        self.name = name
        self.protocols = protocols
        self.classProperties = classProperties
        self.properties = properties
        self.classMethods = classMethods
        self.methods = methods
        self.optionalClassProperties = optionalClassProperties
        self.optionalProperties = optionalProperties
        self.optionalClassMethods = optionalClassMethods
        self.optionalMethods = optionalMethods
    }

    /**
     Initializes a new instance of `ObjCProtocolInfo` for the specified protocol.

     - Parameter protocol: The protocol of the target for which information is to be obtained.
     */
    public init(_ `protocol`: Protocol) {
        self.init(
            name: String(cString: protocol_getName(`protocol`)),
            protocols: Self.protocols(of: `protocol`),
            classProperties: Self.properties(of: `protocol`, isRequired: true, isInstance: false),
            properties:  Self.properties(of: `protocol`, isRequired: true, isInstance: true),
            classMethods: Self.methods(of: `protocol`, isRequired: true, isInstance: false),
            methods: Self.methods(of: `protocol`, isRequired: true, isInstance: true),
            optionalClassProperties: Self.properties(of: `protocol`, isRequired: false, isInstance: false),
            optionalProperties:  Self.properties(of: `protocol`, isRequired: false, isInstance: true),
            optionalClassMethods: Self.methods(of: `protocol`, isRequired: false, isInstance: false),
            optionalMethods: Self.methods(of: `protocol`, isRequired: false, isInstance: true)
        )
    }
    
    /**
     Initializes a new instance of `ObjCProtocolInfo` for the protocol with the specified name.

     - Parameter `protocolName`: The protocol name of the target for which information is to be obtained.
     - Returns: The protocol info, or `nil` if there isn't a protocol with the specified name.
     */
    public init?(_ protocolName: String) {
        guard let proto = NSProtocolFromString(protocolName) else { return nil }
        self.init(proto)
    }
}

extension ObjCProtocolInfo: CustomStringConvertible {
    /// Returns a string representing the protocol in a Objective-C header.
    public var headerString: String {
        var decl = "@protocol \(name)"
        if !protocols.isEmpty {
            let protocols = protocols.map(\.name)
                .joined(separator: ", ")
            decl += " <\(protocols)>"
        }

        var lines = [decl]

        if !classProperties.isEmpty ||
            !properties.isEmpty ||
            !classMethods.isEmpty ||
            !methods.isEmpty {
            lines += ["", "@required"]
        }

        if !classProperties.isEmpty {
            lines.append("")
            lines += classProperties.map(\.headerString)
        }
        if !properties.isEmpty {
            lines.append("")
            lines += properties.map(\.headerString)
        }

        if !classMethods.isEmpty {
            lines.append("")
            lines += classMethods.map(\.headerString)
        }
        if !methods.isEmpty {
            lines.append("")
            lines += methods.map(\.headerString)
        }

        if !optionalClassProperties.isEmpty ||
            !optionalProperties.isEmpty ||
            !optionalClassMethods.isEmpty ||
            !optionalMethods.isEmpty {
            lines += ["", "@optional"]
        }

        if !optionalClassProperties.isEmpty {
            lines.append("")
            lines += optionalClassProperties.map(\.headerString)
        }
        if !optionalProperties.isEmpty {
            lines.append("")
            lines += optionalProperties.map(\.headerString)
        }
        if !optionalClassMethods.isEmpty {
            lines.append("")
            lines += optionalClassMethods.map(\.headerString)
        }
        if !optionalMethods.isEmpty {
            lines.append("")
            lines += optionalMethods.map(\.headerString)
        }
        lines += ["", "@end"]
        return lines.joined(separator: "\n")
    }
    public var description: String { headerString }
}

extension ObjCProtocolInfo {
    /**
     Returns the protocols adopted by the specified protocol.

     - Parameter protocol: The protocol for which the adopted protocols are to be obtained.
     - Returns: An array of `ObjCProtocolInfo` objects representing the adopted protocols.
     */
    public static func protocols(of `protocol`: Protocol) -> [ObjCProtocolInfo] {
        var count: UInt32 = 0
        guard let start = protocol_copyProtocolList(`protocol`, &count) else { return [] }
        defer { free(.init(start)) }
        return UnsafeBufferPointer(start: start, count: Int(count)).map { ObjCProtocolInfo($0) }
    }

    /**
     Returns the properties declared by the specified protocol.

     - Parameters:
       - protocol: The protocol for which the properties are to be obtained.
       - isRequired: A Boolean value indicating whether to include only required properties (`true`) or optional properties (`false`).
       - isInstance: A Boolean value indicating whether to include instance properties (`true`) or class properties (`false`).
     - Returns: An array of `ObjCPropertyInfo` objects representing the properties of the protocol.
     */
    public static func properties(of `protocol`: Protocol, isRequired: Bool, isInstance: Bool) -> [ObjCPropertyInfo] {
        var count: UInt32 = 0
        guard let start = protocol_copyPropertyList2(`protocol`, &count, isRequired, isInstance) else { return [] }
        defer { free(start) }
        return UnsafeBufferPointer(start: start, count: Int(count)).compactMap { ObjCPropertyInfo($0, isClassProperty: !isInstance) }
    }

    /**
     Returns the methods declared by the specified protocol.

     - Parameters:
       - protocol: The protocol for which the methods are to be obtained.
       - isRequired: A Boolean value indicating whether to include only required methods (`true`) or optional methods (`false`).
       - isInstance: A Boolean value indicating whether to include instance methods (`true`) or class methods (`false`).
     - Returns: An array of `ObjCMethodInfo` objects representing the methods of the protocol.
     */
    public static func methods(of `protocol`: Protocol, isRequired: Bool, isInstance: Bool) -> [ObjCMethodInfo] {
        var count: UInt32 = 0
        guard let start = protocol_copyMethodDescriptionList(`protocol`, isRequired, isInstance, &count) else { return [] }
        defer { free(start) }
       return UnsafeBufferPointer(start: start, count: Int(count)).compactMap { ObjCMethodInfo($0, isClassMethod: !isInstance) }
    }
}
