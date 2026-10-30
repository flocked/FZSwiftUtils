//
//  BiCo.swift
//
//
//  Created by Florian Zand on 05.09.26.
//

import Foundation

public struct BidirectionalDictionary<Left: Hashable, Right: Hashable>: ExpressibleByDictionaryLiteral, CustomStringConvertible, CustomDebugStringConvertible {
    @usableFromInline var _leftRight: [Left: Right]
    @usableFromInline var _rightLeft: [Right: Left]

    @inlinable
    public init() {
        _leftRight = Dictionary()
        _rightLeft = Dictionary()
    }

    @inlinable
    public init(minimumCapacity: Int) {
        _leftRight = Dictionary(minimumCapacity: minimumCapacity)
        _rightLeft = Dictionary(minimumCapacity: minimumCapacity)
    }

    public init<S: Sequence<(Left, Right)>>(uniqueKeysWithValues keysAndValues: S) {
        self.init(minimumCapacity: keysAndValues.underestimatedCount)

        for (left, right) in keysAndValues {
            precondition(_leftRight[left] == nil, "Duplicate left value: \(left)")
            precondition(_rightLeft[right] == nil, "Duplicate right value: \(right)")
            _leftRight[left] = right
            _rightLeft[right] = left
        }

        _invariantCheck()
    }

    public init(dictionaryLiteral elements: (Left, Right)...) {
        self.init(uniqueKeysWithValues: elements)
    }

    @inlinable
    public init?(_ dictionary: [Left: Right]) {
        self._leftRight = dictionary
        self._rightLeft = Dictionary(minimumCapacity: dictionary.count)
        for (left, right) in dictionary {
            guard _rightLeft.updateValue(left, forKey: right) == nil else {
                return nil
            }
        }
        _invariantCheck()
    }

    @usableFromInline
    init(_leftRight: [Left: Right], _rightLeft: [Right: Left]) {
        self._leftRight = _leftRight
        self._rightLeft = _rightLeft
    }

    @inlinable
    public var capacity: Int {
        Swift.min(_leftRight.capacity, _rightLeft.capacity)
    }

