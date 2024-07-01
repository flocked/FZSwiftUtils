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
        reduce(into: [Element: Int]()) { currentResult, element in
            currentResult[element, default: 0] += 1
        }
    }
}

/*
public extension Dictionary  {
    /// A dictionary for the occurences of the elements keyed by count.
    init<S>(grouping values: S, by keyForValue: PartialKeyPath<S.Element>) where S: Sequence, S.Element: Equatable & Hashable, Value == [S.Element], S : Sequence, Key == Int {
            self = values.numberOfOccurences()
    }
}
*/
