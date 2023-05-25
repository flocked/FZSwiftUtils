//
//  Numbers+.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public extension BinaryFloatingPoint {
func interpolated(from: ClosedRange<Self>, to: ClosedRange<Self>) -> Self {
    let positionInRange = (self - from.lowerBound) / (from.upperBound - from.lowerBound)
    return (positionInRange * (to.upperBound - to.lowerBound)) + to.lowerBound
  }
}

public extension CGFloat {
    var scaledIntegral: Self {
#if os(macOS)
let scale = NSScreen.main?.backingScaleFactor ?? 1.0
#elseif os(iOS)
let scale = UIScreen.main.scale
#endif
return floor(self * scale) / scale
    }
}

public extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return CGFloat(CGFloat.pi) * self / 180.0
    }
}

public extension BinaryFloatingPoint {
    func degreesToRadians() -> Self {
        return Self.pi * self / 180.0
    }
}


public extension Int {
    static func random(in range: ClosedRange<Self>, excluding: Self) -> Self {
        var randomNumber = Self.random(in: range)
        if (range.count > 1) {
          while excluding == randomNumber {
              randomNumber = Self.random(in: range)
          }
        }
        return randomNumber
    }
    
    static func random(in range: ClosedRange<Self>, excluding: [Self]) -> Self {
        var randomNumber = Self.random(in: range)
        if (range.count > excluding.count) {
            while excluding.contains(randomNumber) == true {
              randomNumber = Self.random(in: range)
          }
        }
        return randomNumber
    }
}

public extension Int {
     enum NextValueType {
        case next
        case previous
        case nextLooping
        case previousLooping
        case random
        case first
        case last
    }
    
    func next(in range: ClosedRange<Self>) -> Self {
        return self.advanced(by: .next, in: range)
    }
    
    func nextLooped(in range: ClosedRange<Self>) -> Self {
        return self.advanced(by: .nextLooping, in: range)
    }
    
    func previous(in range: ClosedRange<Self>) -> Self {
        return self.advanced(by: .previous, in: range)
    }
    
    func previousLooped(in range: ClosedRange<Self>) -> Self {
        return self.advanced(by: .previousLooping, in: range)
    }
    
    func advanced(by type: NextValueType, in range: ClosedRange<Self>) -> Self {
        var index = self
        switch type {
        case .next:
            index = index+1
            if (index > range.upperBound) {
                index = range.upperBound
            }
        case .previous:
            index = index-1
            if (index < range.lowerBound) {
                index = range.lowerBound
            }
        case .nextLooping:
            index = index+1
            if (index > range.upperBound) {
                index = range.lowerBound
            }
        case .previousLooping:
            index = index-1
            if (index <  range.lowerBound) {
                index = range.upperBound
            }
        case .random:
            index = Int.random(in: range, excluding: self)
        case .first:
            index = range.lowerBound
        case .last:
            index = range.upperBound
        }
        return index
    }
}

public enum FloatingPointPlacesRoundingRule {
    case toPlaces(Int)
    case toPlacesTowardZero(Int)
    internal var places: Int {
        switch self {
        case .toPlaces(let value), .toPlacesTowardZero(let value):
            return value
        }
    }
    
    internal var divisor: Double {
        return pow(10.0, Double(places))
    }
    
    internal var rounding: FloatingPointRoundingRule {
        switch self {
        case .toPlaces(_ ):
            return .toNearestOrAwayFromZero
        case .toPlacesTowardZero(_ ):
            return .towardZero
        }
    }
}

public extension BinaryFloatingPoint {
    func rounded(_ rule: FloatingPointPlacesRoundingRule) -> Self {
        let divisor = Self(rule.divisor)
        return (self * divisor).rounded(rule.rounding) / divisor
    }
    
    mutating func round(_ rule: FloatingPointPlacesRoundingRule) {
        let divisor = Self(rule.divisor)
        self = (self * divisor).rounded(rule.rounding) / divisor
    }
    
    var placesCount: Int {
        let decimal = Decimal(Double(self))
        return max(-decimal.exponent, 0)
    }
}
