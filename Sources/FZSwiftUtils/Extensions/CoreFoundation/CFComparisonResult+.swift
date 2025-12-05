//
//  CFComparisonResult+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

extension CFComparisonResult: Swift.ExpressibleByBooleanLiteral {
    /// Returns the reversed result.
    public func reversed() -> CFComparisonResult {
        switch self {
        case .compareLessThan: return .compareGreaterThan
        case .compareGreaterThan: return .compareLessThan
        default: return .compareEqualTo
        }
    }
    
    public init(booleanLiteral value: Bool) {
        self = value ? .compareLessThan : .compareGreaterThan
    }
}
