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
        NSRange(range, in: self)
    }
    
    /// The range of the whole string.
    var range: Range<Index> {
        startIndex..<endIndex
    }

    /**
     A Boolean value indicating whether the string contains all specified strings.
     - Parameter strings: The strings.
     - Returns: `true` if all strings exist in the string, or` false` if not.
     */
    func contains<S>(all strings: S) -> Bool where S: Sequence<StringProtocol> {
        strings.allSatisfy { contains($0) }
    }
    
    /// Returns a new string made by removing all emoji characters.
    func trimmingEmojis() -> String {
        unicodeScalars.filter { !$0.properties.isEmojiPresentation && !$0.properties.isEmoji }.reduce(into: "") { $0 += String($1) }
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
    
    /**
     The number of UTF-16 code units in the string.
     
     This is **not** the same as [count](https://developer.apple.com/documentation/swift/string/count), which counts the number of user-perceived characters (grapheme clusters).
     
     Use `length` when you need the UTF-16 representation size, for example when interacting with APIs that expect UTF-16 encoded strings (such as some Cocoa APIs).
     
     Examples:
     ```swift
     let text = "Hello"
     print(text.count)  // 5 (grapheme clusters)
     print(text.length) // 5 (UTF-16 code units)
     
     let emoji = "👨‍👩‍👧‍👦"
     print(emoji.count)  // 1 (user-perceived character)
     print(emoji.length) // 7 (UTF-16 code units)
     ```
     */
    var length: Int {
        utf16.count
    }
    
    /**
     A Boolean value indicating whether the string contains any of the specified strings.
     - Parameter strings: The strings.
     - Returns: `true` if any of the strings exists in the string, or` false` if non exist in the option set.
     */
    func contains<S>(any strings: S) -> Bool where S: Sequence<StringProtocol> {
        strings.contains { contains($0) }
    }
}

public extension StringProtocol {
    /// Returns the string matching the specified regular expression pattern.
    subscript(pattern pattern: String) -> SubSequence? {
        guard let range = range(of: pattern, options: .regularExpression) else { return nil }
        return self[range]
    }
    
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
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: Range<Int>) -> SubSequence? {
        guard let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        guard let endIndex = index(startIndex, offsetBy: range.count, limitedBy: endIndex) else { return nil }
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
        guard let range = Range(range, in: self) else { return nil }
        return self[range]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeFrom<Int>) -> SubSequence? {
        guard range.lowerBound >= 0, let startIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[startIndex...]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[startIndex...index(startIndex, offsetBy: range.upperBound)] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeThrough<Int>) -> SubSequence? {
        guard range.upperBound >= 0, let endIndex =  index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex) else { return nil }
        return self[startIndex...endIndex]
    }
    
    /// Returns the substring for the specified range.
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[startIndex..<index(startIndex, offsetBy: range.upperBound)] }
    
    /// Returns the substring for the specified range, or `nil` if the range couldn't be found.
    subscript(safe range: PartialRangeUpTo<Int>) -> SubSequence? {
        guard range.upperBound >= 0, let endIndex =  index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex) else { return nil }
        return self[startIndex..<endIndex]
    }
}

