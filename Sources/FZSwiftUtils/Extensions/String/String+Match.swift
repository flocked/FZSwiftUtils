//
//  String+Match.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation
import NaturalLanguage

public extension String {
    /**
     Finds all matches in the string based on the provided regular expression pattern.

     - Parameter regex: The regular expression pattern to search for.
     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(regex: String) -> [StringMatch] {
        results(for: regex, type: .regularExpression)
    }
    
    /**
     Returns a new string containing matching regular expressions replaced with the template string.

     - Parameters:
        - regex: The regular expression pattern to search for.
        - template: The substitution template used when replacing matching instances.
     
     - Returns: A string with matching regular expressions replaced by the template string, or `nil`, if the regular expression pattern is invalid.
     */
    func replace(pattern: String, template: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let replacedString = regex.stringByReplacingMatches(in: self, range: nsRange, withTemplate: template)
            return replacedString
        } catch {
            debugPrint(error)
        }
        return nil
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
        let pattern = fromString.escapedPattern + "(.*?)" + toString.escapedPattern
        let matches = matches(regex: pattern)
        return includingFromTo ? matches.compactMap({$0.withoutGroup}) : matches.compactMap({$0.group.first})
    }
    
    /**
     Finds all matches in the string based on the given option.

     - Parameter option: The option for finding matches.
     - Returns: An array of `StringMatch` objects representing the matches.
     */
    func matches(for option: StringMatchingOption) -> [StringMatch] {
        var matches: [StringMatch] = []
        if let checkingType = option.checkingType {
            matches += self.results(for: checkingType)
        }
        if !option.tags.isEmpty {
            matches += self.results(for: option.tags)
        }
        matches += option.enumerationOptions.flatMap({ self.results(for:$0) })
        matches += option.patterns.flatMap({self.results(for: $0.pattern, type: $0.type)})
        matches = matches.sorted(by: \.range.lowerBound)
        return matches
    }
    
    /// Returns the individual words in the string.
    var words: [String] {
        matches(for: .word).compactMap(\.string)
    }

    /// Returns an array of lines in the string.
    var lines: [String] {
        matches(for: .line).compactMap(\.string)
    }

    /// Returns an array of sentences in the string.
    var sentences: [String] {
        matches(for: .sentence).compactMap(\.string)
    }
    
    /// All integer values inside the string.
    var integerValues: [Int] {
        matches(regex: "[-+]?\\d+.?\\d+").compactMap({Int($0.string)})
    }
    
    /// All double values inside the string.
    var doubleValues: [Double] {
        matches(regex: "[-+]?\\d+.?\\d+").compactMap({Double($0.string.replacingOccurrences(of: ",", with: "."))})
    }
    
    private var escapedPattern: String {
        NSRegularExpression.escapedPattern(for: self)
    }
    
    private func results(for pattern: String, type: StringMatch.ResultType) -> [StringMatch] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            return regex.matches(in: self, range: nsRange).compactMap({ StringMatch($0, string: self, type: type) }).uniqued()
        } catch {
            Swift.debugPrint(error)
            return []
        }
    }
    
    private func results(for tags: [NLTag]) -> [StringMatch] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = self
        let allTags = tagger.tags(in: range, unit: .word, scheme: .nameType, options: [.omitPunctuation,.omitWhitespace, .omitOther, .joinNames, .joinContractions ])
        return allTags.compactMap({if let tag = $0.0 { (tag, $0.1) } else { nil }}).filter({tags.contains($0.0)}).compactMap({StringMatch($0.0, string: self, range: $0.1)})
    }
    
    private func results(for option: NSString.EnumerationOptions) -> [StringMatch] {
        var matches: [StringMatch] = []
        enumerateSubstrings(in: startIndex..., options: option) { _, range, _, _ in
            if let result = StringMatch(option, string: self, range: range) {
                matches.append(result)
            }
        }
        return matches
    }
    
    private func results(for option: NSTextCheckingResult.CheckingType) -> [StringMatch] {
        var option = option
        let checkEmails = option.contains(.emailAddress)
        let checkLinks = option.contains(.link)
        if option.contains(.emailAddress) {
            option.remove(.emailAddress)
            option.insert(.link)
        }
        guard let detector = try? NSDataDetector(types: option.rawValue) else { return [] }
        return detector.matches(in: self, range: nsRange).flatMap({ match in
            (0..<match.numberOfRanges).compactMap {
                guard let range = Range(match.range(at: $0), in: self) else { return nil }
                if match.resultType == .link {
                    let isEmail = match.emailAddress != nil
                    if isEmail, checkEmails {
                        return StringMatch(StringMatch.ResultType.emailAddress, string: self, range: range)
                    } else if !isEmail, checkLinks {
                        return StringMatch(StringMatch.ResultType.link, string: self, range: range)
                    }
                    return nil
                }
                return StringMatch(match.resultType, string: self, range: range)
            }
        })
    }
}

