//
//  OptionSet+.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

import Foundation

public extension SetAlgebra {
    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter elements: The elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    @_disfavoredOverload
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        members.contains(where: { contains($0) })
    }
    
    /**
     A Boolean value that indicates whether the given element exists in the set.
     
     Setting this value to `true`, inserts the given element in the set if it is not already present. Setting it to `false`, removes it from the set.
     */
    subscript (_ element: Element) -> Bool {
        get { contains(element) }
        set {
            if newValue {
                insert(element)
            } else {
                remove(element)
            }
        }
    }
    
    static func + (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }
    
    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }
    
    static func - (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }
    
    static func -= (lhs: inout Self, rhs: Element) {
        lhs.remove(rhs)
    }
}

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