public extension String {
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
        strings.reduce(into: self) { $0 = $0.replacingOccurrences(of: $1, with: replacement, options: options) }
    }

    /**
     Returns a new string in which all occurrences of the target strings are replaced by their replacement strings.

     - Parameters:
        - values: A dictionary mapping target strings to their replacement strings.
        - options: Options for replacing the string.

     - Returns: A new string with occurrences of target strings replaced by the corresponding replacement strings.
     */
    func replacingOccurrences<Target, Replacement>(_ values: [Target: Replacement], options: String.CompareOptions = []) -> String where Target: StringProtocol, Replacement: StringProtocol {
        values.reduce(into: self) { $0 = $0.replacingOccurrences(of: $1.key, with: $1.value, options: options) }
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

    /// Replaces emoji representations of numbers (e.g. "4️⃣3️⃣" to "43").
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

public extension String {
    /**
     A cleaned-up string representation of the given value, flattening optional nesting and quoting string literals.
     
     Example:
     ```swift
     let array: [String?]? = ["value", nil, "value"]
     
     // -> ["value", nil, "value"]
     String(cleanDescribing: array)
     
     // -> Optional([Optional("value"), nil, Optional("value"]))
     String(describing: array)
     ```
     */
    init<Subject>(cleanDescribing instance: Subject) where Subject : TextOutputStreamable {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    /**
     A cleaned-up string representation of the given value, flattening optional nesting and quoting string literals.
     
     Example:
     ```swift
     let array: [String?]? = ["value", nil, "value"]
     
     // -> ["value", nil, "value"]
     String(cleanDescribing: array)
     
     // -> Optional([Optional("value"), nil, Optional("value"]))
     String(describing: array)
     ```
     */
    init<Subject>(cleanDescribing instance: Subject) where Subject : CustomStringConvertible {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    /**
     A cleaned-up string representation of the given value, flattening optional nesting and quoting string literals.
     
     Example:
     ```swift
     let array: [String?]? = ["value", nil, "value"]
     
     // -> ["value", nil, "value"]
     String(cleanDescribing: array)
     
     // -> Optional([Optional("value"), nil, Optional("value"]))
     String(describing: array)
     ```
     */
    init<Subject>(cleanDescribing instance: Subject) where Subject : CustomStringConvertible, Subject : TextOutputStreamable {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    /**
     A cleaned-up string representation of the given value, flattening optional nesting and quoting string literals.
     
     Example:
     ```swift
     let array: [String?]? = ["value", nil, "value"]
     
     // -> ["value", nil, "value"]
     String(cleanDescribing: array)
     
     // -> Optional([Optional("value"), nil, Optional("value"]))
     String(describing: array)
     ```
     */
    init<Subject>(cleanDescribing instance: Subject) {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    internal var nonNil: String {
        var result = self
        while true {
            let matches = result.matches(pattern: #"Optional\(([^()]*?)\)"#)
            if matches.isEmpty { break }
            for match in matches.reversed() {
                if let content = match.groups[safe: 0]?.string {
                    if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                    result.replaceSubrange(match.range, with: String(content))
                }
            }
        }
        return result
    }
}

public extension String {
    /**
     Returns a localized string from a table that Xcode generates for you when exporting localizations.
   
     Use this function to automatically generate a strings files named `[tableName].strings` located in bundle from your code when exporting localizations from Xcode or the `genstrings` utility.
     For information about inserting plural nouns and units into localized strings, see [Localizing strings that contain plurals](doc://com.apple.documentation/documentation/xcode/localizing-strings-that-contain-plurals).
   
     - Important: The values for `key`, `tableName`, `value`, and `comment` must be string literal values. Xcode can read these values from source code to automatically create localization tables when exporting localizations, but it doesn’t resolve string variables. If you want to use string variables, manually create a strings file and use [localizedString(forKey:value:table:)](https://developer.apple.com/documentation/foundation/bundle/localizedstring(forkey:value:table:)) instead. For more information on strings files, see [String Resources](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/10000051i-CH6).
   
     ### Choose Meaningful Keys
   
     Words can often have multiple different meanings depending on the context in which they’re used. For example, the word “Book” can be a noun referring to a printed literary work or a verb for the action of making a reservation. Words with different meanings that share the same spelling are heteronyms.
   
     Different languages often have different heteronyms. “Book” is a heteronym in English, but not in French, where the noun translates to “Livre,” and the verb translates to “Réserver.” For this reason, it’s important to translate each phrase appropriately for its semantics and not its phrasing. Assign unique keys to each string, and add a comment describing the context where it appears to the user.
   
     ```swift
     NSLocalizedString("book-tag-title",
                       value: "Book",
                       comment: "noun: A label attached to literary items in the library.")


     NSLocalizedString("book-button-title",
                       value: "Book",
                       comment: "verb: Title of the button that makes a reservation.")
     ```
   
     For the previous example, the table for the French locale in `fr.lproj/Localized.strings` includes the following lines:
   
     ```
     /* noun: A label attached to literary items in the library. */
     "book-tag-title" = "Livre";


     /* verb: Title of the button that makes a reservation. */
     "book-button-title" = "Réserver";
     ```
   
     ### Avoid String Interpolation
   
     Xcode doesn’t evaluate interpolated strings and string variables when generating strings files from code. Attempting to localize interpolated strings causes Xcode to export something that resembles the original code expression instead of its expected value at runtime. Translators then translate that exported value—leaving international users with a localized string containing code.
   
     The following code with an interpolated string literal has the translator localize the phrase, “The dominant color is (dominantColor)”:
   
     ```swift
     NSLocalizedString("dominant-color-caption",
                       value: "The dominant color is \(dominantColor)."
                       comment: "Image caption identifying the color that stands-out the most.")
     ```
     ```
     /* Image caption identifying the color that stands-out the most. */
     "dominant-color-caption" = "The dominant color is (dominantColor).";
     ```
     Instead, to dynamically insert values within localized strings, set `value` to a format string, and use [localizedStringWithFormat(_:_:)](https://developer.apple.com/documentation/swift/string/localizedstringwithformat(_:_:)) to insert those values.

     ```swift
     let format = NSLocalizedString("dominant-color-caption",
                                    value: "The dominant color is %@.",
                                    comment: "Image caption identifying the color that stands-out the most.")
     let localizedString = String.localizedStringWithFormat(format, favoriteColor)
     ```
     ```
     /* Image caption identifying the color that stands-out the most. */
     "dominant-color-copation" = "The dominant color is %@.";
     ```
   
     For information about inserting plural nouns and units into localized strings, see [Localizing strings that contain plurals](doc://com.apple.documentation/documentation/xcode/localizing-strings-that-contain-plurals).
   
     ### Avoid Multiline String Literals
   
     Using multiline string literals for strings with newlines can result in unexpected behavior when exporting localizations. Xcode inserts a new line before and after the body of text in the strings file, which translators preserve in their localizations.
   
     ```swift
     NSLocalizedString("loading-screen.venus-flytrap-fact",
                       value: """
     Did you know that venus flytraps have flowers atop very long stems?
     The long stem keeps insects a safe distance away from their digestive leaves below.
     """,
                       comment: "An interesting fact about venus flytraps shown on the loading screen.")
     ```
   
     The previous code sample adds the following entry into `Localized.strings` when Xcode exports localizations:
   
     ```
     /* An interesting fact about venus flytraps shown on the loading screen. */
     "loading-screen.venus-flytrap-fact" = "\nDid you know that venus flytraps have flowers atop very long stems?\nThe long stem keeps insects a safe distance away from their digestive leaves below.\n";
     ```
   
     You can preserve the aesthetics of mirroring newlines in a string in their code representation by using string concatenation with [+(_:_:)](https://developer.apple.com/documentation/swift/string/+(_:_:)).
   
     ```swift
     NSLocalizedString("loading-screen.venus-flytrap-fact",
                       value: "Did you know that venus flytraps have flowers atop very long stems?"
                            + "\nThe long stem keeps insects a safe distance away from their digestive leaves below.",
                       comment: "An interesting fact about venus flytraps shown on the loading screen.")
     ```
     ```
     /* An interesting fact about venus flytraps shown on the loading screen. */
     "loading-screen.venus-flytrap-fact" = "Did you know that venus flytraps have flowers atop very long stems?\nThe long stem keeps insects a safe distance away from their digestive leaves below.";
     ```
   
     However, because comments aren’t localized, you can safely use multiline string literals with comment.
   
     ```swift
     NSLocalizedString("balloon-image-caption", value: "A bazillion balloons!", comment: """
     Caption for an image of a lot of balloons.
     The word "bazillion" is intentionally used to invoke a sense of childish excitement.
     """)
     ```
     ```
     /*
     Caption for an image of a lot of balloons.
     The word "bazillion" is intentionally used to invoke a sense of childish excitement.
     */
     "balloon-image-caption" = "A bazillion balloons!";
     ```
   
     - Parameters:
       - key: The key for a string in the specified table.
       
         **Note:** Xcode can’t export localizations for strings whose key is a string variable or an empty string.
       - tableName: The name of the table containing the key-value pairs. This defaults to the table in Localizable.strings when `tableName` is `nil` or an empty string.
       - bundle: The bundle containing the table’s strings file. The main bundle is used if one isn’t specified.
       - value: The localized string for the development locale. For other locales, return this value if `key` isn’t found in the table.
       - comment: The comment to place above the key-value pair in the strings file. This parameter provides the translator with some context where the string appears.

     - Returns: The result of sending [localizedString(forKey:value:table:)](https://developer.apple.com/documentation/foundation/bundle/localizedstring(forkey:value:table:)) to `bundle`, passing the specified `key`, `value`, and `tableName`.
     */
    static func localized(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", _ comment: String) -> String {
        NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
  
    /**
     Returns a localized string from a table that Xcode generates for you when exporting localizations.
   
     Use this function to automatically generate a strings files named `[tableName].strings` located in bundle from your code when exporting localizations from Xcode or the `genstrings` utility.
     For information about inserting plural nouns and units into localized strings, see [Localizing strings that contain plurals](doc://com.apple.documentation/documentation/xcode/localizing-strings-that-contain-plurals).
   
     - Important: The values for `key`, `tableName`, `value`, and `comment` must be string literal values. Xcode can read these values from source code to automatically create localization tables when exporting localizations, but it doesn’t resolve string variables. If you want to use string variables, manually create a strings file and use [localizedString(forKey:value:table:)](https://developer.apple.com/documentation/foundation/bundle/localizedstring(forkey:value:table:)) instead. For more information on strings files, see [String Resources](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/10000051i-CH6).
   
     ### Choose Meaningful Keys
   
     Words can often have multiple different meanings depending on the context in which they’re used. For example, the word “Book” can be a noun referring to a printed literary work or a verb for the action of making a reservation. Words with different meanings that share the same spelling are heteronyms.
   
     Different languages often have different heteronyms. “Book” is a heteronym in English, but not in French, where the noun translates to “Livre,” and the verb translates to “Réserver.” For this reason, it’s important to translate each phrase appropriately for its semantics and not its phrasing. Assign unique keys to each string, and add a comment describing the context where it appears to the user.
   
     ```swift
     NSLocalizedString("book-tag-title",
                       value: "Book",
                       comment: "noun: A label attached to literary items in the library.")


     NSLocalizedString("book-button-title",
                       value: "Book",
                       comment: "verb: Title of the button that makes a reservation.")
     ```
   
     For the previous example, the table for the French locale in `fr.lproj/Localized.strings` includes the following lines:
   
     ```
     /* noun: A label attached to literary items in the library. */
     "book-tag-title" = "Livre";


     /* verb: Title of the button that makes a reservation. */
     "book-button-title" = "Réserver";
     ```
   
     ### Avoid String Interpolation
   
     Xcode doesn’t evaluate interpolated strings and string variables when generating strings files from code. Attempting to localize interpolated strings causes Xcode to export something that resembles the original code expression instead of its expected value at runtime. Translators then translate that exported value—leaving international users with a localized string containing code.
   
     The following code with an interpolated string literal has the translator localize the phrase, “The dominant color is (dominantColor)”:
   
     ```swift
     NSLocalizedString("dominant-color-caption",
                       value: "The dominant color is \(dominantColor)."
                       comment: "Image caption identifying the color that stands-out the most.")
     ```
     ```
     /* Image caption identifying the color that stands-out the most. */
     "dominant-color-caption" = "The dominant color is (dominantColor).";
     ```
     Instead, to dynamically insert values within localized strings, set `value` to a format string, and use [localizedStringWithFormat(_:_:)](https://developer.apple.com/documentation/swift/string/localizedstringwithformat(_:_:)) to insert those values.

     ```swift
     let format = NSLocalizedString("dominant-color-caption",
                                    value: "The dominant color is %@.",
                                    comment: "Image caption identifying the color that stands-out the most.")
     let localizedString = String.localizedStringWithFormat(format, favoriteColor)
     ```
     ```
     /* Image caption identifying the color that stands-out the most. */
     "dominant-color-copation" = "The dominant color is %@.";
     ```
   
     For information about inserting plural nouns and units into localized strings, see [Localizing strings that contain plurals](doc://com.apple.documentation/documentation/xcode/localizing-strings-that-contain-plurals).
   
     ### Avoid Multiline String Literals
   
     Using multiline string literals for strings with newlines can result in unexpected behavior when exporting localizations. Xcode inserts a new line before and after the body of text in the strings file, which translators preserve in their localizations.
   
     ```swift
     NSLocalizedString("loading-screen.venus-flytrap-fact",
                       value: """
     Did you know that venus flytraps have flowers atop very long stems?
     The long stem keeps insects a safe distance away from their digestive leaves below.
     """,
                       comment: "An interesting fact about venus flytraps shown on the loading screen.")
     ```
   
     The previous code sample adds the following entry into `Localized.strings` when Xcode exports localizations:
   
     ```
     /* An interesting fact about venus flytraps shown on the loading screen. */
     "loading-screen.venus-flytrap-fact" = "\nDid you know that venus flytraps have flowers atop very long stems?\nThe long stem keeps insects a safe distance away from their digestive leaves below.\n";
     ```
   
     You can preserve the aesthetics of mirroring newlines in a string in their code representation by using string concatenation with [+(_:_:)](https://developer.apple.com/documentation/swift/string/+(_:_:)).
   
     ```swift
     NSLocalizedString("loading-screen.venus-flytrap-fact",
                       value: "Did you know that venus flytraps have flowers atop very long stems?"
                            + "\nThe long stem keeps insects a safe distance away from their digestive leaves below.",
                       comment: "An interesting fact about venus flytraps shown on the loading screen.")
     ```
     ```
     /* An interesting fact about venus flytraps shown on the loading screen. */
     "loading-screen.venus-flytrap-fact" = "Did you know that venus flytraps have flowers atop very long stems?\nThe long stem keeps insects a safe distance away from their digestive leaves below.";
     ```
   
     However, because comments aren’t localized, you can safely use multiline string literals with comment.
   
     ```swift
     NSLocalizedString("balloon-image-caption", value: "A bazillion balloons!", comment: """
     Caption for an image of a lot of balloons.
     The word "bazillion" is intentionally used to invoke a sense of childish excitement.
     """)
     ```
     ```
     /*
     Caption for an image of a lot of balloons.
     The word "bazillion" is intentionally used to invoke a sense of childish excitement.
     */
     "balloon-image-caption" = "A bazillion balloons!";
     ```
   
     - Parameters:
       - key: The key for a string in the specified table.
       
         **Note:** Xcode can’t export localizations for strings whose key is a string variable or an empty string.
       - tableName: The name of the table containing the key-value pairs. This defaults to the table in Localizable.strings when `tableName` is `nil` or an empty string.
       - bundle: The bundle containing the table’s strings file. The main bundle is used if one isn’t specified.
       - value: The localized string for the development locale. For other locales, return this value if `key` isn’t found in the table.
       - comment: The comment to place above the key-value pair in the strings file. This parameter provides the translator with some context where the string appears.

     - Returns: The result of sending [localizedString(forKey:value:table:)](https://developer.apple.com/documentation/foundation/bundle/localizedstring(forkey:value:table:)) to `bundle`, passing the specified `key`, `value`, and `tableName`.
     */
    static func localized(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String) -> String {
        NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
}

extension String.CompareOptions: Hashable {  }
