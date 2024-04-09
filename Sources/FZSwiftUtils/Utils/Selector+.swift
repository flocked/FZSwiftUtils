//
//  File.swift
//  
//
//  Created by Florian Zand on 09.04.24.
//

import Foundation

extension Selector: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Selector(try container.decode(String.self))
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(NSStringFromSelector(self))
    }
}
