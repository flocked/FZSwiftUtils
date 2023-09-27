//
//  Sequence+Difference.swift
//  
//
//  Created by Florian Zand on 19.07.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    /**
     Returns the difference needed to produce this collection’s ordered elements from the given collection.
     
     - Parameters other: The other collection to compare.
     - Returns: The difference needed to produce this collection’s ordered elements from the given collection.
     */
    func difference<S: Sequence<Element>>(to other: S) -> (removed: [Element], added: [Element]) {
        let removed = self.filter({ other.contains($0) == false })
        let added = other.filter({ self.contains($0) == false })
        return (removed, added)
    }
}
