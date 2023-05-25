//
//  File.swift
//  
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public extension Collection where Element: Collection {
    func flattened() -> [Element.Element] {
        return self.flatMap({$0})
    }
}

public extension Collection where Element: OptionalProtocol {
    func flattened<V>() -> [V] where Element.Wrapped: Collection<V> {
        return self.compactMap({$0.optional}).flattened()
    }
}

public extension Collection where Element: Any {
    func anyFlattened() -> [Any] {
        self.flatMap { x -> [Any] in
            if let anyarray = x as? Array<Any> {
                return anyarray.map { $0 as Any }.anyFlattened()
            }
            return [x]
        }
    }
}

public extension Collection where Element: OptionalProtocol, Element.Wrapped: Any {
    func anyFlattened() -> [Any] where Element.Wrapped: Any {
        return self.compactMap({$0.optional}).anyFlattened()
    }
}
