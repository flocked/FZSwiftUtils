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
    public func notice(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .default, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes a debug message to the log with the specified items.
    public func debug(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .debug, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes a trace message to the log with the specified items.
    public func trace(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .debug, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes an informative message to the log with the specified items.
    public func info(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .info, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes information about an error to the log with the specified items.
    public func error(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .error, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes information about a warning to the log with the specified items.
    public func warning(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .error, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes a message to the log with the specified items about a bug that occurs when your app executes.
    public func fault(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .fault, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    /// Writes a message to the log with the specified items about a critical event in your app’s execution.
    public func critical(_ items: Any..., indent: Int = 0, separator: String = " ", debug: Bool = false) {
        log(level: .fault, items: items, indent: indent, separator: separator, debug: debug)
    }
    
    func log(level: OSLogType, items: [Any], indent: Int, separator: String, debug: Bool) {
        let message = "  ".repeating(amount: indent) + items.compactMap({debug ? String(reflecting: $0) : String(describing: $0)}).joined(separator: separator)
        log(level: level, "\(message)")
    }
}

/**
 Writes the textual representations of the given items into the standard output.
 
 - Parameters:
    - items: Zero or more items to print.
    - indent: The indent of the printed string.
    - separator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func print(_ items: Any..., indent: Int = 0, separator: String = " ", terminator: String = "\n") {
    print("  ".repeating(amount: indent) + items.compactMap({ String(describing: $0) }).joined(separator: separator), terminator: terminator)
}

/**
 Writes the textual representations of the given items most suitable for debugging into the standard output.
 
 - Parameters:
    - items: Zero or more items to print.
    - indent: The indent of the printed string.
    - separator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func debugPrint(_ items: Any..., indent: Int = 0, separator: String = " ", terminator: String = "\n") {
    print("  ".repeating(amount: indent) + items.compactMap({ String(reflecting: $0) }).joined(separator: separator), terminator: terminator)
}
