//
//  ObjCMethodType.swift
//
//
//  Created by p-x9 on 2024/06/22
//  
//

import Foundation

/// Represents the type information of an Objective-C method, including its return type and arguments.
public struct ObjCMethodType: Sendable, Equatable, CustomStringConvertible, Codable {
    /// The arguments of the method.
    public let arguments: [Argument]
        
    /// The total stack size required for the arguments.
    public let stackSize: Int?
        
    /// The return type encoding of the method.
    public let returnType: String
    
    /// The type encoding of the method type information.
    public func encoded() -> String {
        "\(returnType)\(stackSize?.string ?? "")\(arguments.map({ $0.encoded() }).joined())"
    }
    
    public var description: String {
        encoded()
    }
    
    init(arguments: [Argument], stackSize: Int?, returnType: String) {
        self.arguments = arguments
        self.stackSize = stackSize
        self.returnType = returnType
    }
        
    /// Represents an argument of an Objective-C method.
    public struct Argument: Sendable, Equatable, CustomStringConvertible, Codable {
        /// The type encoding of the argument.
        public let type: String
            
        /// The offset of the argument in the stack.
        public let offset: Int?
            
        /// The type encoding of the argument.
        public func encoded() -> String {
            type + (offset?.string ?? "")
        }
        
        public var description: String {
            encoded()
        }
    }
}

extension ObjCMethodType {
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
            while i < type.endIndex {
                let c = type[i]
                i = type.index(after: i)
                switch c {
                case "{", "(", "[": // Nested types
                    var depth = 1
                    let close: Character = c == "{" ? "}" : (c == "(" ? ")" : "]")
                    while i < type.endIndex, depth > 0 {
                        if type[i] == c { depth += 1 }
                        else if type[i] == close { depth -= 1 }
                        i = type.index(after: i)
                    }
                case "A", "j", "r", "n", "N", "o", "O", "R", "V", "+":
                    continue // Keep going to catch the base type
                default: break
                }
                break // Found the base type
            }
            return String(type[start..<i])
        }
        
        let returnType = popType()
        let stackSize = popInt()
        var arguments: [Argument] = []
        while i < type.endIndex {
            arguments.append(.init(type: popType(), offset: popInt()))
        }
        self = .init(arguments: arguments, stackSize: stackSize, returnType: returnType)
    }
}

public struct MethodTypeEncoding {
    /// The arguments of the method.
    public let arguments: [Argument]
        
    /// The total stack size required for the arguments.
    public let stackSize: Int?
        
    /// The return type encoding of the method.
    public let returnType: String
    
    /// Represents an argument of an Objective-C method.
    public struct Argument: Sendable, Equatable, CustomStringConvertible {
        /// The type of the argument.
        public let type: String
            
        /// The offset of the argument in the stack.
        public let offset: Int?
            
        /// The type encoding of the argument.
        public func encoded() -> String {
            type + (offset?.string ?? "")
        }
        
        public var description: String {
           return  encoded()
        }
    }
}
