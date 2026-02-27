//
//  Sequence+Flat.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation


public extension Sequence where Element: Collection {
    /// Returns a flattened array of all collection elements.
    func flattened() -> [Element.Element] {
        flatMap { $0 }
    }
    
    /**
     Flattens a sequence of collections by taking one element from each collection in sequence.

     The resulting array is produced by interleaving the elements of the collections. It takes the first element from each collection (if available), then the second element from each, and so on, until all collections are exhausted.

     Example:
     ```swift
     let input: [[Int]] = [
         [1, 2, 3, 4, 5],
         [11, 22, 33, 44, 55, 66],
         [100, 200]
     ]

     let result = input.interleavedFlatten()
     // result: [1, 11, 100, 2, 22, 200, 3, 33, 4, 44, 5, 55, 66]
     ```
     */
    func interleaveFlattened() -> [Element.Element] {
        var iterators = map { $0.makeIterator() }
        var result: [Element.Element] = []
        var exhausted = false

        while !exhausted {
            exhausted = true
            for i in iterators.indices {
                if let next = iterators[i].next() {
                    result.append(next)
                    exhausted = false
                }
            }
        }

        return result
    }
}

public extension Sequence where Element: OptionalProtocol, Element.Wrapped: Collection {
    /// Returns a flattened array of all collection elements.
    func flattened() -> [Element.Wrapped.Element] {
        compactMap(\.optional).flattened()
    }
    
    /**
     Flattens a sequence of collections by taking one element from each collection in sequence.

     The resulting array is produced by interleaving the elements of the collections. It takes the first element from each collection (if available), then the second element from each, and so on, until all collections are exhausted.
     */
    func interleaveFlattened() -> [Element.Wrapped.Element] {
        compactMap(\.optional).interleaveFlattened()
    }
}

public extension Sequence where Element: Any {
    /// Returns a flattened array of all elements.
    func flattened() -> [Any] {
        flatMap { ($0 as? any Sequence)?.map({$0}).flattened() ?? [$0] }
    }
}

public extension Sequence where Element: OptionalProtocol, Element.Wrapped: Any {
    /// Returns a flattened array of all elements.
    func flattened() -> [Any] {
        compactMap(\.optional).flattened()
    }
}
