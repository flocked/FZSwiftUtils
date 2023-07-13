//
//  Print+.swift
//  
//
//  Created by Florian Zand on 13.07.23.
//

import Foundation

public func printNewLine() {
    Swift.print("\n")
}

public func print<S: StringProtocol>(level: Int, _ value: S) {
    var string = ""
    (0..<level).forEach({ _ in string += "\t" })
    Swift.print(string + value)
}
