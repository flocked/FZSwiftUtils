//
//  NSNumber+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

public extension NSNumber {
    /**
     Returns an NSNumber object initialized to contain the specified value.
     
     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: Bool) { self.init(value: value) }
    
    /**
     Returns an NSNumber object initialized to contain the specified value.
     
     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: CChar) { self.init(value: value) }
    
    /**
     Returns an NSNumber object initialized to contain the specified value.
     
     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init<Value>(_ value: Value) where Value: BinaryFloatingPoint { self.init(value: Float(value)) }
    
    /**
     Returns an NSNumber object initialized to contain the specified value.
     
     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init(_ value: CGFloat) { self.init(value: value) }
    
    /**
     Returns an NSNumber object initialized to contain the specified value.
     
     - Parameter value: The value for the new number.
     - Returns: An `NSNumber` object containing the value.
     */
    convenience init<Value>(_ value: Value) where Value: BinaryInteger { self.init(value: Int(value)) }
    
    /**
     Returns an NSNumber object initialized to contain the specified value of the string.
     
     - Parameter value: The value of the string for the new number.
     - Returns: An `NSNumber` object containing the value of the string, or `nil` if the string doesn't contain a value.
     */
    convenience init?(_ string: String) {
        let formatter = NumberFormatter()
        if let value: Float = formatter.value(from: string) {
            self.init(value)
        } else if let value: Int = formatter.value(from: string) {
            self.init(value)
        } else if let value: Bool = formatter.value(from: string) {
            self.init(value)
        } else {
            return nil
        }
    }
}
