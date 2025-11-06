//
//  Set+.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

public extension Set {
    /**
     A Boolean value that indicates whether the given element exists in the set.
     
     Setting this value to `true`, inserts the given element in the set if it is not already present. Setting it to `false`, removes it from the set.
     */
    subscript (_ element: Element) -> Bool {
        get { contains(element) }
        set {
            if newValue {
                insert(element)
            } else {
                remove(element)
            }
        }
    }
    
    /**
     Removes the specified elements from the set.

     - Parameter elements: An elements to remove from the set.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach { self.remove($0) }
    }

    /**
     Inserts the given elements in the set if they are not already present.

     - Parameter elements: An elements to insert into the set.
     */
    mutating func insert<S: Sequence<Element>>(_ elements: S) {
        elements.forEach { self.insert($0) }
    }

    /**
     Removes all elements that satisfy the contain a value at the given keypath.

     - Parameter keypath: The keypath.
     */
    mutating func removeAll<Value>(containing keypath: KeyPath<Element, Value?>) {
        removeAll(where: { $0[keyPath: keypath] != nil })
    }

    /**
     Removes all elements that satisfy the given predicate.

     - Parameter shouldRemove: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the set.
     */
    @discardableResult
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Set<Element> {
        let toRemove = try filter(shouldBeRemoved)
        remove(Array(toRemove))
        return toRemove
    }

    /// The set as `Array`.
    var asArray: [Element] {
        Array(self)
    }
    
    /// Edits each element in the set.
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        var elements = Array(self)
        try elements.editEach(body)
        self = .init(elements)
    }
    
    /// Removes all elements matching the predicate and returns the removed elements.
    @discardableResult
    mutating func removeAllAndReturn(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Set<Element> {
        var removed: Set<Element> = []
        var kept: Self = .init()
        for element in self {
            if try shouldBeRemoved(element) {
                removed.insert(element)
            } else {
                kept.insert(element)
            }
        }
        self = kept
        return removed
    }
}

public extension Set {
    static func + (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func += (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs += rhs
    }
    
    static func + (lhs: Element, rhs: Self) -> Self {
        return rhs + lhs
    }
    
    static func + (lhs: Element?, rhs: Self) -> Self {
        guard let lhs = lhs else { return rhs }
        return rhs + lhs
    }
    
    static func + <Collection: Sequence<Element>>(lhs: Self, rhs: Collection) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func += (lhs: inout Set<Element>, rhs: Element) {
        lhs.insert(rhs)
    }
    
    static func += <Collection: Sequence<Element>>(lhs: inout Self, rhs: Collection) {
        for element in rhs {
            lhs.insert(element)
        }
    }
}

extension Set {
    /// A function builder type that produces a set.
    @resultBuilder
    public enum Builder {
        public typealias Component = [Element]

        public static func buildExpression(_ expression: Element?) -> Component {
            expression.map({ [$0] }) ?? []
        }

        public static func buildExpression(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildBlock(_ components: Component...) -> Component {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: Component?) -> Component {
            component ?? []
        }

        public static func buildEither(first component: Component) -> Component {
            component
        }

        public static func buildEither(second component: Component) -> Component {
            component
        }

        public static func buildArray(_ components: [Component]) -> Component {
            components.flatMap { $0 }
        }

        public static func buildLimitedAvailability(_ component: Component) -> Component {
            component
        }

        public static func buildFinalResult(_ component: Component) -> [Element] {
            component
        }
    }

    public init(@Builder elements: () -> Self) {
        self = elements()
    }

    public mutating func insert(@Builder elements: () -> Self) {
        formUnion(elements())
    }

    public func inserting(@Builder elements: () -> Self) -> Self {
        union(elements())
    }
}
