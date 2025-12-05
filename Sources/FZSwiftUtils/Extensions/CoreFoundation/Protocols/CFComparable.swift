//
//  CFComparable.swift
//  
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

/// A Core Foundation that is comparable.
public protocol CFComparable {
    /// Compares rhe object to another and returns a comparison result.
    func compare(to other: Self, context: UnsafeMutableRawPointer!) -> CFComparisonResult
}

public extension CFComparable {
    /// Compares rhe object to another and returns a comparison result.
    func compare(to other: Any, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        guard let other = other as? Self else { return .compareLessThan }
        return compare(to: other, context: context)
    }
}

extension CFNumber: CFComparable {
    public func compare(to other: CFNumber, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        CFNumberCompare(self, other, context)
    }
}

extension CFDate: CFComparable {
    public func compare(to other: CFDate, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        CFDateCompare(self, other, context)
    }
}

extension CFString: CFComparable {
    public func compare(to other: CFString, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        CFStringCompare(self, other, [])
    }
}

extension CFBoolean: CFComparable {
    public func compare(to other: CFBoolean, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        let a = CFBooleanGetValue(self)
        let b = CFBooleanGetValue(other)

        if a == b { return .compareEqualTo }
        return a ? .compareGreaterThan : .compareLessThan
    }
}

extension CFURL: CFComparable {
    public func compare(to other: CFURL, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        ((self as URL).absoluteString as CFString).compare(to: (other as URL).absoluteString as CFString, context: context)
    }
}

extension CFLocale: CFComparable {
    public func compare(to other: CFLocale, context: UnsafeMutableRawPointer!) -> CFComparisonResult {
        ((self as Locale).identifier as CFString).compare(to: ((other as Locale).identifier as CFString), context: context)
    }
}
