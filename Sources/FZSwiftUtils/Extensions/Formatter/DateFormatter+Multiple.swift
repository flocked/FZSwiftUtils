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
public class MultiDateFormatter: DateFormatter {
    /// The date format strings used by the receiver.
    public var dateFormats: [String] = [] {
        didSet {
            dateFormats = dateFormats.uniqued()
            dateFormat = dateFormats.first ?? ""
        }
    }
    
    public override func date(from string: String) -> Date? {
        defer { dateFormat = dateFormats.first ?? "" }
        for dateFormat in dateFormats {
            self.dateFormat = dateFormat
            if let date = super.date(from: string) {
                return date
            }
        }
        return nil
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
        dateFormats = coder.decodeObject(of: [String].self, forKey: "dateFormats") ?? []
    }
}
