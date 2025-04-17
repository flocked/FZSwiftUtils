//
//  NSExpression+.swift
//
//
//  Created by Florian Zand on 10.03.23.
//

import Foundation

public extension NSExpression {
    /// Creates an expression using the specificed key path.
    static func keyPath(_ keyPath: String) -> NSExpression {
        NSExpression(forKeyPath: keyPath)
    }
    
    /// Creates an expression using the specificed key path.
    static func keyPath<Root, Value>(_ keyPath: KeyPath<Root, Value>) -> NSExpression {
        NSExpression(forKeyPath: keyPath)
    }
        
    static func variable(_ keyPath: String) -> NSExpression {
        NSExpression(forVariable: keyPath)
    }
    
    /// Creates an expression that represents the specified constant value.
    static func constant(_ value: Any?) -> NSExpression {
        NSExpression(forConstantValue: value)
    }
    
    /// Creates an expression that represents any key for a Spotlight query.
    static var any: NSExpression {
        NSExpression.expressionForAnyKey()
    }
    
    /// Creates the expression with the expression format and arguments list you specify.
    convenience init(_ value: String, _ args: Any...) {
        self.init(format: value, args)
    }
}
