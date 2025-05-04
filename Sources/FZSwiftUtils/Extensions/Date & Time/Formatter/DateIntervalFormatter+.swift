//
//  DateIntervalFormatter+.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

public extension DateIntervalFormatter {
    /// Sets the calendar.
    func calendar(_ calendar: Calendar) -> Self {
        self.calendar = calendar
        return self
    }
    
    /// Sets the locale.
    func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// Sets the time zone.
    func timeZone(_ timeZone: TimeZone) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    /// Sets the style to use when formatting hour, minute, and second information.
    func timeStyle(_ style: Style) -> Self {
        timeStyle = style
        return self
    }
    
    /// Sets the style to use when formatting day, month, and year information.
    func dateStyle(_ style: Style) -> Self {
        dateStyle = style
        return self
    }
    
    /// Sets the template for formatting one date and time value.
    func dateTemplate(_ template: String) -> Self {
        dateTemplate = template
        return self
    }
    
    /// The date components to use.
    var dateComponents: [DateFormat.DateComponent] {
        get { dateTemplate.extractDateComponents() }
        set { dateTemplate = newValue.map({ $0.format }).joined() }
    }
    
    /// Sets the date components to use.
    func dateComponents(_ components: [DateFormat.DateComponent]) -> Self {
        dateComponents = components
        return self
    }
}

fileprivate extension String {
    func extractDateComponents() -> [DateFormat.DateComponent] {
        let knownSymbols: [String] = [
            "MMMMM", "LLLLL", "MMMM", "LLLL", "MMM", "LLL", "MM", "LL", "M", "L",
            "qqqq", "QQQQ", "qqq", "QQQ", "qq", "QQ", "q", "Q",
            "EEEEEE", "cccccc", "eeeeee", // Short
            "EEEEE", "ccccc", "eeeee",   // Narrow
            "EEEE", "cccc", "eeee",    // Full
            "EEE", "ccc", "eee",       // Abbreviated
            "EE",                      // Numeric (Less common in skeletons)
            "E", "c", "e",
            "GGGGG", "GGGG", "GGG", "GG", "G",
            "yyyyy", "YYYYY", // Padding year
            "yyyy", "YYYY",  // Calendar Year / Week-based Year
            "yy", "YY",      // 2-digit year
            "y", "Y",        // Year (usually sufficient)
            "u",             // Extended year
            "ww", // Week of year (2-digit)
            "w",  // Week of year
            "WW", // Week of month (2-digit)
            "W",  // Week of month
            "ddd", // Day of year (3-digit)
            "dd",  // Day of month (2-digit)
            "d",   // Day of month
            "D",   // Day of year
            "F",   // Day of week in month
            "hh", "HH", "kk", "KK", // 2-digit hours
            "h", "H", "k", "K", "j", "J", // Single digit / Locale Preferred
            "mm", "m",
            "ss", "s",
            "SSS", "SS", "S", // Represent precision
            "A", // Milliseconds in day
            "a", "b", "B",
            "zzzz", "vvvv", "ZZZZZ", "ZZZZ", "VVVV", // Full names/locations/offsets
            "zzz", "vvv", // Abbreviated names
            "z", "v", "Z", "V", "O", "X", "x" // Various timezone formats
        ].sorted(.longestFirst)

        var extracted: [String] = []
        var currentIndex = startIndex

        while currentIndex < endIndex {
            var foundMatch = false
            for symbol in knownSymbols {
                // Check if the string `self` has the symbol as a prefix at the current index
                if let range = range( of: symbol, options: [.anchored], range: currentIndex..<endIndex) {
                    extracted.append(symbol)
                    currentIndex = range.upperBound // Move index past the matched symbol
                    foundMatch = true
                    break // Restart search for the *next* symbol from the new position
                }
            }
            if !foundMatch {
                let skippedChar = self[currentIndex]
                let charIndex = distance(from: startIndex, to: currentIndex)
                currentIndex = index(after: currentIndex)
            }
        }
        return extracted.map({ DateFormat.DateComponent( $0) })
    }
}
