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


public extension Sequence where Element: StringProtocol {
    #if os(macOS) || os(iOS)
    /**
     Returns a new string by concatenating the elements of the sequence using the specified joining option.

     - Parameters:
        - option: The option specifying how to join the strings.
        - locale: The locale to use for localized joining options.
     - Returns: A single concatenated string.
     */
    func joined(by option: String.JoinOption, locale: Locale = .current) -> String {
        joined(separator: option.separator(for: locale), lastSeparator: option.lastSeparator(for: locale), transform: option.format)
    }
    #else
    /**
     Returns a new string by concatenating the elements of the sequence using the specified joining option.

     - Parameter option: The option specifying how to join the strings.
     - Returns: A single concatenated string.
     */
    func joined(by option: String.JoinOption) -> String {
        joined(separator: option.separator, lastSeparator: option.lastSeparator, transform: option.format)
    }
    #endif

    private func joined(separator: String, lastSeparator: String?, transform: (_ string: String, _ index: Int) -> String) -> String {
        let strings = enumerated().map { transform(String($0.element), $0.offset) }
        guard let lastSeparator, strings.count >= 2 else { return strings.joined(separator: separator) }
        return strings.dropLast().joined(separator: separator) + lastSeparator + strings[strings.count - 1]
    }
}

public extension String {
    /// Options for joining string sequences.
    enum JoinOption: Int {
        /**
         Joins strings using new lines.

         ```
         Apple
         Orange
         Banana
         ```
         */
        case line

        /**
         Joins strings using commas.

         ```
         Apple, Orange, Strawberry, Banana
         ```
         */
        case comma

        /**
         Joins strings using commas and a localized `and` before the last string.

         ```
         Apple, Orange, Strawberry and Banana
         ```
         */
        case commaAnd

        /**
         Joins strings using commas and a localized `or` before the last string.

         ```
         Apple, Orange, Strawberry or Banana
         ```
         */
        case commaOr

        /**
         Joins strings using commas and `&` before the last string.

         ```
         Apple, Orange, Strawberry & Banana
         ```
         */
        case commaAmpersand

        /**
         Joins strings using a localized `and`.

         ```
         Apple and Orange and Banana
         ```
         */
        case and

        /**
         Joins strings using a localized `or`.

         ```
         Apple or Orange or Banana
         ```
         */
        case or

        /**
         Joins strings using `/`.

         ```
         Apple / Orange / Banana
         ```
         */
        case slash

        /**
         Joins strings using `\`.

         ```
         Apple \ Orange \ Banana
         ```
         */
        case backslash

        /**
         Joins strings as a dashed list.

         ```
          - Apple
          - Orange
          - Banana
         ```
         */
        case list

        /**
         Joins strings as a starred list.

         ```
          * Apple
          * Orange
          * Banana
         ```
         */
        case listStars

        /**
         Joins strings as a numbered list.

         ```
         1 Apple
         2 Orange
         3 Banana
         ```
         */
        case listNumeric

        /**
         Joins strings as a numbered list using dots.

         ```
         1. Apple
         2. Orange
         3. Banana
         ```
         */
        case listNumericDot

        /**
         Joins strings as a numbered list using colons.

         ```
         1: Apple
         2: Orange
         3: Banana
         ```
         */
        case listNumericColon

        /**
         Joins strings as a numbered list using dashes.

         ```
         1 - Apple
         2 - Orange
         3 - Banana
         ```
         */
        case listNumericDash

        fileprivate func format(_ string: String, at index: Int) -> String {
            switch self {
            case .list: return " - \(string)"
            case .listStars: return " * \(string)"
            case .listNumeric: return "\(index + 1) \(string)"
            case .listNumericDot: return "\(index + 1). \(string)"
            case .listNumericColon: return "\(index + 1): \(string)"
            case .listNumericDash: return "\(index + 1) - \(string)"
            default: return string
            }
        }

        #if os(macOS) || os(iOS)
        fileprivate func separator(for locale: Locale) -> String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return " \(ListFormatter.localizedAnd(for: locale)) "
            case .or: return " \(ListFormatter.localizedOr(for: locale)) "
            case .slash: return " / "
            case .backslash: return " \\ "
            }
        }

        fileprivate func lastSeparator(for locale: Locale) -> String? {
            switch self {
            case .commaAnd: return JoinOption.and.separator(for: locale)
            case .commaOr: return JoinOption.or.separator(for: locale)
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
        #else
        fileprivate var separator: String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return " and "
            case .or: return " or "
            case .slash: return " / "
            case .backslash: return " \\ "
            }
        }

        fileprivate var lastSeparator: String? {
            switch self {
            case .commaAnd: return JoinOption.and.separator
            case .commaOr: return JoinOption.or.separator
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
        #endif
    }
}

struct StringJoinFormat<Input: Sequence>: FormatStyle where Input.Element: StringProtocol {
    var locale: Locale
    
    init(locale: Locale = .autoupdatingCurrent) {
        self.locale = locale
    }
    
    func locale(_ locale: Locale) -> Self {
        var copy = self
        copy.locale = locale
        return copy
    }
    
    func format(_ value: Input) -> String {
        value.joined()
    }
}
