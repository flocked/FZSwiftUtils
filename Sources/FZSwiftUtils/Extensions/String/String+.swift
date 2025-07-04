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
        if isEmpty { return String(self) }
        return prefix(1).lowercased() + dropFirst()
    }

    /// A representation of the string where the first character is uppercased.
    func uppercasedFirst() -> String {
        if isEmpty { return String(self) }
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
    
    /// A Boolean value indicating whether the string matches the specific character set.
    func matches(_ characterSet: CharacterSet) -> Bool {
        unicodeScalars.allSatisfy { characterSet.contains($0) }
    }
}

public extension StringProtocol {
    /// Returns the character at the specified offset.
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    
    /// Returns the character at the specified offset, or `nil` if the offset couldn't be found.
    subscript(safe offset: Int) -> Character? {
        guard let index = index(startIndex, offsetBy: offset, limitedBy: endIndex) else { return nil }
        return self[index]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: Range<Int>) -> SubSequence {
        let range = range.clamped(to: 0..<count)
        let startIndex = index(startIndex, offsetBy: range.lowerBound)
        return self[startIndex ..< index(startIndex, offsetBy: range.count)]
    }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: Range<Int>) -> SubSequence? {
        guard let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        guard let endIndex = firstIndex(in: range) else { return nil }
        return self[startIndex...endIndex]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: ClosedRange<Int>) -> SubSequence {
        self[range.lowerBound..<range.upperBound+1]
    }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: ClosedRange<Int>) -> SubSequence? {
        self[safe: range.lowerBound..<range.upperBound+1]
    }
    
    /// Returns the substring for the specified `NSRange`.
    subscript(range: NSRange) -> SubSequence {
        return self[safe: range]!
    }
    
    /// Returns the substring for the specified `NSRange`, or `nil` if the range couldn't be found.
    subscript(safe range: NSRange) -> SubSequence? {
        guard let range = Range<Index>(range, in: self) else { return nil }
        return self[range]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeFrom<Int>) -> SubSequence? {
        guard let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[index(startIndex, offsetBy: range.lowerBound)...]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeThrough<Int>) -> SubSequence? {
        guard let endIndex = firstIndex(in: 0..<range.upperBound) else { return nil }
        return self[...endIndex]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeUpTo<Int>) -> SubSequence? {
        guard let endIndex = firstIndex(in: 0..<range.upperBound) else { return nil }
        return self[..<endIndex]
    }

    private func firstIndex(in range: Range<Int>) -> Index? {
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
    /// Returns the string, repeated by the specified amount.
    func repeated(amount: Int) -> String {
        String(repeating: self, count: amount)
    }
    
    /// The range of the specified prefix, or `nil` if it doesn't exist.
    func rangeOfPrefix(_ prefix: String) -> Range<Index>? {
        guard hasPrefix(prefix) else { return nil }
        return startIndex..<index(startIndex, offsetBy: prefix.count)
    }
    
    /**
     Replaces the specified prefix with a string.
     
     - Parameters:
        - prefix: The prefix to replace.
        - string: The replacement string.
     */
    mutating func replacePrefix(_ prefix: String, with string: String) {
        guard let range = rangeOfPrefix(prefix) else { return }
        replaceSubrange(range, with: string)
    }
    
    /**
     Removes the specified prefix.
     
     - Parameter prefix: The prefix to remove.
     */
    mutating func removePrefix(_ prefix: String) {
        replacePrefix(prefix, with: "")
    }
    
    /**
     Returns the string where the specified prefix is replaced.
     
     - Parameters:
        - prefix: The prefix to replace.
        - string: The replacement string.
     */
    func replacingPrefix(_ prefix: String, with string: String) -> String {
        var _string = self
        _string.replacePrefix(prefix, with: string)
        return _string
    }
    
    /**
     Returns the string with the specified prefix removed.
     
     - Parameter prefix: The prefix to remove.
     */
    func removingPrefix(_ prefix: String) -> String {
        replacingPrefix(prefix, with: "")
    }
    
    /// The range of the specified suffix, or `nil` if it doesn't exist.
    func rangeOfSuffix(_ suffix: String) -> Range<Index>? {
        guard hasSuffix(suffix) else { return nil }
        return index(endIndex, offsetBy: -suffix.count)..<endIndex
    }
    
    /**
     Replaces the specified suffix with a string.
     
     - Parameters:
        - suffix: The suffix to replace.
        - string: The replacement string.
     */
    mutating func replaceSuffix(_ suffix: String, with string: String) {
        guard let range = rangeOfSuffix(suffix) else { return }
        replaceSubrange(range, with: string)
    }
    
    /**
     Removes the specified suffix.
     
     - Parameter suffix: The suffix to remove.
     */
    mutating func removeSuffix(_ suffix: String) {
        replaceSuffix(suffix, with: "")
    }
    
    /**
     Returns the string where the specified suffix is replaced.
     
     - Parameters:
        - suffix: The suffix to replace.
        - string: The replacement string.
     */
    func replacingSuffix(_ suffix: String, with string: String) -> String {
        var _string = self
        _string.replaceSuffix(suffix, with: string)
        return _string
    }
    
    /**
     Returns the string with the specified suffix removed.
     
     - Parameter suffix: The suffix to remove.
     */
    func removingSuffix(_ suffix: String) -> String {
        replacingSuffix(suffix, with: "")
    }
    
    /**
     Returns a new string in which all occurrences of the target strings are replaced by another given string.

     - Parameters:
        - strings: An array of target strings to be replaced.
        - replacement: The replacement string.
        - options: Options for replacing the string.

     - Returns: A new string with occurrences of target strings replaced by the replacement string.
     */
    func replacingOccurrences<S, Replacement>(of strings: S, with replacement: Replacement, options: String.CompareOptions = []) -> String where S: Sequence, S.Element: StringProtocol, Replacement: StringProtocol {
        strings.reduce(into: self) { result, string in
            result = result.replacingOccurrences(of: string, with: replacement, options: options)
        }
    }

    /**
     Returns a new string in which all occurrences of the target strings are replaced by their replacement strings.

     - Parameters:
        - values: A dictionary mapping target strings to their replacement strings.
        - options: Options for replacing the string.

     - Returns: A new string with occurrences of target strings replaced by the corresponding replacement strings.
     */
    func replacingOccurrences<Target, Replacement>(_ values: [Target: Replacement], options: String.CompareOptions = []) -> String where Target: StringProtocol, Replacement: StringProtocol {
        values.reduce(into: self) { result, value in
            result = result.replacingOccurrences(of: value.key, with: value.value, options: options)
        }
    }
    
    /**
     Returns a new string in which all occurrences of the target string are removed.

     - Parameters:
        - target: The string to be removed.
        - options: Options for replacing the string.
        - searchRange: The range of strings to be removed.

     - Returns: A new string with occurrences of target are removed.
     */
    func removingOccurrences<Target>(of target: Target, options: String.CompareOptions = [], range searchRange: Range<Self.Index>? = nil) -> String where Target: StringProtocol {
        replacingOccurrences(of: target, with: "", range: searchRange)
    }
    
    /**
     Returns a new string in which all occurrences of the target strings are removed.

     - Parameters:
        - strings: An array of target strings to be removed.
        - options: Options for replacing the string.

     - Returns: A new string with occurrences of target strings are removed.
     */
    func removingOccurrences<S>(of strings: S, options: String.CompareOptions = []) -> String where S: Sequence, S.Element: StringProtocol {
        replacingOccurrences(of: strings, with: "", options: options)
    }

    /**
     Replaces emoji representations of numbers (e.g. "4️⃣3️⃣" to "43").

     - Returns: A new string with emoji numbers replaced by their corresponding decimal representations.
     */
    func replaceEmojiNumbers() -> String {
        replacingOccurrences(["0️⃣": "0", "1️⃣": "1", "2️⃣": "2", "3️⃣": "3", "4️⃣": "4", "5️⃣": "5", "6️⃣": "6", "7️⃣": "7", "8️⃣": "8", "9️⃣": "9", "🔟": "10"])
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
