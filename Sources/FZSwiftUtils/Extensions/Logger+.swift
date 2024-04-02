//
//  Logger+.swift
//
//
//  Created by Florian Zand on 29.03.24.
//

import Foundation
import os


@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    
    /// Networking logger.
    public static let networking = Logger(subsystem: subsystem, category: "Networking")
    
    /// Presentation logger.
    public static let presentation = Logger(subsystem: subsystem, category: "Presentation")
}
