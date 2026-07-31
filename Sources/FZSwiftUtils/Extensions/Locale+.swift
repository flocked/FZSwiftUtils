//
//  Locale+.swift
//
//
//  Created by Florian Zand on 13.02.25.
//

import Foundation


extension Locale {
    /// The localized display name.
    public var localizedDisplayName: String? {
        if identifier.hasPrefix("zh-Han") {
            guard let trimmed = localizedString(forIdentifier: identifier)?.replacingOccurrences(of: "[（）]", with: "", options: .regularExpression) else { return nil }
            return String(trimmed.suffix(2) + trimmed.prefix(2))
        } else {
            return localizedString(forIdentifier: identifier)
        }
    }
    
    /// Returns the localized display name for the specified locale.
    public func localizedDisplayName(for locale: Locale) -> String? {
        if locale.identifier.hasPrefix("zh-Han") {
            guard let trimmed = localizedString(forIdentifier: locale.identifier)?.replacingOccurrences(of: "[（）]", with: "", options: .regularExpression) else { return nil }
            return String(trimmed.suffix(2) + trimmed.prefix(2))
        } else {
            return localizedString(forIdentifier: locale.identifier)
        }
    }
    
    /// Returns the localized display name in the specified locale.
    public func localizedDisplayName(in locale: Locale) -> String? {
        locale.localizedDisplayName(for: self)
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
    
    /// A locale representing the user system's primary language.
    public static var system: Locale {
        return Locale(identifier: preferredLanguages.first ?? "en")
    }
    
    /// An array of available locales.
    public static var available: [Locale] {
        availableIdentifiers.map(Locale.init(identifier:))
    }

    /// An array of locales for the user's preferred languages.
    public static var preferred: [Locale] {
        preferredLanguages.map(Locale.init(identifier:))
    }
    
    /**
     Returns the language locale for the current locale without any region information.

     For example, `en_US` becomes `en` and `de_CH` becomes `de`.
     */
    public var base: Locale {
        languageCode.map({ Locale(identifier: $0) }) ?? self
    }
    
    /**
     Returns the available regional variants for the locale's language.

     For example, the `en` locale includes variants such as `en_US`, `en_GB`, and `en_AU`.
     */
    public var regionalVariants: [Locale] {
        Locale.available.grouped(by: \._languageCode)[_languageCode]?.filter { $0.regionCode != nil } ?? []
    }
    
    private var _languageCode: String {
        languageCode ?? identifier
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
public extension Locale {
    /// Creates a locale with the specified language code, script, and region identifier.
    init(_ languageCode: Locale.LanguageCode?, script: Locale.Script? = nil, languageRegion: Locale.Region? = nil) {
        self = Locale(languageCode: languageCode, script: script, languageRegion: languageRegion)
    }
    
    /// Returns a localized string for a specified language code.
    func localizedString(forLanguageCode languageCode: LanguageCode) -> String? {
        localizedString(forLanguageCode: languageCode.identifier)
    }
    
    /// Returns a localized string for a specified language.
    func localizedString(forLanguage language: Language) -> String? {
        language.languageCode.flatMap({ localizedString(forLanguageCode: $0) })
    }
    
    /// Returns a localized string for a specified script.
    func localizedString(forScript script: Script) -> String? {
        localizedString(forScriptCode: script.identifier)
    }
    
    /// Returns a localized string for a specified region.
    func localizedString(forRegion region: Region) -> String? {
        localizedString(forRegionCode: region.identifier)
    }
    
    /// Returns a localized string for a specified currency.
    func localizedString(forCurrency currency: Currency) -> String? {
        localizedString(forCurrencyCode: currency.identifier)
    }
    
    /// Returns a localized string for a specified variant.
    func localizedString(forVariant variant: Variant) -> String? {
        localizedString(forVariantCode: variant.identifier)
    }
    
    /// Returns a localized string for a specified collation.
    func localizedString(forCollation collation: Collation) -> String? {
        localizedString(forCollationIdentifier: collation.identifier)
    }
    
    /// The continent that contains this locale.
    var continent: Continent {
        region?.continent.map({ Continent(rawValue: $0.identifier) }) ?? .unknown
    }
    
    /// Returns a localized string for a specified continent.
    func localizedString(forContient continent: Continent) -> String? {
        localizedString(forRegionCode: continent.region.identifier)
    }
    
    /// A type that represents a continent, for use in specifying a locale.
    struct Continent: RawRepresentable, Hashable, Codable, Sendable, CaseIterable {
        /// Europe.
        public static let europe = Self(rawValue: "150")
        /// Americas.
        public static let americas = Self(rawValue: "019")
        /// Africa.
        public static let africa = Self(rawValue: "002")
        /// Oceania.
        public static let oceania = Self(rawValue: "009")
        /// Asia.
        public static let asia = Self(rawValue: "142")
        /// Unknown.
        public static let unknown = Self(rawValue: "ZZ")
        
        public static let allCases: [Self] = [.africa, .americas, .asia, .europe, .oceania, .unknown]
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// The locales whose regions are located in the continent.
        public var locales: [Locale] {
            Locale.available.filter({ $0.continent == self }).sorted(by: \.identifier)
        }
        
        /// The region representing the continent.
        public var region: Region {
            Region(rawValue)
        }
    }
}

extension Locale {
    /// A fixed locale for consistent, locale-independent formatting and parsing.
    public static let posix = Locale(identifier: "en_US_POSIX")
    
    /// English.
    public static let english = Locale(identifier: "en")
    /// English.
    public static let en = Locale(identifier: "en")
    /// English (United States).
    public static let englishUS = Locale(identifier: "en-US")
    /// English (United States).
    public static let enUS = Locale(identifier: "en-US")
    /// English (United Kingdom).
    public static let englishGB = Locale(identifier: "en-GB")
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
    
    /// Portuguese.
    public static let portuguese = Locale(identifier: "pt")
    /// Portuguese.
    public static let pt = Locale(identifier: "pt")
    /// Portuguese (Brazil).
    public static let portugueseBR = Locale(identifier: "pt-BR")
    /// Portuguese (Brazil).
    public static let ptBR = Locale(identifier: "pt-BR")
    /// Portuguese (Portugal).
    public static let portuguesePT = Locale(identifier: "pt-PT")
    /// Portuguese (Portugal).
    public static let ptPT = Locale(identifier: "pt-PT")
    
    /// Korean.
    public static let korean = Locale(identifier: "ko")
    /// Korean.
    public static let ko = Locale(identifier: "ko")
    /// Korean (South Korea).
    public static let koreanKR = Locale(identifier: "ko-KR")
    /// Korean (South Korea).
    public static let koKR = Locale(identifier: "ko-KR")
    
    /// Dutch.
    public static let dutch = Locale(identifier: "nl")
    /// Dutch.
    public static let nl = Locale(identifier: "nl")
    /// Dutch (Netherlands).
    public static let dutchNL = Locale(identifier: "nl-NL")
    /// Dutch (Netherlands).
    public static let nlNL = Locale(identifier: "nl-NL")
    
    /// Arabic.
    public static let arabic = Locale(identifier: "ar")
    /// Arabic.
    public static let ar = Locale(identifier: "ar")
    /// Arabic (Saudi Arabia).
    public static let arabicSA = Locale(identifier: "ar-SA")
    /// Arabic (Saudi Arabia).
    public static let arSA = Locale(identifier: "ar-SA")
    
    /// Hindi.
    public static let hindi = Locale(identifier: "hi")
    /// Hindi.
    public static let hi = Locale(identifier: "hi")
    /// Hindi (India).
    public static let hindiIN = Locale(identifier: "hi-IN")
    /// Hindi (India).
    public static let hiIN = Locale(identifier: "hi-IN")
    
    /// Turkish.
    public static let turkish = Locale(identifier: "tr")
    /// Turkish.
    public static let tr = Locale(identifier: "tr")
    /// Turkish (Türkiye).
    public static let turkishTR = Locale(identifier: "tr-TR")
    /// Turkish (Türkiye).
    public static let trTR = Locale(identifier: "tr-TR")
    
    /// Polish.
    public static let polish = Locale(identifier: "pl")
    /// Polish.
    public static let pl = Locale(identifier: "pl")
    /// Polish (Poland).
    public static let polishPL = Locale(identifier: "pl-PL")
    /// Polish (Poland).
    public static let plPL = Locale(identifier: "pl-PL")
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
