//
//  Collection+Advance.swift
//  ImageViewer
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation

/// Advance option used to advance collections.
public enum AdvanceOption: Int, Hashable {
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
    func advance(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Element? {
        if let index = advanceIndex(by: type, current: current, excluding: excluding) {
            return self[index]
        }
        return nil
    }

    /*
    /**
     Returns the advanced index for the specified current element and advance type.

     - Parameters:
        - type: The advance type.
        - current: The current element used to advance the index.
        - excluding: Elements to exclude from advancing.

     - Returns: The advanced index for the current element.
     */
    func advanceIndex(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Int? {
        if let current = current, let index = firstIndex(of: current) {
            let excluding = (excluding.compactMap({ firstIndex(of: $0) }) + index).sorted()
            switch type {
            case .next:
                return indices[0..<count-1-index].first(where: { !excluding.contains(index+$0+1) })
            case .previous:
                return indices[0..<index].first(where: { !excluding.contains(index-$0-1) })
            case .nextLooping:
                return indices.first(where: { !excluding.contains(index+1+$0 >= count ? -count+$0+index+1 : index+1+$0) })
            case .previousLooping:
                return indices.first(where: { !excluding.contains(index-1-$0 < 0 ? count-$0+index-1 : index-1-$0) })
            case .first:
                return indices.first(where: { !excluding.contains($0) })
            case .last:
                return indices.reversed().first(where: { !excluding.contains($0) })
            case .random:
                return indices.shuffled().first(where: { !excluding.contains($0) })
            }
        } else {
            switch type {
            case .first, .next, .previous, .nextLooping, .previousLooping:
                return !isEmpty ? 0 : nil
            case .last:
                return !isEmpty ? count-1 : nil
            case .random:
                return indices.randomElement()
            }
        }
    }
     */

    /**
     Returns the advanced index for the specified current element and advance type.

     - Parameters:
        - type: The advance type.
        - current: The current element used to advance the index.
        - excluding: Elements to exclude from advancing.

     - Returns: The advanced index for the current element.
     */
    func advanceIndex(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Int? {
        guard !isEmpty else { return nil }
        if let current = current, let index = firstIndex(of: current) {
            let excluding = excluding.compactMap({ firstIndex(of: $0) }) + index
            switch type {
            case .next:
                return indices[index+1..<count].first(where: { !excluding.contains($0) })
            case .previous:
                return indices[0..<index].reversed().first(where: { !excluding.contains($0) })
            case .nextLooping:
                return (indices[safe: index+1..<count] + indices[safe: 0..<index]).first(where: { !excluding.contains($0) })
            case .previousLooping:
                return (indices[0..<index].reversed() + indices[safe: index+1..<count].reversed()).first(where: { !excluding.contains($0) })
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
