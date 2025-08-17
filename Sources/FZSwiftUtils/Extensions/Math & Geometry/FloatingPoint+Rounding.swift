//
//  FloatingPoint+Rounding.swift
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
        (self * Self(rule.divisor)).rounded(rule.rounding) / Self(rule.divisor)
    }
    
    /**
     Rounds the value using the specified rounding rule.
     
     - Parameter rule: The rounding rule to apply.
     */
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        self = rounded(rule)
    }
    
    /**
     Rounds the value to the multiple of the specified value.
     
     - Parameters:
        - factor: The rounding factor.
        - rule: The rounding rule.
     
     - Returns: The rounded value.
     */
    func rounded(toMultiple factor: Self, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        switch rule {
        case .toNearestOrEven:
            return self - self.remainder(dividingBy: factor)
        case .toNearestOrAwayFromZero:
            let x = self >= 0 ? self + factor/2 : self - factor/2
            return x - x.truncatingRemainder(dividingBy: factor)
        case .awayFromZero:
            let x = rounded(toMultiple: factor, rule: .towardZero)
            if self == x {
                return self
            } else {
                return self >= 0 ? x + factor : x - factor
            }
        case .towardZero:
            return self - self.truncatingRemainder(dividingBy: factor)
        case .down:
            return rounded(toMultiple: factor, rule: self < 0 ? .awayFromZero : .towardZero)
        case .up:
            return rounded(toMultiple: factor, rule: self >= 0 ? .awayFromZero : .towardZero)
        default:
            return rounded(toMultiple: factor, rule: .toNearestOrEven)
        }
    }
    
    /**
     Rounds the value to the multiple of the specified value.

     - Parameters:
        - factor: The rounding factor.
        - rule: The rounding rule.
     */
    mutating func round(toMultiple factor: Self, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        self = rounded(toMultiple: factor, rule: rule)
    }
    
    /**
     Rounds the value to the specified amount of places.
     
     - Parameters:
        - places: The amount of places.
        - rule: The rounding rule.
     
     - Returns: The rounded value.
     */
    func rounded(toPlaces places: Int, rule: FloatingPointRoundingRule = .toNearestOrEven) -> Self {
        let factor = Self(pow(10.0, Double(Swift.max(0, places))))
        return (self * factor).rounded(rule) / factor
    }
    
    /**
     Rounds the value to the specified amount of places.
     
     - Parameters:
        - places: The amount of places.
        - rule: The rounding rule.
     */
    mutating func round(toPlaces places: Int, rule: FloatingPointRoundingRule = .toNearestOrEven) {
        self = rounded(toPlaces: places, rule: rule)
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
        case let .toPlaces(places), let .toPlacesTowardZero(places): return Swift.max(0, places)
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
