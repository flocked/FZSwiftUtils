//
//  String+Match.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation
import NaturalLanguage

public extension String {
    ///  A structure representing a match found in a string.
    struct StringMatch: Hashable {
        /// The matched string.
        public let string: String
        /// The range of the matched string within the source string.
        public let range: Range<String.Index>
        /// The score or importance of the match.
        public let score: Int

        init(string: String, range: Range<String.Index>, score: Int) {
            self.string = string
            self.range = range
            self.score = score
        }

        init(_ result: NSTextCheckingResult, source: String) {
            range = Range(result.range, in: source)!
            string = String(source[range])
            score = source.distance(from: range.lowerBound, to: range.upperBound)
        }
    }

    /// Options for matching strings.
    enum StringMatchOption: Int, Hashable {
        /// Characters.
        case characters
        /// Words.
        case words
        /// Sentences.
        case sentences
        /// Paragraphs.
        case paragraphs
        /// Lines.
        case lines
        var enumerationOptions: NSString.EnumerationOptions {
            switch self {
            case .lines: return .byLines
            case .characters: return .byComposedCharacterSequences
            case .paragraphs: return .byParagraphs
            case .words: return .byWords
            case .sentences: return .bySentences
            }
        }
    }

    /**
     Returns an array of individual words in the string.

     - Returns: An array of words.
     */
    var words: [String] {
        matches(for: .words).compactMap(\.string)
    }

    /**
     Returns an array of lines in the string.

     - Returns: An array of lines.
     */
    var lines: [String] {
        matches(for: .lines).compactMap(\.string)
    }

    /**
     Returns an array of sentences in the string.

     - Returns: An array of sentences.
     */
    var sentences: [String] {
        matches(for: .sentences).compactMap(\.string)
    }

    /**
     Finds all matches in the string based on the provided regular expression pattern.

     - Parameter regex: The regular expression pattern to search for.
     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(regex: String) -> [StringMatch] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let string = self
        return regex.matches(in: string, range: NSRange(string.startIndex..., in: string)).flatMap({ match in
            (0..<match.numberOfRanges).compactMap {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: string) else { return nil }
                let score = string.distance(from: range.lowerBound, to: range.upperBound)
                return StringMatch(string: String(string[range]), range: range, score: score)
            }
        })
    }
    
    /// All integer values inside the string.
    var integerValues: [Int] {
        matches(regex: "[-+]?\\d+.?\\d+").compactMap({Int($0.string)})
    }
    
    /// All double values inside the string.
    var doubleValues: [Double] {
        matches(regex: "[-+]?\\d+.?\\d+").compactMap({Double($0.string.replacingOccurrences(of: ",", with: "."))})
    }
    
    /*
    func matchesAlt(regex: String) -> [StringMatch] {
        let string = self
        let regex = try? NSRegularExpression(pattern: regex, options: [])
        return regex?.matches(in: string, range: NSRange(string.startIndex..., in: string)).compactMap { StringMatch($0, source: string) } ?? []
    }
     */

    /**
     Finds all matches of substrings between the two specified strings.

     - Parameters:
        - fromString: The starting string to search for.
        - toString: The ending string to search for.
        - includingFromTo: A flag indicating whether to include the starting and ending strings in the results.

     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(between fromString: String, and toString: String, includingFromTo: Bool = false) -> [StringMatch] {
        let pattern = fromString + "(.*?)" + toString
        var matches = matches(regex: pattern)
        if includingFromTo == false {
            return matches.filter({!$0.string.hasPrefix(fromString) && !$0.string.hasSuffix(toString)})
        }
        return matches.filter({$0.string.hasPrefix(fromString) && $0.string.hasSuffix(toString)})
    }

    /**
     Finds all matches in the string based on the given option.

     - Parameter option: The option for finding matches.
     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(for option: StringMatchOption) -> [StringMatch] {
        var matches: [StringMatch] = []

        enumerateSubstrings(in: startIndex..., options: option.enumerationOptions) { _, range, _, _ in
            let score = self.distance(from: range.lowerBound, to: range.upperBound)
            matches.append(StringMatch(string: String(self[range]), range: range, score: score))
        }

        return matches
    }

    /**
     Finds all matches for the given option using natural language processing.

     - Parameter option: The option for finding matches (e.g. for findinge person names, places, nouns, verbs, etc.)
     - Returns: An array of `StringMatch` objects representing the matches found.
      */
    func matches(for option: NLTag) -> [StringMatch] {
        var matches: [StringMatch] = []
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = self

        let tags = tagger.tags(
            in: startIndex ..< endIndex,
            unit: .word,
            scheme: .nameType,
            options: [
                .omitPunctuation,
                .omitWhitespace,
                .omitOther,
                .joinNames,
            ]
        )
        for (tag, range) in tags {
            if tag == option {
                let score = distance(from: range.lowerBound, to: range.upperBound)
                matches.append(StringMatch(string: String(self[range]), range: range, score: score))
            }
        }
        return matches
    }
}

public extension StringProtocol {
    /// Returns a new string made by removing all emoji characters.
    func trimmingEmojis() -> String {
        unicodeScalars
            .filter { !$0.properties.isEmojiPresentation && !$0.properties.isEmoji }
            .reduce(into: "") { $0 += String($1) }
    }
}

public extension StringProtocol {
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
}
