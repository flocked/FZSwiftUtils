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
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        members.contains(where: { contains($0) })
    }
    
    /// A Boolean value indicating whether the set contains the specified element.
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
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter elements: The elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    func contains(any member: Self) -> Bool {
        member.elements().contains(where: { contains($0) })
    }
    
    /// Returns an array of the elements included in the set.
    func elements() -> [Self] {
        _elements().collect()
    }
    
    private func _elements() -> AnySequence<Self> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnySequence {
            AnyIterator {
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
