//
//  Optional.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

/// A type represeting an optional value.
public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    /// The optional value.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    /// The optional value.
    public var optional: Self { self }
    
    /// A Boolean value that indicates whether the optional value is `nil`.
    var isNil: Bool {
        self.optional == nil
    }
}
