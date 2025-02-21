//
//  CollectionDifference+.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

import Foundation

extension CollectionDifference.Change {
    /// The offset at which the change occurs.
    public var offset: Int {
        switch self {
        case let .insert(offset, _, _): return offset
        case let .remove(offset, _, _): return offset
        }
    }
    
    /// The element associated with the change.
    public var element: ChangeElement {
        switch self {
        case let .insert(_, element, _): return element
        case let .remove(_, element, _): return element
        }
    }
    
    /// The associated offset for matching insertions and removals, if available.
    public var associatedOffset: Int? {
        switch self {
        case let .insert(_, _, associate): return associate
        case let .remove(_, _, associate): return associate
        }
    }
}

extension CollectionDifference where ChangeElement: Hashable {
    /// A value representing the different types of changes that can occur in a collection difference.
    public enum ChangeStep {
        /// Inserts an element at a specific index.
        case insert(_ element: ChangeElement, at: Int)
        /// Removes an element from a specific index.
        case remove(_ element: ChangeElement, at: Int)
        /// Moves an element from one index to another.
        case move(_ element: ChangeElement, from: Int, to: Int)
    }
    
    /// Returns the ordered steps required to transform one collection into another.
    public var steps: [ChangeStep] {
        guard !isEmpty else { return [] }
        
        var steps: [ChangeStep] = []
        var offsetTracker = RemainingRemovalTracker()
        
        inferringMoves().forEach { change in
            switch change {
            case let .remove(offset, element, associatedWith):
                if associatedWith != nil {
                    offsetTracker.addSkippedRemoval(atOffset: offset)
                } else {
                    steps.append(.remove(element, at: offset))
                    offsetTracker.removalMade(at: offset)
                }
            case let.insert(offset, element, associatedWith):
                if let associatedWith = associatedWith {
                    let from = offsetTracker.useSkippedRemoval(withOriginalOffset: associatedWith)
                    let to = offsetTracker.adjustedInsertion(withOriginalOffset: offset)
                    steps.append(.move(element, from: from, to: to))
                    offsetTracker.insertionMade(at: to)
                } else {
                    let to = offsetTracker.adjustedInsertion(withOriginalOffset: offset)
                    steps.append(.insert(element, at: to))
                    offsetTracker.insertionMade(at: to)
                }
            }
        }
        return steps
    }
}

private typealias RemainingRemovalTracker = [Int:Int]

private extension RemainingRemovalTracker {
    mutating func addSkippedRemoval(atOffset offset: Int) {
        self[offset] = offset }
    
    mutating func useSkippedRemoval(withOriginalOffset originalOffset: Int) -> Int {
        let currentOffset = removeValue(forKey: originalOffset)!
        removalMade(at: currentOffset)
        return currentOffset }
    
    mutating func removalMade(at offset: Int) {
        forEach({ key, value in
            if value > offset {
                self[key] = value - 1 } })
    }
    
    mutating func insertionMade(at offset: Int) {
        forEach { key, value in
            if value >= offset {
                self[key] = value + 1 } }
    }
    
    func adjustedInsertion(withOriginalOffset originalOffset: Int) -> Int {
        var adjustedOffset = originalOffset
        values.sorted().forEach { offset in
            if offset <= adjustedOffset {
                adjustedOffset += 1 } }
        return adjustedOffset
    }
}
