//
//  Set+.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

public extension Set {
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
    mutating func removeAll(where shouldRemove: (Self.Element) -> Bool) -> Set<Element> {
        let toRemove = filter(shouldRemove)
        remove(Array(toRemove))
        return toRemove
    }

    /// The set as `Array`.
    var asArray: [Element] {
        Array(self)
    }
    
    /// Edits the elements.
    mutating func editEach(_ body: (inout Element) throws -> Void) rethrows {
        var elements = Array(self)
        try elements.editEach(body)
        self = .init(elements)
    }
}

public extension Set where Element: Hashable {
    static func + (lhs: Set<Element>, rhs: Element) -> Set<Element> {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func + <Collection: Sequence<Element>>(lhs: Set<Element>, rhs: Collection) -> Set<Element> {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    static func += (lhs: inout Set<Element>, rhs: Element) {
        lhs.insert(rhs)
    }
    
    static func += <Collection: Sequence<Element>>(lhs: inout Set<Element>, rhs: Collection) {
        for element in rhs {
            lhs.insert(element)
        }
    }
}

extension Set: Comparable where Element: Comparable {
    public static func < (lhs: Set<Element>, rhs: Set<Element>) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

extension Set {

    @resultBuilder
    public enum Builder {

        // swiftlint:disable:next nesting
        public typealias Expression = Element

        // swiftlint:disable:next nesting
        public typealias Component = Set<Element>

        // swiftlint:disable:next nesting
        public typealias FinalResult = Set<Element>

        public static func buildExpression(_ expression: Expression?) -> Component {
            guard let expression: Expression
            else { return [] }
            return [expression]
        }

        public static func buildExpression(_ component: Component?) -> Component {
            guard let component: Component
            else { return [] }
            return component
        }

        public static func buildBlock(_ components: Component...) -> Component {
            components.reduce(into: Set()) { $0.formUnion($1) }
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
            components.reduce(into: Set()) { $0.formUnion($1) }
        }

        public static func buildLimitedAvailability(_ component: Component) -> Component {
            component
        }

        public static func buildFinalResult(_ component: Component) -> FinalResult {
            component
        }
    }

    public init(@Builder elements: () -> Self) {
        self = elements()
    }

    public static func build(@Builder elements: () -> Self) -> Self {
        elements()
    }

    public mutating func insert(@Builder elements: () -> Self) {
        formUnion(elements())
    }

    public func inserting(@Builder elements: () -> Self) -> Self {
        union(elements())
    }
}
