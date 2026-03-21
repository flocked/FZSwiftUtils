//
//  Sequence+String.swift
//
//
//  Created by Florian Zand on 06.09.23.
//

import Foundation

public extension Sequence {
    /**
     Returns the elements whose string value produced by the given closure matches the specified string.
          
     - Parameters:
        - value: A closure that returns the string value to search for each element, or `nil` to exclude the element.
        - string: The string to search for in each element's value.
        - options: The options to use when comparing values.
        - range: The range of each value to search, or `nil` to search the full value.
        - locale: The locale to use for the comparison.
        - sortByBestMatch: A Boolean value that determines whether matching elements are sorted by best match.

         If `true`, matches are ordered by relevance, prioritizing exact matches, then prefix matches, then later substring matches.
     - Returns: An array containing the elements whose non-`nil` values match `string`.
     */
    func filter<S: StringProtocol, T: StringProtocol>(by value: (Element) throws -> (S?), matching string: T, options: String.CompareOptions = [], range: Range<S.Index>? = nil, locale: Locale? = nil, sortByBestMatch: Bool = false) rethrows -> [Element] {
        guard !string.isEmpty else { return [] }
        let results: [(element: Element, value: S, score: Int, offset: Int)] = try compactMap { element in
            guard let value = try value(element) else { return nil }
            guard let matchRange = value.range(of: string, options: options, range: range, locale: locale) else {
                return nil
            }
            if value.count == string.count {
                return (element, value, 0, 0)
            } else if matchRange.lowerBound == value.startIndex {
                return (element, value,  1, 0)
            } else {
                return (element, value, 2, value.distance(from: value.startIndex, to: matchRange.lowerBound))
            }
        }
        if !sortByBestMatch { return results.map(\.element) }
        return results.sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score < rhs.score
            }
            if lhs.offset != rhs.offset {
                return lhs.offset < rhs.offset
            }
            return lhs.value.compare(rhs.value, options: options, range: range, locale: locale) == .orderedAscending
        }.map(\.element)
    }
    
    /**
     Returns the elements whose string value at the given key path contains the specified string.
     
     - Parameters:
        - keyPath: A key path to the string value used for matching.
        - string: The string to search for in each element’s value.
        - options: The options to use when comparing values.
        - range: The range of each value to search., or `nil` to search the full value.
        - locale: The locale to use for the comparison.
        - sortByBestMatch: A Boolean value that determines whether matching elements are sorted by best match.
   
            If `true`, matches are ordered by relevance, prioritizing exact matches, then prefix matches, then later substring matches.
     - Returns: An array containing the elements whose values match `string`.
     */
    func filter<S: StringProtocol, T: StringProtocol>(by keyPath: KeyPath<Element, S>, matching string: T, options: String.CompareOptions = [],  range: Range<S.Index>? = nil, locale: Locale? = nil, sortByBestMatch: Bool = false) -> [Element] {
        filter(by: { $0[keyPath: keyPath] }, matching: string, options: options, range: range, locale: locale, sortByBestMatch: sortByBestMatch)
    }

    /**
     Returns the elements whose optional string value at the given key path contains the specified string.
     
     Elements whose value at `keyPath` is `nil` are excluded from the result.
     
     - Parameters:
        - keyPath: A key path to the optional string value used for matching.
        - string: The string to search for in each element’s value.
        - options: The options to use when comparing values.
        - range: The range of each value to search, or `nil` to search the full value.
        - locale: The locale to use for the comparison.
        - sortByBestMatch: A Boolean value that determines whether matching elements are sorted by best match.

            If `true`, matches are ordered by relevance, prioritizing exact matches, then prefix matches, then later substring matches.
     - Returns: An array containing the elements whose non-`nil` values match `string`.
     */
    func filter<S: StringProtocol, T: StringProtocol>(by keyPath: KeyPath<Element, S?>, matching string: T, options: String.CompareOptions = [], range: Range<S.Index>? = nil, locale: Locale? = nil, sortByBestMatch: Bool = false) -> [Element] {
        filter(by: { $0[keyPath: keyPath] }, matching: string, options: options, range: range, locale: locale, sortByBestMatch: sortByBestMatch)
    }
}

public extension Sequence where Element: StringProtocol {
    /**
     Returns the elements that contain the given string using the specified comparison options.
     
     - Parameters:
       - string: The string to search for in each element.
       - options: The options to use when comparing each element to `string`.
       - range: The range of each element to search, or `nil` to search the full element.
       - locale: The locale to use for the comparison.
       - sortByBestMatch: A Boolean value that determines whether matching elements are sorted by best match.
     
            If `true`, matches are ordered by relevance, prioritizing exact matches, then prefix matches, then later substring matches.
     - Returns: An array containing the elements that match `string`.
     */
    func filter<T: StringProtocol>(by string: T, options: String.CompareOptions = [], range: Range<Element.Index>? = nil, locale: Locale? = nil, sortByBestMatch: Bool = false) -> [Element] {
        filter(by: { $0 }, matching: string, options: options, range: range, locale: locale, sortByBestMatch: sortByBestMatch)
    }
}

public extension Sequence where Element: OptionalProtocol, Element.Wrapped: StringProtocol {
    /**
     Returns the elements that contain the given string using the specified comparison options.
     
     - Parameters:
       - string: The string to search for in each element.
       - options: The options to use when comparing each element to `string`.
       - range: The range of each element to search, or `nil` to search the full element.
       - locale: The locale to use for the comparison.
       - sortByBestMatch: A Boolean value that determines whether matching elements are sorted by best match.
     
            If `true`, matches are ordered by relevance, prioritizing exact matches, then prefix matches, then later substring matches.
     - Returns: An array containing the elements that match `string`.
     */
    func filter<T: StringProtocol>(by string: T, options: String.CompareOptions = [], range: Range<Element.Wrapped.Index>? = nil, locale: Locale? = nil, sortByBestMatch: Bool = false) -> [Element] {
        filter(by: ({ $0.optional }), matching: string, options: options, range: range, locale: locale, sortByBestMatch: sortByBestMatch)
    }
}


