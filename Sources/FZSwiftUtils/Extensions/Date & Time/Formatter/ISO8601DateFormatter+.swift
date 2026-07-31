//
//  ISO8601DateFormatter+.swift
//
//
//  Created by Florian Zand on 31.07.26.
//

import Foundation

public extension ISO8601DateFormatter {
    /// Creates an ISO 8601 date formatter with the specified format options and time zone.
    convenience init(options: Options, timeZone: TimeZone? = nil) {
        self.init()
        self.timeZone = timeZone
        self.formatOptions = options
    }
    
    /// Sets the options for generating and parsing ISO 8601 date representations.
    @discardableResult
    func formatOptions(_ options: Options) -> Self {
        self.formatOptions = options
        return self
    }
    
    /// Sets the time zone used to create and parse date representations.
    @discardableResult
    func timeZone(_ timeZone: TimeZone) -> Self {
        self.timeZone = timeZone
        return self
    }
}
