//
//  Sequence+Occurency.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Sequence where Element: Comparable & Hashable {
    /// A dictionary for the occurences of the elements keyed by count.
    func numberOfOccurences() -> [Int: [Element]] {
        var occurences:  [Int: [Element]] = [:]
        for occurency in self.numberOfOccurencesByElement() {
            if let value = occurences[occurency.value] {
                occurences[occurency.value] = value + occurency.key
            } else {
                occurences[occurency.value] = [occurency.key]
            }
        }
        
        return occurences
    }
    
    /// A dictionary for the occurences of the elements keyed by element value.
    func numberOfOccurencesByElement() -> [Element: Int] {
        reduce(into: [Element: Int]()) { currentResult, element in
            currentResult[element, default: 0] += 1
        }
    }
    
    /**
     An array of elements sorted by number of occurences.
     
     - Parameters order: The order of the sorting.
     */
    func sortedByOccurences(order: SequenceSortOrder = .ascending) -> [Element] {
        let numberOfOccurences = self.numberOfOccurencesByElement()
        let values = sorted(by: { current, next in numberOfOccurences[current]! < numberOfOccurences[next]! })
        if (order == .ascending) {
            return values
        } else {
            return values.reversed()
        }
    }
}
