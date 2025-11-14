//
//  Int+.swift
//
//
//  Created by Florian Zand on 14.11.25.
//

public extension BinaryInteger {
    /// Returns the position of the single set bit if the integer is a power of two, otherwise `nil`.
    var bitPosition: Int? {
        guard self > 0, (self & (self - 1)) == 0 else { return nil }
        return trailingZeroBitCount
    }
}
