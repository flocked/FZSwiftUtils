//
//  Sequence+Difference.swift
//  
//
//  Created by Florian Zand on 19.07.23.
//

import Foundation

public extension Sequence where Element: Equatable {
    func difference<S: Sequence<Element>>(to sequence: S) -> (removed: [Element], added: [Element]) {
        let removed = self.filter({ sequence.contains($0) == false })
        let added = sequence.filter({ self.contains($0) == false })
        return (removed, added)
    }
}
