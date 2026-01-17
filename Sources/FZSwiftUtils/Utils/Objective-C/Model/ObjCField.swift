//
//  ObjCField.swift
//
//
//  Created by p-x9 on 2024/06/21
//  
//

import Foundation

/// Represents a field in an Objective-C struct or union.
public struct ObjCField: Sendable, Equatable, Codable {
    
    /// The type of the field.
    public let type: ObjCType
    
    /// The name of the field.
    public var name: String?
    
    /// The bit width of the field.
    public var bitWidth: Int?

    /// Creates a new Objective-C field with the given type, name, and optional bit width.
    public init(type: ObjCType, name: String? = nil, bitWidth: Int? = nil) {
        self.type = type
        self.name = name
        self.bitWidth = bitWidth
    }
    
    /// The type encodibg of the Objective-C struct/union field.
    public func encoded() -> String {
        let name = name.map({ "\"\($0)\"" }) ?? ""
        if let bitWidth {
            return "\(name)b\(bitWidth)"
        } else {
            return "\(name)\(type.encoded())"
        }
    }

    public func decoded(tab: String = "    ") -> String {
        if let bitWidth {
            "\(type.decoded(tab: tab)) \(name ?? "x") : \(bitWidth);"
        } else {
            "\(type.decoded(tab: tab)) \(name ?? "x");"
        }
    }

    func decoded(fallbackName: String, tab: String = "    ") -> String {
        if let bitWidth {
            "\(type.decoded(tab: tab)) \(name ?? fallbackName) : \(bitWidth);"
        } else {
            "\(type.decoded(tab: tab)) \(name ?? fallbackName);"
        }
    }
    
    func decodedForHeader(fallbackName: String, tab: String = "    ") -> String  {
        if [.char, .uchar].contains(type) {
            return "BOOL \(name ?? fallbackName);"
        }
        return decoded(fallbackName: fallbackName, tab: tab)
    }
}

extension [ObjCField] {
    func decoded(tab: String) -> String {
        enumerated().map {
            $1.decoded(fallbackName: "x\($0)", tab: tab).components(separatedBy: .newlines).map { tab + $0 }.joined(separator: "\n")
        }.joined(separator: "\n")
    }
}
