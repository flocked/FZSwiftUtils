//
//  NSAttributedString+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

import Foundation

public extension NSAttributedString {
    /**
     Applies the specified attributes to the attributed string.

     - Parameter attributes: The attributes to apply to the attributed string.

     - Returns: A new attributed string with the specified attributes applied.
     */
    func applyingAttributes(_ attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0 ..< length))
        return copy
    }

    /**
     Removes the specified attributes.

     - Parameters:
        - attributes: The attributes to remove.

     - Returns: A new attributed string with the attributes removed.
     */
    func removingAttributes(_ attributes: [Key]) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let range = NSRange(0 ..< length)
        let copy = NSMutableAttributedString(attributedString: self)
        for attribute in attributes {
            copy.removeAttribute(attribute, range: range)
        }
        return copy
    }
    
    /**
     Applies the specified color to the attributed string.

     - Parameter color: The color to apply.

     - Returns: A new attributed string with the specified color applied.
     */
    func color(_ color: NSUIColor?) -> NSAttributedString {
        if let color = color {
            return applyingAttributes([.foregroundColor: color])
        }
        return removingAttributes([.foregroundColor])
    }
    
    /**
     Applies the specified color to the attributed string.

     - Parameter color: The color to apply.

     - Returns: A new attributed string with the specified color applied.
     */
    func backgroundColor(_ color: NSUIColor?) -> NSAttributedString {
        if let color = color {
            return applyingAttributes([.backgroundColor: color])
        }
        return removingAttributes([.backgroundColor])
    }

    /**
     Applies the specified link to the attributed string.

     - Parameter link: The link to apply.

     - Returns: A new attributed string with the specified link applied.
     */
    func link(_ url: URL?) -> NSAttributedString {
        if let url = url {
            return applyingAttributes([.link: url])
        }
        return removingAttributes([.link])
    }

    /**
     Applies the specified font to the attributed string.

     - Parameter font: The font to apply.

     - Returns: A new attributed string with the specified font applied.
     */
    func font(_ font: NSUIFont) -> NSAttributedString {
        applyingAttributes([.font: font])
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
        let index = (lhs.string as NSString).length - 1
        if index >= 0, let font = lhs.attribute(.font, at: index, effectiveRange: nil) {
            lhs += NSAttributedString(string: rhs, attributes: [.font: font])
        } else {
            lhs += NSAttributedString(string: rhs)
        }
    }

    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        let index = (lhs.string as NSString).length - 1
        if index >= 0, let font = lhs.attribute(.font, at: index, effectiveRange: nil) {
            return lhs + NSAttributedString(string: rhs, attributes: [.font: font])
        } else {
            return lhs + NSAttributedString(string: rhs)
        }
    }

    /**
     Finds and returns the range of the first occurrence of a given string within the string.

     - Parameter string: The string to search for.
     - Returns: An NSRange structure giving the location and length in the receiver of the first occurrence of searchString. Returns `{NSNotFound, 0}` if searchString is not found or is empty ("").
     */
    func range(of string: String) -> NSRange {
        (self.string as NSString).range(of: string)
    }
    
    /// A `AttributedString` representation of the attributed string.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var attributedString: AttributedString {
        AttributedString(self)
    }
}

public extension NSAttributedString {
    subscript(substring: StringLiteralType) -> NSAttributedString? {
        guard string.contains(substring) else { return nil }
        let range = (string as NSString).range(of: substring)
        return attributedSubstring(from: range)
    }

    subscript(range: ClosedRange<Int>) -> NSAttributedString {
        let string = String(string[range])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(offset: Int) -> NSAttributedString {
        let string = String(string[offset])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(range: Range<Int>) -> NSAttributedString {
        let string = String(string[range])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(range: PartialRangeFrom<Int>) -> NSAttributedString {
        let string = String(string[range])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(range: PartialRangeThrough<Int>) -> NSAttributedString {
        let string = String(string[range])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(range: PartialRangeUpTo<Int>) -> NSAttributedString {
        let string = String(string[range])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }

    subscript(range: NSRange) -> NSAttributedString {
        let string = String(string[range.closedRange])
        let range = (self.string as NSString).range(of: string)
        return attributedSubstring(from: range)
    }
}

public extension Array where Element: NSAttributedString {
    /**
     Returns a new attributed string by concatenating the elements of the sequence, adding the given separator between each element.
     - Parameter separator: An attributed string to insert between each of the elements in this sequence.
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
     - Parameter separator: A string to insert between each of the elements in this sequence. The default separator is an empty string.
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

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
public extension NSAttributedString {
    /// The foreground color of the attributed string.
    var foregroundColor: NSUIColor? {
        attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSUIColor
    }
    
    /// The background color of the attributed string.
    var backgroundColor: NSUIColor? {
        attribute(.backgroundColor, at: 0, effectiveRange: nil) as? NSUIColor
    }
    
    /// The shadow of the attributed string.
    var shadow: NSShadow? {
        attribute(.shadow, at: 0, effectiveRange: nil) as? NSShadow
    }
    
    /**
     Applies the specified shadow to the attributed string.

     - Parameter shadow: The shadow to apply.

     - Returns: A new attributed string with the specified shadow applied.
     */
    func shadow(_ shadow: NSShadow?) -> NSAttributedString {
        if let shadow = shadow {
            return applyingAttributes([.shadow:  shadow])
        } else {
            return removingAttributes([.shadow])
        }
    }
    
    /**
     Applies the specified stroke color and width to the attributed string.

     - Parameters:
        - color: The color of the stroke.
        - width: The width of the stroke.

     - Returns: A new attributed string with the specified stroke color and width applied.
     */
    func stroke(_ color: NSUIColor?, width: CGFloat = 1.0) -> NSAttributedString {
        if let color = color {
            return applyingAttributes([.strokeColor: color, .strokeWidth: width])
        } else {
            return removingAttributes([.strokeColor, .strokeWidth])
        }
    }
}
