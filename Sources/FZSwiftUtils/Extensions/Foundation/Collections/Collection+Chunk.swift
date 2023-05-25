//
//  Collection+Chunk.swift
//  
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Collection where Index == Int {        
    func chunked(into size: Int) -> [[Element]] {
        let size = (size > 0) ? size : 1
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    func chunked(toPieces pieces: Int) -> [[Element]] {
        let pieces = pieces.clamped(max: self.count)
        let chunksize = (Float(self.count) / Float(pieces)).rounded(.up)
        return chunked(into: Int(chunksize))
    }
    
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C?>, ascending: Bool = true) -> [(C, [Element])] {
       return self.chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }
    
    func chunked<C: Comparable>(by keyPath: KeyPath<Element, C>, ascending: Bool = true) -> [(C, [Element])] {
       return self.chunked(by: { $0[keyPath: keyPath] }, ascending: ascending)
    }
    
    func chunked<C: Comparable>(by comparison: ((Element)->C?), ascending: Bool = true) -> [(C, [Element])] {
        let items: [(value: C?, element: Element)] = self.compactMap({(comparison($0), $0)})
        var uniqueValues = items.compactMap({$0.value}).uniqued()
        if (ascending == false) {
            uniqueValues = uniqueValues.reversed()
        }
        var elements: [(C, [Element])] = []
        for uniqueValue in uniqueValues {
            let filtered = items.filter({$0.value == uniqueValue}).compactMap({$0.element})
            elements.append((uniqueValue, filtered))
        }
        return elements
    }
}
