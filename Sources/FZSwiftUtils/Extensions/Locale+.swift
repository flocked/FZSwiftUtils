//
//  Locale+.swift
//
//
//  Created by Florian Zand on 13.02.25.
//

import Foundation


extension Locale {
    /// A type that represents a continent, for use in specifying a locale.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public enum Continent: String {
        /// Europe.
        case europe = "150"
        /// America.
        case america = "019"
        /// Africa.
        case africa = "002"
        /// Oceania.
        case oceania = "009"
        /// Asia.
        case asia = "142"
        /// Unknown.
        case unknown = "ZZ"
        
        /// The identifier of the continent.
        public var identifier: String {
            rawValue
        }
        
        /// An array of all locales that the continent contains.
        public var locales: [Locale] {
            Locale.availableLocales.filter({ $0.continent == self }).sorted(by: \.identifier)
        }
        
        /// The `Region` representing the continent.
        public var region: Region {
            Region(identifier)
        }
    }
    
    /// The continent that contains this locale.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public var continent: Continent {
        guard let identifier = region?.continent?.identifier else { return .unknown }
        return Continent(rawValue: identifier)!
    }
    
    /// Returns a localized string for a specified continent.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forContient continent: Continent) -> String? {
        localizedString(forRegionCode: continent.region.identifier)
    }
    
    /**
     Returns the localized string by localizing the specified locale to the receiver's locale.
     
     For example, if the receiver is “en” locale:
        - "es" locale returns "Spanish"
        - "fr" locale returns "French"
        - "ja" locale returns "Japanese"

     - Parameter locale: The `Locale`
     - Returns: A localized string for the specified locale, or `nil` if not available.
     */
    public func localizedString(for locale: Locale) -> String? {
        localizedString(forIdentifier: locale.identifier)
    }
    
    /**
     Returns the localized string by localizing the receiver's locale to the specified locale.
          
     For example, if the receiver is “en” locale:
        - "es" locale returns "español"
        - "fr" locale returns "français"
        - "ja" locale returns "日本語"

     - Parameter locale: The `Locale` to localize to.
     - Returns: A localized string by localizing to the specified locale, or `nil` if not available.
     */
    public func localizedString(byLocalizingTo locale: Locale) -> String? {
        locale.localizedString(for: self)
    }
    
    /// Returns the localized string by localizing the receiver's locale to the `.current` locale.
    public var localizedString: String? {
        localizedString(byLocalizingTo:.autoupdatingCurrent)
    }
    
    /// Returns a localized string for a specified language code.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forLanguageCode languageCode: LanguageCode) -> String? {
        localizedString(forLanguageCode: languageCode.identifier)
    }
    
    /// Returns a localized string for a specified language.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forLanguage language: Language) -> String? {
        guard let languageCode = language.languageCode else { return nil }
        return localizedString(forLanguageCode: languageCode)
    }
    
    /// Returns a localized string for a specified script.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forScript script: Script) -> String? {
        localizedString(forScriptCode: script.identifier)
    }
    
    /// Returns a localized string for a specified region.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forRegion region: Region) -> String? {
        localizedString(forRegionCode: region.identifier)
    }
    
    /// Returns a localized string for a specified currency.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forCurrency currency: Currency) -> String? {
        localizedString(forCurrencyCode: currency.identifier)
    }
    
    /// Returns a localized string for a specified variant.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forVariant variant: Variant) -> String? {
        localizedString(forVariantCode: variant.identifier)
    }
    
    /// Returns a localized string for a specified collation.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public func localizedString(forCollation collation: Collation) -> String? {
        localizedString(forCollationIdentifier: collation.identifier)
    }
    
    /// A locale representing the user system's primary language.
    public static var system: Locale {
        return Locale(identifier: preferredLanguages.first ?? "en")
    }
    
    /// An array of available `Locale`s.
    public static let availableLocales = Locale.availableIdentifiers.compactMap({Locale(identifier: $0)})
    
    /// An array of `Locale`s of the user’s preferred languages.
    public static let preferredLocales = Locale.preferredLanguages.compactMap({Locale(identifier: $0)})
    
    /**
     Returns the base locale (language) for the current locale without any region information.
     
     For example, if the receiver locale is `en_US` or `en_GB`, it returns a locale with the identifier `en`.
     */
    public var baseLocale: Locale {
        Locale(identifier: _languageCode)
    }
    
    /// Returns an array of regional variants for the locale.
    public var regionalVariants: [Locale] {
        let mappedRegions = Dictionary(grouping: Locale.availableLocales, by: \._languageCode).compactMapKeys({ Locale(identifier: $0) })
        return (mappedRegions.first(where: { val in val.value.contains(where: { $0.identifier == identifier }) || val.key.identifier == identifier })?.value ?? []).filter({$0.regionCode != nil})
    }
    
    private var _languageCode: String {
        languageCode ?? identifier.components(separatedBy: "_").first ?? identifier
    }
}

