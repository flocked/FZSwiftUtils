//
//  Array+.swift
//  ImageViewer
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation

public enum AdvanceOption {
    case next
    case previous
    case nextLooping
    case previousLooping
    case first
    case last
    case random
}

public extension Collection where Element: Equatable, Index == Int {
    func advance(by type: AdvanceOption, current: Element?, excluding: [Element] = []) -> Element? {
        if let index = advanceIndex(by: type, current: current, excluding: excluding) {
            return self[index]
        }
        return nil
    }

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