public struct StringMatch: Hashable, CustomStringConvertible {
    /// The matched string.
    public let string: String
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The result type.
    public let type: ResultType
    /// The score or importance of the match.
    public let score: Int
    /// The matched groups of a regular expression match.
    public let group: [StringMatch]
    
    public var description: String {
        "[\(type.rawValue): \(string)]"
    }
    
    var withoutGroup: StringMatch {
        StringMatch(type, string: string, range: range)
    }
    
    init(_ type: ResultType, string: String, range: Range<String.Index>, group: [StringMatch] = []) {
        self.type = type
        self.string = String(string[range])
        self.range = range
        self.score = string.distance(from: range.lowerBound, to: range.upperBound)
        self.group = group
    }
    
    init?(_ result: NSTextCheckingResult, string: String, type: ResultType = .regularExpression) {
        var matches: [StringMatch] = (0..<result.numberOfRanges).compactMap {
            guard let range = Range(result.range(at: $0), in: string) else { return nil }
            return StringMatch(type, string: string, range: range)
        }
        guard let first = matches.first else { return nil }
        self.init(type, string: string, range: first.range, group: Array(matches.dropFirst()))
    }
    
    init?(_ tag: NLTag, string: String, range: Range<String.Index>) {
        guard let type = ResultType(tag: tag) else { return nil }
        self.init(type, string: string, range: range)
    }
    
    init?(_ enumerationOptions: NSString.EnumerationOptions, string: String, range: Range<String.Index>) {
        guard let type = ResultType(enumerationOptions: enumerationOptions) else { return nil }
        self.init(type, string: string, range: range)
    }
    
    init?(_ checkingType: NSTextCheckingResult.CheckingType, string: String, range: Range<String.Index>) {
        guard let type = ResultType(checkingType: checkingType) else { return nil }
        self.init(type, string: string, range: range)
    }
    
    /// The type of the matched string.
    public enum ResultType: String, Hashable {
        /// Adverb.
        case adverb
        /// Adjective.
        case adjective
        /// Noun.
        case noun
        /// Number.
        case number
        /// Verb.
        case verb
        /// Characters.
        case characters
        /// Word.
        case word
        /// Sentence.
        case sentence
        /// Line.
        case line
        /// Paragraph.
        case paragraph
        /// Date.
        case date
        /// Personal name.
        case personalName
        /// Organization name.
        case organizationName
        /// Place name.
        case placeName
        /// Phone number.
        case phoneNumber
        /// Email address.
        case emailAddress
        /// URL.
        case link
        /// Regular Expression.
        case regularExpression = "regex"
        /// Orthography.
        case orthography
        /// Address.
        case address
        /// Hashtag (e.g. `#hashtag`).
        case hashtag
        /// Reply (e.g. `@username`).
        case reply
            
        init?(enumerationOptions: NSString.EnumerationOptions) {
            switch enumerationOptions {
            case .byWords: self = .word
            case .byLines: self = .line
            case .byComposedCharacterSequences: self = .characters
            case .byParagraphs: self = .paragraph
            case .bySentences: self = .sentence
            default: return nil

            }
        }
        
        init?(tag: NLTag) {
            switch tag {
            case .placeName: self = .placeName
            case .personalName: self = .personalName
            case .organizationName: self = .organizationName
            case .number: self = .number
            case .adverb: self = .adverb
            case .noun: self = .noun
            case .adjective: self = .adjective
            case .verb: self = .verb
            default: return nil
            }
        }
        
        init?(checkingType: NSTextCheckingResult.CheckingType) {
            switch checkingType {
            case .orthography: self = .orthography
            case .regularExpression: self = .regularExpression
            case .date: self = .date
            case .emailAddress: self = .emailAddress
            case .link: self = .link
            case .phoneNumber: self = .phoneNumber
            case .address: self = .address
            default: return nil
            }
        }
    }
}

