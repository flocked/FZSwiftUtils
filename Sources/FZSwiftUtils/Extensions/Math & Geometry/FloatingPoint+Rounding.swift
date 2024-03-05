//
//  File.swift
//  
//
//  Created by Florian Zand on 03.02.24.
//

import Foundation

public extension BinaryFloatingPoint {
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
     - roundingFactor: The rounding factor.
     - rule: The rounding rule to apply. The default value is `up`.
     
     - Returns: The rounded value.
     */
    func rounded(toNearest roundingFactor: Self, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        (self / roundingFactor).rounded(rule) * roundingFactor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
     - roundingFactor: The rounding factor.
     - rule: The rounding rule to apply. The default value is `up`.
     */
    mutating func round(toNearest roundingFactor: Self, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        self = (self / roundingFactor).rounded(rule) * roundingFactor
    }
}

public extension CGFloat {
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     - Returns: The rounded value.
     */
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
     - roundingFactor: The rounding factor.
     - rule: The rounding rule to apply. The default value is `up`.
     
     - Returns: The rounded value.
     */
    func rounded(toNearest roundingFactor: Self, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        (self / roundingFactor).rounded(rule) * roundingFactor
    }
    
    /**
     Rounds the value by the specified rounding factor.
     
     - Parameters:
     - roundingFactor: The rounding factor.
     - rule: The rounding rule to apply. The default value is `up`.
     */
    mutating func round(toNearest roundingFactor: Self, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        self = (self / roundingFactor).rounded(rule) * roundingFactor
    }
}

/// A rule for rounding a floating-point number to decimal places.
public enum FloatingPointPlacesRoundingRule {
    /**
     Round to the specified number of decimal places.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.66675).rounded(.toPlaces(2))
     // 0.67
     
     (0.66675).rounded(.toPlaces(4))
     // 0.6668
     ```
     */
    case toPlaces(Int)
    /**
     Round to the specified number of decimal places towards zero.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.66675).rounded(.toPlacesTowardZero(2))
     // 0.66
     
     (0.66675).rounded(.toPlacesTowardZero(4))
     // 0.6667
     ```
     */
    case toPlacesTowardZero(Int)
    
    var places: Int {
        switch self {
        case let .toPlaces(value), let .toPlacesTowardZero(value):
            return value
        }
    }
    
    var divisor: Double {
        pow(10.0, Double(places))
    }
    
    var rounding: FloatingPointRoundingRule {
        switch self {
        case .toPlaces:
            return .toNearestOrAwayFromZero
        case .toPlacesTowardZero:
            return .towardZero
        }
    }
}

/// A rule for rounding a floating-point number by a rounding factor.
public enum FloatingPointFactorRoundingRule {
    /**
     Round to the closest allowed value that is greater than or equal to the source.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.75).rounded(toNearest: 0.5, .up)
     // 1.0
     
     (0.5).rounded(toNearest: 0.2, .down)
     // 0.6
     ```
     */
    case up
    /**
     Round to the closest allowed value that is less than or equal to the source.
     
     The following example shows the results of rounding numbers using this rule:
     
     ```swift
     (0.75).rounded(toNearest: 0.5, .down)
     // 0.5
     
     (0.5).rounded(toNearest: 0.2, .down)
     // 0.4
     ```
     */
    case down
    
    var rounding: FloatingPointRoundingRule {
        switch self {
        case .up: return .toNearestOrAwayFromZero
        case .down: return .towardZero
        }
    }
}
