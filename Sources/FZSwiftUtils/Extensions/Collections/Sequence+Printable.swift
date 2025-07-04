//
//  Sequence+Printable.swift
//
//
//  Created by Florian Zand on 04.07.25.
//


import Foundation

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
