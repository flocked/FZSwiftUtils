//
//  Collection+Chunk.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Collection where Index == Int {
    
    /**
     Splits the collection into arrays with the specified size.
     
     Any remaining elements will be added to a seperate chunk.
     
     ```swift
     let array = [1,2,3,4,5,6,7,8,9]
     array.chunked(size: 3) // [[1,2,3], [4,5,6], [7,8,9]]
     array.chunked(size: 2) // [[1,2], [3,4], [5,6], [7,8], [9]]
     ```
     
     - Parameter size: The size of the chunk.
     - Returns: Returns an array of chunks.
     */
    func chunked(size: Int) -> [[Element]] {
        let size = (size > 0) ? size : 1
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    /**
     Splits the collection into arrays by the specified amount.
     
     Example:
     ```swift
     let array = [1,2,3,4,5,6,7,8,9]
     array.chunked(amount: 3) // [[1,2,3], [4,5,6], [7,8,9]]
     array.chunked(amount: 2) // [[1,2,3,4], [5,6,7,8,9]]
     ```
     
     - Parameter amount: The amount of chunks.
     - Returns: Returns an array of chunks.
     */
    func chunked(amount: Int) -> [[Element]] {
        let amount = amount.clamped(max: count)
        let chunksize = Int((Float(count) / Float(amount)).rounded(.towardZero))
        
        /*
        let remaining = Int(Double(self.count).remainder(dividingBy: Double(amount)))
        var count = 0
        var array: [Element] = []
        var output: [[Element]] = []
        for value in self {
            array.append(value)
            count += 1
            if count == chunksize {
                output.append(array)
                array = []
                count = 0
            }
        }
         */
        
        return chunked(size: chunksize)
    }

    /** Splits the collection into arrays for each specified unique keypath value.
     
     - Parameter keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C?>, ascending: Bool = true) -> [(C, [Element])] {
        return chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }

    /** 
     Splits the collection into arrays for each specified unique keypath value.
     
     - Parameter keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C>, ascending: Bool = true) -> [(C, [Element])] {
        return chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }

    /** 
     Splits the collection into arrays for each specified unique comparison value.
     
     - Parameter comparison: A comparison handler returning a comparable value.
     - Returns: Returns an array of chunks for each unique comparison value.
     */
    func chunked<C: Comparable>(by comparison: (Element) -> C?, ascending: Bool = true) -> [(C, [Element])] {
        let items: [(value: C?, element: Element)] = compactMap { (comparison($0), $0) }
        var uniqueValues = items.compactMap { $0.value }.uniqued()
        if ascending == false {
            uniqueValues = uniqueValues.reversed()
        }
        var elements: [(C, [Element])] = []
        for uniqueValue in uniqueValues {
            let filtered = items.filter { $0.value == uniqueValue }.compactMap { $0.element }
            elements.append((uniqueValue, filtered))
        }
        return elements
    }
}
