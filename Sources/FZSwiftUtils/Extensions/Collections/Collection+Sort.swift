//
//  Collection+Sort.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

import Foundation

public extension RandomAccessCollection {
    /**
     Reorders the elements of the collection towards the center, alternating between elements
     from the start and end, moving toward the middle.
     
     - Returns: A new array where elements from the start and end of the collection are arranged alternately,
       progressing towards the center.
       For example, for a collection `[A, B, C, D, E]`, the result would be `[A, E, B, D, C]`.
     */
    func reorderedTowardsCenter() -> [Element] {
        guard !isEmpty else { return [] }
        
        var result: [Element] = []
        var start = startIndex
        var end = index(before: endIndex)
        
        while start <= end {
            if start != end {
                result.append(self[start])
                result.append(self[end])
            } else {
                result.append(self[start]) // Add the middle element
            }
            start = index(after: start)
            end = index(before: end)
        }
        
        return result
    }

    /**
     Reorders the elements of the collection starting from the center and expanding outwards.
     
     - Returns: A new array where elements from the center of the collection are added first,
       followed by elements progressively further from the center.
       For example, for a collection `[A, B, C, D, E]`, the result would be `[C, B, D, A, E]`.
     */
    func reorderedFromCenterOutwards() -> [Element] {
        guard !isEmpty else { return [] }
        
        let middleIndex = index(startIndex, offsetBy: count / 2)
        var result: [Element] = []
        
        for i in 0...count / 2 {
            let leftIndex = index(middleIndex, offsetBy: -i)
            if indices.contains(leftIndex) {
                result.append(self[leftIndex])
            }
            
            let rightIndex = index(middleIndex, offsetBy: i)
            if indices.contains(rightIndex), leftIndex != rightIndex {
                result.append(self[rightIndex])
            }
        }
        
        return result
    }
}
