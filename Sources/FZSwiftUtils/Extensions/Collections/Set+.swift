//
//  Set+.swift
//  NewImageViewer
//
//  Created by Florian Zand on 15.09.22.
//

import Foundation

/*
struct TestOption: OptionSet {
    /// Nanosecond
    public static let nanosecond = Self(rawValue: 1 << 0)
    public static let microsecond = Self(rawValue: 1 << 1)
    public static let millisecond = Self(rawValue: 1 << 2)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    func aaa() {
        contains(.nanosecond)
        let aaa: [Self] = [.nanosecond, .microsecond]
        contains(aaa)
    }
}
*/

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
    @_disfavoredOverload
    mutating func insert(_ elements: Self) {
        formUnion(elements)
    }

    /**
     Removes the elements of the given sequence from the set.

     - Parameter elements: The elements to remove.
     */
    @_disfavoredOverload
    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach { remove($0) }
    }

    /**
     Removes the elements of the given set from the set.

     - Parameter elements: The set of elements to remove.
     */
    @_disfavoredOverload
    mutating func remove(_ elements: Self) {
        subtract(elements)
    }

    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter members: The elements to look for in the set.
     - Returns: `true` if any of the elements exist in the set, otherwise `false`.
     */
    @_disfavoredOverload
    func contains<S: Sequence<Element>>(any members: S) -> Bool {
        members.contains { contains($0) }
    }

    /**
     A Boolean value indicating whether the set contains any of the specified elements.

     - Parameter members: The set of elements to look for in the set.
     - Returns: `true` if any of the elements exist in the set, otherwise `false`.
     */
    func contains(any members: Self) -> Bool {
        !intersection(members).isEmpty
    }

    /**
     A Boolean value indicating whether the set contains all specified elements.

     - Parameter members: The set of elements to look for in the set.
     - Returns: `true` if all elements exist in the set, otherwise `false`.
     */
    @_disfavoredOverload
    func contains(_ members: Self) -> Bool {
        isSuperset(of: members)
    }

    /**
     A Boolean value indicating whether the set contains all specified elements.

     - Parameter members: The elements to look for in the set.
     - Returns: `true` if all elements exist in the set, otherwise `false`.
     */
    @_disfavoredOverload
    func contains<S: Sequence<Element>>(_ members: S) -> Bool {
        !members.contains { !contains($0) }
    }

    /**
     A Boolean value that indicates whether the given element exists in the set.

     Setting this value to `true` inserts the element into the set if it is not already present. Setting it to `false` removes the element from the set.
     */
    subscript(_ element: Element) -> Bool {
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
     A Boolean value that indicates whether all elements of the given set exist in the set.

     Setting this value to `true` inserts the elements of the given set into the set. Setting it to `false` removes the elements from the set.
     */
    @_disfavoredOverload
    subscript(_ elements: Self) -> Bool {
        get { contains(elements) }
        set {
            if newValue {
                insert(elements)
            } else {
                remove(elements)
            }
        }
    }

    /**
     A Boolean value that indicates whether all elements of the given sequence exist in the set.

     Setting this value to `true` inserts the elements of the given sequence into the set. Setting it to `false` removes the elements from the set.
     */
    @_disfavoredOverload
    subscript<S: Sequence<Element>>(_ elements: S) -> Bool {
        get { contains(elements) }
        set {
            if newValue {
                insert(elements)
            } else {
                remove(elements)
            }
        }
    }

    static func + (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }

    static func + (lhs: Self, rhs: Element?) -> Self {
        guard let rhs else { return lhs }
        return lhs + rhs
    }

    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }

    static func += (lhs: inout Self, rhs: Element?) {
        guard let rhs else { return }
        lhs.insert(rhs)
    }

    static func - (lhs: Self, rhs: Element) -> Self {
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }

    static func - (lhs: Self, rhs: Element?) -> Self {
        guard let rhs else { return lhs }
        return lhs - rhs
    }

    static func -= (lhs: inout Self, rhs: Element) {
        lhs.remove(rhs)
    }

    static func -= (lhs: inout Self, rhs: Element?) {
        guard let rhs else { return }
        lhs.remove(rhs)
    }

    @_disfavoredOverload
    static func + <S: Sequence<Element>>(lhs: Self, rhs: S) -> Self {
        var lhs = lhs
        lhs.insert(rhs)
        return lhs
    }

    @_disfavoredOverload
    static func + <S: Sequence<Element>>(lhs: Self, rhs: S?) -> Self {
        guard let rhs else { return lhs }
        return lhs + rhs
    }

    @_disfavoredOverload
    static func += <S: Sequence<Element>>(lhs: inout Self, rhs: S) {
        lhs.insert(rhs)
    }

    @_disfavoredOverload
    static func += <S: Sequence<Element>>(lhs: inout Self, rhs: S?) {
        guard let rhs else { return }
        lhs.insert(rhs)
    }

    @_disfavoredOverload
    static func - <S: Sequence<Element>>(lhs: Self, rhs: S) -> Self {
        var lhs = lhs
        lhs.remove(rhs)
        return lhs
    }

    @_disfavoredOverload
    static func - <S: Sequence<Element>>(lhs: Self, rhs: S?) -> Self {
        guard let rhs else { return lhs }
        return lhs - rhs
    }

    @_disfavoredOverload
    static func -= <S: Sequence<Element>>(lhs: inout Self, rhs: S) {
        lhs.remove(rhs)
    }

    @_disfavoredOverload
    static func -= <S: Sequence<Element>>(lhs: inout Self, rhs: S?) {
        guard let rhs else { return }
        lhs.remove(rhs)
    }

    @_disfavoredOverload
    static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs.formUnion(rhs)
        return lhs
    }

    @_disfavoredOverload
    static func + (lhs: Self, rhs: Self?) -> Self {
        guard let rhs else { return lhs }
        return lhs + rhs
    }

    @_disfavoredOverload
    static func += (lhs: inout Self, rhs: Self) {
        lhs.formUnion(rhs)
    }

    @_disfavoredOverload
    static func += (lhs: inout Self, rhs: Self?) {
        guard let rhs else { return }
        lhs.formUnion(rhs)
    }

    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs.subtract(rhs)
        return lhs
    }

    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self?) -> Self {
        guard let rhs else { return lhs }
        return lhs - rhs
    }

    @_disfavoredOverload
    static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }

    @_disfavoredOverload
    static func -= (lhs: inout Self, rhs: Self?) {
        guard let rhs else { return }
        lhs.subtract(rhs)
    }
}

