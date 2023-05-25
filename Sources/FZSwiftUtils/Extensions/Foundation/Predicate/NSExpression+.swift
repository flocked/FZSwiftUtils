//
//  NSExpression+.swift
//  
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

public extension NSExpression {
    convenience init(_ value: String, _ args: Any...) {
        self.init(format: value, args)
    }
}
