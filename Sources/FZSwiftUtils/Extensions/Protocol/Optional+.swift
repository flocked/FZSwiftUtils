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
        guard case .some(let wrapped) = self else {
            throw OptionalError.nilValue(
                ofType: Wrapped.self,
                message: messageOnFail,
                line: line,
                file: file)
        }
        return wrapped
    }

    /// Unwraps the optional value by throwing a fatal error.
    func unwrapOrFatalError(message: String, line: Int = #line, file: String = #file) -> Wrapped {
        guard case .some(let wrapped) = self else {
            fatalError("\(file):\(line) - \(message)")
        }

        return wrapped
    }

    /// Unwraps and casts the optional value by throwing.
    func unwrapCast<T>(as: T.Type, message: String? = nil, line: Int = #line, file: String = #file) throws -> T {
        let unwrapped = try self.unwrap(message, line: line, file: file)
        guard let unwrapped = (unwrapped as? T) else {
            throw OptionalError.castFailed(type: Wrapped.self, message: message, line: line, file: file)
        }
        return unwrapped
    }

    /// Unwraps and casts the optional value by throwing a fatal error.
    func unwrapCastOrFatalError<T>(as: T.Type, message: String, line: Int = #line, file: String = #file) -> T {
        let unwrapped = self.unwrapOrFatalError(message: message, line: line, file: file)
        return (unwrapped as? T).unwrapOrFatalError(message: message, line: line, file: file)
    }
    
    /// Error for unwrapping an optional.
    enum OptionalError: Error, CustomDebugStringConvertible {
        
        /// The optional value is `nil`.
        case nilValue(ofType: Wrapped.Type, message: String?, line: Int, file: String)
        
        /// Casting the optional value failed.
        case castFailed(type: Wrapped.Type, message: String?, line: Int, file: String)
        
        public var debugDescription: String {
            switch self {
            case .nilValue(let type, let message, _, _):
                guard let message else {
                    return "OptionalError.nilValue of \(type)"
                }
                return  "OptionalError.nilValue of \(type) - \(message)"
            case .castFailed(type: let type, message: let message, _, _):
                guard let message else {
                    return "OptionalError.castFailed of \(type)"
                }
                return  "OptionalError.castFailed of \(type) - \(message)"
            }
        }
    }
}

/// A type represeting an optional value.
public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    /// The optional value.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    /// The optional value.
    public var optional: Self { self }
    
    /// A Boolean value indicating whether the optional value is `nil`.
    var isNil: Bool {
        self.optional == nil
    }
}
