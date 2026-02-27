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

     - Parameter size: The size of each chunk.
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
        let amount = Swift.max(1, Swift.min(amount, count))
        let chunkSize = count / amount
        let remainder = count % amount

        var start = startIndex
        return (0..<amount).reduce(into: []) { chunks, i in
            let thisChunkSize = chunkSize + (i < remainder ? 1 : 0)
            let end = start + thisChunkSize
            chunks += Array(self[start..<end])
            start = end
        }
    }
}

public extension Sequence {
    /**
     Splits the collection into arrays for each specified unique keypath value.

     - Parameter keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C?>, order: SortOrder = .forward) -> [(C, [Element])] {
        chunked(by: { $0[keyPath: keyPath] }, order: order)
    }

    /**
     Splits the collection into arrays for each specified unique keypath value.

     - Parameter keyPath: The keyPath of the value.
     - Returns: Returns an array of chunks for each unique keypath value.
     */
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C>, order: SortOrder = .forward) -> [(C, [Element])] {
        chunked(by: { $0[keyPath: keyPath] }, order: order)
    }
    
    /**
     Splits the collection into arrays for each specified unique comparison value.

     - Parameter comparison: A comparison handler returning a comparable value.
     - Returns: Returns an array of chunks for each unique comparison value.
     */
    func chunked<C: Comparable>(by comparison: (Element) -> C?, order: SortOrder = .forward) -> [(C, [Element])] {
        let items = compactMap { (comparison($0), $0) }
        var uniqueValues = items.compactMap(\.0).uniqued()
        if order == .descending {
          uniqueValues.reverse()
        }
        
        return uniqueValues.reduce(into: []) { results, uniqueValue in
            results += (uniqueValue, items.filter { $0.0 == uniqueValue }.map(\.1))
        }
    }
    
    /**
     Splits the collection into arrays for each specified unique comparison value.

     - Parameter comparison: A comparison handler returning a comparable value.
     - Returns: Returns an array of chunks for each unique comparison value.
     */
    func chunked<C: Comparable & Hashable>(by comparison: (Element) -> C?, order: SortOrder = .forward) -> [(C, [Element])] {
        let groups: [C: [Element]] = reduce(into: [:]) { groups, element in
            guard let key = comparison(element) else { return }
            groups[key, default: []] += element
        }
        return groups.keys.sorted(order).map { ($0, groups[$0]!) }
    }
}

public extension Sequence {
    /**
     Splits the collection into array, chunked by the given predicate.

     - Parameter belongInSameGroup: A closure that takes two adjacent elements of the collection and returns whether or not they belong in the same group.
    */
    func chunked(by belongInSameGroup: (Element, Element) throws -> Bool) rethrows -> [[Element]] {
        var iterator = makeIterator()
        
        guard var previous = iterator.next() else { return [] }
        
        var result: [[Element]] = []
        var currentChunk: [Element] = [previous]
        
        while let next = iterator.next() {
            if try belongInSameGroup(previous, next) {
                currentChunk += next
            } else {
                result += currentChunk
                currentChunk = [next]
            }
            previous = next
        }
        
        if !currentChunk.isEmpty {
            result += currentChunk
        }
        
        return result
    }
}

public extension RandomAccessCollection {
    /**
     Splits the collection into array, chunked by the given predicate.

     - Parameter belongInSameGroup: A closure that takes two adjacent elements of the collection and returns whether or not they belong in the same group.
    */
    func chunked(by belongInSameGroup: (Element, Element) throws -> Bool) rethrows -> [[Element]] {
    guard !isEmpty else { return [] }

    var result: [[Element]] = []
    var start = startIndex
    var previous = self[start]
    var index = index(after: start)

    while index != endIndex {
      let current = self[index]
      if try !belongInSameGroup(previous, current) {
        result += Array(self[start..<index])
        start = index
      }
      previous = current
      formIndex(after: &index)
    }

    result += Array(self[start..<endIndex])
    return result
  }
}
