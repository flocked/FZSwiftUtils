//
//  File.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

import Foundation

public extension NSAttributedString {    
    /**
     Applies the specified attributes to the attributed string.

     - Parameters:
        - attributes: The attributes to apply to the attributed string.

     - Returns: A new attributed string with the specified attributes applied.
     */
    func applying(attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0 ..< length))
        return copy
    }
    
    /**
     Applies the specified color to the sttributed string.

     - Parameters:
        - color: The color to apply.

     - Returns: A new sttributed string with the specified color applied.
     */
    func color(_ color: NSUIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }

    /**
     Applies the specified link to the sttributed string.

     - Parameters:
        - link: The link to apply.

     - Returns: A new sttributed string with the specified link applied.
     */
    func link(_ url: URL) -> NSAttributedString {
        return applying(attributes: [.link: url])
    }

    /**
     Applies the specified font to the sttributed string.

     - Parameters:
        - font: The font to apply.

     - Returns: A new sttributed string with the specified font applied.
     */
    func font(_ font: NSUIFont) -> NSAttributedString {
        return applying(attributes: [.font: font])
    }

    /**
     Returns a lowercase version of the attributed string.

     - Returns: A lowercase copy of the attributed string.
     */
    func lowercased() -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.lowercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    /**
     Returns a uppercase version of the attributed string.

     - Returns: A uppercase copy of the attributed string.
     */
    func uppercased() -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.uppercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    /**
     Returns a capitalized version of the attributed string.

     - Returns: A capitalized copy of the attributed string.
     */
    func capitalized() -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.capitalized
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }

    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }

    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }

    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs + NSAttributedString(string: rhs)
    }
}

public extension Array where Element: NSAttributedString {
    /**
     Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
     - Parameters separator: An attributed string to insert between each of the elements in this sequence.
     - Returns: A single, concatenated attributed string.
     */
    func joined(separator: NSAttributedString) -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(separator)
            result.append(element)
        }
    }

    /**
     Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
     - Parameters separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
     - Returns: A single, concatenated attributed string.
     */
    func joined(separator: String = "") -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        let attributedStringSeparator = NSAttributedString(string: separator)
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(attributedStringSeparator)
            result.append(element)
        }
    }
}
