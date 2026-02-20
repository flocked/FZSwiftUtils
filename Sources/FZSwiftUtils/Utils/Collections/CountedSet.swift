//
//  CountedSet.swift
//
//
//  Created by Florian Zand on 23.01.26.
//

/// An unordered collection of unique elements that may appear more than once in the collection.
public struct CountedSet<Element: Hashable>: SetAlgebra, ExpressibleByArrayLiteral {
    fileprivate var storage = [Element: Int]()

    public init() { }

    public init(arrayLiteral elements: Element...) {
        insert(elements)
    }

    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        insert(sequence)
    }
    
    public var count: Int {
        storage.count
    }

    public var isEmpty: Bool {
        count == 0
    }

    public func count(for object: Element) -> Int {
        storage[object] ?? 0
    }

    public func contains(_ member: Element) -> Bool {
        storage[member] != nil
    }

    fileprivate mutating func insert(_ members: [Element]) {
        for member in members {
            guard !insert(member).inserted else { continue }
            update(with: member)
        }
    }


    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        if contains(newMember) {
            return (false, newMember)
        } else {
            storage[newMember] = 1
            return (true, newMember)
        }
    }

    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        update(with: newMember, count: 1)
    }

    @discardableResult
    public mutating func update(with newMember: Element, count: Int) -> Element? {
        if let existing = storage[newMember] {
            storage[newMember] = (existing + count)
            return newMember
        } else {
            storage[newMember] = count
            return nil
        }
    }

    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        remove(member, count: 1)
    }

    @discardableResult
    public mutating func remove(_ member: Element, count: Int = 1) -> Element? {
        guard let value = storage[member] else {
            return nil
        }
        if value > count {
            storage[member] = (value - count)
        } else {
            storage.removeValue(forKey: member)
        }
        return member
    }

    public mutating func formUnion(_ other: CountedSet<Element>) {
        for (key, value) in other.storage {
            if let existingValue = storage[key] {
                storage[key] = existingValue + value
            } else {
                storage[key] = value
            }
        }
    }

    public func union(_ other: CountedSet<Element>) -> CountedSet<Element> {
        var unionized = self
        unionized.formUnion(other)
        return unionized
    }

    public mutating func formIntersection(_ other: CountedSet<Element>) {
        for (key, value) in storage {
            if let existingValue = other.storage[key] {
                storage[key] = existingValue + value
            } else {
                storage.removeValue(forKey: key)
            }
        }
    }

    public func intersectsSet(_ other: CountedSet<Element>) -> Bool {
        for (key, _) in other.storage {
            if let _ = storage[key] {
                return true
            }
        }
        return false
    }

    public func intersection(_ other: CountedSet<Element>) -> CountedSet<Element> {
        var intersected = self
        intersected.formIntersection(other)
        return intersected
    }

    public mutating func formSymmetricDifference(_ other: CountedSet<Element>) {
        for (key, value) in other.storage {
            if let _ = storage[key] {
                storage.removeValue(forKey: key)
            } else {
                storage[key] = value
            }
        }
    }
    
    public func symmetricDifference(_ other: CountedSet<Element>) -> CountedSet<Element> {
        var xored = self
        xored.formSymmetricDifference(other)
        return xored
    }

    public mutating func subtract(_ other: CountedSet<Element>) {
        for (key, value) in other.storage {
            guard let existingValue = storage[key] else { continue }
            if value >= existingValue {
                storage.removeValue(forKey: key)
            } else {
                storage[key] = existingValue - value
            }
        }
    }

    public func subtracting(_ other: CountedSet<Element>) -> CountedSet<Element> {
        var subtracted = self
        subtracted.subtract(other)
        return subtracted
    }

    public func isSubset(of other: CountedSet<Element>) -> Bool {
        for (key, _) in storage {
            if !other.storage.keys.contains(key) {
                return false
            }
        }
        return true
    }

    public func isDisjoint(with other: CountedSet<Element>) -> Bool {
        intersection(other).isEmpty
    }

    public func isSuperset(of other: CountedSet<Element>) -> Bool {
        for (key, _) in other.storage {
            if !storage.keys.contains(key) {
                return false
            }
        }
        return true
    }

    public func isStrictSupersetOf(_ other: CountedSet<Element>) -> Bool {
        isSuperset(of: other) && count > other.count
    }

    public func isStrictSubsetOf(_ other: CountedSet<Element>) -> Bool {
        isSubset(of: other) && count < other.count
    }

    public static func element(_ a: Element, subsumes b: Element) -> Bool {
        CountedSet([a]).isSuperset(of: CountedSet([b]))
    }

    public static func element(_ a: Element, isDisjointWith b: Element) -> Bool {
        !CountedSet.element(a, subsumes: b) && !CountedSet.element(b, subsumes: a)
    }
}

extension CountedSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable, CVarArg {
    public var description: String {
        storage.description
    }

    public var debugDescription: String {
        storage.debugDescription
    }
    
    public var customMirror: Mirror {
        storage.customMirror
    }
    
    public var _cVarArgEncoding: [Int] {
        storage._cVarArgEncoding
    }
}

extension CountedSet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension CountedSet: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        var keysIterator = storage.keys.makeIterator()
        return AnyIterator { keysIterator.next() }
    }
    
    public var elementCounts: [Element: Int] {
        storage
    }
}

extension CountedSet: Decodable where Element: Decodable { }
extension CountedSet: Encodable where Element: Encodable { }
extension CountedSet: Sendable where Element: Sendable { }
