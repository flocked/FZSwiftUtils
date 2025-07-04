//
//  Sequence+Printable.swift
//
//
//  Created by Florian Zand on 04.07.25.
//


import Foundation

extension Sequence {
    /**
     Writes the textual representations of each element of the sequence into the standard output.
     
     - Parameters:
        - separator: A string to print between each item. The default is a single space (`" "`).
        - terminator: The string to print after all items have been printed. The default is a newline (`"\n"`).
        - includeIndex: A Boolean value indicating whether to include the index of each element.
     */
    public func printEach(separator: String = " ", terminator: String = "\n") {
        forEach({ print($0, separator: separator, terminator: terminator) })
    }
    
    /**
     Writes the textual representations of each element of the sequence for debugging into the standard output.
     
     - Parameters:
        - separator: A string to print between each item. The default is a single space (`" "`).
        - terminator: The string to print after all items have been printed. The default is a newline (`"\n"`).
        - includeIndex: A Boolean value indicating whether to include the index of each element.
     */
    public func debugPrintEach(separator: String = " ", terminator: String = "\n") {
        forEach({ debugPrint($0, separator: separator, terminator: terminator) })
    }
}

extension Collection {
    /**
     Writes the textual representations of each element of the collection into the standard output.
     
     - Parameters:
        - includeIndex: A Boolean value indicating whether to include the index of each element.
        - separator: A string to print between each element. The default is a single space (`" "`).
        - terminator: The string to print after all element have been printed. The default is a newline (`"\n"`).
     */
    public func printEach(includeIndex: Bool, separator: String = " ", terminator: String = "\n") {
        includeIndex ? indexed().forEach({ print("\($0.index): \($0.element)", separator: separator, terminator: terminator) }) : forEach({ print($0, separator: separator, terminator: terminator) })
    }
    
    /**
     Writes the textual representations of each element of the collection for debugging into the standard output.
     
     - Parameters:
        - includeIndex: A Boolean value indicating whether to include the index of each element.
        - separator: A string to print between each element. The default is a single space (`" "`).
        - terminator: The string to print after all element have been printed. The default is a newline (`"\n"`).
     */
    public func debugPrintEach(includeIndex: Bool, separator: String = " ", terminator: String = "\n") {
        includeIndex ? indexed().forEach({ debugPrint("\($0.index): \($0.element)", separator: separator, terminator: terminator) }) : forEach({ debugPrint($0, separator: separator, terminator: terminator) })
    }
}

extension Sequence {
    /**
     Returns a formatted string representation of the sequence.
     
     - Parameter newLines: A `Boolean` value indicating whether to format each element on a new line.
     */
    public func printableDescription(newLines: Bool = false) -> String {
        map { String(cleanDescribing: $0) }.printable(newLines: newLines)
    }
}

extension Dictionary {
    /**
     Returns a formatted string representation of the dictionary.

     - Parameter newLines: A `Boolean` value indicating whether to format each key-value pair on a new line.
     */
    public func printableDescription(newLines: Bool = false) -> String {
        map { (key, value) -> String in
            let keyStr = String(cleanDescribing: key)
            let valueStr = value is String ? "\"\(value)\"" : "\(value)"
            return "\(keyStr): \(valueStr)"
        }.printable(newLines: newLines)
    }
}

extension KeyValuePairs {
    /**
     Returns a formatted string representation of the key value pairs.

     - Parameter newLines: A `Boolean` value indicating whether to format each key-value pair on a new line.
     */
    public func printableDescription(newLines: Bool = false) -> String {
        map { "\(String(cleanDescribing: $0.key)): \(String(cleanDescribing: $0.value))" }.printable(newLines: newLines)
    }
}

fileprivate extension [String] {
    func printable(newLines: Bool) -> String {
        newLines ? "[\n\(map { "  \($0)" }.joined(separator: ",\n"))\n]" : "[\(joined(separator: ", "))]"
    }
}
