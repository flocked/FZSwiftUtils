//
//  Sequence+Occurency.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Sequence where Element: Hashable {
    /**
     Returns a dictionary grouping the elements of the sequence by the number of times they occur.

     Each key in the returned dictionary represents the number of occurrences, and its value is an array of distinct elements that appear exactly that many times in the sequence.

     ### Example
     ```swift
     let values = [1, 2, 1, "C", 2, 1]
     let result = values.numberOfOccurrences()
     // result == [1: [3], 2: [2], 3: [1]]
     ```
     */
    func numberOfOccurrences() -> [Int: [Element]] {
        let counts = Dictionary(map { ($0, 1) }, uniquingKeysWith: +)
        return Dictionary(grouping: counts.keys, by: { counts[$0]! })
    }

    /**
     A dictionary mapping each unique element in the sequence to the number of times it occurs.

     ### Example
     ```swift
     let values = ["A", "B", "A", "C", "B", "A"]
     let counts = values.numberOfOccurrencesByElement()
     // counts == ["A": 3, "B": 2, "C": 1]
     ```
     */
    func numberOfOccurencesByElement() -> [Element: Int] {
         reduce(into: [Element: Int]()) { $0[$1, default: 0] += 1 }
    }
}

public extension Sequence where Element: Equatable {
    /**
     Returns a dictionary grouping the elements of the sequence by the number of times they occur.

     Each key in the returned dictionary represents the number of occurrences, and its value is an array of distinct elements that appear exactly that many times in the sequence.

     ### Example
     ```swift
     let values = [1, 2, 1, 3, 2, 1]
     let result = values.numberOfOccurrences()
     // result == [1: [3], 2: [2], 3: [1]]
     ```
     */
    func numberOfOccurrences() -> [Int: [Element]] {
        var uniqueElements: [Element] = []
        var counts: [Int] = []

        // Count occurrences manually
        for element in self {
            if let index = uniqueElements.firstIndex(of: element) {
                counts[index] += 1
            } else {
                uniqueElements.append(element)
                counts.append(1)
            }
        }

        // Group elements by their count
        var result: [Int: [Element]] = [:]
        for (element, count) in zip(uniqueElements, counts) {
            result[count, default: []].append(element)
        }

        return result
    }
}
