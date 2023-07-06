//
//  Sequence+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /**
     Returns indexes of elements that satisfies the given predicate.

     - Parameters predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
     
     - Returns: The indexes of the elements that satisfies the given predicate.
     */
    func indexes(where predicate: (Element) throws -> Bool) rethrows -> IndexSet {
        var indexes = IndexSet()
        for (index, element) in enumerated() {
            if try (predicate(element) == true) {
                indexes.insert(index)
            }
        }
        return indexes
    }
}

public extension Sequence where Element: RawRepresentable {
    /// An array of corresponding values of the raw type.
    func rawValues() -> [Element.RawValue] {
        compactMap { $0.rawValue }
    }
}

public extension Sequence where Element: RawRepresentable, Element.RawValue: Equatable {
    /**
     Returns the first element of the sequence that satisfies the  raw value.

     - Parameters rawValue: The raw value.
     
     - Returns: The first element of the sequence that matches the raw value.
     */
    func first(rawValue: Element.RawValue) -> Element? {
        return first(where: { $0.rawValue == rawValue })
    }
}

public extension Sequence where Element: Equatable {
    /**
     A boolean value indicating whether the sequence contains any of the specified elements.
     - Parameters elements: The elements.
     - Returns: `true` if any of the elements exists in the sequence, or` false` if non exist in the sequence.
     */
    func contains<S: Sequence<Element>>(any elements: S) -> Bool {
        for element in elements {
            if contains(element) {
                return true
            }
        }
        return false
    }

    /**
     A boolean value indicating whether the sequence contains all specified elements.
     - Parameters elements: The elements.
     - Returns: `true` if all elements exist in the sequence, or` false` if not.
     */
    func contains<S: Sequence<Element>>(all elements: S) -> Bool {
        for checkElement in elements {
            if contains(checkElement) == false {
                return false
            }
        }
        return true
    }
}

public extension Sequence where Element == String {
    /**
     Returns a new string by concatenating the elements of the sequence, adding a separator for the option.
     
     - Parameters option: The option for joining the strings.
     - Returns: A single, concatenated string.
     */
    func joined(by option: String.JoinOptions) -> String {
        var strings = Array(self)
        if let prefix = option.prefix {
            strings = strings.compactMap({ prefix + $0 })
        }
        if option.isNumeric {
           strings = strings.enumerated().compactMap({ "\($0.offset + 1)\($0.element)" })
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
    enum JoinOptions: Int {
        /// Joined by adding lines.
        case line
        /// Joined by adding comma's.
        case comma
        /// Joined by adding comma's and `and` to join the last string.
        case commaAnd
        /// Joined by adding comma's and `or` to join the last string.
        case commaOr
        /// Joined by adding comma's and `&` to join the last string.
        case commaAmpersand
        /// Joined by adding `and`.
        case and
        /// Joined by adding `or`.
        case or
        /// Joined by adding new lines and `-`.
        case list
        /// Joined by adding new lines and `*`.
        case listStars
        /// Joined by adding new lines and numbers.
        case listNumeric
        /// Joined by adding new lines and numbers.
        case listNumericDot
        /// Joined by adding new lines and numbers.
        case listNumericColon
        
        internal var seperator: String {
            switch self {
            case .line, .list, .listStars, .listNumeric, .listNumericDot, .listNumericColon: return "\n"
            case .comma, .commaAnd, .commaOr, .commaAmpersand: return ", "
            case .and: return " and "
            case .or: return " or "
            }
        }
        
        internal var isNumeric: Bool {
            switch self {
            case .listNumeric, .listNumericDot, .listNumericColon: return true
            default: return false
            }
        }
        
        internal var prefix: String? {
            switch self {
            case .list: return " - "
            case .listStars: return " * "
            case .listNumericDot: return ". "
            case .listNumericColon: return ": "
            case .listNumeric: return " "
            default: return nil
            }
        }
        
        internal var lastSeperator: String? {
            switch self {
            case .commaAnd: return " and "
            case .commaOr: return " or "
            case .commaAmpersand: return " & "
            default: return nil
            }
        }
    }
}
