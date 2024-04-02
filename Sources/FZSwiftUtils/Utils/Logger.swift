//
//  Logger.swift
//
//
//  Created by Florian Zand on 22.03.24.
//

import Foundation

/*
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
        - indent: The indent level of the print.
        - items: Zero or more items to print.
        - separator: A string to print between each item. The default is a single space (" ").
        - terminator: The string to print after all items have been printed. The default is a newline ("\n").
     */
    public static func print(indent: Int = 0, _ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard state != .inactive else { return }
        func print() {
            if outputFormat == .normal {
                Swift.print(Array(repeating: "\t", count: indent).joined(), items, separator: separator, terminator: terminator)
            } else {
                debugPrint(Array(repeating: "\t", count: indent).joined(), items, separator: separator, terminator: terminator)
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
        - indent: The indent level of the print.
        - items: Zero or more items to print.
        - separator: A string to print between each item. The default is a single space (" ").
        - terminator: The string to print after all items have been printed. The default is a newline ("\n").
        - output: An output stream to receive the text representation of each item.
     */
    public static func print<Target>(indent: Int = 0, _ items: Any..., separator: String = " ", terminator: String = "\n", to output: inout Target
    ) where Target : TextOutputStream {
        guard state != .inactive else { return }
        func print() {
            if outputFormat == .normal {
                Swift.print(Array(repeating: "\t", count: indent).joined(), items, separator: separator, terminator: terminator, to: &output)
            } else {
                debugPrint(Array(repeating: "\t", count: indent).joined(), items, separator: separator, terminator: terminator, to: &output)
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
*/
