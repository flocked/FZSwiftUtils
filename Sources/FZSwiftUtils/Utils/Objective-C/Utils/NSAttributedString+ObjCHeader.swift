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
    static func updateObjCHeader(_ attributed: NSMutableAttributedString, protocols: [String] = [], font: NSUIFont?) {
        let font = font ?? NSUIFont(name: "SF Mono Regular", size: 13) ?? NSUIFont(name: "Menlo Regular", size: 13) ?? .monospacedSystemFont(ofSize: 13.0, weight: .regular)
        let headerString = attributed.string
        let fullRange = attributed.string.nsRange
        let classes = ObjCRuntime.classNames() + ObjCType.structNames.synchronized
        let structs = ObjCType.structNames.synchronized

        let commentRanges = commentRegex.matches(in: attributed.string, options: [], range: fullRange).map(\.range)
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
                colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywords: objcHeaderkeywords, classes: classes, structs: structs, protocols: protocols, font: font)
            }
            searchLocation = commentRange.location + commentRange.length
        }
        if searchLocation < fullRange.length {
            let range = NSRange(location: searchLocation, length: fullRange.length - searchLocation)
            colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywords: objcHeaderkeywords, classes: classes, structs: structs, protocols: protocols, font: font)
        }
    }
}

extension NSAttributedString {
    static let imageNames = Set(ObjCRuntime.imageNames())
    