public extension Sequence where Element == String {
    #if os(macOS) || os(iOS)
    /**
     Returns a new string by concatenating the elements of the sequence, adding a separator for the option.

     - Parameters:
        - option: The option how to join the strings.
        - locale: The locale to use (for options like ``Swift/String/JoinOption/and``, ``Swift/String/JoinOption/or``, …)
     - Returns: A single, concatenated string.
     */
    func joined(by option: String.JoinOption, locale: Locale = .current) -> String {
        var strings = Array(self)
        if let prefix = option.prefix {
            strings = strings.compactMap { prefix + $0 }
        }
        if option.isNumeric {
            strings = strings.indexed().compactMap { "\($0.index + 1)\($0.element)" }
        }
        if let lastSeperator = option.lastSeperator(for: locale), strings.count >= 2 {
            let lastString = strings.removeLast()
            var string = strings.joined(separator: option.seperator(for: locale))
            string = [string, lastString].joined(separator: lastSeperator)
            return string
        }
        return strings.joined(separator: option.seperator(for: locale))
    }
    #else
    /**
     Returns a new string by concatenating the elements of the sequence, adding a separator for the option.

     - Parameter option: The option how to join the strings.
     - Returns: A single, concatenated string.
     */
    func joined(by option: String.JoinOption) -> String {
        var strings = Array(self)
        if let prefix = option.prefix {
            strings = strings.compactMap { prefix + $0 }
        }
        if option.isNumeric {
            strings = strings.indexed().compactMap { "\($0.index + 1)\($0.element)" }
        }
        if let lastSeperator = option.lastSeperator, strings.count >= 2 {
            let lastString = strings.removeLast()
            var string = strings.joined(separator: option.seperator)
            string = [string, lastString].joined(separator: lastSeperator)
            return string
        }
        return strings.joined(separator: option.seperator)
    }
    #endif
}

public extension String {
    /// Options for joining string sequences.
    enum JoinOption: Int {
        /**
         Joined by adding lines.

         ```
         Apple
         Orange
         Banana
         ```
         */
        case line
        /**
         Joined by adding comma's.

         ```
         Apple, Orange, Strawberry, Banana
         ```
         */
        case comma
        /**
         Joined by adding comma's and `and` to join the last string.

         ```
         Apple, Orange, Strawberry and Banana
         ```
         */
        case commaAnd
        /**
         Joined by adding comma's and `or` to join the last string.

         ```
         Apple, Orange, Strawberry or Banana
         ```
         */
        case commaOr
        /**
         Joined by adding comma's and `&` to join the last string.

         ```
         Apple, Orange, Strawberry & Banana
         ```
         */
        case commaAmpersand
        /**
         Joined by adding `and`.

         ```
         Apple and Orange and Banana
         ```
         */
        case and
        /**
         Joined by adding `or`.

         ```
         Apple or Orange or Banana
         ```
         */
        case or
        /**
         Joined by adding `/`.

         ```
         Apple / Orange / Banana
         ```
         */
        case slash
        /**
         Joined by adding `\`.

         ```
         Apple \ Orange \ Banana
         ```
         */
        case backslash
        /**
         Joined by adding new lines and `-`.

         ```
          - Apple
          - Orange
          - Banana
         ```
         */
        case list
        /**
         Joined by adding new lines and `*`.

         ```
          * Apple
          * Orange
          * Banana
         ```
         */
        case listStars
        /// Joined by adding new lines and numbers.
        /**
         Joined by adding new lines and numbers.

         ```
         1 Apple
         2 Orange
         3 Banana
         ```
         */
        case listNumeric
        /**
         Joined by adding new lines and numbers with dots.

         ```
         1. Apple
         2. Orange
         3. Banana
         ```
         */
        case listNumericDot
        /**
         Joined by adding new lines and numbers with colons.

         ```
         1: Apple
         2: Orange
         3: Banana
         ```
         */
        case listNumericColon
        /**
         Joined by adding new lines and numbers with dashes.

         ```
         1 - Apple
         2 - Orange
         3 - Banana
         ```
         */
        case listNumericDash
        
        var isNumeric: Bool {
            switch self {
            case .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return true
            default: return false
            }
        }

        var prefix: String? {
            switch self {
            case .list, .listNumericDash: return " - "
            case .listStars: return " * "
            case .listNumericDot: return ". "
            case .listNumericColon: return ": "
            case .listNumeric: return " "
            default: return nil
            }
        }
        
        #if os(macOS) || os(iOS)
        func seperator(for locale: Locale) -> String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return " \(ListFormatter.localizedAnd(for: locale)) "
            case .slash: return " / "
            case .backslash: return " \\ "
            case .or: return " \(ListFormatter.localizedOr(for: locale)) "
            }
        }
        
        func lastSeperator(for locale: Locale) -> String? {
            switch self {
            case .commaAnd: return JoinOption.and.seperator(for: locale)
            case .commaOr: return JoinOption.or.seperator(for: locale)
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
        #else
        var seperator: String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return  " and "
            case .slash: return " / "
            case .backslash: return " \\ "
            case .or: return " or "
            }
        }
        
        var lastSeperator: String? {
            switch self {
            case .commaAnd: return JoinOption.and.seperator
            case .commaOr: return JoinOption.or.seperator
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
        #endif
    }
}
