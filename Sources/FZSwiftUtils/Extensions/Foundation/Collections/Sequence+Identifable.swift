//
//  Array+Identifable.swift
//  FZCollection
//
//  Created by Florian Zand on 03.05.22.
//

import Foundation

public extension Sequence where Element: Identifiable {
    var ids: [Element.ID] {
        return self.compactMap({$0.id})
    }
    
    subscript(id id: Element.ID) -> Element? {
       first { $0.id == id }
    }
    
    subscript<S: Sequence<Element.ID>>(ids ids: S) -> [Element] {
        self.filter({ids.contains($0.id)})
    }
    
}

public extension Collection where Element: Identifiable {
    func index(of element: Element) -> Self.Index? {
        return self.firstIndex(where: {$0.id == element.id})
    }
    func indexes<S: Sequence<Element>>(of elements: S) -> [Self.Index] {
        return elements.compactMap({self.index(of: $0)})
    }
}

public extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element)  {
        if let index = self.index(of: element) {
            self.remove(at: index)
        }
    }
    
    mutating func remove<S: Sequence>(_ elements: S)  where S.Element == Element {
        for element in elements {
            self.remove(element)
        }
    }
}

public extension Array where Element: Identifiable {
    mutating func move<S: Sequence>(_ elements: S, before: Element) where S.Element == Element  {
        if let toIndex = self.index(of: before) {
            let indexSet = IndexSet(self.indexes(of: elements))
            self.move(from: indexSet, to: toIndex)
        }
    }
    
    mutating func move<S: Sequence>(_ elements: S, after: Element)  where S.Element == Element   {
        if let toIndex = self.index(of: after) {
            let indexSet = IndexSet(self.indexes(of: elements))
            self.move(from: indexSet, to: toIndex)
        }
    }
}
