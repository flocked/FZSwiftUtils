//
//  ListFormatter+.swift
//
//
//  Created by Florian Zand on 07.11.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension ListFormatter {
    /// Represents the final conjunction used by a list formatter when joining items.
    public enum Conjunction {
        /// And
        case and
        /// Or
        case or
    }
    
    /**
     The final conjunction used when joining the items of the list.
          
     Example:
     ```swift
     let formatter = ListFormatter()
     formatter.conjunction = .or
     formatter.string(from: ["A", "B", "C"]) // "A, B, or C"
     formatter.conjunction = .and
     formatter.string(from: ["A", "B", "C"]) // "A, B, and C"
     ```
     */
    public var conjunction: Conjunction {
        get { orHook == nil ? .and : .or }
        set {
            guard newValue != conjunction else { return }
            if newValue == .or {
                do {
                    orHook = try hook(#selector(ListFormatter.string(for:)), closure: {
                        original, formatter, selector, value in
                        guard let value = original(formatter, selector, value) else { return nil }
                        return value.replacingLastOccurrence(of: ListFormatter.localizedAnd(for: formatter.locale ?? .en), with: ListFormatter.localizedOr(for: formatter.locale ?? .en))
                    } as @convention(block) ((ListFormatter, Selector, Any?) -> String?, ListFormatter, Selector, Any?) -> String?)
                } catch {
                    Swift.print(error)
                }
            } else {
                try? orHook?.revert()
                orHook = nil
            }
        }
    }
    
    /// Returns the localized `"and"` for the specified locale.
    public static func localizedAnd(for locale: Locale = .current) -> String {
        if let value = localizedAnds[locale] { return value }
        shared.locale = locale
        if let value = shared.string(for: ["Val1", "Val2"])?.removingOccurrences(of: ["Val1 ", " Val2"]) {
            localizedAnds[locale] = value
            return value
        }
        shared.locale = .init(identifier: "en")
        let value = shared.string(for: ["Val1", "Val2"])!.removingOccurrences(of: ["Val1 ", " Val2"])
        localizedAnds[locale] = value
        return value
    }
    
    /// Returns the localized `"or"` for the specified locale.
    public static func localizedOr(for locale: Locale = .current) -> String {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            if let value = localizedOrs[locale] {
                return value
            }
            let value = ["Val1", "Val2"].formatted(.list(type: .or).locale(locale)).removingOccurrences(of: ["Val1 ", " Val2"])
            localizedOrs[locale] = value
            return value
        }
        return orTranslations[locale.languageCode ?? "-"] ?? "or"
    }
        
    /**
     Constructs a formatted string from an array of strings that uses the list format specific to the current locale.
     
     - Tip: Use this method to join strings that are ready to be displayed in a bullet-point list. Sentences, phrases with punctuations, and appositions may not work well when joined together.
     
     - Parameters:
        - strings: An array of strings to join together in a list.
        - conjunction: The final conjunction used when joining the strings.
     - Returns: A formatted string that joins together a list of strings using a locale-specific list format.
     */
    public class func localizedString(byJoining strings: [String], conjunction: Conjunction) -> String {
        let string = localizedString(byJoining: strings)
        return conjunction == .and ? string : string.replacingLastOccurrence(of: ListFormatter.localizedAnd(), with: ListFormatter.localizedOr())
    }
    
    private var orHook: Hook? {
        get { getAssociatedValue("orHook") }
        set { setAssociatedValue(newValue, key: "orHook") }
    }
    
    private static let shared = ListFormatter()
    
    private static let orTranslations: [String: String] = [
        "en": "or",       // English
        "es": "o",        // Spanish
        "fr": "ou",       // French
        "de": "oder",     // German
        "zh": "或者",      // Chinese (Simplified)
        "hi": "या",       // Hindi
        "ar": "أو",       // Arabic
        "pt": "ou",       // Portuguese
        "ru": "или",      // Russian
        "ja": "または",    // Japanese
        "bn": "বা",       // Bengali
        "pa": "ਜਾਂ",      // Punjabi
        "mr": "किंवा",    // Marathi
        "te": "లేదా",    // Telugu
        "ta": "அல்லது",   // Tamil
        "tr": "veya",     // Turkish
        "vi": "hoặc",     // Vietnamese
        "ko": "또는",      // Korean
        "it": "o",        // Italian
        "pl": "lub"       // Polish
    ]
    
    private static var localizedAnds: [Locale: String] = [:]
    private static var localizedOrs: [Locale: String] = [:]
}

fileprivate extension String {
    func replacingLastOccurrence(of target: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\s+\(NSRegularExpression.escapedPattern(for: target))\\s+", options: []) else { return self }
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        guard let lastMatch = matches.last else { return self }
        return nsString.replacingCharacters(in: lastMatch.range, with: " \(replacement) ")
    }
}
#endif
