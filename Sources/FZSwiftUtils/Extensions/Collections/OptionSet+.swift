//
//  OptionSet+.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

import Foundation

public extension OptionSet where RawValue: FixedWidthInteger, Element == Self {
    /**
     A Boolean value indicating whether the set contains any of the elements in the specified set.

     - Parameter member: The elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    func contains(any member: Self) -> Bool {
        (rawValue & member.rawValue) != 0
    }
    
    /// Returns an array of the elements included in the set.
    func elements() -> [Element] {
        Array(_elements())
    }
    
    private func _elements() -> AnySequence<Element> {
        var remainingBits = rawValue
        return AnySequence {
            AnyIterator {
                guard remainingBits != 0 else { return nil }
                let lowestBit = remainingBits & ~(remainingBits - 1)
                remainingBits &= ~lowestBit
                return Self(rawValue: lowestBit)
            }
        }
    }
}

extension OptionSet where RawValue: FixedWidthInteger {
    /**
     Creates a new option set from the given bit index.
          
     - Parameter bitIndex: The zero-based index of the bit to set. Must be less than `RawValue.bitWidth`.
          
     Example:
     ```swift
     struct Direction: OptionSet {
        let rawValue: Int

        static let left = Direction(bitIndex: 0)
        static let right = Direction(bitIndex: 1)
        static let down = Direction(bitIndex: 2)
        static let up = Direction(bitIndex: 3)
     
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
     }
     ```
     */
    public init(bitIndex: UInt) {
        precondition(bitIndex < RawValue.bitWidth, "Bit index out of range.")
        self.init(rawValue: 1 << Int(bitIndex))
    }
}
