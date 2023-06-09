//
//  Optinal.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

/// A protocol represeting an iotional value.
public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    /// The optional value.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    /// The optional value.
    public var optional: Self { self }
}
