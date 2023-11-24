//
//  Options.swift
//
//
//  Created by Florian Zand on 24.11.23.
//

import Foundation

/// A type that represents an option and that can be with ``Options``.
public protocol Option: Equatable {
    /// The type that represents the option key.
    associatedtype OptionKey: Equatable
    /// The key of the option.
    var optionKey: OptionKey { get }
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

/// A collection of unique oprions.
public struct Options<Element: Option>: Equatable, ExpressibleByArrayLiteral, SetAlgebra, Sequence {
    var elements: [Element] = []

    public init() {
        
    }
    
    public init<S: Sequence<Element>>(_ elements: S) {
        self.elements = .init(elements).uniquedOptions()
    }
    
    public init(arrayLiteral elements: Element...) {
        self.elements = elements.uniquedOptions()
    }
            
    @discardableResult
    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if let oldMember = self.elements.first(where: { $0 == newMember }) {
            return (false, oldMember)
        }
        elements.append(newMember)
        return (true, newMember)
    }
    
    public mutating func insert<S: Sequence<Element>>(_ newElements: S) {
        self.elements = (newElements + self.elements).uniquedOptions()
    }
    
    @discardableResult
    public mutating func update(with newMember: __owned Element) -> Element? {
        if let index = elements.firstIndex(where: { $0 == newMember }) {
            let oldMember = elements[index]
            elements[index] = newMember
            return oldMember
        }
        return nil
    }
    
    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        self.elements.remove(member)
    }
    
    public mutating func removeAll() {
        self.elements.removeAll()
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
        Self(try self.elements.filter({ try isIncluded($0) }))
    }
    
    public func contains(_ member: Element) -> Bool {
        self.elements.contains(member)
    }
    
    public var isEmpty: Bool {
        self.elements.isEmpty
    }
    
    public func union(_ other: __owned Options<Element>) -> Options<Element> {
        Self((self.elements + other.elements).uniquedOptions())
    }
    
    public mutating func formUnion(_ other: __owned Options<Element>) {
        self = self.union(other)
    }
    
    public func intersection(_ other: Options<Element>) -> Options<Element> {
        Self(self.elements.filter({ other.elements.contains($0) }))
    }
    
    public mutating func formIntersection(_ other: Options<Element>) {
        self = self.intersection(other)
    }
    
    public func symmetricDifference(_ other: __owned Options<Element>) -> Options<Element> {
        var newElements = self.elements.filter({ other.elements.contains($0) == false })
        newElements.append(contentsOf: other.elements.filter({ self.elements.contains($0) == false }))
        return Self(newElements)
    }
    
    public mutating func formSymmetricDifference(_ other: __owned Options<Element>) {
        self = self.symmetricDifference(other)
    }
    
    public func makeIterator() -> IndexingIterator<[Element]> {
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