    @inlinable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _leftRight.reserveCapacity(minimumCapacity)
        _rightLeft.reserveCapacity(minimumCapacity)
    }

    @discardableResult
    @inlinable
    public mutating func updateRight(_ rightValue: Right?, for leftValue: Left) -> Right? {
        let oldRight = self[left: leftValue]
        self[left: leftValue] = rightValue
        return oldRight
    }

    @discardableResult
    @inlinable
    public mutating func updateLeft(_ leftValue: Left?, for rightValue: Right) -> Left? {
        let oldLeft = self[right: rightValue]
        self[right: rightValue] = leftValue
        return oldLeft
    }

    @discardableResult
    @inlinable
    public mutating func removeValue(forLeft leftValue: Left) -> Right? {
        defer { _invariantCheck() }
        guard let rightValue = _leftRight.removeValue(forKey: leftValue) else { return nil }
        _rightLeft.removeValue(forKey: rightValue)
        return rightValue
    }

    @discardableResult
    @inlinable
    public mutating func removeValue(forRight rightValue: Right) -> Left? {
        defer { _invariantCheck() }
        guard let leftValue = _rightLeft.removeValue(forKey: rightValue) else { return nil }
        _leftRight.removeValue(forKey: leftValue)
        return leftValue
    }

    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        defer { _invariantCheck() }
        _leftRight.removeAll(keepingCapacity: keepCapacity)
        _rightLeft.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public func contains(left leftValue: Left) -> Bool {
        _leftRight[leftValue] != nil
    }

    @inlinable
    public func contains(right rightValue: Right) -> Bool {
        _rightLeft[rightValue] != nil
    }

    @inlinable
    public subscript(left leftValue: Left) -> Right? {
        get { _leftRight[leftValue] }
        set(rightValue) {
            defer { _invariantCheck() }

            guard _leftRight[leftValue] != rightValue else { return }

            guard let rightValue else {
                guard let existingRight = _leftRight.removeValue(forKey: leftValue) else { return }
                _rightLeft.removeValue(forKey: existingRight)
                return
            }

            if let replacedLeft = _rightLeft.updateValue(leftValue, forKey: rightValue), replacedLeft != leftValue {
                _leftRight.removeValue(forKey: replacedLeft)
            }

            if let replacedRight = _leftRight.updateValue(rightValue, forKey: leftValue), replacedRight != rightValue {
                _rightLeft.removeValue(forKey: replacedRight)
            }
        }
    }

    @inlinable
    public subscript(_ leftValue: Left) -> Right? {
        get { self[left: leftValue] }
        set { self[left: leftValue] = newValue }
    }

    @inlinable
    public subscript(right rightValue: Right) -> Left? {
        get { _rightLeft[rightValue] }
        set(leftValue) {
            defer { _invariantCheck() }

            guard _rightLeft[rightValue] != leftValue else { return }

            guard let leftValue else {
                guard let existingLeft = _rightLeft.removeValue(forKey: rightValue) else { return }
                _leftRight.removeValue(forKey: existingLeft)
                return
            }

            if let replacedRight = _leftRight.updateValue(rightValue, forKey: leftValue), replacedRight != rightValue {
                _rightLeft.removeValue(forKey: replacedRight)
            }

            if let replacedLeft = _rightLeft.updateValue(leftValue, forKey: rightValue), replacedLeft != leftValue {
                _leftRight.removeValue(forKey: replacedLeft)
            }
        }
    }

    @_disfavoredOverload
    @inlinable
    public subscript(_ rightValue: Right) -> Left? {
        get { self[right: rightValue] }
        set { self[right: rightValue] = newValue }
    }

    @inlinable
    public subscript(left leftValue: Left, default defaultValue: @autoclosure () -> Right) -> Right {
        get { self[left: leftValue] ?? defaultValue() }
        set { self[left: leftValue] = newValue }
    }

    @inlinable
    public subscript(_ leftValue: Left, default defaultValue: @autoclosure () -> Right) -> Right {
        get { self[left: leftValue] ?? defaultValue() }
        set { self[left: leftValue] = newValue }
    }

    @inlinable
    public subscript(right rightValue: Right, default defaultValue: @autoclosure () -> Left) -> Left {
        get { self[right: rightValue] ?? defaultValue() }
        set { self[right: rightValue] = newValue }
    }

    @_disfavoredOverload
    @inlinable
    public subscript(_ rightValue: Right, default defaultValue: @autoclosure () -> Left) -> Left {
        get { self[right: rightValue] ?? defaultValue() }
        set { self[right: rightValue] = newValue }
    }

    @inlinable
    public func element(forLeft leftValue: Left) -> Element? {
        guard let rightValue = _leftRight[leftValue] else { return nil }
        return (left: leftValue, right: rightValue)
    }

    @inlinable
    public func element(forRight rightValue: Right) -> Element? {
        guard let leftValue = _rightLeft[rightValue] else { return nil }
        return (left: leftValue, right: rightValue)
    }

    /// A bidirectional dictionary with the left and right values interchanged.
    @inlinable
    public var inverse: BidirectionalDictionary<Right, Left> {
        .init(_leftRight: _rightLeft, _rightLeft: _leftRight)
    }

    public typealias LeftValues = Dictionary<Left, Right>.Keys
    public typealias RightValues = Dictionary<Left, Right>.Values

    @inlinable
    public var leftValues: LeftValues {
        _leftRight.keys
    }

    @inlinable
    public var rightValues: RightValues {
        _leftRight.values
    }
    
    @inlinable public var leftRight: [Left: Right] {
        _leftRight
    }

    @inlinable public var rightLeft: [Right: Left] {
        _rightLeft
    }
    
    public var description: String {
        _leftRight.description
    }
    
    public var debugDescription: String {
        _leftRight.debugDescription
    }
}


// MARK: - Collection

extension BidirectionalDictionary: Collection {
    public typealias Element = (left: Left, right: Right)

    public struct Index: Comparable {
        @usableFromInline
        let _leftRightIndex: Dictionary<Left, Right>.Index

        @usableFromInline
        init(_ ltrIndex: Dictionary<Left, Right>.Index) {
            self._leftRightIndex = ltrIndex
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs._leftRightIndex < rhs._leftRightIndex
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(_leftRight.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(_leftRight.endIndex)
    }

    @inlinable
    public subscript(position: Index) -> Element {
        let element = _leftRight[position._leftRightIndex]
        return (left: element.key, right: element.value)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        Index(_leftRight.index(after: i._leftRightIndex))
    }

    @inlinable
    public func index(of element: Element) -> Index? {
        guard let index = _leftRight.index(forKey: element.left), _leftRight[index].value == element.right else { return nil }
        return Index(index)
    }

    @inlinable
    public func index(forLeft leftValue: Left) -> Index? {
        _leftRight.index(forKey: leftValue).map(Index.init)
    }

    @inlinable
    public func index(forRight rightValue: Right) -> Index? {
        guard let leftValue = _rightLeft[rightValue] else { return nil }
        return _leftRight.index(forKey: leftValue).map(Index.init)
    }

    @inlinable
    public var isEmpty: Bool {
        assert(_leftRight.isEmpty == _rightLeft.isEmpty)
        return _leftRight.isEmpty
    }

    @inlinable
    public var count: Int {
        assert(_leftRight.count == _rightLeft.count)
        return _leftRight.count
    }
}


// MARK: - Iterator

extension BidirectionalDictionary {
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        var _leftRightIterator: Dictionary<Left, Right>.Iterator

