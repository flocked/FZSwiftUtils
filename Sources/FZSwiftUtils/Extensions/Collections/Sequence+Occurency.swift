//
//  Sequence+Occurency.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension Sequence where Element: Equatable & Hashable {
    /// A dictionary for the occurences of the elements keyed by count.
    func numberOfOccurences() -> [Int: [Element]] {
        var occurences: [Int: [Element]] = [:]
        for occurency in numberOfOccurencesByElement() {
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
        return reduce(into: [Element: Int]()) { currentResult, element in
            currentResult[element, default: 0] += 1
        }
    }
    
    func numberOfOccurences<Value: Hashable>(of keyPath: KeyPath<Element, Value>) -> [Value: [Element]] {
        return reduce(into: [Value: [Element]]()) { currentResult, element in
            currentResult[element[keyPath: keyPath], default: []] += element
        }
    }
}
