//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation
import NaturalLanguage

public struct StringMatch {
    public let string: String
    public let range: Range<String.Index>
    public let score: Int
}

internal extension StringMatch {
    init(_ result: NSTextCheckingResult, source: String) {
        range = Range(result.range, in: source)!
        string = String(source[range])
        score = string.distance(from: range.lowerBound, to: range.upperBound)
    }
}

public extension String {
    func substrings(_ option: EnumerationOptions) -> [String] {
        var array = [String]()
        enumerateSubstrings(in: startIndex..., options: option) { _, range, _, _ in
            array.append(String(self[range]))
        }
        return array
    }
    
    func substringRanges(_ option: EnumerationOptions) -> [(string: String, range: Range<Index>)] {
        var array = [(string: String, range: Range<Index>)]()
        enumerateSubstrings(in: startIndex..., options: option) { _, range, _, _ in
            array.append((String(self[range]), range))
        }
        return array
    }
    
    func substrings(between fromString: String, and toString: String, includingFromTo: Bool = false) -> [String] {
        let pattern = fromString + "(.*?)" + toString
        let matches = self.matches(regex: pattern)
        if includingFromTo == false {
            return matches.compactMap { String($0.dropFirst(fromString.count).dropLast(toString.count)) }
        }
        return matches
    }

    /// An array of words of the string.
    var words: [String] {
        return substrings(.byWords)
    }

    /// An array of lines of the string.
    var lines: [String] {
        return substrings(.byLines)
    }

    /// An array of sentences of the string.
    var sentences: [String] {
        return substrings(.bySentences)
    }
        
    func matches(pattern: String) -> [StringMatch] {
        let string = self
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return regex?.matches(in: string, range: NSMakeRange(0, string.utf16.count)).compactMap { StringMatch($0, source: string) } ?? []
    }

    func matches(regex pattern: String) -> [String] {
        let string = self
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        return regex?.matches(in: string, range: NSMakeRange(0, string.utf16.count)).compactMap { String(string[Range($0.range, in: string)!]) } ?? []
    }

    func findPersonNames() -> [String] {
        var personNames = [String]()
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
            switch tag {
            case .personalName?:
                personNames.append(String(self[range]))
            default:
                break
            }
        }

        return personNames
    }
}
