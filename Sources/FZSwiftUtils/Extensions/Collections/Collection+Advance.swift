//
//  Collection+Advance.swift
//  ImageViewer
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation

/// Advance option used to advance collections.
public enum AdvanceOption {
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
     - Parameters type: The advance type.
     - Parameters current: The current element used to advance the index.
     - Parameters excluding: Elements to exclude from advancing.
     - Returns: The advanced element for the current element.
     */
    func advance(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Element? {
        if let index = advanceIndex(by: type, current: current, excluding: excluding) {
            return self[index]
        }
        return nil
    }

    /**
     Returns the advanced index for the specified current element and advance type.
     - Parameters type: The advance type.
     - Parameters current: The current element used to advance the index.
     - Parameters excluding: Elements to exclude from advancing.
     - Returns: The advanced index for the current element.
     */
    func advanceIndex(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Int? {
        var excluding = excluding
        if let current = current {
            excluding.append(current)
        }
        if let current = current, var index = firstIndex(of: current) {
            switch type {
            case .next:
                for _ in 0 ..< count - 1 {
                    index = index + 1
                    if index < count {
                        if excluding.contains(self[index]) == false {
                            return index
                        }
                    }
                }
            case .previous:
                for _ in 0 ..< count - 1 {
                    index = index - 1
                    if index >= 0 {
                        if excluding.contains(self[index]) == false {
                            return index
                        }
                    }
                }
            case .nextLooping:
                for _ in 0 ..< count - 1 {
                    index = index + 1
                    if index >= count {
                        index = 0
                    }
                    if excluding.contains(self[index]) == false {
                        return index
                    }
                }
            case .previousLooping:
                for _ in 0 ..< count - 1 {
                    index = index - 1
                    if index < 0 {
                        index = count - 1
                    }
                    if excluding.contains(self[index]) == false {
                        return index
                    }
                }
            case .first:
                return (isEmpty == false) ? 0 : nil
            case .last:
                return (isEmpty == false) ? count - 1 : nil
            case .random:
                for (idx, ele) in shuffled().enumerated() {
                    if excluding.contains(ele) == false {
                        return idx
                    }
                }
            }
        } else {
            switch type {
            case .first, .next, .previous, .nextLooping, .previousLooping:
                return (isEmpty == false) ? 0 : nil
            case .last:
                return (isEmpty == false) ? count - 1 : nil
            case .random:
                return (isEmpty == false) ? Int.random(in: 0 ... count - 1) : nil
            }
        }
        return nil
    }
}
