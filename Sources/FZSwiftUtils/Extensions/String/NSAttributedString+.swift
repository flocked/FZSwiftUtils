//
//  File.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

import Foundation

public extension NSAttributedString {
    func applying(attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0 ..< length))
        return copy
    }

    func color(_ color: NSUIColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }

    func link(_ url: URL) -> NSAttributedString {
        return applying(attributes: [.link: url])
    }

    func font(_ font: NSUIFont) -> NSAttributedString {
        return applying(attributes: [.font: font])
    }

    func lowercased() -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.lowercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

    func uppercased() -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let value = NSMutableAttributedString(attributedString: self)
        let string = value.string.uppercased()
        value.replaceCharacters(in: range, with: string)
        return value.attributedSubstring(from: range)
    }

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
    func joined(separator: NSAttributedString) -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(separator)
            result.append(element)
        }
    }

    func joined(separator: String) -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        let attributedStringSeparator = NSAttributedString(string: separator)
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(attributedStringSeparator)
            result.append(element)
        }
    }
}
