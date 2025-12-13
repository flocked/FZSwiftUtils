//
//  Selector+.swift
//
//
//  Created by Florian Zand on 09.04.24.
//

import Foundation

extension Selector: Swift.Encodable, Swift.Decodable {
    public init(from decoder: any Decoder) throws {
        self = .string(try decoder.singleValueContainer().decode())
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
    
    /// `String` representation of the selector.
    public var string: String {
        NSStringFromSelector(self)
    }
    
    /// Returns a selector with the specified name.
    public static func string(_ name: String) -> Selector {
        NSSelectorFromString(name)
    }
}
