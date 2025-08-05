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
#if canImport(WebKit)
import WebKit
#endif
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
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

public extension NSObjectProtocol where Self: NSAttributedString {
    /**
     The font of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var font: NSUIFont? {
        get { self[.font] }
        set { self[.font] = newValue }
    }
    
    /**
     The foreground color of the attributed string.
     
     Modifying this value only works, if it is a `NSMutableAttributedString`.
     */
    var foregroundColor: NSUIColor? {
        get { self[.foregroundColor] }
        set { self[.foregroundColor] = newValue }
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

extension NSAttributedString {
    /**
     Returns the data that contains a text stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: A dictionary specifying the document attributes. The dictionary contains values from Document Types and must at least contain documentType.
     */
    public func data(documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [:]) -> Data {
        try! data(from: fullRange, documentAttributes: documentAttributes)
    }
    
    /**
     Returns the data that contains a text stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: The document attributes.
     */
    public func data(documentAttributes: DocumentAttributes) -> Data {
        data(documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns the data that contains a text stream corresponding to the characters and attributes within the specified range.
     
     - Parameters:
        - range: The range.
        - documentAttributes: The document attributes.
     - Returns: The data, or `nil` if any part of range lies beyond the end of the attribute string’s characters.
     */
    public func data(from range: NSRange, documentAttributes: DocumentAttributes) -> Data? {
        try? data(from: range, documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns a file wrapper that contains a text stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: A dictionary specifying the document attributes. The dictionary contains values from Document Types and must at least contain documentType.
     */
    public func fileWrapper(documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [:]) -> FileWrapper {
        try! fileWrapper(from: fullRange, documentAttributes: documentAttributes)
    }
    
    /**
     Returns a file wrapper that contains a text stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: The document attributes.
     */
    public func fileWrapper(documentAttributes: DocumentAttributes) -> FileWrapper {
        fileWrapper(documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns a file wrapper that contains a text stream corresponding to the characters and attributes within the specified range.
     
     - Parameters:
        - range: The range.
        - documentAttributes: The document attributes.
     - Returns: The filewrapper, or `nil` if any part of range lies beyond the end of the attribute string’s characters.
     */
    public func fileWrapper(from range: NSRange, documentAttributes: DocumentAttributes) -> FileWrapper? {
        try? fileWrapper(from: range, documentAttributes: documentAttributes.dict)
    }
    
    #if os(macOS)
    
    /**
     Returns the data object that contains an RTF stream corresponding to the characters and attributes, omitting all attachment attributes.
     
     - Parameter documentAttributes: A dictionary specifying the document attributes. The dictionary contains values from Document Types and must at least contain documentType.
     */
    public func rtf(documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [:]) -> Data {
        documentAttributes.isEmpty ? rtf(from: fullRange)! : rtf(from: fullRange, documentAttributes: documentAttributes)!
    }
    
    /**
     Returns the data object that contains an RTF stream corresponding to the characters and attributes, omitting all attachment attributes.
     
     - Parameter documentAttributes: The document attributes.
     */
    public func rtf(documentAttributes: DocumentAttributes) -> Data {
        rtf(documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns the data object that contains an RTF stream corresponding to the characters and attributes, omitting all attachment attributes within the specified range.
     
     - Parameters:
        - range: The range.
        - documentAttributes: The document attributes.
     - Returns: The data, or `nil` if any part of range lies beyond the end of the attribute string’s characters.
     */
    public func rtf(from range: NSRange, documentAttributes: DocumentAttributes) -> Data? {
        documentAttributes.dict.isEmpty ? rtf(from: range) : rtf(from: range, documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns the data object that contains an RTFD stream corresponding to the characters and attributes, omitting all attachment attributes.
     
     - Parameter documentAttributes: A dictionary specifying the document attributes. The dictionary contains values from Document Types and must at least contain documentType.
     */
    public func rtfd(documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [:]) -> Data {
        documentAttributes.isEmpty ? rtfd(from: fullRange)! : rtfd(from: fullRange, documentAttributes: documentAttributes)!
    }
    
    /**
     Returns the data object that contains an RTFD stream corresponding to the characters and attributes, omitting all attachment attributes.
     
     - Parameter documentAttributes: The document attributes.
     */
    public func rtfd(documentAttributes: DocumentAttributes) -> Data {
        rtfd(documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns the data object that contains an RTFD stream corresponding to the characters and attributes, omitting all attachment attributes within the specified range.
     
     - Parameters:
        - range: The range.
        - documentAttributes: The document attributes.
     - Returns: The data, or `nil` if any part of range lies beyond the end of the attribute string’s characters.
     */
    public func rtfd(from range: NSRange, documentAttributes: DocumentAttributes) -> Data? {
        documentAttributes.dict.isEmpty ? rtfd(from: range) : rtfd(from: range, documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns a data object that contains a Microsoft Word–format stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: A dictionary specifying the document attributes. The dictionary contains values from Document Types and must at least contain documentType.
     */
    public func docFormat(documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [:]) -> Data {
        docFormat(from: fullRange, documentAttributes: documentAttributes)!
    }
    
    /**
     Returns a data object that contains a Microsoft Word–format stream corresponding to the characters and attributes.
     
     - Parameter documentAttributes: The document attributes.
     */
    public func docFormat(documentAttributes: DocumentAttributes) -> Data {
        docFormat(documentAttributes: documentAttributes.dict)
    }
    
    /**
     Returns a data object that contains a Microsoft Word–format stream corresponding to the characters and attributes within the specified range.
     
     - Parameters:
        - range: The range.
        - documentAttributes: The document attributes.
     - Returns: The data, or `nil` if any part of range lies beyond the end of the attribute string’s characters.
     */
    public func docFormat(from range: NSRange, documentAttributes: DocumentAttributes) -> Data? {
        docFormat(from: range, documentAttributes: documentAttributes.dict)
    }
    #endif
    
    /**
     Creates an attributed string from the data in the specified data.

     - Parameters:
        - data: The data from which to create the string.
        - options: Options for importing the document. The default valus is `automatic` and tries to automatically determine the appropriate attributes.
     - Throws: If the data can’t be decoded.
     */
    public convenience init(data: Data, options: DataDocumentReadingOptions = .automatic) throws {
        try self.init(data: data, options: options.dict, documentAttributes: nil)
    }
    
    /**
     Creates an attributed string from the data in the specified data.

     - Parameters:
        - data: The data from which to create the string.
        - options: Options for importing the document. The default valus is `automatic` and tries to automatically determine the appropriate attributes.
        - documentAttributes: The document attributes.
     - Throws: If the data can’t be decoded.
     */
    public convenience init(data: Data, options: DataDocumentReadingOptions = .automatic, documentAttributes: inout DocumentAttributes) throws {
        var _attributes: NSDictionary? = documentAttributes.dict as NSDictionary
        try self.init(data: data, options: options.dict, documentAttributes: &_attributes)
        if let updatedAttributes = _attributes as? [NSAttributedString.DocumentAttributeKey: Any] {
            documentAttributes.update(with: updatedAttributes)
        }
    }
    
    /**
     Creates an attributed string from the contents of the specified URL.

     - Parameters:
        - url: The url of the document to load.
        - options: Options for importing the document. The default valus is `automatic` and tries to automatically determine the appropriate attributes.
     - Throws: If the data can’t be decoded.
     */
    public convenience init(url: URL, options: DataDocumentReadingOptions = .automatic) throws {
        try self.init(url: url, options: options.dict, documentAttributes: nil)
    }
    
    /**
     Creates an attributed string from the contents of the specified URL.

     - Parameters:
        - url: The url of the document to load.
        - options: Options for importing the document. The default valus is `automatic` and tries to automatically determine the appropriate attributes.
        - documentAttributes: The document attributes.
     - Throws: If the data can’t be decoded.
     */
    public convenience init(url: URL, options: DataDocumentReadingOptions = .automatic, documentAttributes: inout DocumentAttributes) throws {
        var _attributes: NSDictionary? = documentAttributes.dict as NSDictionary
        try self.init(url: url, options: options.dict, documentAttributes: &_attributes)
        if let updatedAttributes = _attributes as? [NSAttributedString.DocumentAttributeKey: Any] {
            documentAttributes.update(with: updatedAttributes)
        }
    }
    
    #if os(macOS) || os(iOS)
    /// Creates an attributed string by converting the contents of the specified HTML URL request.
    public class func loadFromHTML(request: URLRequest, options: DocumentReadingOptions, completionHandler: @escaping CompletionHandler) {
        loadFromHTML(request: request, options: options.dict, completionHandler: completionHandler)
    }
    
    /// Creates an attributed string by converting the content of a local HTML file at the specified URL.
    public class func loadFromHTML(fileURL: URL, options: DocumentReadingOptions, completionHandler: @escaping CompletionHandler) {
        loadFromHTML(fileURL: fileURL, options: options.dict, completionHandler: completionHandler)
    }
    
    /// Creates an attributed string from the specified HTML string.
    public class func loadFromHTML(string: String, options: DocumentReadingOptions, completionHandler: @escaping CompletionHandler) {
        loadFromHTML(string: string, options: options.dict, completionHandler: completionHandler)
    }
    
    /// Creates an attributed string from the specified HTML data.
    public class func loadFromHTML(data: Data, options: DocumentReadingOptions, completionHandler: @escaping CompletionHandler) {
        loadFromHTML(data: data, options: options.dict, completionHandler: completionHandler)
    }
    #endif
}

extension NSAttributedString {
    /// Options for importing documents.
    public struct DocumentReadingOptions {
        #if os(macOS)
        /// The base URL for HTML documents.
        public var baseURL: URL?
        #endif
        
        /// The character encoding used in the document.
        public var characterEncoding: String.Encoding?
        
        /// The default attributes to apply to plain files.
        public var defaultAttributes: [NSAttributedString.Key: Any]?
        
        /// The document type.
        public var documentType: NSAttributedString.DocumentType?
        
        #if os(macOS)
        /// The file type of the document (e.g., RTF, HTML, etc.).
        public var fileTypeIdentifier: String?
        
        @available (macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public var fileType: UTType? {
            get {
                guard let fileTypeIdentifier = fileTypeIdentifier else { return nil }
                return UTType(fileTypeIdentifier)
            }
            set { fileTypeIdentifier = newValue?.identifier }
        }
        #endif
        
        #if os(macOS) || os(iOS)
        /// The local files WebKit can access when loading content.
        public var readAccessURL: URL?
        #endif
        
        /// The source text scaling.
        public var sourceTextScaling: CGFloat?

        /// The target text scaling.
        public var targetTextScaling: CGFloat?
        
        #if os(macOS)
        /// The name of the text encoding used in the document.
        public var textEncodingName: String?
        
        /// The scale factor for font sizes.
        public var textSizeMultiplier: CGFloat?
        
        /// The time, in seconds, to wait for a document to finish loading.
        public var timeout: CGFloat?
        #endif
        
        var dict: [DocumentReadingOptionKey: Any] {
            var dict: [DocumentReadingOptionKey: Any] = [:]
            dict[.characterEncoding] = characterEncoding?.rawValue
            dict[.defaultAttributes] = defaultAttributes
            dict[.documentType] = documentType
            dict[.sourceTextScaling] = sourceTextScaling
            dict[.targetTextScaling] = targetTextScaling
            #if os(macOS)
            dict[.baseURL] = baseURL
            dict[.fileType] = fileTypeIdentifier
            dict[.textEncodingName] = textEncodingName
            dict[.textSizeMultiplier] = textSizeMultiplier
            dict[.timeout] = timeout
            #endif
            #if os(macOS) || os(iOS)
            dict[.readAccessURL] = readAccessURL
            #endif
            return dict
        }
    }
    
    /// Options for importing documents from data.
    public struct DataDocumentReadingOptions {
        /// The character encoding used in the document.
        public var characterEncoding: String.Encoding?
        
        /// The default attributes to apply to plain files.
        public var defaultAttributes: [NSAttributedString.Key: Any]?
        
        /// The document type.
        public var documentType: NSAttributedString.DocumentType?
        
        /// Automatically determines the appropriate attributes.
        public static let automatic = DataDocumentReadingOptions()
        
        var dict: [DocumentReadingOptionKey: Any] {
            var dict: [DocumentReadingOptionKey: Any] = [:]
            dict[.characterEncoding] = characterEncoding?.rawValue
            dict[.defaultAttributes] = defaultAttributes
            dict[.documentType] = documentType
            return dict
        }
    }
    
    /// The document attributes of a attributed string.
    public struct DocumentAttributes {
        /// The type of the document (e.g., plain text, rich text, etc.).
        public var documentType: NSAttributedString.DocumentType?
        
        #if os(macOS)
        /// A boolean indicating whether the document has been converted.
        public var isConverted: Bool?
        
        /// The version of Cocoa used to create the document.
        public var cocoaVersion: String?
        
        /// The file type of the document (e.g., RTF, HTML, etc.).
        public var fileTypeIdentifier: String?
        
        @available (macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public var fileType: UTType? {
            get {
                guard let fileTypeIdentifier = fileTypeIdentifier else { return nil }
                return UTType(fileTypeIdentifier)
            }
            set { fileTypeIdentifier = newValue?.identifier }
        }
        
        /// The title of the document.
        public var title: String?
        
        /// The company or organization name associated with the document.
        public var company: String?
        
        /// The copyright information for the document.
        public var copyright: String?
        
        /// The subject of the document.
        public var subject: String?
        
        /// The author of the document.
        public var author: String?
        
        /// The keywords of the document.
        public var keywords: [String]?
        
        /// The document comments.
        public var comment: String?
        
        /// The editor of the document.
        public var editor: String?
        
        /// The creation time of the document.
        public var creationTime: Date?
        
        /// The last modification time of the document.
        public var modificationTime: Date?
        
        /// The manager of the document.
        public var manager: String?
        
        /// The category to which the document belongs.
        public var category: String?
        
        /// The appearance style of the document.
        public var appearance: String?
        #endif
        
        /// The character encoding used in the document.
        public var characterEncoding: String.Encoding?
        
        /// The default attributes applied to the document.
        public var defaultAttributes: [NSAttributedString.Key: Any]?
        
        /// The paper size for printing the document.
        public var paperSize: CGSize?
        
        #if os(macOS)
        /// The left margin of the document.
        public var leftMargin: CGFloat?
        
        /// The right margin of the document.
        public var rightMargin: CGFloat?
        
        /// The top margin of the document.
        public var topMargin: CGFloat?
        
        /// The bottom margin of the document.
        public var bottomMargin: CGFloat?
        #endif
        
        /// The size of the document's view.
        public var viewSize: CGSize?
        
        /// The zoom level of the document's view.
        public var viewZoom: CGFloat?
        
        /// The view mode of the document (e.g., full screen, layout view).
        public var viewMode: String?
        
        /// A boolean indicating whether the document is read-only.
        public var isReadOnly: Bool?
        
        /// The background color of the document's view.
        public var backgroundColor: NSUIColor?
        
        /// The hyphenation factor applied to the document.
        public var hyphenationFactor: Float?
        
        /// The default tab stop interval for the document.
        public var defaultTabInterval: CGFloat?
        
        /// The sections that define the document's text layout.
        public var textLayoutSections: [TextLayoutSection]?
        
        /// A section that defines the document layout.
        public struct TextLayoutSection {
            
            /// Constants that describe the text layout orientation.
            public enum Orentation: Int {
                /// Lines render horizontally, each line following the previous from top to bottom.
                case horizontal
                /// Lines render vertically, each line following the previous from right to left.
                case vertical
            }
            
            /// The orientation of the section.
            public let orientation: Orentation
            
            /// The character range of the section.
            public let range: NSRange
            
            #if os(macOS) || os(iOS) || os(tvOS)
            var dict: [TextLayoutSectionKey: Any] {
                [.orientation: NSLayoutManager.TextLayoutOrientation(rawValue: orientation.rawValue)!, .range: range]
            }
            #else
            var dict: [TextLayoutSectionKey: Any] {
                [.orientation: orientation.rawValue, .range: range]
            }
            #endif
            
            /// Creates a text layout section with the specified orientation and range.
            public init(orientation: Orentation = .horizontal, range: NSRange) {
                self.orientation = orientation
                self.range = range
            }
            
            init(dict: [TextLayoutSectionKey: Any]) {
                orientation = .init(rawValue: dict[.orientation] as? Int ?? 0)!
                range = dict[.range] as! NSRange
            }
        }
        
        #if os(macOS)
        /// The HTML elements to exclude from the document's text layout.
        public var excludedElements: [String]?
        
        /// The name of the text encoding used in the document.
        public var textEncodingName: String?
        
        /// The number of spaces for indenting nested HTML elements.
        public var prefixSpaces: Int?
        #endif
        
        /// A boolean indicating whether the default font is excluded in the document.
        public var isDefaultFontExcluded: Bool?
        
        /// The scaling factor applied to the text in the document.
        public var textScaling: CGFloat?
        
        /// The scaling factor applied to the source text in the document.
        public var sourceTextScaling: CGFloat?

        /// A dictionary mapping the document attributes to their respective keys.
        var dict: [DocumentAttributeKey: Any] {
            var dict: [DocumentAttributeKey: Any] = [:]
            #if os(macOS)
            dict[.converted] = isConverted
            dict[.cocoaVersion] = cocoaVersion
            dict[.fileType] = fileTypeIdentifier
            dict[.title] = title
            dict[.company] = company
            dict[.copyright] = copyright
            dict[.subject] = subject
            dict[.author] = author
            dict[.keywords] = keywords
            dict[.comment] = comment
            dict[.editor] = editor
            dict[.creationTime] = creationTime
            dict[.modificationTime] = modificationTime
            dict[.manager] = manager
            dict[.category] = category
            dict[.leftMargin] = leftMargin
            dict[.rightMargin] = rightMargin
            dict[.topMargin] = topMargin
            dict[.appearance] = appearance
            dict[.bottomMargin] = bottomMargin
            dict[.excludedElements] = excludedElements
            dict[.textEncodingName] = textEncodingName
            dict[.prefixSpaces] = prefixSpaces
            #endif
            dict[.documentType] = documentType
            dict[.characterEncoding] = characterEncoding?.rawValue
            dict[.defaultAttributes] = defaultAttributes
            dict[.paperSize] = paperSize
            dict[.viewSize] = viewSize?.nsValue
            dict[.viewZoom] = viewZoom
            dict[.viewMode] = viewMode
            dict[.readOnly] = isReadOnly
            dict[.backgroundColor] = backgroundColor
            dict[.hyphenationFactor] = hyphenationFactor
            dict[.defaultTabInterval] = defaultTabInterval
            dict[.textLayoutSections] = textLayoutSections?.compactMap({$0.dict})
            dict[.textScaling] = textScaling
            dict[.sourceTextScaling] = sourceTextScaling
            if #available(macOS 14, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
                dict[.defaultFontExcluded] = isDefaultFontExcluded
            }
            return dict
        }
        
        mutating func update(with dict: [NSAttributedString.DocumentAttributeKey: Any]) {
            #if os(macOS)
            isConverted = dict[.converted] as? Bool
            cocoaVersion = dict[.cocoaVersion] as? String
            fileTypeIdentifier = dict[.fileType] as? String
            title = dict[.title] as? String
            company = dict[.company] as? String
            copyright = dict[.copyright] as? String
            subject = dict[.subject] as? String
            author = dict[.author] as? String
            keywords = dict[.keywords] as? [String]
            comment = dict[.comment] as? String
            editor = dict[.editor] as? String
            creationTime = dict[.creationTime] as? Date
            modificationTime = dict[.modificationTime] as? Date
            manager = dict[.manager] as? String
            category = dict[.category] as? String
            appearance = dict[.appearance] as? String
            leftMargin = dict[.leftMargin] as? CGFloat
            rightMargin = dict[.rightMargin] as? CGFloat
            topMargin = dict[.topMargin] as? CGFloat
            bottomMargin = dict[.bottomMargin] as? CGFloat
            excludedElements = dict[.excludedElements] as? [String]
            textEncodingName = dict[.textEncodingName] as? String
            prefixSpaces = dict[.prefixSpaces] as? Int
            #endif
            documentType = dict[.documentType] as? NSAttributedString.DocumentType
            characterEncoding = String.Encoding(rawValue: (dict[.characterEncoding] as? UInt) ?? 12212323)
            defaultAttributes = dict[.defaultAttributes] as? [NSAttributedString.Key: Any]
            paperSize = dict[.paperSize] as? CGSize
            viewSize = dict[.viewSize] as? CGSize
            viewZoom = dict[.viewZoom] as? CGFloat
            viewMode = dict[.viewMode] as? String
            isReadOnly = dict[.readOnly] as? Bool
            backgroundColor = dict[.backgroundColor] as? NSUIColor
            hyphenationFactor = dict[.hyphenationFactor] as? Float
            defaultTabInterval = dict[.defaultTabInterval] as? CGFloat
            textLayoutSections = (dict[.textLayoutSections] as? [[TextLayoutSectionKey: Any]])?.compactMap({TextLayoutSection(dict: $0)})
            textScaling = dict[.textScaling] as? CGFloat
            sourceTextScaling = dict[.sourceTextScaling] as? CGFloat
            if #available(macOS 14, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
                isDefaultFontExcluded = dict[.defaultFontExcluded] as? Bool
            }
        }
    }
}
