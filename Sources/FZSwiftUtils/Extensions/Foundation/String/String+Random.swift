//
//  File.swift
//  
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation


extension String {
    public enum RandomizationType: String {
        case numbers = "0123456789"
        case letters = "abcdefghijklmnopqrstuvwxyz"
        case lettersUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }
            
    public static func random(_ types: [RandomizationType] = [.letters, .lettersUppercase], length: Int = 8) -> String {
        let letters = types.map(\.rawValue).reduce("", +)
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public static func random(_ types: [RandomizationType] = [.letters, .lettersUppercase], length: Range<Int>) -> String {
        return self.random(Array(types), length: Int.random(in: length))
    }
}

public extension String {
    static func loremIpsum(ofLength length: Int = 445) -> String {
        guard length > 0 else { return "" }
        let loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        if loremIpsum.count > length {
            return String(loremIpsum[loremIpsum.startIndex..<loremIpsum.index(loremIpsum.startIndex, offsetBy: length)])
        }
        return loremIpsum
    }
}
