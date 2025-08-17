//
//  Sequence+Index.swift
//  
//
//  Created by Florian Zand on 17.08.25.
//

public extension Collection {
    /**
     Returns indexes of elements that satisfies the given predicate.

     - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the index of the element should be included in the returned array.

     - Returns: The indexes of the elements that satisfies the given predicate.
     */
    func indexes(where isIncluded: (Element) throws -> Bool) rethrows -> [Index] {
        try indices.filter({ try isIncluded(self[$0]) })
    }
}

public extension Collection where Element: Equatable {
    /**
     Returns indexes of the specified element.

     - Parameter element: The element to return it's indexes.

     - Returns: The indexes of the element.
     */
    func indexes(of element: Element) -> [Index] {
        indexes(where: { $0 == element })
    }

    /**
     Returns indexes of the specified elements.

     - Parameter elements: The elements to return their indexes.

     - Returns: The indexes of the elements.
     */
    func indexes<S>(of elements: S) -> [Index] where S: Sequence<Element> {
        indexes(where: { elements.contains($0) })
    }
}

public extension Collection where Element: Hashable {
    /**
     Returns the indexes of the specified elements.

     - Parameter elements: The elements to return their indexes.

     - Returns: The indexes of the elements.
     */
    func indexes<S>(of elements: S) -> [Index] where S: Sequence<Element> {
        let lookup = Set(elements)
        return indexes(where: { lookup.contains($0) })
    }
}
