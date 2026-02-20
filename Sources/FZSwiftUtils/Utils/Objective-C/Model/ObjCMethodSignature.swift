//
//  ObjCMethodSignature.swift
//
//
//  Created by p-x9 on 2024/06/22
//  
//

import Foundation

/// Represents the type information for the return value and parameters of an Objective-C  method.
public struct ObjCMethodSignature: Sendable, Equatable, CustomStringConvertible, Codable {
    /// The arguments of the method.
    public let arguments: [MethodValue]
        
    /// The total stack size required for the arguments.
    public let stackSize: Int?
    
    /// The return value of the method.
    public let returnValue: MethodValue
    
    /// The type encoding of the method.
    public func encoded() -> String {
        "\(returnValue.typeEncoding)\(stackSize?.string ?? "")\(arguments.map({ $0.encoded() }).joined())"
    }
    
    public var description: String {
        encoded()
    }
    
    /// Represents a value of an Objective-C method.
    public struct MethodValue: Sendable, Equatable, CustomStringConvertible, Codable {
        /// The type encoding of the value.
        public let typeEncoding: String
        
        /// The offset of the value in the stack.
        public let offset: Int?
        
        /// The type of the value.
        public var type: ObjCType {
            ObjCType(typeEncoding) ?? .unknown
        }
        
        /// The size of the value.
        public var size: Int? {
            ObjCRuntime.sizeAndAlignment(for: typeEncoding)?.size
        }
            
        /// The type encoding of the value.
        public func encoded() -> String {
            typeEncoding + offset?.string
        }
        
        public var description: String {
            encoded()
        }
    }
}

extension ObjCMethodSignature {
    /// Creates a new instance by parsing the specified Objective-C method type encoding.
    public init(_ typeEncoding: String) {
        let type = typeEncoding
        var i = type.startIndex
        
        func popInt() -> Int? {
            let start = i
            while i < type.endIndex, type[i].isNumber { i = type.index(after: i) }
            return start == i ? nil : Int(type[start..<i])
        }
        
        func popType() -> String {
            let start = i
            parseOne()
            return String(type[start..<i])
            
            func parseOne() {
                guard i < type.endIndex else { return }
                let c = type[i]
                i = type.index(after: i)
                switch c {
                case "r", "n", "N", "o", "O", "R", "V", "+", "A", "j":  // Qualifiers (prefix, repeatable) "A", "j",
                    parseOne()
                case "^": // Pointer: recursively parse the pointee
                    parseOne()
                case "@": // Block/object
                    guard i < type.endIndex else { return }
                    if type[i] == "?" {
                        i = type.index(after: i)
                        if i < type.endIndex, type[i] == "<" {
                            i = type.index(after: i)
                            parseBracket("<", ">")
                        }
                    } else if type[i] == "\"" {
                        i = type.index(after: i)
                        while i < type.endIndex, type[i] != "\"" {
                            i = type.index(after: i)
                        }
                        if i < type.endIndex {
                            i = type.index(after: i)
                        }
                    }
                case "b": // Bitfield
                    while i < type.endIndex, type[i].isNumber {
                        i = type.index(after: i)
                    }
                case "!":
                    while i < type.endIndex, type[i].isNumber {
                        i = type.index(after: i)
                    }
                    parseOne()
                case "{", "(", "[": // Aggregates
                    parseBracket(c, (c == "{") ? "}" : (c == "(" ? ")" : "]"))
                default: // All scalar / object / selector types
                    break
                }
            }
            
            func parseBracket(_ open: Character, _ close: Character) {
                var depth = 1
                while i < type.endIndex, depth > 0 {
                    let ch = type[i]
                    i = type.index(after: i)
                    if ch == open { depth += 1 }
                    else if ch == close { depth -= 1 }
                }
            }
        }
        
        let returnType = popType()
        let stackSize = popInt()
        var arguments: [MethodValue] = []
        while i < type.endIndex {
            arguments.append(.init(typeEncoding: popType(), offset: popInt()))
        }
        self = .init(arguments: arguments, stackSize: stackSize, returnValue: .init(typeEncoding: returnType, offset: nil))
    }
    
    /// Creates a new instance for the specified Objective-C method.
    public init?(_ method: Method) {
        guard let typeEncoding = method_getTypeEncoding(method)?.string else { return nil }
        self.init(typeEncoding)
    }
}
