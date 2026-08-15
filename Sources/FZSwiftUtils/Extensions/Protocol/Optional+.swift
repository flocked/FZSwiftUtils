//
//  Optional+.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

import Foundation

public extension Optional {
    /// Unwraps the optional value by throwing.
    func unwrap(_ messageOnFail: String? = nil, line: Int = #line, file: String = #file) throws -> Wrapped {
        try unwrap(or: OptionalError.nilValue(ofType: Wrapped.self, message: messageOnFail, line: line, file: file))
    }
    
    /// Unwraps the optional value by throwing.
    func unwrap(or error: Error) throws -> Wrapped {
        guard let wrapped = self else { throw error }
        return wrapped
    }
    
    /// Unwraps and casts the optional value by throwing.
    func unwrap<T>(as: T.Type = T.self, message: String? = nil, line: Int = #line, file: String = #file) throws -> T {
        guard let value = try unwrap(message, line: line, file: file) as? T else {
            throw OptionalError.castFailed(from: Wrapped.self, to: T.self, message: message, line: line, file: file)
        }
        return value
    }
    
    /// Unwraps and casts the optional value by throwing.
    func unwrap<T>(as: T.Type = T.self, or error: Error) throws -> T {
        guard let wrapped = self, let value = wrapped as? T else { throw error }
        return value
    }
    
    /// Unwraps the optional value or triggers a fatal error.
    func unwrapOrFatalError(message: String? = nil, line: Int = #line, file: String = #file) -> Wrapped {
        guard let wrapped = self else {
            let description = "Optional value of type \(Wrapped.self) is nil."
            fatalError("\(file):\(line) - \(description)" + (message.map { " - \($0)" } ?? ""))
        }
        return wrapped
    }
    
    /// Unwraps the optional value or triggers a fatal error.
    func unwrapOrFatalError(message: String? = nil) -> Wrapped {
        guard let wrapped = self else {
            fatalError("Optional value of type \(Wrapped.self) is nil" + (message.map { ". Debug description: \($0)" } ?? ""))
        }
        return wrapped
    }
    
    /// Unwraps and casts the optional value or triggers a fatal error.
    func unwrapOrFatalError<T>(as: T.Type = T.self, message: String? = nil) -> T {
        guard let value = unwrapOrFatalError(message: message) as? T else {
            fatalError("Optional value of type \(Wrapped.self) couldn't be cast to \(T.self)" + (message.map { ". Debug description: \($0)" } ?? ""))
        }
        return value
    }

    /// Unwraps and casts the optional value or triggers a fatal error.
    func unwrapOrFatalError<T>(as: T.Type = T.self, message: String? = nil, line: Int = #line, file: String = #file) -> T {
        guard let value = unwrapOrFatalError(message: message, line: line, file: file) as? T else {
            let description = "Optional value of type \(Wrapped.self) couldn't be cast to \(T.self)."
            fatalError("\(file):\(line) - \(description)" + (message.map { " - \($0)" } ?? ""))
        }
        return value
    }
    
    /// Error for unwrapping an optional.
    private enum OptionalError: Error, CustomDebugStringConvertible {
        /// The optional value is `nil`.
        case nilValue(ofType: Wrapped.Type, message: String?, line: Int, file: String)
        /// Casting the optional value failed.
        case castFailed(from: Wrapped.Type, to: Any.Type, message: String?, line: Int, file: String)
        
        public var debugDescription: String {
            switch self {
            case .nilValue(let type, let message, let line, let file):
                return "Optional value of type \(type) is nil" + (message.map { ". Debug description: \($0)" } ?? "")
            /*
             let description = "Optional value of type \(type) is nil"
             return "\(file):\(line) - \(description)" + (message.map { ". Debug description: \($0)" } ?? "")
              */
            case .castFailed(let source, let target, let message, let line, let file):
                return "Optional value of type \(source) couldn't be cast to \(target)" + (message.map { ". Debug description: \($0)" } ?? "")
                /*
                 let description = "Optional value of type \(source) couldn't be cast to \(target)"
                 return "\(file):\(line) - \(description)" + (message.map { ". Debug description: \($0)" } ?? "")
                  */
            }
        }
    }
}

/// A type represeting an optional value.
public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    /// The optional value.
    var optional: Wrapped? { get }
    /// The type of the wrapped value.
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalProtocol {
    public var optional: Self {
        self
    }

    public static var wrappedType: Any.Type {
        Wrapped.self
    }
    
    /// A Boolean value indicating whether the optional value is `nil`.
    var isNil: Bool {
        optional == nil
    }
}

public extension Optional where Wrapped: Collection {
    /// A Boolean value indicating whether the optional collection is either empty or `nil`.
    var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}

/*
 extension Optional where Wrapped: MultiplicativeArithmetic {
     public static func * (lhs: Self, rhs: Self) -> Self {
         guard let lhs = lhs.optional else { return rhs }
         guard let rhs = rhs.optional else { return lhs }
         return lhs * rhs
     }
     
     public static func / (lhs: Self, rhs: Self) -> Self {
         guard let lhs = lhs.optional else { return rhs }
         guard let rhs = rhs.optional else { return lhs }
         return lhs / rhs
     }
     
     public static func *= (lhs: inout Self, rhs: Self) {
         lhs = lhs * rhs
     }
     
     public static func /= (lhs: inout Self, rhs: Self) {
         lhs = lhs / rhs
     }
 }

 extension Optional where Wrapped: AdditiveArithmetic {
     public static func + (lhs: Self, rhs: Self) -> Self {
         guard let lhs = lhs.optional else { return rhs }
         guard let rhs = rhs.optional else { return lhs }
         return lhs + rhs
     }
     
     public static func - (lhs: Self, rhs: Self) -> Self {
         guard let lhs = lhs.optional else { return rhs }
         guard let rhs = rhs.optional else { return lhs }
         return lhs - rhs
     }
     
     public static func += (lhs: inout Self, rhs: Self) {
         lhs = lhs + rhs
     }
     
     public static func -= (lhs: inout Self, rhs: Self) {
         lhs = lhs - rhs
     }
 }
 */
