//
//  File.swift
//  
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Self { self }
}