extension Locale {
    /// Creates a locale with the specified language code, script, and region identifier.
    @available(macOS 13, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public init(_ languageCode: Locale.LanguageCode?, script: Locale.Script? = nil, languageRegion: Locale.Region? = nil) {
        self = Locale(languageCode: languageCode, script: script, languageRegion: languageRegion)
    }
    
    /// English.
    public static let english = Locale(identifier: "en")
    /// English.
    public static let en = Locale(identifier: "en")
    
    /// English (United States).
    public static let englishUS = Locale(identifier: "en-US")
    /// English (United States).
    public static let enUS = Locale(identifier: "en-US")
    
    /// English (United Kingdom).
    public static let englishUK = Locale(identifier: "en-GB")
    /// English (United Kingdom).
    public static let enGB = Locale(identifier: "en-GB")
        
    /// English (Canada).
    public static let englishCA = Locale(identifier: "en-CA")
    /// English (Canada).
    public static let enCA = Locale(identifier: "en-CA")
    
    /// German.
    public static let german = Locale(identifier: "de")
    /// German.
    public static let de = Locale(identifier: "de")
    
    /// German (Germany).
    public static let germanDE = Locale(identifier: "de-DE")
    /// German (Germany).
    public static let deDE = Locale(identifier: "de-DE")
    
    /// French.
    public static let french = Locale(identifier: "fr")
    /// French.
    public static let fr = Locale(identifier: "fr")
    
    /// French (France).
    public static let frenchFR = Locale(identifier: "fr-FR")
    /// French (France).
    public static let frFR = Locale(identifier: "fr-FR")
    
    /// Spanish.
    public static let spanish = Locale(identifier: "es")
    /// Spanish.
    public static let es = Locale(identifier: "es")
    
    /// Spanish (Spain).
    public static let spanishES = Locale(identifier: "es-ES")
    /// Spanish (Spain).
    public static let esES = Locale(identifier: "es-ES")
    
    /// Italian.
    public static let italian = Locale(identifier: "it")
    /// Italian.
    public static let it = Locale(identifier: "it")
    
    /// Italian (Italy).
    public static let italianIT = Locale(identifier: "it-IT")
    /// Italian (Italy).
    public static let itIT = Locale(identifier: "it-IT")
    
    /// Japanese.
    public static let japanese = Locale(identifier: "ja")
    /// Japanese.
    public static let ja = Locale(identifier: "ja")
    
    /// Japanese (Japan).
    public static let japaneseJP = Locale(identifier: "ja-JP")
    /// Japanese (Japan).
    public static let jaJP = Locale(identifier: "ja-JP")
    
    /// Chinese.
    public static let chinese = Locale(identifier: "zh")
    /// Chinese.
    public static let zh = Locale(identifier: "zh")
    
    /// Chinese (Simplified, China).
    public static let chineseCN = Locale(identifier: "zh-CN")
    /// Chinese (Simplified, China).
    public static let zhCN = Locale(identifier: "zh-CN")
    
    /// Chinese (Traditional, Taiwan).
    public static let chineseTW = Locale(identifier: "zh-TW")
    /// Chinese (Traditional, Taiwan).
    public static let zhTW = Locale(identifier: "zh-TW")
    
    /// Russian.
    public static let russian = Locale(identifier: "ru")
    /// Russian.
    public static let ru = Locale(identifier: "ru")
    
    /// Russian (Russia).
    public static let russianRU = Locale(identifier: "ru-RU")
    /// Russian (Russia).
    public static let ruRU = Locale(identifier: "ru-RU")
    
    /// A fixed locale for consistent, locale-independent formatting and parsing.
    public static let posix = Locale(identifier: "en_US_POSIX")
}

extension Sequence where Element == Locale {
    /**
     Returns the dictionary of localized strings by localizing the specified locale to the locales of of the sequence.

     - Parameter locale: The `Locale`
     - Returns: A dictionary where the keys are the `Locale` elements and the values are the corresponding localized strings.
    */
    public func localizedStrings(for locale: Locale) -> [Locale: String] {
        reduce(into: [Locale: String]()) { partialResult, element in
            partialResult[element] = locale.localizedString(for: element)
        }
    }
    
    /**
     Returns the dictionary of localized strings by localizing the locales of the sequence to the specified locale.

     - Parameter locale: The `Locale` object to localize to. Defaults to the `.current` locale.
     - Returns: A dictionary where the keys are the `Locale` elements and the values are the corresponding localized strings.
     */
    public func localizedStrings(byLocalizingTo locale: Locale = .current) -> [Locale: String] {
        reduce(into: [Locale: String]()) { partialResult, element in
            partialResult[element] = locale.localizedString(byLocalizingTo: element)
        }
    }
}
