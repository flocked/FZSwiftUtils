//
//  TextCheckingResult.swift
//  
//
//  Created by Florian Zand on 08.04.24.
//

import Foundation
import NaturalLanguage

extension String {
    public func matchesNew(for option: StringMatchingOption) -> [TextCheckingResult] {
        var results: [TextCheckingResult] = []
        if let checkingType = option.checkingType {
            results += self.results(for: checkingType)
        }
        if !option.tags.isEmpty {
            results += self.results(for: option.tags)
        }
        results += option.enumerationOptions.flatMap({ self.results(for:$0) })
        results = results.sorted(by: \.range.lowerBound)
        return results
    }
    
    private func results(for tags: [NLTag]) -> [TextCheckingResult] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = self
        let allTags = tagger.tags(in: range, unit: .word, scheme: .nameType, options: [.omitPunctuation,.omitWhitespace, .omitOther, .joinNames, .joinContractions ])
        return allTags.compactMap({if let tag = $0.0 { (tag, $0.1) } else { nil }}).filter({tags.contains($0.0)}).compactMap({TextCheckingResult($0.0, string: self, range: $0.1)})
    }
    
    private func results(for option: NSString.EnumerationOptions) -> [TextCheckingResult] {
        var matches: [TextCheckingResult] = []
        enumerateSubstrings(in: startIndex..., options: option) { _, range, _, _ in
            if let result = TextCheckingResult(option, string: self, range: range) {
                matches.append(result)
            }
        }
        return matches
    }
    
    private func results(for option: NSTextCheckingResult.CheckingType) -> [TextCheckingResult] {
        var option = option
        let checkOnlyEmail = option.contains(.emailAddress) && !option.contains(.link)
        if option.contains(.emailAddress) {
            option.remove(.emailAddress)
            option.insert(.link)
        }
        guard let detector = try? NSDataDetector(types: option.rawValue) else { return [] }
        return detector.matches(in: self, range: nsRange).flatMap({ match in
            (0..<match.numberOfRanges).compactMap {
                guard option.contains(match.resultType) else { return nil }
                if match.resultType == .link, checkOnlyEmail, match.emailAddress == nil { return nil }
                guard let range = Range(match.range(at: $0), in: self) else { return nil }
                
                if match.resultType == .date && match.date == nil { return nil }
                if match.resultType == .link && match.url == nil { return nil }
                if match.resultType == .phoneNumber && match.phoneNumber == nil { return nil }
                if match.resultType == .address && match.addressComponents == nil { return nil }
                if match.resultType == .orthography && match.orthography == nil { return nil }
                if match.resultType == .date {
                    Swift.print(String(self[range]), match.date ?? "nil")
                }
                return TextCheckingResult(match.resultType, string: self, range: range)
            }
        })
    }
    
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
        public static let quote = StringMatchingOption(rawValue: 1 << 18)
        public static let orthography = StringMatchingOption(rawValue: 1 << 19)
        public static let address = StringMatchingOption(rawValue: 1 << 20)
        
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
            if self.contains(.quote) { insert(.quote) }
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
    }
}

public struct TextCheckingResult: Hashable {
    /// The matched string.
    public let string: String
    /// The range of the matched string within the source string.
    public let range: Range<String.Index>
    /// The result type.
    public let type: ResultType
    /// The score or importance of the match.
    public let score: Int
    
    init?(_ tag: NLTag, string: String, range: Range<String.Index>) {
        guard let type = ResultType(tag: tag) else { return nil }
        self.type = type
        self.string = String(string[range])
        self.range = range
        self.score = string.distance(from: range.lowerBound, to: range.upperBound)
    }
    
    init?(_ enumerationOptions: NSString.EnumerationOptions, string: String, range: Range<String.Index>) {
        guard let type = ResultType(enumerationOptions: enumerationOptions) else { return nil }
        self.type = type
        self.string = String(string[range])
        self.range = range
        self.score = string.distance(from: range.lowerBound, to: range.upperBound)
    }
    
    init?(_ checkingType: NSTextCheckingResult.CheckingType, string: String, range: Range<String.Index>) {
        guard let type = ResultType(checkingType: checkingType) else { return nil }
        self.type = type
        self.string = String(string[range])
        self.range = range
        self.score = string.distance(from: range.lowerBound, to: range.upperBound)
    }
    
    public enum ResultType: Int, Hashable {
        case adverb
        case adjective
        case noun
        case number
        case verb
        case characters
        case word
        case sentence
        case line
        case paragraph
        case date
        case personalName
        case organizationName
        case placeName
        case phoneNumber
        case emailAddress
        case link
        case regularExpression
        case quote
        case orthography
        case address
            
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
            case .quote: self = .quote
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
