//
//  Range+NSRange.swift
//  
//
//  Created by Florian Zand on 30.08.23.
//

import Foundation

public extension ClosedRange where Bound == IntegerLiteralType {
    /// The closed range as `NSRange`.
    var nsRange: NSRange {
        let length = self.upperBound-self.lowerBound
        return NSRange(location: self.lowerBound, length: length)
    }
}

public extension Range where Bound == IntegerLiteralType {
    /// The range as `NSRange`.
    var nsRange: NSRange {
        let length = self.upperBound-self.lowerBound
        return NSRange(location: self.lowerBound, length: length)
    }
}
