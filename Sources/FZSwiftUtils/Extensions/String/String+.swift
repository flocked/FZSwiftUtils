//
//  String+.swift
//  FZExtensions
//
//  Created by Florian Zand on 05.06.22.
//

import Foundation
import NaturalLanguage

public extension String {
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

    /// Returns a new string in which all occurrences of target strings in a specified range of the string are replaced by another given string.
    func replacingOccurrences<Target, Replacement>(of strings: [Target], with replacement: Replacement) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var newString = self
        for string in strings {
            newString = newString.replacingOccurrences(of: string, with: replacement)
        }
        return newString
    }
    
    /**
     Returns a new string in which all occurrences of target strings in a specified range of the string are replaced by other given strings.
     
     - Note: The number of target strings has to be the same as the number of replacement strings.
     */
    func replacingOccurrences<Target, Replacement>(of values: [Target], with withValues: [Replacement]) -> String where Target: StringProtocol, Replacement: StringProtocol {
        guard values.count == withValues.count else { return self }
        var string = self
        for value in zip(values, withValues) {
            string = string.replacingOccurrences(of: value.0, with: value.1)
        }
        return string
    }
    
    /// Returns a string with all emoji characters removed.
    func withoutEmoji() -> String {
        filter { $0.isASCII }
    }
    
    /// Returns a string where all numbers represented as emoji characters are replaced with numeric characters.
    func replaceEmojiNumbers() -> String {
        var string = self
        string = string.replacingOccurrences(of: ["0️⃣", "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟", "💯"], with: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "100"])
        string = string.replacingOccurrences(of: ["%", "٪", "﹪", "％"], with: "%")
        return string
    }
    
    /// A mangled representation of the string.
    var mangled: String {
        String(utf16.map { $0 - 1 }.compactMap(UnicodeScalar.init).map(Character.init))
    }

    /// A unmangled representation of the string.
    var unmangled: String {
        String(utf16.map { $0 + 1 }.compactMap(UnicodeScalar.init).map(Character.init))
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
