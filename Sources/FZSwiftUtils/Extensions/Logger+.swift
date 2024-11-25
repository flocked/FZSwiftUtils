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
    static let subsystem = Bundle.main.bundleIdentifier ?? Bundle.main.bundlePath
    
    /// Presentation logger.
    public static let presentation = Logger(subsystem: subsystem, category: "Presentation")
    
    /// Networking logger.
    public static let networking = Logger(subsystem: subsystem, category: "Networking")
    
    /// Writes a message to the log with the specified items using the default log type.
    public func notice(indent: Int = 0, items: Any..., separator: String = " ") {
        notice("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes a debug message to the log with the specified items.
    public func debug(indent: Int = 0, items: Any..., separator: String = " ") {
        debug("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes a trace message to the log with the specified items.
    public func trace(indent: Int = 0, items: Any..., separator: String = " ") {
        trace("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes an informative message to the log with the specified items.
    public func info(indent: Int = 0, items: Any..., separator: String = " ") {
        info("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes information about an error to the log with the specified items.
    public func error(indent: Int = 0, items: Any..., separator: String = " ") {
        error("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes information about a warning to the log with the specified items.
    public func warning(indent: Int = 0, items: Any..., separator: String = " ") {
        warning("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes a message to the log with the specified items about a bug that occurs when your app executes.
    public func fault(indent: Int = 0, items: Any..., separator: String = " ") {
        fault("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
    
    /// Writes a message to the log with the specified items about a critical event in your app’s execution.
    public func critical(indent: Int = 0, items: Any..., separator: String = " ") {
        critical("\(Array(repeating: "\t", count: indent).joined())\(items.compactMap({String(describing: $0)}).joined(separator: separator))")
    }
}
