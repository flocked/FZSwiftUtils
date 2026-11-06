//
//  Collection+Advance.swift
//  ImageViewer
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation

/// Advance option used to advance collections.
public enum SelectionOption: Int, Hashable, Sendable {
    /// Next element.
    case next
    /// Previous element.
    case previous
    /// Next element looping.
    case nextLooping
    /// Previous element looping.
    case previousLooping
    /// First element.
    case first
    /// Last element.
    case last
    /// Random element.
    case random
}

public extension Collection where Element: Equatable, Index == Int {
    /**
     Returns the advanced element for the specified current element and advance type.

     - Parameters:
        - type: The advance type.
        - current: The current element used to advance the index.
        - excluding: Elements to exclude from advancing.

     - Returns: The advanced element for the current element.
     */
    func advance(by type: SelectionOption, current: Element?, excluding: [Element] = []) -> Element? {
        if let index = advanceIndex(by: type, current: current, excluding: excluding) {
            return self[index]
        }
        return nil
    }

    /**
     Returns the advanced index for the specified current element and advance type.

     - Parameters:
        - type: The advance type.
        - current: The current element used to advance the index.
        - excluding: Elements to exclude from advancing.

     - Returns: The advanced index for the current element.
     */
    func advanceIndex(by type: SelectionOption, current: Element?, excluding: [Element] = []) -> Int? {
        guard !isEmpty else { return nil }
        if let current = current, let index = firstIndex(of: current) {
            let excluding = excluding.compactMap({ firstIndex(of: $0) }) + index
            switch type {
            case .next:
                return indices[index+1..<count].first(where: { !excluding.contains($0) })
            case .previous:
                return indices[0..<index].reversed().first(where: { !excluding.contains($0) })
            case .nextLooping:
                return (indices[clamped: index+1..<count] + indices[clamped: 0..<index]).first(where: { !excluding.contains($0) })
            case .previousLooping:
                return (indices[0..<index].reversed() + indices[clamped: index+1..<count].reversed()).first(where: { !excluding.contains($0) })
            case .first:
                return indices.filter({ !excluding.contains($0) }).first
            case .last:
                return indices.filter({ !excluding.contains($0) }).last
            case .random:
                return indices.randomElement(excluding: excluding)
            }
        } else {
            switch type {
            case .first, .next, .previous, .nextLooping, .previousLooping:
                return !isEmpty ? 0 : nil
            case .last:
                return !isEmpty ? count - 1 : nil
            case .random:
                return indices.randomElement()
            }
        }
    }
}

extension BidirectionalCollection {
    func advanceIndex(
        _ index: Index,
        by advancement: SelectionOption,
        matching predicate: ((Element) throws -> Bool)? = nil
    ) rethrows -> Index? {
        guard !isEmpty, index != endIndex else { return nil }
        switch advancement {
        case .next:
            var i = self.index(after: index)
            while i != endIndex {
                if try predicate?(self[i]) ?? true { return i }
                formIndex(after: &i)
            }
            return nil
        case .previous:
            var i = index
            while i != startIndex {
                formIndex(before: &i)
                if try predicate?(self[i]) ?? true { return i }
            }
            return nil
        case .nextLooping:
            var i = index
            repeat {
                i = self.index(after: i)
                if i == endIndex { i = startIndex }
                if try predicate?(self[i]) ?? true { return i }
            } while i != index
            return nil
        case .previousLooping:
            var i = index
            repeat {
                if i == startIndex { i = endIndex }
                formIndex(before: &i)
                if try predicate?(self[i]) ?? true { return i }
            } while i != index
            return nil
        case .first:
            return try firstIndex {
                try predicate?($0) ?? true
            }
        case .last:
            return try lastIndex {
                try predicate?($0) ?? true
            }
        case .random:
            let matchingIndices = try indices.filter {
                try predicate?(self[$0]) ?? true
            }
            return matchingIndices.randomElement()
        }
    }
}