    static func objCHeader(for headerString: String, font: NSUIFont? = nil) -> NSAttributedString {
        let font = XcodePresentationTheme.shared.font(for: .argument) ?? font ?? NSUIFont(name: "SF Mono Regular", size: 13) ?? NSUIFont(name: "Menlo Regular", size: 13) ?? .monospacedSystemFont(ofSize: 13.0, weight: .regular)
        let attributed = NSMutableAttributedString(string: headerString, attributes: [.font: font])
        let fullRange = headerString.nsRange
        let classes = ObjCRuntime.classNames()
        let protocols = ObjCRuntime.protocolNames()
        let structs = ObjCType.structNames.synchronized

        let commentRanges = commentRegex.matches(in: headerString, options: [], range: fullRange).map(\.range)
        apply(ranges: commentRanges, to: attributed, color: XcodePresentationTheme.shared.color(for: .comment), font: font)
        
        for commentRange in commentRanges {
            guard let imageMatch = imageRegex.firstMatch(in: headerString, range: commentRange), let pathRange = Range(imageMatch.range(at: 1), in: headerString) else { continue }
            let imagePath = String(headerString[pathRange])
            attributed.addAttribute(.objcImageName, value: imagePath, range: imageMatch.range(at: 1))
        }

        var searchLocation = 0
        for commentRange in commentRanges {
            if searchLocation < commentRange.location {
                let range = NSRange(location: searchLocation, length: commentRange.location - searchLocation)
                colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywords: objcHeaderkeywords, classes: classes, structs: structs, protocols: protocols, font: font)
            }
            searchLocation = commentRange.location + commentRange.length
        }
        if searchLocation < fullRange.length {
            let range = NSRange(location: searchLocation, length: fullRange.length - searchLocation)
            colorIdentifiersAndDirectives(in: headerString, range: range, attributed: attributed, keywords: objcHeaderkeywords, classes: classes, structs: structs, protocols: protocols, font: font)
        }
        return attributed
    }

    private static func colorIdentifiersAndDirectives(in text: String, range: NSRange, attributed: NSMutableAttributedString, keywords: Set<String>, classes: Set<String>, structs: Set<String>, protocols: Set<String>, font: NSUIFont?) {
        tokenRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let match else { return }
            let nsString = text as NSString
            let tokenRange = match.range
            let token = nsString.substring(with: tokenRange)
            if token.utf8.first == UInt8(ascii: "@") {
                attributed.setTextColor(XcodePresentationTheme.shared.color(for: .keyword), font: XcodePresentationTheme.shared.font(for: .keyword), range: tokenRange)
            } else if structs.contains(token) {
                attributed.setTextColor(XcodePresentationTheme.shared.color(for: .type(.struct, .name)), font: XcodePresentationTheme.shared.font(for: .argument), range: tokenRange)
            } else if keywords.contains(token) {
                attributed.setTextColor(XcodePresentationTheme.shared.color(for: .keyword), font: XcodePresentationTheme.shared.font(for: .keyword), range: tokenRange)
            } else if classes.contains(token) {
                attributed.setTextColor(XcodePresentationTheme.shared.color(for: .type(.class, .name)), font: XcodePresentationTheme.shared.font(for: .argument), range: tokenRange)
                attributed.addAttribute(.objcClassName, value: token, range: tokenRange)
            } else if protocols.contains(token) {
                attributed.setTextColor(XcodePresentationTheme.shared.color(for: .type(.protocol, .name)), font: XcodePresentationTheme.shared.font(for: .argument), range: tokenRange)
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

    private static let objcHeaderkeywords: Set<String> = [
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

extension NSMutableAttributedString {
    fileprivate func setTextColor(_ color: NSUIColor, font: NSUIFont?, range: NSRange) {
        guard NSMaxRange(range) <= length else {
            return
        }
        var attributes: [NSAttributedString.Key : Any] = [.foregroundColor: color]
        attributes[.font] = font
        setAttributes(attributes, range: range)
    }
    
    func addObjCDeclarationAttributes(_ declarations: [(line: String, key: NSAttributedString.Key, value: Any)]) {
        let text = string as NSString
        var searchLocation = 0
        for declaration in declarations where !declaration.line.isEmpty {
            let searchRange = NSRange(location: searchLocation, length: text.length - searchLocation)
            let range = text.range(of: declaration.line, options: [], range: searchRange)
            guard range.location != NSNotFound else { continue }
            addAttribute(declaration.key, value: declaration.value, range: range)
            searchLocation = range.location + range.length
        }
    }
}

public extension NSAttributedString.Key {
    /// The Objective-C class name of the text.
    static let objcClassName = NSAttributedString.Key("objcClassName")
    /// The Objective-C protocol name of the text.
    static let objcProtocolName = NSAttributedString.Key("objcProtocolName")
    /// The Objective-C image name of the text.
    static let objcImageName = NSAttributedString.Key("objcImageName")
    
    /// The Objective-C method of the text.
    static let objcMethod = NSAttributedString.Key("objcMethod")
    /// The Objective-C method of the text.
    static let objcClassMethod = NSAttributedString.Key("objcClassMethod")
    /// The Objective-C property of the text.
    static let objcProperty = NSAttributedString.Key("objcProperty")
    /// The Objective-C property of the text.
    static let objcClassProperty = NSAttributedString.Key("objcClassProperty")
    /// The Objective-C ivar of the text.
    static let objcIvar = NSAttributedString.Key("objcIvar")
}

extension NSUIColor {
    convenience init(light: NSUIColor, dark: NSUIColor) {
        #if os(macOS)
        self.init(name: nil) { $0.bestMatch(from: [.aqua, .darkAqua]) == .aqua ? light : dark }
        #else
        self.init { $0.userInterfaceStyle == .dark ? dark : light }
        #endif
    }
}
struct XcodePresentationTheme {
    public static var shared = XcodePresentationTheme()
    
    public var selectionBackgroundColor: NSUIColor = #colorLiteral(red: 0.3904261589, green: 0.4343567491, blue: 0.5144847631, alpha: 1)

    public var backgroundColor: NSUIColor = .init(light: #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.1251632571, green: 0.1258862913, blue: 0.1465735137, alpha: 1))

    public var fontSize: CGFloat = 13

    public func font(for type: SemanticType) -> NSUIFont {
        switch type {
        case .keyword:
            return .monospacedSystemFont(ofSize: fontSize, weight: .semibold)
        default:
            return .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
    }

    private static var colorCache: [SemanticType: NSUIColor] = [:]

    public func color(for type: SemanticType) -> NSUIColor {
        if let existColor = Self.colorCache[type] {
            return existColor
        }
        let light: NSUIColor
        let dark: NSUIColor
        switch type {
        case .comment:
            light = #colorLiteral(red: 0.4095562398, green: 0.4524990916, blue: 0.4956067801, alpha: 1)
            dark = #colorLiteral(red: 0.4976348877, green: 0.5490466952, blue: 0.6000126004, alpha: 1)
        case .keyword:
            light = #colorLiteral(red: 0.7660875916, green: 0.1342913806, blue: 0.4595085979, alpha: 0.8)
            dark = #colorLiteral(red: 0.9686241746, green: 0.2627249062, blue: 0.6156817079, alpha: 1)
        case .variable,
             .function(.declaration),
             .member(.declaration),
             .type(_, .declaration):
            light = #colorLiteral(red: 0.01979870349, green: 0.4877431393, blue: 0.6895453334, alpha: 1)
            dark = #colorLiteral(red: 0.2426597476, green: 0.7430019975, blue: 0.8773110509, alpha: 1)
        case .type(_, .name),
             .function(.name),
             .member(.name):
            light = #colorLiteral(red: 0.2404940426, green: 0.115125142, blue: 0.5072092414, alpha: 1)
            dark = #colorLiteral(red: 0.853918612, green: 0.730949223, blue: 1, alpha: 1)
        case .numeric:
            light = #colorLiteral(red: 0.01564520039, green: 0.2087542713, blue: 1, alpha: 1)
            dark = #colorLiteral(red: 1, green: 0.9160019755, blue: 0.5006220341, alpha: 1)
        case .error:
            light = #colorLiteral(red: 0.831372549, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
            dark = #colorLiteral(red: 0.831372549, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
        default:
            #if os(macOS)
            return .labelColor
            #else
            return .label
            #endif
        }
        let color = NSUIColor(light: light, dark: dark)
        Self.colorCache[type] = color
        return color
    }

    public mutating func fontSizeSmaller() {
        fontSize -= 1
    }

    public mutating func fontSizeLarger() {
        fontSize += 1
    }
}

public enum SemanticType: Hashable, Codable, Sendable {
    public enum TypeKind: CaseIterable, Hashable, Codable, Sendable {
        case `enum`
        case `struct`
        case `class`
        case `protocol`
        case other
    }

    public enum Context: CaseIterable, Hashable, Codable, Sendable {
        case declaration
        case name
    }

    case standard
    case comment
    case keyword
    case variable
    case numeric
    case argument
    case error
    case type(TypeKind, Context)
    case member(Context)
    case function(Context)
    case other
}

#endif
