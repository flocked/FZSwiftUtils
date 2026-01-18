//
//  ObjCMethodSignature.swift
//
//
//  Created by p-x9 on 2024/06/22
//  
//

import Foundation
/// Represents the type information for the return value and parameters of a Objective-C  method.
/// Represents the type information of an Objective-C method, including its return type and arguments.
public struct ObjCMethodSignature: Sendable, Equatable, CustomStringConvertible, Codable {
    /// The arguments of the method.
    public let arguments: [Argument]
        
    /// The total stack size required for the arguments.
    public let stackSize: Int?
        
    /// The type encoding of the return value.
    public let returnType: String
    
    public var decoded: DecodedMethodSignature {
        .init(type: self)
    }
    
    /// The type encoding of the method.
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
        /// The type encoding of the argument value.
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
    
    public struct DecodedMethodSignature {
        let type: ObjCMethodSignature
        
        public var returnType: ObjCType {
            ObjCType(type.returnType) ?? .unknown
        }
        
        public var argumentTypes: [ObjCType] {
            type.arguments.map({ ObjCType($0.type) ?? .unknown })
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
    
    /// Creates a new instance for the specified Objective-C method.
    public init?(_ method: Method) {
        guard let typeEncoding = method_getTypeEncoding(method)?.string else { return nil }
        self.init(typeEncoding)
    }
}


/*
/// Represents the parsed type signature of an Objective-C method, including its return type, parameters, and stack layout information.
public struct ObjCMethodSignatureAlt: Sendable, Equatable, Codable {
    /// The parameters of the method.
    public let arguments: [Argument]
    
    /// The total stack size (in bytes) required to hold all arguments, if known.
    public let stackSize: Int?
    
    /// The Objective-C type encoding of the return value.
    public let returnTypeEncoding: String
    
    
    public var argumentTypes: [ObjCType] {
        arguments.map({$0.type})
    }
    
    public var returnType: ObjCType {
        ObjCType(returnTypeEncoding) ?? .unknown
    }
    
    /// The full Objective-C type encoding of the method, including return type, argument types, and stack offsets.
    public let rawValue: String
    
    /// Represents a parameter of an Objective-C method, including its type and stack offset.
    public struct Argument: Sendable, Equatable, Codable {
        /// The Objective-C type encoding of this parameter.
        public let typeEncoding: String
        
        /// The offset (in bytes) of this parameter on the stack, if known.
        public let offset: Int?
        
        public var type: ObjCType {
            ObjCType(typeEncoding) ?? .unknown
        }
        
        /// The Objective-C type encoding for this parameter, including the optional stack offset.
        public let rawValue: String
        
        init(typeEncoding: String, offset: Int?) {
            self.typeEncoding = typeEncoding
            self.offset = offset
            self.rawValue = typeEncoding + (offset?.string ?? "")
        }
        
        public func encoded() -> String {
            typeEncoding + (offset?.string ?? "")
        }
    }
}

extension ObjCMethodSignatureAlt: RawRepresentable {
    public init(rawValue: String) {
        let type = rawValue
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
            arguments.append(.init(typeEncoding: popType(), offset: popInt()))
        }
        self = .init(arguments: arguments, stackSize: stackSize, returnTypeEncoding: returnType, rawValue: rawValue)
    }
}

extension ObjCMethodSignatureAlt.Argument: RawRepresentable {
    public init(rawValue: String) {
        let mapped = rawValue.readLastDigits()
        self.typeEncoding = mapped.leading
        self.offset = mapped.digits.map({ Int($0)! })
        self.rawValue = rawValue
    }
}

extension String {
    func readLastDigits() -> (leading: String, digits: String?) {
        var index = endIndex
        while index > startIndex {
            let previous = self.index(before: index)
            guard self[previous].isNumber else { break }
            index = previous
        }
        guard index != endIndex else {
            return (leading: self, digits: nil)
        }
        return (String(self[..<index]), String(self[index...]))
    }
}
*/
