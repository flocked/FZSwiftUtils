//
//  Logger.swift
//
//
//  Created by Florian Zand on 22.03.24.
//

import Foundation

/// Logging utility that prints textual representations of objects.
public struct Logger {
    
    /// The state of the logger.
    public enum State: Int {
        /// Active.
        case active
        /// Active when debugging.
        case activeWhenDebugging
        /// Inactive.
        case inactive
    }
    
    /// The output format of the logger.
    public enum OutputFormat: Int {
        /// Normal.
        case normal
        /// Debug.
        case debug
    }
    
    /// The state of the logger.
    public static var state: State = .activeWhenDebugging
    
    /// The output format of the logger.
    public static var outputFormat: OutputFormat = .debug
    
    /**
     Writes the textual representations of the given items into the standard output.
     
     - Parameters:
        - items: Zero or more items to print.
        - separator: A string to print between each item. The default is a single space (" ").
        - terminator: The string to print after all items have been printed. The default is a newline ("\n").
     */
    public static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard state != .inactive else { return }
        func print() {
            if outputFormat == .normal {
                Swift.print(items, separator: separator, terminator: terminator)
            } else {
                Swift.debugPrint(items, separator: separator, terminator: terminator)
            }
        }
        #if DEBUG
        print()
        #else
        guard state == .active else { return }
        print()
        #endif
    }
    
    /**
     Writes the textual representations of the given items into the given output stream.
     
     - Parameters:
        - items: Zero or more items to print.
        - separator: A string to print between each item. The default is a single space (" ").
        - terminator: The string to print after all items have been printed. The default is a newline ("\n").
        - output: An output stream to receive the text representation of each item.
     */
    public static func print<Target>(_ items: Any..., separator: String = " ", terminator: String = "\n", to output: inout Target
    ) where Target : TextOutputStream {
        guard state != .inactive else { return }
        func print() {
            if outputFormat == .normal {
                Swift.print(items, separator: separator, terminator: terminator, to: &output)
            } else {
                Swift.debugPrint(items, separator: separator, terminator: terminator, to: &output)
            }
        }
        #if DEBUG
        print()
        #else
        guard state == .active else { return }
        print()
        #endif
    }
}
