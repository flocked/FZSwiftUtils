//
//  Collection+Chunk.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Collection where Index == Int {
    
    /** Splits the collection into arrays with the specified size.
     - Parameters size: The size of the chunk.
     - Returns: Returns an array of chunks.
     */
    func chunked(into size: Int) -> [[Element]] {
        let size = (size > 0) ? size : 1
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    /** Splits the collection into arrays by the specified amount.
     - Parameters amount: The amount of the chunks.
     - Returns: Returns an array of chunks.
     */
    func chunked(toPieces pieces: Int) -> [[Element]] {
        let pieces = pieces.clamped(max: count)
        let chunksize = (Float(count) / Float(pieces)).rounded(.up)
        return chunked(into: Int(chunksize))
    }

    /** Splits the collection into arrays for each specified unique keypath value.
     - Parameters keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C?>, ascending: Bool = true) -> [(C, [Element])] {
        return chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }

    /** Splits the collection into arrays for each specified unique keypath value.
     - Parameters keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C>, ascending: Bool = true) -> [(C, [Element])] {
        return chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }

    /** Splits the collection into arrays for each specified unique comparison value.
     - Parameters comparison: A comparison handler returning a comparable value.
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
