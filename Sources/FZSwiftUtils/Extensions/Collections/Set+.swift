//
//  Set+.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

extension Set {
    /**
     Removes the specified elements from the set.

     - Parameters elements: An elements to remove from the set.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach({ self.remove($0) })
    }

    /**
     Inserts the given elements in the set if they are not already present.

     - Parameters elements: An elements to insert into the set.
     */
    mutating func insert<S: Sequence<Element>>(_ elements: S) {
        elements.forEach({ self.insert($0) })
    }
    
    /**
     Removes all elements that satisfy the contain a value at the given keypath.

     - Parameters keypath: The keypath.
     */
    mutating func removeAll<Value>(containing keypath: KeyPath<Element, Value?>) {
        self.removeAll(where: { $0[keyPath: keypath] != nil })
    }

    @discardableResult
    /**
     Removes all elements that satisfy the given predicate.

     - Parameters shouldRemove: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the set.
     */
    mutating func removeAll(where shouldRemove: (Self.Element) -> Bool) -> Set<Element> {
        let toRemove = filter(shouldRemove)
        self.remove(Array(toRemove))
        return toRemove
    }
    
    /// The set as `Array`.
    var asArray: [Element] {
        Array(self)
    }
}
