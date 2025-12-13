//
//  Notification+.swift
//
//
//  Created by Florian Zand on 07.12.24.
//

import Foundation

extension Notification.Name: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByUnicodeScalarLiteral, Swift.ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
