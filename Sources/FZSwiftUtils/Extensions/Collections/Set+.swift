//
//  Set+.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

public extension SetAlgebra {
    /**
     Adds the elements of the given sequence to the set.

     - Parameter elements: The elements to add.
     */
    @_disfavoredOverload
    mutating func insert<S: Sequence<Element>>(_ elements: S) {
        elements.forEach { insert($0) }
    }
    
    /**
     Adds the elements of the given set to the set.
     
     - Parameter elements: The set of elements to add.
     */
    mutating func insert(_ elements: Self) {
        formUnion(elements)
    }
    
    /**
     Removes the elements of the given sequence from this set.

     - Parameter elements: The elements to remove.
     */
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach { remove($0) }
    }
    
    /**
     Removes the elements of the given set from this set.
     
     - Parameter elements: The set of elements to remove.
     */
    mutating func remove(_ elements: Self) {
        subtract(elements)
    }
    
    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter elements: The elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    @_disfavoredOverload
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        members.contains(where: { contains($0) })
    }
    
    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter elements: The set of elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    func contains(any members: Self) -> Bool {
        !intersection(members).isEmpty
    }
    
    /**
     A Boolean value indicating whether the set contains all specified elements.

     - Parameter elements: The set of elements to look for in the set.
     - Returns: `true` if all elements exists in the set, otherwise ` false`.
     */
    func contains(_ members: Self) -> Bool {
        isSuperset(of: members)
    }
    
    /**
     A Boolean value indicating whether the set contains all specified elements.

     - Parameter elements: The set of elements to look for in the set.
     - Returns: `true` if all elements exists in the set, otherwise ` false`.
     */
    func contains<S>(_ members: S) -> Bool where S: Sequence<Element> {
        !members.contains(where: { !contains($0) })
    }
        
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
     A Boolean value that indicates whether the elements of the given set exists in the set.
     
     Setting this value to `true`, inserts the elements of the given set in the set. Setting it to `false`, removes the elements from the set.
     */
    @_disfavoredOverload
    subscript (_ element: Self) -> Bool {
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
     A Boolean value that indicates whether the elements of the given sequence exists in the set.
     
     Setting this value to `true`, inserts the elements of the given sequence in the set. Setting it to `false`, removes the elements from the set.
     */
    @_disfavoredOverload
    subscript <S>(_ element: S) -> Bool where S: Sequence<Element> {
        get { contains(element) }
        set {
            if newValue {
                insert(element)
            } else {
                remove(element)
            }
        }
    }
    
    static func + (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }
    
    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        return lhs + rhs
    }
    
    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }
    
    static func += (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs.insert(rhs)
    }
    
    static func - (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }
    
    static func - (lhs: Self, rhs: Element?) -> Self {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }
    
    static func -= (lhs: inout Self, rhs: Element) {
        lhs.remove(rhs)
    }
    
    static func -= (lhs: inout Self, rhs: Element?) {
        guard let rhs = rhs else { return }
        lhs.remove(rhs)
    }
    
    @_disfavoredOverload
    static func + <S>(lhs: Self, rhs: S) -> Self where S: Sequence<Element> {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func += <S>(lhs: inout Self, rhs: S) where S: Sequence<Element> {
        lhs.insert(rhs)
    }
    
    @_disfavoredOverload
    static func + <S>(lhs: Self, rhs: S?) -> Self where S: Sequence<Element> {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func += <S>(lhs: inout Self, rhs: S?) where S: Sequence<Element> {
        guard let rhs = rhs else { return }
        lhs.insert(rhs)
    }
    
    @_disfavoredOverload
    static func - <S>(lhs: Self, rhs: S) -> Self where S: Sequence<Element> {
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func -= <S>(lhs: inout Self, rhs: S) where S: Sequence<Element> {
        lhs.remove(rhs)
    }
    
    @_disfavoredOverload
    static func - <S>(lhs: Self, rhs: S?) -> Self where S: Sequence<Element> {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func -= <S>(lhs: inout Self, rhs: S?) where S: Sequence<Element> {
        guard let rhs = rhs else { return }
        lhs.remove(rhs)
    }
    
    @_disfavoredOverload
    static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs.formUnion(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func += (lhs: inout Self, rhs: Self) {
        lhs.formUnion(rhs)
    }
    
    @_disfavoredOverload
    static func + (lhs: Self, rhs: Self?) -> Self {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs.formUnion(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func += (lhs: inout Self, rhs: Self?) {
        guard let rhs = rhs else { return }
        lhs.formUnion(rhs)
    }
    
    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs.subtract(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
    
    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self?) -> Self {
        guard let rhs = rhs else { return lhs }
        var lhs = lhs
        lhs.subtract(rhs)
        return lhs
    }
    
    @_disfavoredOverload
    static func -= (lhs: inout Self, rhs: Self?) {
        guard let rhs = rhs else { return }
        lhs.subtract(rhs)
    }
}

public extension Set {
    /**
     A Boolean value indicating whether the set contains all specified elements.

     - Parameter elements: The set of elements to look for in the set.
     - Returns: `true` if all elements exists in the set, otherwise ` false`.
     */
    func contains<S>(_ elements: S) -> Bool where S: Sequence<Element> {
        contains(Set(elements))
    }
    
    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter elements: The set of elements to look for in the set.
     - Returns: `true` if any of the elements exists in the set, otherwise ` false`.
     */
    func contains<S>(any elements: S) -> Bool where S: Sequence<Element> {
        contains(any: Set(elements))
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
        subtract(toRemove)
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
