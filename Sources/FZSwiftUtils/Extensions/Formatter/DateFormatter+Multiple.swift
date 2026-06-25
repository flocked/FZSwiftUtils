//
//  DateFormatter+Multiple.swift
//  
//
//  Created by Florian Zand on 23.04.26.
//

import Foundation

extension DateFormatter {
    /// Returns a date formatter that uses the specified date formats for decoding strings to date.
    public static func multiple(_ dateFormats: [String]) -> MultiDateFormatter {
        MultiDateFormatter(dateFormats)
    }
}

/// A date formatter that allows to specify several date format strings for decoding strings to date.
public class MultiDateFormatter: DateFormatter, @unchecked Sendable {
    /// The date format strings used by the receiver.
    public var dateFormats: [String] = [] {
        didSet {
            dateFormats = dateFormats.uniqued()
            dateFormat = dateFormats.first ?? ""
        }
    }
    
    private var iso8601Formatter: ISO8601DateFormatter?
    
    /// A Boolean value indicating whether to also format strings using `ISO860`.
    public var includeISO8601: Bool {
        get { iso8601Formatter != nil }
        set {
            guard newValue != includeISO8601 else { return }
            iso8601Formatter = newValue ? .init() : nil
        }
    }
    
    /// Sets the Boolean value indicating whether to also format strings using `ISO860`.
    @discardableResult
    public func includeISO8601(_ include: Bool) -> Self {
        includeISO8601 = include
        return self
    }
    
    public override func date(from string: String) -> Date? {
        defer { dateFormat = dateFormats.first ?? "" }
        if adjusted { return date(fromAdjusted: string) }
        if let date = iso8601Formatter?.date(from: string) {
            return date
        }
        for dateFormat in dateFormats {
            self.dateFormat = dateFormat
            if let date = super.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    fileprivate func date(fromAdjusted string: String) -> Date? {
        if let date = iso8601Formatter?.date(from: string.replacingOccurrences(ofPattern: #":60(?=(?:[.,]\d+)?(?:Z|[+-]\d{2}:?\d{2})?$)"#, with: ":59")) {
            return date
        }
        for dateFormat in dateFormats {
            self.dateFormat = dateFormat
            if let date = super.date(from: string.adjusted(dateFormat: dateFormat)) {
                return date
            }
        }
        return nil
    }
    
    fileprivate var adjusted = false
    func adjusted(_ adjusted: Bool) -> Self {
        self.adjusted = adjusted
        return self
    }
    
    /// Creates a date formatter with the specified date formats.
    public init(_ dateFormats: [String]) {
        defer { self.dateFormats = dateFormats }
        super.init()
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(dateFormats, forKey: "dateFormats")
        super.encode(with: coder)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        dateFormats = coder.decode("dateFormats") ?? []
    }
}

fileprivate extension String {
    func adjusted(dateFormat: String) -> String {
        guard let range = dateFormat.range(of: "ss") else { return self }
        let offset = dateFormat.distance(from: dateFormat.startIndex, to: range.lowerBound)
        guard let start = index(startIndex, offsetBy: offset, limitedBy: endIndex), let end = index(start, offsetBy: 2, limitedBy: endIndex), self[start..<end] == "60" else { return self }
        var result = self
        result.replaceSubrange(start..<end, with: "59")
        return result
    }
}
