//
//  String+.swift
//  FZExtensions
//
//  Created by Florian Zand on 05.06.22.
//

import Foundation
import NaturalLanguage

public extension String {
    func lowercasedFirst() -> String {
        if isEmpty { return "" }
        return prefix(1).lowercased() + dropFirst()
    }

    func uppercasedFirst() -> String {
        if isEmpty { return "" }
        return prefix(1).uppercased() + dropFirst()
    }

    var mangled: String {
        String(utf16.map { $0 - 1 }.compactMap(UnicodeScalar.init).map(Character.init))
    }

    var unmangled: String {
        String(utf16.map { $0 + 1 }.compactMap(UnicodeScalar.init).map(Character.init))
    }

    func replacingOccurrences(of strings: [String], with replacement: String) -> String {
        var newString = self
        for string in strings {
            newString = newString.replacingOccurrences(of: string, with: replacement)
        }
        return newString
    }
}

public extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
    }

    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
    }

    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
