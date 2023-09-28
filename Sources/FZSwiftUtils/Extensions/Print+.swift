//
//  Print+.swift
//  
//
//  Created by Florian Zand on 13.07.23.
//

import Foundation

/**
 Writes the textual representations of the given items most suitable for debugging into the standard output.
 
 - Parameters:
    - leading: The string to print before all items have been printed.
    - items: Zero or more items to print.
    - seperator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func print(leading: String, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    Swift.print([leading] + [items], separator: separator, terminator: terminator)
}

/**
 Writes the textual representations of the given items most suitable for debugging into the standard output.
 
 - Parameters:
    - indent: The indent level of the print.
    - leading: The string to print before all items have been printed. The default is ("").
    - items: Zero or more items to print.
    - seperator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func print(indent: Int, leading: String = "", _ items: Any..., separator: String = " ", terminator: String = "\n") {
    let leading = Array(repeating: "\t", count: indent).joined() + leading
    Swift.print([leading] + [items], separator: separator, terminator: terminator)
}

/**
 Writes the textual representations of the given items most suitable for debugging into the standard output.
 
 - Parameters:
    - leading: The string to print before all items have been printed.
    - items: Zero or more items to print.
    - seperator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func debugPrint(leading: String, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    Swift.debugPrint([leading] + [items], separator: separator, terminator: terminator)
}

/**
 Writes the textual representations of the given items most suitable for debugging into the standard output.
 
 - Parameters:
    - indent: The indent level of the print.
    - leading: The string to print before all items have been printed. The default is ("").
    - items: Zero or more items to print.
    - seperator: A string to print between each item. The default is a single space (" ").
    - terminator: The string to print after all items have been printed. The default is a newline ("\n").
 */
public func debugPrint(indent: Int, leading: String = "", _ items: Any..., separator: String = " ", terminator: String = "\n") {
    let leading = Array(repeating: "\t", count: indent).joined() + leading
    Swift.debugPrint([leading] + [items], separator: separator, terminator: terminator)
}
