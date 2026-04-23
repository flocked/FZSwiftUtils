//
//  MultiDateFormatter.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

/// A date formatter that allows to specify several date format strings for decoding strings to date.
public class MultiDateFormatter: Formatter {
    /// The date format strings used by the receiver.
    public var dateFormats: [String] {
        get { dateFormatter.map({$0.dateFormat}) }
        set { setup(newValue) }
    }
    
    /// Sets the date format strings used by the receiver.
    @discardableResult
    public func dateFormats(_ dateFormats: [String]) -> Self {
        self.dateFormats = dateFormats
        return self
    }
    
    /// The locale for the receiver.
    public var locale: Locale = .current {
        didSet { dateFormatter.forEach({$0.locale = locale}) }
    }
    
    /// Sets the locale for the receiver.
    @discardableResult
    public func locale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    
    /// The time zone for the receiver.
    public var timeZone: TimeZone = .current {
        didSet { dateFormatter.forEach({$0.timeZone = timeZone}) }
    }
    
    /// Sets the time zone for the receiver.
    @discardableResult
    public func timeZone(_ timeZone: TimeZone) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    /// Returns a date representation of a specified string that the system interprets using the receiver’s current settings.
    public func date(from string: String) -> Date? {
        dateFormatter.lazy.compactMap({$0.date(from: string)}).first
    }
    
    public override func string(for obj: Any?) -> String? {
        dateFormatter.first?.string(for: obj)
    }
    
    /// Returns a string representation of a specified date that the system formats using the receiver’s current settings.
    public func string(from date: Date) -> String? {
        dateFormatter.first?.string(from: date)
    }
    
    /// Creates a date formatter with the specified date formats.
    public init(_ dateFormats: [String]) {
        super.init()
        setup(dateFormats)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        timeZone = coder.decodeObject(of: TimeZone.self, forKey: "timeZone") ?? .current
        locale = coder.decodeObject(of: Locale.self, forKey: "locale") ?? .current
        setup(coder.decodeObject(of: [String].self, forKey: "dateFormats") ?? [])
    }
    
    private func setup(_ formats: [String]) {
        let formats = formats.uniqued()
        guard formats != dateFormats else { return }
        let diff = formats.count - dateFormatter.count
        if diff > 0 {
            for _ in 0..<diff {
                let formatter = DateFormatter()
                formatter.locale = locale
                formatter.timeZone = timeZone
                dateFormatter += formatter
            }
        } else if diff < 0 {
            dateFormatter.removeLast(-diff)
        }
        for (index, dateFormat) in formats.enumerated() {
            dateFormatter[index].dateFormat = dateFormat
        }
    }
    
    private var dateFormatter: [DateFormatter] = []
}
