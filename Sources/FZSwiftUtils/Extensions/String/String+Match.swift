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
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: An array of ``RegexMatch``  representing the matches found. It returns an empty array, if the pattern is invalid.
     */
    func matches(pattern: String, options: NSRegularExpression.Options = []) -> [RegexMatch] {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            return expression.matches(in: self, range: nsRange).compactMap {
                RegexMatch($0, regex: expression, string: self)
            }
        } catch {
            Swift.debugPrint(error)
            return []
        }
    }
    
    /**
     Returns the number of matches of the regular expression.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: The number of matches of the regular expression. It returns `0`, if the pattern is invalid.
     */
    func numberOfMatches(pattern: String, options: NSRegularExpression.Options = []) -> Int {
        do {
        return try NSRegularExpression(pattern: pattern, options: options).numberOfMatches(in: self, options: [], range: nsRange)
        } catch {
            debugPrint(error)
            return 0
        }
    }
    
    /**
     Returns the first match of the specified regular expression.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: The first match for the regular expression. It returns `nil`, if the pattern is invalid.
     */
    func firstMatch(pattern: String, options: NSRegularExpression.Options = []) -> RegexMatch? {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            guard let result = expression.firstMatch(in: self, range: nsRange) else {
                return nil
            }
            return RegexMatch(result, regex: expression, string: self)
        } catch {
            debugPrint(error)
            return nil
        }
     }
    
    /**
     Enumerates the matches for the specified regular expression pattern in the string.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
        - reportProgress: A Boolean value indicating whether to report the progress. If `true`, the update handler is periodically called during long-running match operations.
        - block: The handler that is called whenever a new match is found with the following parameters:
            - match: The match that was found, or `nil` for a progress or completion event.
            - isCompleted: A Boolean value indicating whether matching has finished.
            - stop: Set this value to `true` to stop enumerating matches.
     */
    func enumerateMatches(pattern: String, options: NSRegularExpression.Options = [], reportProgress: Bool = false, using block: (_ match: RegexMatch?, _ isFinished: Bool, _ stop: inout Bool) -> ()) {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            expression.enumerateMatches(in: self, options: reportProgress ? [.reportProgress, .reportCompletion] : [.reportCompletion], range: nsRange) { result, flags, stop in
                let completed = flags.contains(any: [.requiredEnd, .hitEnd, .internalError])
                let match = result.flatMap({ RegexMatch($0, regex: expression, string: self) })
                var shouldStop = false
                block(match, completed, &shouldStop)
                if shouldStop, !completed {
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
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: `true` if the string is matching the regular expression, or `false` if the string isn't matching or the the expression is invalid.
     */
    func isMatching(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        firstMatch(pattern: pattern, options: options) != nil
    }
    
    /**
     Returns a new string containing matching regular expressions replaced with the template string.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - template: The substitution template used when replacing matching instances.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: A string with matching regular expressions replaced by the template string, or `nil`, if the regular expression pattern is invalid.
     */
    func replace(pattern: String, with template: String, options: NSRegularExpression.Options = []) -> String? {
        do {
            return try NSRegularExpression(pattern: pattern, options: options).stringByReplacingMatches(in: self, range: nsRange, withTemplate: template)
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    /**
     Finds all matches in the string based on the given option.

     - Parameter option: The option for finding matches.
     - Returns: An array of `StringMatch` objects representing the matches.
     */
    func matches(for option: StringMatchingOption) -> [StringMatch] {
        var matches: [StringMatch] = []
        
        if let textCheckingType = option.textCheckingType {
            matches += results(for: textCheckingType)
        }

        let (tags, tagScheme) = option.nlTags

        if !tags.isEmpty {
            matches += results(for: tags, tagScheme: tagScheme)
        }

        matches += option.enumerationOptions.flatMap {
            results(for: $0)
        }

        return matches.sorted(by: \.range.lowerBound)
    }
    
    /// Returns the individual words in the string.
    var words: [String] {
        matches(for: .word).map({ String($0.string) })
    }

    /// Returns an array of sentences in the string.
    var sentences: [String] {
        matches(for: .sentence).map({ String($0.string) })
    }
    
    /// All integer values inside the string.
    var integerValues: [Int] {
        matches(pattern: "[-+]?\\d+.?\\d+").compactMap { Int($0.string) }
    }
    
    /// All double values inside the string.
    var doubleValues: [Double] {
        matches(pattern: "[-+]?\\d+.?\\d+").compactMap { Double($0.string.replacingOccurrences(of: ",", with: ".")) }
    }
    
    fileprivate var escapedPattern: String {
        NSRegularExpression.escapedPattern(for: self)
    }
    
    fileprivate func results(for tags: [NLTag], tagScheme: NLTagScheme, range: Range<Index>? = nil) -> [StringMatch] {
        let tagger = NLTagger(tagSchemes: [tagScheme])
        tagger.string = self
        let allTags = tagger.tags(in: range ?? startIndex..<endIndex, unit: .word, scheme: tagScheme, options: [.omitPunctuation, .omitWhitespace, .omitOther, .joinNames, .joinContractions])
        return allTags.compactMap { if let tag = $0.0 { (tag, $0.1) } else { nil }}.filter { tags.contains($0.0) }.compactMap { StringMatch($0.0, string: self, range: $0.1) }
    }
    
    fileprivate func results(for option: NSString.EnumerationOptions, range: Range<String.Index>? = nil) -> [StringMatch] {
        var matches: [StringMatch] = []
        enumerateSubstrings(in: range ?? startIndex..<endIndex, options: option) { _, range, _, _ in
            if let result = StringMatch(option, string: self, range: range) {
                matches.append(result)
            }
        }
        return matches
    }
    
    fileprivate func results(for option: NSTextCheckingResult.CheckingType, range: Range<String.Index>? = nil) -> [StringMatch] {
        var option = option
        let checkEmails = option.contains(.emailAddress)
        let checkLinks = option.contains(.link)
        if option.contains(.emailAddress) {
            option.remove(.emailAddress)
            option.insert(.link)
        }
        guard let detector = try? NSDataDetector(types: option.rawValue) else { return [] }
        return detector.matches(in: self, range: range?.nsRange(in: self) ?? nsRange).flatMap { match in
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
        }
    }
}

/// A value representing a regex string match.
public struct RegexMatch: Hashable, CustomStringConvertible {
    /// The matched string.
    public let string: Substring
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The matched groups .
    public let groups: [RegexMatch?]

    private let regularExpression: NSRegularExpression?
    
    init?(_ result: NSTextCheckingResult, regex: NSRegularExpression, string: String) {
        guard let range = Range(result.range, in: string) else { return nil }
        self.string = string[range]
        self.range = range
        self.regularExpression = regex
        self.groups = (1..<result.numberOfRanges).compactMap({
            if let range = Range(result.range(at: $0), in: string) { return RegexMatch(string, range: range)
            } else { return nil }
        })
    }
    
    init(_ string: String, range: Range<String.Index>) {
        self.string = string[range]
        self.range = range
        self.groups = []
        self.regularExpression = nil
    }

    /// Returns the matched group at the specified index of a regular expression string match.
    public subscript(groupIndex: Int) -> RegexMatch? {
        groups[safe: groupIndex] ?? nil
    }
    
    /// Returns the matched group with the specified name of a regular expression string match.
    public subscript(groupName: String) -> RegexMatch? {
        group(named: groupName)
    }
    
    /// Returns the matched group at the specified index.
    public func group(at index: Int) -> RegexMatch? {
        groups[safe: index] ?? nil
    }
    
    /// The matched group with the specified name of a regular expression string match.
    public func group(named name: String) -> RegexMatch? {
        guard let index = regularExpression?.captureGroupIndex(withName: name) else { return nil }
        return group(at: index + 1)
    }
    
    public var description: String {
        guard !groups.isEmpty else {
            return "RegexMatch(\(range), \"\(string)\")"
        }
        var strings = ["RegexMatch(\(range), \"\(string)\","]
        strings += groups.enumerated().map { index, group in
            group.map {
                "  \(index + 1): \($0.range), \"\($0.string)\""
            } ?? "  \(index + 1): nil"
        }
        strings += ")"
        return strings.joined(separator: "\n")
    }
}

/// A value representing a string match, such as a regular expression match.
public struct StringMatch: Hashable, CustomStringConvertible {
    /// The matched string.
    public let string: Substring
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The result type.
    public let type: ResultType
    /// The extracted components.
    public let components: Components
    
    /// Extracted components.
    public struct Components: Hashable {
        /// URL.
        public let url: URL?
        /// Date.
        public let date: Date?
        /// Time zone.
        public let timeZone: TimeZone?
        /// Date Duration.
        public let duration: TimeDuration
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
            self.duration = .seconds(result?.duration ?? 0)
        }
        
        /// A postal address detected within a string.
        public struct Address: Hashable {
            /// The name associated with the address.
            public let name: String?
            /// The job title associated with the address.
            public let jobTitle: String?
            /// The street address.
            public let street: String?
            /// The city.
            public let city: String?
            /// The state, province, or region.
            public let state: String?
            /// The postal or ZIP code.
            public let zip: String?
            /// The country.
            public let country: String?
            /// The phone number associated with the address.
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
        
        /// Transit information, for example, flight information detected within a string.
        public struct TransitInformation: Hashable {
            /// The airline identifier.
            public let airline: String?
            /// The flight number.
            public let flight: String?
            
            init(_ result: NSTextCheckingResult) {
                self.airline = result.components?[.airline]
                self.flight = result.components?[.flight]
            }
        }
    }
    
    public var description: String {
        "[\(range), \(string)]"
    }
    
    init(_ type: ResultType, string: String, range: Range<String.Index>, result: NSTextCheckingResult? = nil) {
        self.type = type
        self.string = string[range]
        self.range = range
        self.components = result.map { Components($0) } ?? Components()
    }
    
    init(_ type: ResultType, string: Substring, range: Range<String.Index>) {
        self.type = type
        self.string = string
        self.range = range
        self.components = .init()
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
        /// Between
        case between
            
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

public extension Collection where Element == StringMatch {
    /// The matched strings.
    var strings: [Substring] {
        compactMap { $0.string }
    }
    
    /// The ranges of the matched strings.
    var ranges: [Range<String.Index>] {
        compactMap { $0.range }
    }
}

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
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
        
    var nlTags: (tags: [NLTag], tagScheme: NLTagScheme) {
        var tags: [NLTag] = []
        if contains(.placeName) { tags.append(.placeName) }
        if contains(.personalName) { tags.append(.personalName) }
        if contains(.organizationName) { tags.append(.organizationName) }
        let count = tags.count
        if contains(.noun) { tags.append(.noun) }
        if contains(.verb) { tags.append(.verb) }
        if contains(.adjective) { tags.append(.adjective) }
        if contains(.adverb) { tags.append(.adverb) }
        if contains(.pronoun) { tags.append(.pronoun) }
        if contains(.determiner) { tags.append(.determiner) }
        if contains(.preposition) { tags.append(.preposition) }
        if contains(.conjunction) { tags.append(.conjunction) }
        if contains(.interjection) { tags.append(.interjection) }
        return (tags, tags.count != count ? count == 0 ? .lexicalClass : .nameTypeOrLexicalClass : .nameType)
    }
        
    /*
     et personalName = StringMatchingOption(rawValue: 1 << 17)
     /// Organization name.
     public static let organizationName = StringMatchingOption(rawValue: 1 << 18)
     /// Place name.
     public static let placeName
     */
                        
    var textCheckingType: NSTextCheckingResult.CheckingType? {
        var checkingType: NSTextCheckingResult.CheckingType = []
        if contains(.regularExpression) { checkingType.insert(.regularExpression) }
        if contains(.date) { checkingType.insert(.date) }
        if contains(.emailAddress) { checkingType.insert(.emailAddress) }
        if contains(.link) { checkingType.insert(.link) }
        if contains(.phoneNumber) { checkingType.insert(.phoneNumber) }
        if contains(.address) { checkingType.insert(.address) }
        if contains(.transitInformation) { checkingType.insert(.transitInformation) }
        return checkingType.rawValue != 0 ? checkingType : nil
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

public extension StringProtocol {
    /// Returns an array of lines in the string.
    var lines: [String] {
        var lines: [String] = []
        enumerateLines { line, _ in
            lines += line
        }
        if last?.isNewline == true {
            lines += ""
        }
        return lines
    }
}

public extension Substring {
    /**
     Finds all matches in the string based on the provided regular expression pattern.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: An array of `StringMatch` objects representing the matches found. It returns an empty array, if the pattern is invalid.
     */
    func matches(pattern: String, options: NSRegularExpression.Options = []) -> [RegexMatch] {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let string = String(base)
            let range = NSRange(startIndex..<endIndex, in: string)
            return expression.matches(in: string, range: range).compactMap { RegexMatch($0, regex: expression, string: string) }
        } catch {
            Swift.debugPrint(error)
            return []
        }
    }
    
    /**
     Returns the number of matches of the regular expression.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: The number of matches of the regular expression. It returns `0`, if the pattern is invalid.
     */
    func numberOfMatches(pattern: String, options: NSRegularExpression.Options = []) -> Int {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let string = String(base)
            let range = NSRange(startIndex..<endIndex, in: string)
            return expression.numberOfMatches(in: string, options: [], range: range)
        } catch {
            debugPrint(error)
            return 0
        }
    }
    
    /**
     Returns the first match of the specified regular expression.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: The first match for the regular expression. It returns `nil`, if the pattern is invalid.
     */
    func firstMatch(pattern: String, options: NSRegularExpression.Options = []) -> RegexMatch? {
        do {
            let string = String(base)
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(startIndex..<endIndex, in: string)

            guard let result = expression.firstMatch(in: string, range: range) else {
                return nil
            }

            return RegexMatch(result, regex: expression, string: string)
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    /**
     Enumerates the matches for the specified regular expression pattern in the string.
     
     - Parameters:
        - pattern: The regular expression pattern to search for.
        - options: The regular expression options that are applied to the expression during matching.
        - reportProgress: A Boolean value indicating whether to report the progress. If `true`, the update handler is periodically called during long-running match operations.
        - block: The handler that is called whenever a new match is found with the following parameters:
            - match: The match that was found, or `nil` for a progress or completion event.
            - isCompleted: A Boolean value indicating whether matching has finished.
            - stop: Set this value to `true` to stop enumerating matches.
     */
    func enumerateMatches(pattern: String, options: NSRegularExpression.Options = [], reportProgress: Bool = false, using block: (_ match: RegexMatch?, _ isFinished: Bool, _ stop: inout Bool) -> ()) {
        do {
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let string = String(base)
            let range = NSRange(startIndex..<endIndex, in: string)
            expression.enumerateMatches(in: string, options: reportProgress ? [.reportProgress, .reportCompletion] : [.reportCompletion], range: range) { result, flags, stop in
                let completed = flags.contains(any: [.requiredEnd, .hitEnd, .internalError])
                let match = result.flatMap({ RegexMatch($0, regex: expression, string: string) })
                var shouldStop = false
                block(match, completed, &shouldStop)
                if shouldStop, !completed {
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
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: `true` if the string is matching the regular expression, or `false` if the string isn't matching or the the expression is invalid.
     */
    func isMatching(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        firstMatch(pattern: pattern, options: options) != nil
    }
    
    /**
     Returns a new string containing matching regular expressions replaced with the template string.

     - Parameters:
        - pattern: The regular expression pattern to search for.
        - template: The substitution template used when replacing matching instances.
        - options: The regular expression options that are applied to the expression during matching.
     
     - Returns: A string with matching regular expressions replaced by the template string, or `nil`, if the regular expression pattern is invalid.
     */
    func replace(pattern: String, with template: String, options: NSRegularExpression.Options = []) -> String? {
        do {
            let string = String(base)
            let expression = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(startIndex..<endIndex, in: string)
            return expression.stringByReplacingMatches(in: string, range: range, withTemplate: template)
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    /**
     Finds all matches in the string based on the given option.

     - Parameter option: The option for finding matches.
     - Returns: An array of `StringMatch` objects representing the matches.
     */
    func matches(for option: StringMatchingOption) -> [StringMatch] {
        var matches: [StringMatch] = []
        let string = String(base)
        let range = startIndex..<endIndex
        
        if let textCheckingType = option.textCheckingType {
            matches += string.results(for: textCheckingType, range: range)
        }

        let (tags, tagScheme) = option.nlTags

        if !tags.isEmpty {
            matches += string.results(for: tags, tagScheme: tagScheme, range: range)
        }

        matches += option.enumerationOptions.flatMap {
            string.results(for: $0, range: range)
        }

        return matches.sorted(by: \.range.lowerBound)
    }
}

public extension StringProtocol where SubSequence == Substring {
    
    /**
     Finds the first substring delimited by the specified start and end delimiters.

     - Parameters:
        - startDelimiter: The string that marks the beginning of a match.
        - endDelimiter: The string that marks the end of a match.
        - includingDelimiters: A Boolean value indicating whether each match includes the start and end delimiters.
        - allowsNesting: A Boolean value indicating whether nested delimiter pairs are treated as part of the same match.
        - options: The String options to apply during matching.
        - locale: The locale to use.

     - Returns: A ``StringMatch`` representing the first match found.
     */
    func firstMatch<S1: StringProtocol, S2: StringProtocol>(between startDelimiter: S1, and endDelimiter: S2, includeDelimiters: Bool = false, options: String.CompareOptions = [], locale: Locale? = nil) -> StringMatch? {
        guard !startDelimiter.isEmpty, !endDelimiter.isEmpty else { return nil }
        guard let startRange = range(of: startDelimiter, options: options, locale: locale), let endRange = range(of: endDelimiter, options: options, range: startRange.upperBound..<endIndex, locale: locale) else { return nil }
        let range = (includeDelimiters ? startRange.lowerBound : startRange.upperBound)..<(includeDelimiters ? endRange.upperBound : endRange.lowerBound)
        return StringMatch(.between, string: self[range], range: range)
    }
    
    /**
     Finds all substrings delimited by the specified start and end delimiters.

     - Parameters:
        - startDelimiter: The string that marks the beginning of a match.
        - endDelimiter: The string that marks the end of a match.
        - includingDelimiters: A Boolean value indicating whether each match includes the start and end delimiters.
        - allowsNesting: A Boolean value indicating whether nested delimiter pairs are treated as part of the same match.
        - options: The String options to apply during matching.
        - locale: The locale to use.

     - Returns: An array of ``StringMatch`` representing the matches found.
     */
    func matches<S1: StringProtocol, S2: StringProtocol>(between startDelimiter: S1, and endDelimiter: S2, includeDelimiters: Bool = false, allowsNesting: Bool = false, options: String.CompareOptions = [], locale: Locale? = nil) -> [StringMatch] {
        guard !startDelimiter.isEmpty, !endDelimiter.isEmpty else { return [] }
        if allowsNesting {
            return nestedMatches(between: startDelimiter, and: endDelimiter, includeDelimiters: includeDelimiters, options: options, locale: locale)
        }
        var matches: [StringMatch] = []
        var searchStart = startIndex
        while let startRange = range(of: startDelimiter, options: options, range: searchStart..<endIndex, locale: locale), let endRange = range(of: endDelimiter, options: options, range: startRange.upperBound..<endIndex, locale: locale) {
            let range = (includeDelimiters ? startRange.lowerBound : startRange.upperBound)..<(includeDelimiters ? endRange.upperBound : endRange.lowerBound)
            matches += StringMatch(.between, string: self[range], range: range)
            searchStart = endRange.upperBound
        }
        return matches
    }
    
    fileprivate func nestedMatches<S1: StringProtocol, S2: StringProtocol>(between startDelimiter: S1, and endDelimiter: S2, includeDelimiters: Bool, options: String.CompareOptions, locale: Locale?) -> [StringMatch] {
        let options = options - [.backwards, .anchored]

        let sameDelimiter = startDelimiter.elementsEqual(endDelimiter)

        var matches: [StringMatch] = []
        var startStack: [Range<Index>] = []
        var searchStart = startIndex

        while searchStart < endIndex {
            let nextStart = range(of: startDelimiter, options: options, range: searchStart..<endIndex, locale: locale)
            if sameDelimiter {
                guard let delimiterRange = nextStart else { break }

                if let openingRange = startStack.popLast() {
                    let range = (includeDelimiters
                               ? openingRange.lowerBound
                               : openingRange.upperBound)..<(includeDelimiters
                               ? delimiterRange.upperBound
                               : delimiterRange.lowerBound)
                    matches += StringMatch(.between, string: self[range], range: range)
                } else {
                    startStack += delimiterRange
                }
                searchStart = delimiterRange.upperBound
                continue
            }

            let nextEnd = range(of: endDelimiter, options: options, range: searchStart..<endIndex, locale: locale)
            switch (nextStart, nextEnd) {
            case let (startRange?, endRange?)
                where startRange.lowerBound <= endRange.lowerBound:
                startStack += startRange
                searchStart = startRange.upperBound
            case let (_, endRange?):
                if let startRange = startStack.popLast() {
                    let range = (includeDelimiters
                               ? startRange.lowerBound
                               : startRange.upperBound)..<(includeDelimiters
                               ? endRange.upperBound
                               : endRange.lowerBound)
                    matches += StringMatch(.between, string: self[range], range: range)
                }
                searchStart = endRange.upperBound
            case let (startRange?, nil):
                startStack += startRange
                searchStart = startRange.upperBound
            case (nil, nil):
                return matches
            }
        }
        return matches
    }
}

fileprivate extension NSRegularExpression {
    func captureGroupIndex(withName name: String) -> Int? {
        Self.captureGroupNumberMethod?(self, Self.groupNameSelector, name)
    }
    
    static let captureGroupNumberMethod = instanceMethod(for: groupNameSelector, as: (@convention(c) (AnyObject, Selector, String) -> Int).self)
    
    static let groupNameSelector = NSSelectorFromString("_captureGroupNumberWithName:")
}
