//
//  Sequence+String.swift
//
//
//  Created by Florian Zand on 06.09.23.
//

import Foundation

public extension Sequence where Element == String {
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
        #else
        func seperator(for locale: Locale) -> String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon, .listNumericDash: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return  " and "
            case .slash: return " / "
            case .backslash: return " \\ "
            case .or: return " or "
            }
        }
        #endif
        
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
        
        func lastSeperator(for locale: Locale) -> String? {
            switch self {
            case .commaAnd: return JoinOption.and.seperator(for: locale)
            case .commaOr: return JoinOption.or.seperator(for: locale)
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
    }
}