        @usableFromInline
        init(_ ltrIterator: Dictionary<Left, Right>.Iterator) {
            self._leftRightIterator = ltrIterator
        }

        @inlinable
        public mutating func next() -> Element? {
            guard let element = _leftRightIterator.next() else { return nil }
            return (left: element.key, right: element.value)
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(_leftRight.makeIterator())
    }
}

extension BidirectionalDictionary.Iterator: Sendable where Left: Sendable, Right: Sendable {}
extension BidirectionalDictionary.Index: Sendable where Left: Sendable, Right: Sendable {}


// MARK: - Codable

extension BidirectionalDictionary: Encodable where Left: Encodable, Right: Encodable {
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle(_leftRight)
    }
}

extension BidirectionalDictionary: Decodable where Left: Decodable, Right: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([Left: Right].self)

        guard let value = Self(dictionary) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "The decoded dictionary must have unique left and right values."
            )
        }

        self = value
    }
}


// MARK: - Dictionary conversion

public extension Dictionary {
    @inlinable
    init(_ bidirectionalDictionary: BidirectionalDictionary<Key, Value>) where Value: Hashable {
        self = bidirectionalDictionary._leftRight
    }
}


// MARK: - Equatable / Hashable

extension BidirectionalDictionary: Hashable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._leftRight == rhs._leftRight
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_leftRight)
    }
}

public extension BidirectionalDictionary {
    @inlinable
    static func == (lhs: Self, rhs: [Left: Right]) -> Bool {
        lhs._leftRight == rhs
    }

    @inlinable
    static func == (lhs: [Left: Right], rhs: Self) -> Bool {
        lhs == rhs._leftRight
    }
}


// MARK: - Sendable

extension BidirectionalDictionary: Sendable where Left: Sendable, Right: Sendable {}
#if compiler(>=6.2) && canImport(Swift, _version: 6.2)
extension BidirectionalDictionary: SendableMetatype {}
#endif

// MARK: - Reflection

extension BidirectionalDictionary: CustomReflectable {
    public var customMirror: Mirror {
        _leftRight.customMirror
    }
}


// MARK: - Objective-C bridging

extension BidirectionalDictionary: _ObjectiveCBridgeable {
    public func _bridgeToObjectiveC() -> _BidirectionalDictionary<Left, Right> {
        _BidirectionalDictionary(self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: _BidirectionalDictionary<Left, Right>, result: inout Self?) {
        result = source.value
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: _BidirectionalDictionary<Left, Right>, result: inout Self?) -> Bool {
        result = source.value
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: _BidirectionalDictionary<Left, Right>?) -> Self {
        guard let source else { return Self() }
        var result: Self?
        _forceBridgeFromObjectiveC(source, result: &result)
        return result!
    }
}

/// The Objective-C class for ``BidirectionalDictionary``.
public final class _BidirectionalDictionary<Left: Hashable, Right: Hashable>: NSObject, NSCopying {
    let value: BidirectionalDictionary<Left, Right>
    
    init(_ value: BidirectionalDictionary<Left, Right>) {
        self.value = value
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        self
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return self === other || value == other.value
    }

    public override var hash: Int {
        value.hashValue
    }
}

extension BidirectionalDictionary {
    #if DEBUG
        @usableFromInline @inline(never)
        func _invariantCheck() {
            assert(_leftRight.count == _rightLeft.count, "Internal dictionaries should always have same count after update.")
            for (leftKey, leftValue) in _leftRight {
                assert(
                    _rightLeft[leftValue] == leftKey,
                    "Internal dictionaries should have same key value pairs after update."
                )
            }
            for (rightKey, rightValue) in _rightLeft {
                assert(
                    _leftRight[rightValue] == rightKey,
                    "Internal dictionaries should have same key value pairs after update."
                )
            }
        }
    #else
        @inlinable @inline(__always)
        func _invariantCheck() {}
    #endif
}

public extension BidirectionalDictionary {
    /// Merges the specified elements, combining values associated with duplicate left keys.
    @inlinable
    mutating func merge<S: Sequence, E: Error>(
        _ other: S,
        uniquingKeysWith combine: (Right, Right) throws(E) -> Right
    ) throws(E) where S.Element == Element {
        for (left, right) in other {
            if let existing = self[left: left] {
                self[left: left] = try combine(existing, right)
            } else {
                self[left: left] = right
            }
        }
    }

    /// Returns a dictionary by merging the specified elements, combining values associated with duplicate left keys.
    @inlinable
    func merging<S: Sequence, E: Error>(
        _ other: S,
        uniquingKeysWith combine: (Right, Right) throws(E) -> Right
    ) throws(E) -> Self where S.Element == Element {
        var result = self
        try result.merge(other, uniquingKeysWith: combine)
        return result
    }
}
