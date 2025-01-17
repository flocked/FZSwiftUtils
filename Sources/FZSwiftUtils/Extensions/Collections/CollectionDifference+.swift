//
//  CollectionDifference+.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
excerpt

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
