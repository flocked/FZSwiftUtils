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

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - range: The range of the string to search, or `nil` to search everywhere.
        - options: Options for matching.
     
     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(pattern: String, in range: Range<Index>? = nil, options: NSRegularExpression.Options = []) -> [StringMatch] {
        results(for: pattern, type: .regularExpression, options: options)
    }
    
    /**
     Returns the first match of the specified regular expression.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - range: The range of the string to search, or `nil` to search everywhere.
        - options: Options for matching.
     */
    func firstMatch(pattern: String, in range: Range<Index>? = nil, options: NSRegularExpression.Options = []) -> StringMatch? {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            guard let result = expression.firstMatch(in: self, range: nsRange) else { return nil }
            return StringMatch(result, string: self)
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    /**
     Enumerates the matches for the specified string.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - range: The range of the string to search, or `nil` to search everywhere.
        - options: Options for matching.
     */
    func enumerateMatches(pattern: String, in range: Range<Index>? = nil, options: NSRegularExpression.Options = [], update: ((_ match: StringMatch?, _ completed: Bool)->(Bool))) {
        let matchOptions: NSRegularExpression.MatchingOptions =  [.reportProgress, .reportCompletion]
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            expression.enumerateMatches(in: self, options: matchOptions, range: range?.nsRange(in: self) ?? nsRange) { result, flags, stop in
                guard let result = result, let match = StringMatch(result, string: self) else { return }
                let completed = flags.contains(any: [.requiredEnd, .hitEnd, .internalError])
                if update(match, completed), !completed {
                    stop.pointee = true
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    /**
     A Boolean value indicating whether the string is matching the specified regular expression.

     - Parameters:
        - pattern: The regular expression pattern for validating.
        - range: The range of the string to search, or `nil` to search everywhere.
        - options: Options for matching.
     
     - Returns: `true` if the string is matching the regular expression, or `false` if the string isn't matching or the the expression is invalid.
     */
    func isMatching(pattern: String, in range: Range<Index>? = nil, options: NSRegularExpression.Options = []) -> Bool {
        firstMatch(pattern: pattern, in: range, options: options) != nil
    }
    
    /**
     Returns a new string containing matching regular expressions replaced with the template string.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - range: The range of the string to search, or `nil` to search everywhere.
        - template: The substitution template used when replacing matching instances.
        - options: Options for matching.
     
     - Returns: A string with matching regular expressions replaced by the template string, or `nil`, if the regular expression pattern is invalid.
     */
    func replace(pattern: String, in range: Range<Index>? = nil, with template: String, options: NSRegularExpression.Options = []) -> String? {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let replacedString = expression.stringByReplacingMatches(in: self, range: range?.nsRange(in: self) ?? nsRange, withTemplate: template)
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
        - range: The range of the string to search, or `nil` to search everywhere.
        - options: Options for matching.

     - Returns: An array of `StringMatch` objects representing the matches found.
     */
    func matches(between fromString: String, and toString: String, includingFromTo: Bool = false, in range: Range<Index>? = nil, options: NSRegularExpression.Options = []) -> [StringMatch] {
        let pattern = fromString.escapedPattern + "(.*?)" + toString.escapedPattern
        let matches = matches(pattern: pattern, in: range, options: options)
        return includingFromTo ? matches.compactMap({$0.withoutGroup}) : matches.compactMap({$0.groups.first})
    }
    
    /**
     Finds all matches in the string based on the given option.

     - Parameter option: The option for finding matches.
     - Returns: An array of `StringMatch` objects representing the matches.
     */
    func matches(for option: StringMatchingOption) -> [StringMatch] {
        var matches: [StringMatch] = []
        if let textCheckingType = option.textCheckingType {
            matches += self.results(for: textCheckingType)
        }
        if !option.nlTags.isEmpty {
            matches += self.results(for: option.nlTags)
        }
        matches += option.enumerationOptions.flatMap({ self.results(for:$0) })
        matches += option.regularExpressions.flatMap({self.results(for: $0.expression, type: $0.type)})
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
        matches(pattern: "[-+]?\\d+.?\\d+").compactMap({Int($0.string)})
    }
    
    /// All double values inside the string.
    var doubleValues: [Double] {
        matches(pattern: "[-+]?\\d+.?\\d+").compactMap({Double($0.string.replacingOccurrences(of: ",", with: "."))})
    }
    
    private var escapedPattern: String {
        NSRegularExpression.escapedPattern(for: self)
    }
    
    private func results(for pattern: String, in range: Range<Index>? = nil, type: StringMatch.ResultType, options: NSRegularExpression.Options = []) -> [StringMatch] {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            return expression.matches(in: self, range: range?.nsRange(in: self) ?? nsRange).compactMap({ StringMatch($0, string: self, type: type) }).uniqued()
        } catch {
            Swift.debugPrint(error)
            return []
        }
    }
    
    private func results(for tags: [NLTag]) -> [StringMatch] {
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = self
        let allTags = tagger.tags(in: range, unit: .word, scheme: .nameTypeOrLexicalClass, options: [.omitPunctuation,.omitWhitespace, .omitOther, .joinNames, .joinContractions])
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

/// A value representing a string match, such as a regular expression match.
public struct StringMatch: Hashable, CustomStringConvertible {
    /// The matched string.
    public let string: String
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The result type.
    public let type: ResultType
    /// The extracted components.
    public let components: Components
    /// The matched groups of a regular expression string match.
    public let groups: [StringMatch]
    /// The pattern of a regular expression match.
    public let regularExpression: String?
    
    /// Extracted components.
    public struct Components: Hashable {
        /// URL.
        public let url: URL?
        /// Date.
        public let date: Date?
        /// Time zone.
        public let timeZone: TimeZone?
        /// Date Duration.
        public let duration: TimeInterval
        /// Address.
        public let address: Address?
        /// Transit information, for example, flight information.
        public let transitInformation: TransitInformation?
        
        init(_ result: NSTextCheckingResult? = nil) {
            self.address = result?.resultType == .address ? Address(result!) : nil
            self.transitInformation = result?.resultType == .transitInformation ? TransitInformation(result!) : nil
            self.date = result?.date
            self.url = result?.url
            self.timeZone = result?.timeZone
            self.duration = result?.duration ?? 0
        }
        
        /// Address information.
        public struct Address: Hashable {
            public let name: String?
            public let jobTitle: String?
            public let street: String?
            public let city: String?
            public let state: String?
            public let zip: String?
            public let country: String?
            public let phone: String?
            
            init(_ result: NSTextCheckingResult) {
                self.name = result.addressComponents?[.name]
                self.jobTitle = result.addressComponents?[.jobTitle]
                self.street = result.addressComponents?[.street]
                self.city = result.addressComponents?[.city]
                self.state = result.addressComponents?[.state]
                self.zip = result.addressComponents?[.zip]
                self.country = result.addressComponents?[.country]
                self.phone = result.addressComponents?[.phone]
            }
        }
        
        /// Transit information, for example, flight information.
        public struct TransitInformation: Hashable {
            public let airline: String?
            public let flight: String?
            
            init(_ result: NSTextCheckingResult) {
                self.airline = result.addressComponents?[.airline]
                self.flight = result.addressComponents?[.flight]
            }
        }
    }
    
    public var description: String {
        return "StringMatch(\(type.rawValue): \"\(string)\")"
    }
    
    var withoutGroup: StringMatch {
        StringMatch(type, string: string, range: range)
    }
    
    init(_ type: ResultType, string: String, range: Range<String.Index>, groups: [StringMatch] = [], result: NSTextCheckingResult? = nil) {
        self.type = type
        self.string = String(string[range])
        self.range = range
        self.groups = groups
        if let result = result {
            components = Components(result)
            regularExpression = result.regularExpression?.pattern
        } else {
            components = Components()
            regularExpression = nil
        }
    }
    
    init?(_ result: NSTextCheckingResult, string: String, type: ResultType = .regularExpression) {
        let matches: [StringMatch] = (0..<result.numberOfRanges).compactMap {
            guard let range = Range(result.range(at: $0), in: string) else { return nil }
            return StringMatch(type, string: string, range: range)
        }
        guard let first = matches.first else { return nil }
        self.init(type, string: string, range: first.range, groups: Array(matches.dropFirst()), result: result)
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
        /// Regular Expression.
        case regularExpression
        /// URL.
        case link
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
        /// Address.
        case address
        /// Transit information, for example, flight information.
        case transitInformation
        /// Hashtag (e.g. `#hashtag`).
        case hashtag
        /// Reply (e.g. `@username`).
        case reply
        
        /// Character.
        case character
        /// Word.
        case word
        /// Sentence.
        case sentence
        /// Line.
        case line
        /// Paragraph.
        case paragraph
        
        /// Adverb.
        case adverb
        /// Adjective.
        case adjective
        /// Noun.
        case noun
        /// Pronoun.
        case pronoun
        /// Preposition.
        case preposition
        /// Conjunction.
        case conjunction
        /// Interjection.
        case interjection
        /// Determiner.
        case determiner
        /// Number.
        case number
        /// Verb.
        case verb
            
        init?(enumerationOptions: NSString.EnumerationOptions) {
            switch enumerationOptions {
            case .byWords: self = .word
            case .byLines: self = .line
            case .byComposedCharacterSequences: self = .character
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
            case .pronoun: self = .pronoun
            case .preposition: self = .preposition
            case .conjunction: self = .conjunction
            case .interjection: self = .interjection
            case .determiner: self = .determiner
            default: return nil
            }
        }
                
        init?(checkingType: NSTextCheckingResult.CheckingType) {
            switch checkingType {
            case .date: self = .date
            case .emailAddress: self = .emailAddress
            case .link: self = .link
            case .phoneNumber: self = .phoneNumber
            case .address: self = .address
            case .transitInformation: self = .transitInformation
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
    /// Option for finding matches in a string.
    public struct StringMatchingOption: OptionSet, Codable {
        /// Noun.
        public static let noun = StringMatchingOption(rawValue: 1 << 0)
        /// Verb.
        public static let verb = StringMatchingOption(rawValue: 1 << 1)
        /// Adjective.
        public static let adjective = StringMatchingOption(rawValue: 1 << 2)
        /// Adverb.
        public static let adverb = StringMatchingOption(rawValue: 1 << 3)
        /// Pronoun.
        public static let pronoun = StringMatchingOption(rawValue: 1 << 4)
        /// Determiner.
        public static let determiner = StringMatchingOption(rawValue: 1 << 5)
        /// Preposition.
        public static let preposition = StringMatchingOption(rawValue: 1 << 6)
        /// Conjunction.
        public static let conjunction = StringMatchingOption(rawValue: 1 << 7)
        /// interjection
        public static let interjection = StringMatchingOption(rawValue: 1 << 8)
        /// Number.
        public static let number = StringMatchingOption(rawValue: 1 << 9)
        /// All lexical matches.
        public static var allLexical: StringMatchingOption = [.noun, .verb, .adjective, .adverb, .pronoun, .determiner, .preposition, .conjunction, .interjection, .number]
        
        /// Characters.
        public static let character = StringMatchingOption(rawValue: 1 << 10)
        /// Word.
        public static let word = StringMatchingOption(rawValue: 1 << 11)
        /// Sentence.
        public static let sentence = StringMatchingOption(rawValue: 1 << 12)
        /// Line.
        public static let line = StringMatchingOption(rawValue: 1 << 13)
        /// Paragraph.
        public static let paragraph = StringMatchingOption(rawValue: 1 << 14)
        
        /// Date.
        public static let date = StringMatchingOption(rawValue: 1 << 15)
        /// URL.
        public static let link = StringMatchingOption(rawValue: 1 << 16)
        /// Personal name.
        public static let personalName = StringMatchingOption(rawValue: 1 << 17)
        /// Organization name.
        public static let organizationName = StringMatchingOption(rawValue: 1 << 18)
        /// Place name.
        public static let placeName = StringMatchingOption(rawValue: 1 << 19)
        /// Phone Number.
        public static let phoneNumber = StringMatchingOption(rawValue: 1 << 20)
        /// Email Address.
        public static let emailAddress = StringMatchingOption(rawValue: 1 << 21)
        /// Address.
        public static let address = StringMatchingOption(rawValue: 1 << 22)
        /// Transit information, e.g., flight information.
        public static let transitInformation = StringMatchingOption(rawValue: 1 << 23)
        /// Hashtag, e.g. "#hashtag".
        public static let hashtag = StringMatchingOption(rawValue: 1 << 24)
        /// Reply, e.g. "@username".
        public static let reply = StringMatchingOption(rawValue: 1 << 25)
        
        /// Regular Expression.
        public static let regularExpression = StringMatchingOption(rawValue: 1 << 26)

        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
        
        var nlTags: [NLTag] {
            var tags: [NLTag] = []
            if contains(.placeName) { tags.append(.placeName) }
            if contains(.personalName) { tags.append(.personalName) }
            if contains(.organizationName) { tags.append(.organizationName) }
            if contains(.noun) { tags.append(.noun) }
            if contains(.verb) { tags.append(.verb) }
            if contains(.adjective) { tags.append(.adjective) }
            if contains(.adverb) { tags.append(.adverb) }
            if contains(.pronoun) { tags.append(.pronoun) }
            if contains(.determiner) { tags.append(.determiner) }
            if contains(.preposition) { tags.append(.preposition) }
            if contains(.conjunction) { tags.append(.conjunction) }
            if contains(.interjection) { tags.append(.interjection) }
            return tags
        }
                        
        var textCheckingType: NSTextCheckingResult.CheckingType? {
            var checkingType: NSTextCheckingResult.CheckingType?
            func insert(_ type: NSTextCheckingResult.CheckingType) {
                if checkingType != nil {
                    checkingType?.insert(type)
                } else {
                    checkingType = type
                }
            }
            if contains(.regularExpression) { insert(.regularExpression) }
            if contains(.date) { insert(.date) }
            if contains(.emailAddress) { insert(.emailAddress) }
            if contains(.link) { insert(.link) }
            if contains(.phoneNumber) { insert(.phoneNumber) }
            if contains(.address) { insert(.address) }
            if contains(.transitInformation) { insert(.transitInformation) }
            return checkingType
        }
        
        var enumerationOptions: [NSString.EnumerationOptions] {
            var options: [NSString.EnumerationOptions] = []
            if contains(.word) { options.append(.byWords) }
            if contains(.line) { options.append(.byLines) }
            if contains(.character) { options.append(.byComposedCharacterSequences) }
            if contains(.paragraph) { options.append(.byParagraphs) }
            if contains(.sentence) { options.append(.bySentences) }
            return options
        }
        
        var regularExpressions: [(expression: String, type: StringMatch.ResultType)] {
            var patterns: [(expression: String, type: StringMatch.ResultType)] = []
            if contains(.hashtag) { patterns.append(("(#+[a-zA-Z0-9(_)]{1,})", .hashtag)) }
            if contains(.reply) { patterns.append((#"(?<![\w])@[\S]*\b"#, .reply)) }
            if contains(.number) { patterns.append((#"\d+(?:\.\d+)?"#, .number)) }
            return patterns
        }
    }
}
