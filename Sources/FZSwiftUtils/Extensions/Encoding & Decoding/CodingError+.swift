//
//  CodingError+.swift
//  
//
//  Created by Florian Zand on 11.01.26.
//

import Foundation

extension DecodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    public init(_ debugDescription: String) {
        self.init(codingPath: [], debugDescription: debugDescription)
    }
}

extension EncodingError.Context: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(codingPath: [], debugDescription: value)
    }
    
    public init(_ debugDescription: String) {
        self.init(codingPath: [], debugDescription: debugDescription)
    }
}
