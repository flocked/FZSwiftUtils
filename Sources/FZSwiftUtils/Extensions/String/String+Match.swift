//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation
import NaturalLanguage


///  A structure representing a match found in a string based on a regular expression pattern.
public struct StringMatch: Hashable {
    /// The matched string.
    public let string: String
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The score or importance of the match.
    public let score: Int
}

internal extension StringMatch {
    init(_ result: NSTextCheckingResult, source: String) {
        range = Range(result.range, in: source)!
        string = String(source[range])
        score = string.distance(from: range.lowerBound, to: range.upperBound)
    }
}

public enum StringMatchOption {
    case lines
    case composedCharacterSequences
    case paragraphs
    case words
    case sentences
    internal var enumerationOptions: NSString.EnumerationOptions {
        switch self {
        case .lines: return .byLines
        case .composedCharacterSequences: return .byComposedCharacterSequences
        case .paragraphs: return .byParagraphs
        case .words: return .byWords
        case .sentences: return .bySentences
        }
    }
}

public extension String {
    /**
     Returns an array of individual words in the string.
     
     - Returns: An array of words.
     */
    var words: [String] {
        self.matches(for: .words).compactMap({$0.string})
    }

    /**
     Returns an array of lines in the string.
     
     - Returns: An array of lines.
     */
    var lines: [String] {
        self.matches(for: .lines).compactMap({$0.string})
    }

    /**
     Returns an array of sentences in the string.
     
     - Returns: An array of sentences.
     */
    var sentences: [String] {
        self.matches(for: .sentences).compactMap({$0.string})
    }
        
    /**
     Finds all matches in the string based on the provided regular expression pattern.
     
     - Parameter regex: The regular expression pattern to search for.
     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(regex: String) -> [StringMatch] {
        let string = self
        let regex = try? NSRegularExpression(pattern: regex, options: [])
        return regex?.matches(in: string, range: NSMakeRange(0, string.utf16.count)).compactMap { StringMatch($0, source: string) } ?? []
    }
    
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
        var matches = self.matches(regex: pattern)
        if includingFromTo == false {
            matches = matches.compactMap({ match in
                let lowerBound = self.index(match.range.lowerBound, offsetBy: fromString.count)
                let upperBound = self.index(match.range.upperBound, offsetBy: -toString.count)
                let range = lowerBound..<upperBound
                let score = self.distance(from: range.lowerBound, to: range.upperBound)
                let string = String(match.string.dropFirst(fromString.count).dropLast(toString.count))
                return StringMatch(string: string, range: range, score: score)
            })
        }
        return matches
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
                let score = self.distance(from: range.lowerBound, to: range.upperBound)
                matches.append(StringMatch(string: String(self[range]), range: range, score: score))
            }
        }
        return matches
    }
}
