//
//  Notification+.swift
//
//
//  Created by Florian Zand on 07.12.24.
//

import Foundation

extension Notification.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
