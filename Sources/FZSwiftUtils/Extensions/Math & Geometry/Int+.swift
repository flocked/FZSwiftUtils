//
//  Int+.swift
//
//
//  Created by Florian Zand on 01.02.25.
//

import Foundation

extension BinaryInteger {
    /// Returns the shift value for which `1 << shiftValue` equals the integer, or `nil` if not a power of two.
    var shiftValue: Int? {
        guard self > 0 else { return nil }
        return Int(log2(Double(self)))
    }
}
