//
//  String+.swift
//
//
//  Created by Florian Zand on 05.06.22.
//

import Foundation

public extension StringProtocol {
    /// The range of the whole string as `NSRange`.
    var nsRange: NSRange {
        NSRange(startIndex..., in: self)
    }

    /// The length of the string.
    var length: Int {
        utf16.count
    }
    
    /// The range of the whole string.
    var range: Range<Index> {
        startIndex..<endIndex
    }
    
    /**
     A Boolean value indicating whether the string contains any of the specified strings.
     - Parameter strings: The strings.
     - Returns: `true` if any of the strings exists in the string, or` false` if non exist in the option set.
     */
    func contains<S>(any strings: S) -> Bool where S: Sequence<StringProtocol> {
        for string in strings {
            if contains(string) {
                return true
            }
        }
        return false
    }

    /**
     A Boolean value indicating whether the string contains all specified strings.
     - Parameter strings: The strings.
     - Returns: `true` if all strings exist in the string, or` false` if not.
     */
    func contains<S>(all strings: S) -> Bool where S: Sequence<StringProtocol> {
        for string in strings {
            if contains(string) == false {
                return false
            }
        }
        return true
    }
    
    /// Returns a new string made by removing all emoji characters.
    func trimmingEmojis() -> String {
        unicodeScalars
            .filter { !$0.properties.isEmojiPresentation && !$0.properties.isEmoji }
            .reduce(into: "") { $0 += String($1) }
    }

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
    
    /// Returns a new string made by removing from both ends of the String characters contained in the given character sets.
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
    
    subscript(range: NSRange) -> SubSequence? {
        guard let range = Range<Index>(range, in: self) else { return nil }
        return self[range]
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
    /**
     Returns a new string in which all occurrences of the target strings are replaced by another given string.

     - Parameters:
        - strings: An array of target strings to be replaced.
        - replacement: The replacement string.

     - Returns: A new string with occurrences of target strings replaced by the replacement string.
     */
    func replacingOccurrences<Target, Replacement>(of strings: [Target], with replacement: Replacement, options: String.CompareOptions = []) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var newString = self
        for string in strings {
            newString = newString.replacingOccurrences(of: string, with: replacement, options: options)
        }
        return newString
    }
    
    /*
    /**
     Returns a new string in which all occurrences of the target strings are replaced by another given string.

     - Parameters:
        - strings: An array of target strings to be replaced.
        - replacement: The replacement string.

     - Returns: A new string with occurrences of target strings replaced by the replacement string.
     */
    func replacingOccurrences<Target, Replacement>(of strings: [Target], with replacement: Replacement, options: String.CompareOptions = [], range searchRange: Range<Self.Index>? = nil) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var newString = self
        for string in strings {
            newString = newString.replacingOccurrences(of: string, with: replacement, options: options, range: range)
        }
        return newString
    }
    */

    /**
     Returns a new string in which all occurrences of the target strings are replaced by their replacement strings.

     - Parameters:
        - values: A dictionary mapping target strings to their replacement strings.

     - Returns: A new string with occurrences of target strings replaced by the corresponding replacement strings.
     */
    func replacingOccurrences<Target, Replacement>(_ values: [Target: Replacement], options: String.CompareOptions = [], range searchRange: Range<Self.Index>? = nil) -> String where Target: StringProtocol, Replacement: StringProtocol {
        var string = self
        for value in values {
            string = string.replacingOccurrences(of: value.key, with: value.value, options: options, range: range)
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
    
    /// The string as `CFString`.
    var cfString: CFString {
        self as CFString
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

public extension NSString {
    /// The range of the whole string as `NSRange`.
    var range: NSRange {
        NSRange(location: 0, length: length)
    }
}

public extension unichar {
    /// The character as `Swift` character.
    var swift: Character? {
        guard let scalar = UnicodeScalar(self) else { return nil }
        return Character(scalar)
    }
    
    /// A Boolean value indicating whether this character represents a newline
    var isNewline: Bool {
        switch self {
        case 0x000A, 0x000B, 0x000C, 0x000D, 0x0085, 0x2028, 0x2029:
            return true
        default:
            return false
        }
    }
}
