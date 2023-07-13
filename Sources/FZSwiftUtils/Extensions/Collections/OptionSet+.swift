//
//  OptionSet+.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

import Foundation

public extension OptionSet {
    /**
     A boolean value indicating whether the option set contains all specified elements.
     - Parameters elements: The elements.
     - Returns: `true` if all elements exist in the option set, or` false` if not.
     */
    func contains(all members: [Self.Element]) -> Bool {
        for member in members {
            if contains(member) == false {
                return false
            }
        }
        return true
    }

    /**
     A boolean value indicating whether the option set contains any of the specified elements.
     - Parameters elements: The elements.
     - Returns: `true` if any of the elements exists in the option set, or` false` if non exist in the option set.
     */
    func contains(any members: [Self.Element]) -> Bool {
        for member in members {
            if contains(member) {
                return true
            }
        }
        return false
    }
}

public extension OptionSet where RawValue: FixedWidthInteger {
    /// Returns a sequence of all elements included in the option set.
    func elements() -> AnySequence<Self> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnySequence {
            return AnyIterator {
                while remainingBits != 0 {
                    defer { bitMask = bitMask &* 2 }
                    if remainingBits & bitMask != 0 {
                        remainingBits = remainingBits & ~bitMask
                        return Self(rawValue: bitMask)
                    }
                }
                return nil
            }
        }
    }
}
