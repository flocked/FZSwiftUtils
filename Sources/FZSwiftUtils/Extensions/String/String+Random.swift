//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public extension String {
    enum RandomizationType: String {
        case numbers = "0123456789"
        case letters = "abcdefghijklmnopqrstuvwxyz"
        case lettersUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        case symbols = "+-.,/:;!$%&()=?´`^#'*><-_"
    }

    /**
     Generates a random string.

     - Parameters:
        - types: An array of `RandomizationType` values specifying the types of characters to be used.
        - length: The length of the generated random string.

     - Returns: A randomly generated string based on the specified randomization types and length.
     */
    static func random(using types: [RandomizationType] = [.letters, .lettersUppercase], length: Int = 8) -> String {
        let letters = types.map(\.rawValue).reduce("", +)
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    /**
       Generates a random string.

       - Parameters:
          - types: An array of `RandomizationType` values specifying the types of characters to be used.
          - length: A range representing the length of the generated random string.

       - Returns: A randomly generated string based on the specified randomization types and a random length within the given range.
       */
    static func random(using types: [RandomizationType] = [.letters, .lettersUppercase], length: Range<Int>) -> String {
        return random(using: Array(types), length: Int.random(in: length))
    }
}

public extension String {
    /**
     Generates a lorem ipsum string.

      - Parameters:
         - length: The length of the generated lorem ipsum string.

      - Returns: A lorem ipsum string based on the specified length.
      */
    static func loremIpsum(ofLength length: Int = 445) -> String {
        guard length > 0 else { return "" }
        let loremIpsum = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        if loremIpsum.count > length {
            return String(loremIpsum[loremIpsum.startIndex ..< loremIpsum.index(loremIpsum.startIndex, offsetBy: length)])
        }
        return loremIpsum
    }
}
