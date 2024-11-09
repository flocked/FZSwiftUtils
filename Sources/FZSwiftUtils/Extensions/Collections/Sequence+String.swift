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

     - Parameter option: The option for joining the strings.
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
}

public extension String {
    /// The option for joining string sequences.
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

        var seperator: String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return " and "
            case .slash: return " / "
            case .backslash: return " \\ "
            case .or: return " or "
            }
        }

        var isNumeric: Bool {
            switch self {
            case .listNumeric, .listNumericDot, .listNumericColon: return true
            default: return false
            }
        }

        var prefix: String? {
            switch self {
            case .list: return " - "
            case .listStars: return " * "
            case .listNumericDot: return ". "
            case .listNumericColon: return ": "
            case .listNumeric: return " "
            default: return nil
            }
        }

        var lastSeperator: String? {
            switch self {
            case .commaAnd: return " and "
            case .commaOr: return " or "
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
    }
}
