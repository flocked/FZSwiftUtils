//
//  Array+.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

import Foundation

public extension Array {
    /**
     Creates a new array containing the specified number of elements returned by the specifed closure.
     
     Here’s an example of creating an array initialized with five random integers.
     
     ```swift
     let numbers = Array(repeating: { Int.random(in: 0..<10) }, count: 5)
     print(numbers)
     // Prints "[4, 7, 3, 2, 7]"
     ```
     
     - Parameters:
        - repeating: The closure that returns an element.
        - count: The number of times to repeat the closure's value passed in the `repeating` parameter.
     */
    init(repeating: ()->(Element), count: Int) {
        self = count >= 0 ? (0..<count).compactMap({ _ in repeating() }) : []
    }
}

/*
extension Array: Comparable where Element: Comparable {
    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count else { return lhs.count < rhs.count }
        return !zip(lhs, rhs).contains(where: { $0.0 > $0.1 })
    }
}
 */

public extension ArraySlice {
     /// The array slice as `Array`.
    var asArray: [Element] {
        Array(self)
    }
}
