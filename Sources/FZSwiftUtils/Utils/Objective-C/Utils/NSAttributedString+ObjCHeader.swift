//
//  NSAttributedString+ObjCHeader.swift
//
//
//  Created by Florian Zand on 20.03.26.
//

#if os(macOS) || canImport(UIKit)
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSAttributedString {
    static let imageNames = Set(ObjCRuntime.imageNames())
    
    static func objCHeader(for headerString: String, protocols: [String] = [], font: NSUIFont? = nil) -> NSAttributedString {
        let font = font ?? NSUIFont(name: "SF Mono Regular", size: 13) ?? NSUIFont(name: "Menlo Regular", size: 13) ?? .monospacedSystemFont(ofSize: 13.0, weight: .regular)
        let attributed = NSMutableAttributedString(string: headerString, attributes: [.font: font])
        let fullRange = headerString.nsRange
        let classes = ObjCRuntime.classNames()

        let commentRanges = commentRegex.matches(in: headerString, options: [], range: fullRange).map(\.range)
        apply(ranges: commentRanges, to: attributed, color: objcHeaderColors.comments, font: font)
        
        for commentRange in commentRanges {
            guard let imageMatch = imageRegex.firstMatch(in: headerString, range: commentRange), let pathRange = Range(imageMatch.range(at: 1), in: headerString) else { continue }
            let imagePath = String(headerString[pathRange])
            attributed.addAttribute(.objcImageName, value: imagePath, range: imageMatch.range(at: 1))
        }

        let protocols = Set(protocols)
        var searchLocation = 0
        
        for commentRange in commentRanges {
            if searchLocation < commentRange.location {
                let range = NSRange(location: searchLocation, length: commentRange.location - searchLocation)
                colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywordSet: objcHeaderKeywordSet, classSet: classes, protocolsSet: protocols, font: font)
            }
            searchLocation = commentRange.location + commentRange.length
        }
        if searchLocation < fullRange.length {
            let range = NSRange(location: searchLocation, length: fullRange.length - searchLocation)
            colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywordSet: objcHeaderKeywordSet, classSet: classes, protocolsSet: protocols, font: font)
        }
        return attributed
    }

    private static func colorIdentifiersAndDirectives(in text: String, range: NSRange, attributed: NSMutableAttributedString, keywordSet: Set<String>, classSet: Set<String>, protocolsSet: Set<String>, font: NSUIFont?) {
        tokenRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match else { return }
            let nsString = text as NSString
            let tokenRange = match.range
            let token = nsString.substring(with: tokenRange)

            if token.utf8.first == UInt8(ascii: "@") {
                attributed.setTextColor(objcHeaderColors.keywords, font: font, range: tokenRange)
                return
            }

            if keywordSet.contains(token) {
                attributed.setTextColor(objcHeaderColors.keywords, font: font, range: tokenRange)
            } else if classSet.contains(token) {
                attributed.setTextColor(objcHeaderColors.classes, font: font, range: tokenRange)
                attributed.addAttribute(.objcClassName, value: token, range: tokenRange)
            } else if protocolsSet.contains(token) {
                attributed.addAttribute(.objcProtocolName, value: token, range: tokenRange)
            }
        }
    }

    private static func apply(ranges: [NSRange], to attributed: NSMutableAttributedString, color: NSUIColor, font: NSUIFont?) {
        for range in ranges where range.length > 0 {
            attributed.setTextColor(color, font: font, range: range)
        }
    }

    private static func baseAttributes(font: NSUIFont?) -> [NSAttributedString.Key: Any] {
        guard let font else { return [:] }
        return [.font: font]
    }

    private static let commentRegex: NSRegularExpression = {
        try! NSRegularExpression(
            pattern: #"/\*[\s\S]*?\*/|//.*"#,
            options: [.anchorsMatchLines]
        )
    }()
    
    private static let imageRegex: NSRegularExpression = {
        try! NSRegularExpression(
            pattern: #"^// Image:\s+(.+)$"#,
            options: [.anchorsMatchLines]
        )
    }()

    private static let tokenRegex: NSRegularExpression = {
        try! NSRegularExpression(
            pattern: #"@[A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]*"#,
            options: []
        )
    }()

    private static let objcHeaderKeywordSet: Set<String> = [
        "class",
        "NSUInteger", "nonatomic", "readwrite", "NSInteger", "readonly", "register", "uint16_t", "uint32_t",
        "uint64_t", "continue", "unsigned", "volatile", "IBAction", "IBOutlet", "typedef", "uint8_t",
        "unichar", "int16_t", "int32_t", "int64_t", "default", "atomic", "assign", "strong", "retain",
        "signed", "sizeof", "static", "oneway", "struct", "setter", "return", "switch", "UInt16",
        "UInt32", "double", "extern", "getter", "bycopy", "int8_t", "super", "short", "byref", "union",
        "while", "break", "UInt8", "const", "inout", "float", "weak", "void", "BOOL", "bool", "case",
        "char", "else", "NULL", "enum", "long", "copy", "auto", "goto", "int", "for", "nil", "Nil",
        "SEL", "IMP", "YES", "out", "NO", "id", "if", "do", "in", "Class"
    ]
    
    #if canImport(AppKit)
    private static let objcHeaderColors = (comments: NSUIColor(calibratedRed: 0.0, green: 119.0 / 255.0, blue: 0.0, alpha: 1.0), keywords: NSUIColor(calibratedRed: 193.0 / 255.0, green: 0.0, blue: 145.0 / 255.0, alpha: 1.0), classes: NSUIColor(calibratedRed: 103.0 / 255.0, green: 31.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0))
    #else
    private static let objcHeaderColors = (comments: NSUIColor(red: 0.0, green: 119.0 / 255.0, blue: 0.0, alpha: 1.0), keywords: NSUIColor(red: 193.0 / 255.0, green: 0.0, blue: 145.0 / 255.0, alpha: 1.0), classes: NSUIColor(red: 103.0 / 255.0, green: 31.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0))
    #endif
}

fileprivate extension NSMutableAttributedString {
    func setTextColor(_ color: NSUIColor, font: NSUIFont?, range: NSRange) {
        guard NSMaxRange(range) <= length else {
            return
        }
        var attributes: [NSAttributedString.Key : Any] = [.foregroundColor: color]
        attributes[.font] = font
        setAttributes(attributes, range: range)
    }
}

public extension NSAttributedString.Key {
    /// The Objective-C class name of the text.
    static let objcClassName = NSAttributedString.Key("objcClassName")
    /// The Objective-C protocol name of the text.
    static let objcProtocolName = NSAttributedString.Key("objcProtocolName")
    /// The Objective-C image name of the text.
    static let objcImageName = NSAttributedString.Key("objcImageName")
}
#endif
