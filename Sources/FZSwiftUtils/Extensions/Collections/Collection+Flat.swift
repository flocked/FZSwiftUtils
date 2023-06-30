//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public extension Collection where Element: Collection {
    /// Returns a flattened array of all collection elements.
    func flattened() -> [Element.Element] {
        return flatMap { $0 }
    }
}

public extension Collection where Element: OptionalProtocol {
    /// Returns a flattened array of all collection elements.
    func flattened<V>() -> [V] where Element.Wrapped: Collection<V> {
        return compactMap { $0.optional }.flattened()
    }
}

public extension Collection where Element: Any {
    /// Returns a flattened array of all elements.
    func anyFlattened() -> [Any] {
        flatMap { x -> [Any] in
            if let anyarray = x as? [Any] {
                return anyarray.map { $0 as Any }.anyFlattened()
            }
            return [x]
        }
    }
}

public extension Collection where Element: OptionalProtocol, Element.Wrapped: Any {
    func anyFlattened() -> [Any] where Element.Wrapped: Any {
        return compactMap { $0.optional }.anyFlattened()
    }
}
