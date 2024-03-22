//
//  String+.swift
//  FZExtensions
//
//  Created by Florian Zand on 05.06.22.
//

import Foundation
import NaturalLanguage

public extension String {
    /**
     Returns a new string in which all occurrences of the target strings are replaced by another given string.

     - Parameters:
        - strings: An array of target strings to be replaced.
        - replacement: The replacement string.

     - Returns: A new string with occurrences of target strings replaced by the replacement string.
     */
    func replacingOccurrences<Target, Replacement>(of strings: [Target], with replacement: Replacement) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var newString = self
        for string in strings {
            newString = newString.replacingOccurrences(of: string, with: replacement)
        }
        return newString
    }

    /**
     Returns a new string in which all occurrences of the target strings are replaced by their replacement strings.

     - Parameters:
        - values: A dictionary mapping target strings to their replacement strings.

     - Returns: A new string with occurrences of target strings replaced by the corresponding replacement strings.
     */
    func replacingOccurrences<Target, Replacement>(_ values: [Target: Replacement]) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var string = self
        for value in values {
            string = string.replacingOccurrences(of: value.key, with: value.value)
        }
        return string
    }

    /**
     Replaces emoji representations of numbers.

     - Returns: A new string with emoji numbers replaced by their corresponding decimal representations.
     */
    func replaceEmojiNumbers() -> String {
        replacingOccurrences(["0️⃣": "0", "1️⃣": "1", "2️⃣": "2", "3️⃣": "3", "4️⃣": "4", "5️⃣": "5", "6️⃣": "6", "7️⃣": "7", "8️⃣": "8", "9️⃣": "9", "🔟": "10"])
    }
    
    /// Returns the substring for the `NSRange`, or `nil` if the range couldn't be found.
    func substring(fron range: NSRange) -> Substring? {
        guard range != .notFound, let range = Range(range, in: self) else { return nil }
        return self[range]
    }
}

public extension StringProtocol {
    /// A representation of the string where the first character is lowercased.
    func lowercasedFirst() -> String {
        if isEmpty { return "" }
        return prefix(1).lowercased() + dropFirst()
    }

    /// A representation of the string where the first character is uppercased.
    func uppercasedFirst() -> String {
        if isEmpty { return "" }
        return prefix(1).uppercased() + dropFirst()
    }

    /// A mangled representation of the string.
    var mangled: String {
        String(utf16.map { $0 - 1 }.compactMap(UnicodeScalar.init).map(Character.init))
    }

    /// A unmangled representation of the string.
    var unmangled: String {
        String(utf16.map { $0 + 1 }.compactMap(UnicodeScalar.init).map(Character.init))
    }
    
    /// Returns a new string made by removing from both ends of the String characters contained in a given character set.
    func trimmingCharacters(in sets: [CharacterSet]) -> String {
        trimmingCharacters(in: sets.union)
    }
}

public extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    
    subscript(safe offset: Int) -> Character? {
        guard let index = index(startIndex, offsetBy: offset, limitedBy: endIndex) else { return nil }
        return self[index]
    }
    
    subscript(range: Range<Int>) -> SubSequence {
        let range = range.clamped(to: 0..<count)
        let startIndex = index(startIndex, offsetBy: range.lowerBound)
        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
    }
    
    subscript(range: ClosedRange<Int>) -> SubSequence {
        self[range.lowerBound..<range.upperBound+1]
    }
    
    subscript(safe range: Range<Int>) -> SubSequence? {
        guard let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        guard let endIndex = firstIndex(in: range) else { return nil }
        return self[startIndex...endIndex]
    }
    
    subscript(safe range: ClosedRange<Int>) -> SubSequence? {
        self[safe: range.lowerBound..<range.upperBound+1]
    }
    
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
    
    subscript(safe range: PartialRangeFrom<Int>) -> SubSequence? {
        guard let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[index(startIndex, offsetBy: range.lowerBound)...]
    }
    
    subscript(safe range: PartialRangeThrough<Int>) -> SubSequence? {
        guard let endIndex = firstIndex(in: 0..<range.upperBound) else { return nil }
        return self[...endIndex]
    }
    
    subscript(safe range: PartialRangeUpTo<Int>) -> SubSequence? {
        guard let endIndex = firstIndex(in: 0..<range.upperBound) else { return nil }
        return self[..<endIndex]
    }
    
    internal func firstIndex(in range: Range<Int>) -> Index? {
        var upperBound = range.upperBound
        var endIndex = index(startIndex, offsetBy: upperBound, limitedBy: endIndex)
        while endIndex == nil {
            upperBound -= 1
            if upperBound <= range.lowerBound {
                return nil
            } else {
                endIndex = index(startIndex, offsetBy: upperBound, limitedBy: self.endIndex)
            }
        }
        return endIndex
    }
}

public extension String {
    static func += (lhs: inout Self, rhs: Character) {
        lhs += String(rhs)
    }

    static func + (lhs: String, rhs: Character) -> String {
        lhs + String(rhs)
    }
}

public extension Character {
    static func + (lhs: Character, rhs: String) -> String {
        String(lhs) + rhs
    }
}