public extension Set {
    /**
     Removes all elements that satisfy the contain a value at the given keypath.

     - Parameter keypath: The keypath.
     */
    @discardableResult
    mutating func removeAll<Value>(containing keypath: KeyPath<Element, Value?>) -> Self {
        removeAll(where: { $0[keyPath: keypath] != nil })
    }

    /**
     Removes all elements that satisfy the given predicate.

     - Parameter shouldRemove: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be removed from the set.
     */
    @discardableResult
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Self {
        let toRemove = try filter(shouldBeRemoved)
        subtract(toRemove)
        return toRemove
    }

    /// The set as `Array`.
    var asArray: [Element] {
        Array(self)
    }

    /// Edits each element in the set.
    mutating func editEach(_ transform: (_ element: inout Element) throws -> Void) rethrows {
        self = try Self(map({
            var element = $0
            try transform(&element)
            return element
        }))
    }
}

public extension Set {
    /// A function builder type that produces a set.
    @resultBuilder
    enum Builder {
        public static func buildExpression(_ expression: Element?) -> [Element] {
            expression.map { [$0] } ?? []
        }

        public static func buildExpression(_ component: [Element]?) -> [Element] {
            component ?? []
        }

        public static func buildBlock(_ components: [Element]...) -> [Element] {
            components.flatMap { $0 }
        }

        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }

        public static func buildEither(first component: [Element]) -> [Element] {
            component
        }

        public static func buildEither(second component: [Element]) -> [Element] {
            component
        }

        public static func buildArray(_ components: [[Element]]) -> [Element] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression<S: Sequence<Element>>(_ expression: S) -> [Element] {
            Array(expression)
        }
    }

    /// Creates a new set from the specified elements.
    init(@Builder elements: () -> Self) {
        self = elements()
    }

    /// Inserts the specified elements into the set.
    mutating func insert(@Builder elements: () -> Self) {
        formUnion(elements())
    }

    /// Returns a new set with the specified elements inserted.
    func inserting(@Builder elements: () -> Self) -> Self {
        union(elements())
    }
}

public extension Sequence where Element: SetAlgebra {
    /// The union of all elements in the sequence.
    var union: Element {
        reduce(into: []) { $0.formUnion($1) }
    }

    /// The intersection of all elements in the sequence.
    var intersection: Element? {
        var iterator = makeIterator()
        guard var result = iterator.next() else { return nil }
        while let element = iterator.next() {
            result.formIntersection(element)
        }
        return result
    }

    /// Returns whether all elements are pairwise disjoint.
    var areDisjoint: Bool {
        var accumulated: Element = []
        for element in self {
            guard accumulated.isDisjoint(with: element) else { return false }
            accumulated.formUnion(element)
        }
        return true
    }
}
