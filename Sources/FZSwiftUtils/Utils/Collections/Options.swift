//
//  Options.swift
//
//
//  Created by Florian Zand on 24.11.23.
//

import Foundation

/// A type that represents an option and that can be with ``Options``.
public protocol Option: Hashable {
    /// The type that represents the option key.
    associatedtype OptionKey: Equatable
    /// The key of the option.
    var optionKey: OptionKey { get }
}

public extension Array where Element: Option {
    /// An array of unique options.
    func uniquedOptions() -> [Element] {
        var newValues: [Element] = []
        for element in self {
            if newValues.contains(where: { $0.optionKey == element.optionKey }) == false {
                newValues.append(element)
            }
        }
        return newValues
    }
}

public extension Set where Element: Option {
    /// A set of unique options.
    func uniquedOptions() -> Self {
        var newValues: Self = []
        for element in self {
            if newValues.contains(where: { $0.optionKey == element.optionKey }) == false {
                newValues.insert(element)
            }
        }
        return newValues
    }
}

/// A collection of unique oprions.
public struct Options<Element: Option>: Equatable, ExpressibleByArrayLiteral, SetAlgebra, Sequence, Collection {
    public typealias Index = Set<Element>.Index

    var elements: Set<Element> = []

    public init() {

    }

    public init<S: Sequence<Element>>(_ elements: S) {
        self.elements = .init(elements).uniquedOptions()
    }

    public init(arrayLiteral elements: Element...) {
        self.elements = Set(elements).uniquedOptions()
    }

    public var startIndex: Index { return elements.startIndex }
    public var endIndex: Index { return elements.endIndex }

    public subscript(index: Index) -> Element {
        get { return elements[index] }
    }

    public func index(after i: Index) -> Index {
        return elements.index(after: i)
    }

    @discardableResult
    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let oldMember = elements.first(where: { $0 == newMember }) {
            return (false, oldMember)
        }
        elements = .init(([newMember] + elements.collect()).uniquedOptions())
        return (true, newMember)
    }

    public mutating func insert<S: Sequence<Element>>(_ newElements: S) {
        elements = .init((newElements + elements.collect()).uniquedOptions())
    }

    @discardableResult
    public mutating func update(with newMember: __owned Element) -> Element? {
        elements.update(with: newMember)
    }

    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        elements.remove(member)
    }

    mutating func remove<S: Sequence<Element>>(_ elements: S) {
        elements.forEach({ self.remove($0) })
    }

    public mutating func removeAll() {
        elements.removeAll()
    }

    mutating func removeAll(where shouldRemove: (Self.Element) -> Bool) -> Self {
        let toRemove = filter(shouldRemove)
        self.remove(Array(toRemove))
        return toRemove
    }

    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        Self(try elements.filter({ try isIncluded($0) }))
    }

    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult) rethrows -> [ElementOfResult] {
        try self.elements.compactMap({ try transform($0) })
    }

    public func contains(_ member: Element) -> Bool {
        elements.contains(member)
    }

    public var isEmpty: Bool {
        elements.isEmpty
    }

    public func union(_ other: __owned Options<Element>) -> Options<Element> {
        Self((elements.collect() + other.collect()).uniquedOptions())
    }

    public mutating func formUnion(_ other: __owned Options<Element>) {
        self = self.union(other)
    }

    public func intersection(_ other: Options<Element>) -> Options<Element> {
        Self(elements.intersection(other))
    }

    public mutating func formIntersection(_ other: Options<Element>) {
        self = self.intersection(other)
    }

    public func symmetricDifference(_ other: __owned Options<Element>) -> Options<Element> {
        Self(self.elements.symmetricDifference(other))
    }

    public mutating func formSymmetricDifference(_ other: __owned Options<Element>) {
        self = self.symmetricDifference(other)
    }

    public func makeIterator() -> Set<Element>.Iterator {
        self.elements.makeIterator()
    }
}

extension Options: Hashable where Element: Hashable { }
extension Options: Sendable where Element: Sendable { }
extension Options: Encodable where Element: Encodable { }
extension Options: Decodable where Element: Decodable { }

extension Options: CustomStringConvertible {
    public var description: String {
        elements.description
    }
}

extension Options: CustomReflectable {
    public var customMirror: Mirror {
        elements.customMirror
    }
}

extension Options: CustomDebugStringConvertible {
    public var debugDescription: String {
        elements.debugDescription
    }
}

extension Options: CVarArg {
    public var _cVarArgEncoding: [Int] {
        elements._cVarArgEncoding
    }
}

public extension Options {
    static func + (lhs: Options, rhs: Options) -> Options {
        lhs.union(rhs)
    }

    static func += (lhs: inout Options, rhs: Options) {
        lhs.formUnion(rhs)
    }

    static func + (lhs: Options, rhs: Element) -> Options {
        var options = lhs
        options.insert(rhs)
        return options
    }

    static func += (lhs: inout Options, rhs: Element) {
        lhs.insert(rhs)
    }
}
