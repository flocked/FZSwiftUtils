//
//  ObjCType+Modifier.swift
//
//
//  Created by p-x9 on 2024/06/21
//  
//

import Foundation

extension ObjCType {
    /// Represents Objective-C modifiers for method argument or return types.
    public enum Modifier: Character, CaseIterable, Sendable, Equatable, Codable {
        /// Complex type, e.g., struct or union.
        case complex = "j"
        /// Atomic access modifier (rare for methods).
        case atomic = "A"
        /// Constant value.
        case const = "r"
        /// Input parameter.
        case `in` = "n"
        /// Input-output parameter.
        case `inout` = "N"
        /// Output parameter.
        case out = "o"
        /// Passed by copy.
        case bycopy = "O"
        /// Passed by reference.
        case byref = "R"
        /// Asynchronous, no immediate return.
        case oneway = "V"
        /// Suggests storage in a CPU register.
        case register = "+"
        
        /// The type encodibg for the modifier.
        public func encoded() -> String {
            String(rawValue)
        }
        
        public func decoded(tab: String = "    ") -> String {
            switch self {
            case .complex: "_Complex" // #include <complex.h>
            case .atomic: "_Atomic" // #include <stdatomic.h>
            case .const: "const"
            case .in: "in"
            case .inout: "inout"
            case .out: "out"
            case .bycopy: "bycopy"
            case .byref: "byref"
            case .oneway: "oneway"
            case .register: "register" // FIXME: ????
            }
        }
    }
}
