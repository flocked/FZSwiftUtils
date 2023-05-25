//
//  Collection+Unique.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    func uniqued() -> [Element] {
        var elements: [Element] = []
        for element in self {
            if elements.contains(element) == false {
                elements.append(element)
            }
        }
        return elements
    }
}

public extension Sequence {
    func uniqued<T: Equatable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return uniqued(by: { $0[keyPath: keyPath] })
    }

    func uniqued<T: Equatable>(by map: (Element) -> T) -> [Element] {
        var uniqueElements: [T] = []
        var ordered: [Element] = []
        for element in self {
            let check = map(element)
            if uniqueElements.contains(check) == false {
                uniqueElements.append(check)
                ordered.append(element)
            }
        }
        return ordered
    }
}
