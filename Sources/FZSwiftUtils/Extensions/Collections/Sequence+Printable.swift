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
        map { String(describingNil: $0) }.printable(newLines: newLines)
    }
}

extension Dictionary {
    /**
     Returns a formatted string representation of the dictionary.

     - Parameter newLines: A `Boolean` value indicating whether to format each key-value pair on a new line.
     */
    public func printableDescription(newLines: Bool = false) -> String {
        map { (key, value) -> String in
            let keyStr = String(describingNil: key)
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
        map { "\(String(describingNil: $0.key)): \(String(describingNil: $0.value))" }.printable(newLines: newLines)
    }
}

fileprivate extension [String] {
    func printable(newLines: Bool) -> String {
        newLines ? "[\n\(map { "  \($0)" }.joined(separator: ",\n"))\n]" : "[\(joined(separator: ", "))]"
    }
}

fileprivate extension String {
    init<Subject>(describingNil instance: Subject) where Subject : TextOutputStreamable {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    init<Subject>(describingNil instance: Subject) where Subject : CustomStringConvertible {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    init<Subject>(describingNil instance: Subject) where Subject : CustomStringConvertible, Subject : TextOutputStreamable {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    init<Subject>(describingNil instance: Subject) {
        if let instance = instance as? String {
            self = "\"\(instance)\""
        } else {
            self = String(describing: instance).nonNil
        }
    }
    
    var nonNil: String {
        var result = self
        while true {
            let matches = result.matches(pattern: #"Optional\(([^()]*?)\)"#)
            if matches.isEmpty { break }
            for match in matches.reversed() {
                if let content = match.groups[safe: 0]?.string {
                    if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
                    result.replaceSubrange(match.range, with: String(content))
                }
            }
        }
        return result
    }
}

