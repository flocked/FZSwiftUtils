//
//  NSAttributedString+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSAttributedString {
    /// Returns the full range of the attributed string.
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }
    
    /**
     Applies the specified attributes to the attributed string.

     - Parameters:
        - attributes: The attributes to add.
        - range: The range of characters, or `nil` to use the full range.

     - Returns: A new attributed string with the specified attributes applied.
     */
    func applyingAttributes(_ attributes: [Key: Any], at range: NSRange? = nil) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: range ?? fullRange)
        return copy
    }

    /**
     Removes the specified attributes.

     - Parameters:
        - attributes: The attributes to remove.
        - range: The range of characters, or `nil` to use the full range.

     - Returns: A new attributed string with the attributes removed.
     */
    func removingAttributes(_ attributes: [Key], at range: NSRange? = nil) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.removeAttributes(attributes, at: range)
        return copy
    }
    
    /**
     Sets the specified attribute value.

     - Parameters:
        - attributes: The attributes to add.
        - range: The range of characters, or `nil` to use the full range.

     - Returns: A new attributed string with the specified attributes applied.
     */
    internal func settingAttribute(_ name: Key, to value: Any?, at range: NSRange? = nil) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.setAttribute(name, to: value, at: range)
        return copy
    }
    
    /**
     Sets the foreground color of the attributed string.

     - Returns: A new attributed string with the specified goreground color applied.
     */
    func color(_ color: NSUIColor?) -> NSAttributedString {
        settingAttribute(.foregroundColor, to: color)
    }
    
    /**
     Sets the background color of the attributed string.

     - Returns: A new attributed string with the specified background color applied.
     */
    func backgroundColor(_ color: NSUIColor?) -> NSAttributedString {
        settingAttribute(.backgroundColor, to: color)

    }

    /**
     Sets the link of the attributed string.

     - Returns: A new attributed string with the specified link applied.
     */
    func link(_ url: URL?) -> NSAttributedString {
        settingAttribute(.link, to: url)

    }

    /**
     Sets the font of the attributed string.

     - Returns: A new attributed string with the specified font applied.
     */
    func font(_ font: NSUIFont?) -> NSAttributedString {
        settingAttribute(.font, to: font)
    }
    
    /**
     Sets the shadow of the attributed string.

     - Returns: A new attributed string with the specified shadow applied.
     */
    func shadow(_ shadow: NSShadow?) -> NSAttributedString {
        settingAttribute(.shadow, to: shadow)
    }
    
    /**
     Sets the underline color of the attributed string.

     - Returns: A new attributed string with the specified underline color applied.
     */
    func underlineColor(_ color: NSUIColor?) -> NSAttributedString {
        settingAttribute(.underlineColor, to: color)
    }
    
    /**
     Sets the underline style of the attributed string.

     - Returns: A new attributed string with the specified underline style applied.
     */
    func underlineStyle(_ style: NSUnderlineStyle?) -> NSAttributedString {
        settingAttribute(.underlineStyle, to: style?.rawValue)
    }
    
    /**
     Sets the stroke color of the attributed string.

     - Returns: A new attributed string with the specified stroke color applied.
     */
    func strokeColor(_ color: NSUIColor?) -> NSAttributedString {
        settingAttribute(.strokeColor, to: color)
    }
    
    /**
     Sets the stroke width of the attributed string.

     - Returns: A new attributed string with the specified stroke width applied.
     */
    func strokeWidth(_ width: CGFloat?) -> NSAttributedString {
        settingAttribute(.strokeWidth, to: width)
    }
    
    /**
     Sets the strikethrough color of the attributed string.

     - Returns: A new attributed string with the specified strikethrough color applied.
     */
    func strikethroughColor(_ color: NSUIColor?) -> NSAttributedString {
        settingAttribute(.strikethroughColor, to: color)
    }
    
    /**
     Sets the strikethrough style of the attributed string.

     - Returns: A new attributed string with the specified strikethrough style applied.
     */
    func strikethroughStyle(_ style: NSUnderlineStyle?) -> NSAttributedString {
        settingAttribute(.strikethroughStyle, to: style?.rawValue)
    }

    /**
     Returns a lowercase version of the attributed string.

     - Returns: A lowercase copy of the attributed string.
     */
    func lowercased() -> NSAttributedString {
        let range = fullRange
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.lowercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }
    
    /**
     Returns a version of the attributed string where the first character is lowercased.

     - Returns: A lowercase copy of the attributed string.
     */
    func lowercasedFirst() -> NSAttributedString {
        let range = fullRange
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.lowercasedFirst()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    /**
     Returns a uppercase version of the attributed string.

     - Returns: A uppercase copy of the attributed string.
     */
    func uppercased() -> NSAttributedString {
        let range = fullRange
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.uppercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }
    
    /**
     Returns a version of the attributed string, where the first character is uppercased.

     - Returns: A lowercase copy of the attributed string.
     */
    func uppercasedFirst() -> NSAttributedString {
        let range = fullRange
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.uppercasedFirst()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    /**
     Returns a capitalized version of the attributed string.

     - Returns: A capitalized copy of the attributed string.
     */
    func capitalized() -> NSAttributedString {
        let range = fullRange
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
    
    /// A `mutable` representation of the attributed string.
    var mutable: NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
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

public extension NSAttributedString {
    /**
     The value for the specified attribute.
     
     - Parameters:
        - name: The name of the attribute.
        - range: The range of characters, or `nil` to use the full range.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    subscript <V>(name: NSAttributedString.Key, range: NSRange? = nil) -> V? {
        get { attribute(name, at: range?.location ?? 0, effectiveRange: nil) as? V }
        set {
            guard let self = self as? NSMutableAttributedString else { return }
            self.setAttribute(name, to: newValue, at: range)
        }
    }
    
    /**
     The value for the specified attribute.
     
     - Parameters:
        - name: The name of the attribute.
        - range: The range of characters, or `nil` to use the full range.

     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    subscript <V>(name: NSAttributedString.Key, range: NSRange? = nil) -> V? where V: RawRepresentable, V.RawValue == Int {
        get {
            guard let rawValue = attribute(name, at: range?.location ?? 0, effectiveRange: nil) as? Int else { return nil }
            return V(rawValue: rawValue)
        }
        set {
            guard let self = self as? NSMutableAttributedString else { return }
            self.setAttribute(name, to: newValue?.rawValue, at: range)
        }
    }
    
    /**
     The foreground color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var foregroundColor: NSUIColor? {
        get { self[.foregroundColor] }
        set { self[.foregroundColor] = newValue }
    }

    /**
     The background color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var backgroundColor: NSUIColor? {
        get { self[.backgroundColor] }
        set { self[.backgroundColor] = newValue }
    }

    /**
     The stroke color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var strokeColor: NSUIColor? {
        get { self[.strokeColor] }
        set { self[.strokeColor] = newValue }
    }

    /**
     The stroke width of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var strokeWidth: CGFloat? {
        get { self[.strokeWidth] }
        set { self[.strokeWidth] = newValue }
    }

    /**
     The font of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var font: NSUIFont? {
        get { self[.font] }
        set { self[.font] = newValue }
    }

    /**
     The shadow of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var shadow: NSShadow? {
        get { self[.shadow] }
        set { self[.shadow] = newValue }
    }

    /**
     The link for the text.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var link: URL? {
        get { self[.link] }
        set { self[.link] = newValue }
    }

    #if os(macOS)
    /**
     The tooltip text.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var toolTip: String? {
        get { self[.toolTip] }
        set { self[.toolTip] = newValue }
    }
    #endif

    /**
     The underline color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var underlineColor: NSUIColor? {
        get { self[.underlineColor] }
        set { self[.underlineColor] = newValue }
    }

    /**
     The underline style of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var underlineStyle: NSUnderlineStyle? {
        get { self[.underlineStyle] }
        set { self[.underlineStyle] = newValue }
    }

    /**
     The strikethrough color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var strikethroughColor: NSUIColor? {
        get { self[.strikethroughColor] }
        set { self[.strikethroughColor] = newValue }
    }

    /**
     The strikethrough style of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var strikethroughStyle: NSUnderlineStyle? {
        get { self[.strikethroughStyle] }
        set { self[.strikethroughStyle] = newValue }
    }

    #if os(macOS) || os(iOS) || os(tvOS)
    /**
     The attachment of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var attachment: NSTextAttachment? {
        get { self[.attachment] }
        set { self[.attachment] = newValue }
    }
    #endif

    /**
     The vertical offset for the position of the text.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var baselineOffset: CGFloat? {
        get { self[.baselineOffset] }
        set { self[.baselineOffset] = newValue }
    }

    /**
     The kerning of the text.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var kern: CGFloat? {
        get { self[.kern] }
        set { self[.kern] = newValue }
    }
}

public extension NSMutableAttributedString {
    /**
     Adds the specified attributes to the whole attributed string.
     
     - Parameter attributes: A dictionary containing the attributes to add.
     */
    func addAttributes(_ attributes: [NSAttributedString.Key : Any]) {
        addAttributes(attributes, range: fullRange)
    }
    
    /**
     Removes the specified attribute from the whole attributed string.
     
     - Parameter name: The name of the attribute.
     */
    func removeAttribute(_ name: NSAttributedString.Key) {
        removeAttribute(name, range: fullRange)
    }
    
    /**
     Removes the specified attributes from the whole attributed string.
     
     - Parameters:
        - names: The names of the attribute.
        - range: The range of characters, or `nil` to use the full range.
     */
    func removeAttributes(_ names: [Key], at range: NSRange? = nil) {
        let range = range ?? fullRange
        names.forEach({ removeAttribute($0, range: range) })
    }
    
    /**
     Sets the specified attribute value.
     
     - Parameters:
        - name: The name of the attribute.
        - value: The value of the attribute.
        - range: The range of characters, or `nil` to use the full range.
     */
    func setAttribute(_ name: NSAttributedString.Key, to value: Any?, at range: NSRange? = nil) {
        if let value = value {
            addAttributes([name: value], range: NSRange(location: 0, length: length))
        } else {
            removeAttribute(name, range: NSRange(location: 0, length: length))
        }
    }
}