extension Collection where Element == StringMatch {
    /// The matched strings.
    public var strings: [String] {
        compactMap({$0.string})
    }
    
    /// The ranges of the matched strings.
    public var ranges: [Range<String.Index>] {
        compactMap({$0.range})
    }
}

extension String {
    public struct StringMatchingOption: OptionSet, Codable {
        
        public static let adverb = StringMatchingOption(rawValue: 1 << 0)
        public static let adjective = StringMatchingOption(rawValue: 1 << 1)
        public static let noun = StringMatchingOption(rawValue: 1 << 2)
        public static let number = StringMatchingOption(rawValue: 1 << 3)
        public static let verb = StringMatchingOption(rawValue: 1 << 4)
        public static let characters = StringMatchingOption(rawValue: 1 << 5)
        public static let word = StringMatchingOption(rawValue: 1 << 6)
        public static let sentence = StringMatchingOption(rawValue: 1 << 7)
        public static let line = StringMatchingOption(rawValue: 1 << 8)
        public static let paragraph = StringMatchingOption(rawValue: 1 << 9)
        public static let date = StringMatchingOption(rawValue: 1 << 10)
        public static let personalName = StringMatchingOption(rawValue: 1 << 11)
        public static let organizationName = StringMatchingOption(rawValue: 1 << 12)
        public static let placeName = StringMatchingOption(rawValue: 1 << 13)
        public static let phoneNumber = StringMatchingOption(rawValue: 1 << 14)
        public static let emailAddress = StringMatchingOption(rawValue: 1 << 15)
        public static let link = StringMatchingOption(rawValue: 1 << 16)
        public static let regularExpression = StringMatchingOption(rawValue: 1 << 17)
        public static let orthography = StringMatchingOption(rawValue: 1 << 18)
        public static let address = StringMatchingOption(rawValue: 1 << 19)
        public static let hashtag = StringMatchingOption(rawValue: 1 << 20)
        public static let reply = StringMatchingOption(rawValue: 1 << 21)

        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
        
        var tags: [NLTag] {
            var tags: [NLTag] = []
            if self.contains(.placeName) { tags.append(.placeName) }
            if self.contains(.personalName) { tags.append(.personalName) }
            if self.contains(.organizationName) { tags.append(.organizationName) }
            if self.contains(.number) { tags.append(.number) }
            if self.contains(.adverb) { tags.append(.adverb) }
            if self.contains(.noun) { tags.append(.noun) }
            if self.contains(.adjective) { tags.append(.adjective) }
            if self.contains(.verb) { tags.append(.verb) }
            return tags
        }
        
        var checkingType: NSTextCheckingResult.CheckingType? {
            var checkingType: NSTextCheckingResult.CheckingType?
            func insert(_ type: NSTextCheckingResult.CheckingType) {
                if checkingType != nil {
                    checkingType?.insert(type)
                } else {
                    checkingType = type
                }
            }
            if self.contains(.orthography) { insert(.orthography) }
            if self.contains(.regularExpression) { insert(.regularExpression) }
            if self.contains(.date) { insert(.date) }
            if self.contains(.emailAddress) { insert(.emailAddress) }
            if self.contains(.link) { insert(.link) }
            if self.contains(.phoneNumber) { insert(.phoneNumber) }
            if self.contains(.address) { insert(.address) }
            return checkingType
        }
        
        var enumerationOptions: [NSString.EnumerationOptions] {
            var options: [NSString.EnumerationOptions] = []
            if self.contains(.word) { options.append(.byWords) }
            if self.contains(.line) { options.append(.byLines) }
            if self.contains(.characters) { options.append(.byComposedCharacterSequences) }
            if self.contains(.paragraph) { options.append(.byParagraphs) }
            if self.contains(.sentence) { options.append(.bySentences) }
            return options
        }
        
        var patterns: [(pattern: String, type: StringMatch.ResultType)] {
            var patterns: [(pattern: String, type: StringMatch.ResultType)] = []
            if contains(.hashtag) { patterns.append(("(#+[a-zA-Z0-9(_)]{1,})", .hashtag)) }
            if contains(.reply) { patterns.append((#"(?<![\w])@[\S]*\b"#, .reply)) }
            return patterns
        }
    }
}
