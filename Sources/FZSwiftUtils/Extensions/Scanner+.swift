//
//  Scanner+.swift
//
//
//  Created by Florian Zand on 23.01.26.
//

import Foundation

public extension Scanner {
    /// Scans for a long long value from a hexadecimal representation, returning a found value by reference.
    func scanHexInt64() -> UInt64? {
        var hexValue: UInt64 = 0
        return scanHexInt64(&hexValue) ? hexValue : nil
    }
    
    /// Scans for a double value from a hexadecimal representation, returning a found value by reference.
    func scanHexDouble() -> Double? {
        var hexValue: Double = 0
        return scanHexDouble(&hexValue) ? hexValue : nil
    }
    
    /// Scans for a double value from a hexadecimal representation, returning a found value by reference.
    func scanHexFloat() -> Float? {
        var hexValue: Float = 0
        return scanHexFloat(&hexValue) ? hexValue : nil
    }
    
    /// Scans for an NSInteger value from a decimal representation, returning a found value by reference
    func scanInt() -> Int? {
        var value: Int = 0
        return scanInt(&value) ? value : nil
    }
    
    /// Scans for a long long value from a decimal representation, returning a found value by reference.
    func scanInt64() -> Int64? {
        var value: Int64 = 0
        return scanInt64(&value) ? value : nil
    }
    
    /// Scans for an unsigned long long value from a decimal representation, returning a found value by reference.
    func scanUnsignedLongLong() -> UInt64? {
        var value: UInt64 = 0
        return scanUnsignedLongLong(&value) ? value : nil
    }
    
    /// Scans for a long long value from a hexadecimal representation of the specified string, returning a found value by reference.
    static func scanHexInt64(for string: String) -> UInt64? {
        Scanner(string: string).scanHexInt64()
    }
    
    /// Scans for a double value from a hexadecimal representation of the specified string, returning a found value by reference.
    static func scanHexDouble(for string: String) -> Double? {
        Scanner(string: string).scanHexDouble()
    }
    
    /// Scans for a double value from a hexadecimal representation of the specified string, returning a found value by reference.
    static func scanHexFloat(for string: String) -> Float? {
        Scanner(string: string).scanHexFloat()
    }
    
    /// Scans for an NSInteger value from a decimal representation of the specified string, returning a found value by reference
    static func scanInt(for string: String) -> Int? {
        Scanner(string: string).scanInt()
    }
    
    /// Scans for a long long value from a decimal representation of the specified string, returning a found value by reference.
    static func scanInt64(for string: String) -> Int64? {
        Scanner(string: string).scanInt64()
    }
    
    /// Scans for an unsigned long long value from a decimal representation of the specified string, returning a found value by reference.
    static func scanUnsignedLongLong(for string: String) -> UInt64? {
        Scanner(string: string).scanUnsignedLongLong()
    }
}
