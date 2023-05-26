//
//  File.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import Foundation

public extension RangeReplaceableCollection where Element: Equatable {
    static func - (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        return lhs.filter { $0 != rhs }
    }

    static func - <Other>(lhs: Self, rhs: Other) -> Self where Other: Sequence, Self.Element == Other.Element {
        return lhs.filter { rhs.contains($0) == false }
    }

    static func -= (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs.removeAll(where: { $0 == rhs })
    }

    static func -= <Other>(lhs: inout Self, rhs: Other) where Other: Sequence, Self.Element == Other.Element {
        lhs.removeAll(where: { rhs.contains($0) })
    }
}

public extension RangeReplaceableCollection {
    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        return lhs + [rhs]
    }

    static func + (lhs: Element?, rhs: Self) -> Self {
        guard let lhs = lhs else { return rhs }
        return [lhs] + rhs
    }

    static func += (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs.append(rhs)
    }
}
