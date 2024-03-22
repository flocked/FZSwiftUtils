//
//  Logger.swift
//
//
//  Created by Florian Zand on 22.03.24.
//

import Foundation

/// Logging utility that prints textual representations of objects.
public struct Logger {
    /// The activation state of the logger.
    public enum State: Int {
        /// The logger is active.
        case active
        /// The logger is active when debugging.
        case activeIfDebugging
        /// The logger is inactive.
        case inactive
    }
    
    /// The activation state.
    public static var state: State = .activeIfDebugging
    
    /**
     Writes the textual representations of the given items into the standard output.
     
     - Parameters:
        - items: Zero or more items to print.
        - separator: A string to print between each item. The default is a single space (" ").
        - terminator: The string to print after all items have been printed. The default is a newline ("\n").
     */
    public static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard state != .inactive else { return }
        if state == .active {
            Swift.print(items, separator: separator, terminator: terminator)
        } else {
            Swift.debugPrint(items, separator: separator, terminator: terminator)
        }
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
        if state == .active {
            Swift.print(items, separator: separator, terminator: terminator, to: &output)
        } else {
            Swift.debugPrint(items, separator: separator, terminator: terminator, to: &output)
        }
    }
}
