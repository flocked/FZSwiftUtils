//
//  BiCo.swift
//
//
//  Created by Florian Zand on 05.09.26.
//

import Foundation

public struct BidirectionalDictionary<Left: Hashable, Right: Hashable>: ExpressibleByDictionaryLiteral, CustomStringConvertible, CustomDebugStringConvertible {
    @usableFromInline internal var _ltr: [Left: Right]
    @usableFromInline internal var _rtl: [Right: Left]

    @inlinable
    public init() {
        self._ltr = Dictionary()
        self._rtl = Dictionary()
    }

    @inlinable
    public init(minimumCapacity: Int) {
        self._ltr = Dictionary(minimumCapacity: minimumCapacity)
        self._rtl = Dictionary(minimumCapacity: minimumCapacity)
    }

    public init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Left, Right) {
        self.init(minimumCapacity: keysAndValues.underestimatedCount)

        for (left, right) in keysAndValues {
            guard _ltr.updateValue(right, forKey: left) == nil else {
                fatalError("\(Self.self) contains duplicate left value: \(String(reflecting: left)).")
            }
            guard _rtl.updateValue(left, forKey: right) == nil else {
                fatalError("\(Self.self) contains duplicate right value: \(String(reflecting: right)).")
            }
        }

        _invariantCheck()
    }

    public init(dictionaryLiteral elements: (Left, Right)...) {
        self.init(uniqueKeysWithValues: elements)
    }

    @inlinable
    public init?(_ dictionary: [Left: Right]) {
        self._ltr = dictionary
        self._rtl = Dictionary(minimumCapacity: dictionary.count)
        for (left, right) in dictionary {
            guard _rtl.updateValue(left, forKey: right) == nil else {
                return nil
            }
        }
        _invariantCheck()
    }

    @usableFromInline
    internal init(_ltr: [Left: Right], _rtl: [Right: Left]) {
        self._ltr = _ltr
        self._rtl = _rtl
    }

    @inlinable
    public var capacity: Int {
        Swift.min(_ltr.capacity, _rtl.capacity)
    }

    @inlinable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _ltr.reserveCapacity(minimumCapacity)
        _rtl.reserveCapacity(minimumCapacity)
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
        guard let rightValue = _ltr.removeValue(forKey: leftValue) else { return nil }
        _rtl.removeValue(forKey: rightValue)
        return rightValue
    }

    @discardableResult
    @inlinable
    public mutating func removeValue(forRight rightValue: Right) -> Left? {
        defer { _invariantCheck() }
        guard let leftValue = _rtl.removeValue(forKey: rightValue) else { return nil }
        _ltr.removeValue(forKey: leftValue)
        return leftValue
    }

    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        defer { _invariantCheck() }
        _ltr.removeAll(keepingCapacity: keepCapacity)
        _rtl.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public func contains(left leftValue: Left) -> Bool {
        _ltr[leftValue] != nil
    }

    @inlinable
    public func contains(right rightValue: Right) -> Bool {
        _rtl[rightValue] != nil
    }

    @inlinable
    public subscript(left leftValue: Left) -> Right? {
        get {
            _ltr[leftValue]
        }
        set(rightValue) {
            defer { _invariantCheck() }

            guard _ltr[leftValue] != rightValue else { return }

            guard let rightValue else {
                guard let existingRight = _ltr.removeValue(forKey: leftValue) else { return }
                _rtl.removeValue(forKey: existingRight)
                return
            }

            if let replacedLeft = _rtl.updateValue(leftValue, forKey: rightValue), replacedLeft != leftValue {
                _ltr.removeValue(forKey: replacedLeft)
            }

            if let replacedRight = _ltr.updateValue(rightValue, forKey: leftValue), replacedRight != rightValue {
                _rtl.removeValue(forKey: replacedRight)
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
        get {
            _rtl[rightValue]
        }
        set(leftValue) {
            defer { _invariantCheck() }

            guard _rtl[rightValue] != leftValue else { return }

            guard let leftValue else {
                guard let existingLeft = _rtl.removeValue(forKey: rightValue) else { return }
                _ltr.removeValue(forKey: existingLeft)
                return
            }

            if let replacedRight = _ltr.updateValue(rightValue, forKey: leftValue), replacedRight != rightValue {
                _rtl.removeValue(forKey: replacedRight)
            }

            if let replacedLeft = _rtl.updateValue(leftValue, forKey: rightValue), replacedLeft != leftValue {
                _ltr.removeValue(forKey: replacedLeft)
            }
        }
    }

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

    @inlinable
    public subscript(_ rightValue: Right, default defaultValue: @autoclosure () -> Left) -> Left {
        get { self[right: rightValue] ?? defaultValue() }
        set { self[right: rightValue] = newValue }
    }

    @inlinable
    public func element(forLeft leftValue: Left) -> Element? {
        guard let rightValue = _ltr[leftValue] else { return nil }
        return (left: leftValue, right: rightValue)
    }

    @inlinable
    public func element(forRight rightValue: Right) -> Element? {
        guard let leftValue = _rtl[rightValue] else { return nil }
        return (left: leftValue, right: rightValue)
    }

    /// A bidirectional dictionary with the left and right values interchanged.
    @inlinable
    public var inverse: BidirectionalDictionary<Right, Left> {
        .init(_ltr: _rtl, _rtl: _ltr)
    }

    public typealias LeftValues = Dictionary<Left, Right>.Keys
    public typealias RightValues = Dictionary<Left, Right>.Values

    @inlinable
    public var leftValues: LeftValues {
        _ltr.keys
    }

    @inlinable
    public var rightValues: RightValues {
        _ltr.values
    }
    
    @inlinable public var leftRight: [Left: Right] {
        _ltr
    }

    @inlinable public var rightLeft: [Right: Left] {
        _rtl
    }
    
    public var description: String {
        _ltr.description
    }
    
    public var debugDescription: String {
        _ltr.debugDescription
    }
}


// MARK: - Collection

extension BidirectionalDictionary: Collection {
    public typealias Element = (left: Left, right: Right)

    public struct Index: Comparable {
        @usableFromInline
        internal let _ltrIndex: Dictionary<Left, Right>.Index

        @usableFromInline
        internal init(_ ltrIndex: Dictionary<Left, Right>.Index) {
            self._ltrIndex = ltrIndex
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs._ltrIndex < rhs._ltrIndex
        }
    }

    @inlinable
    public var startIndex: Index {
        Index(_ltr.startIndex)
    }

    @inlinable
    public var endIndex: Index {
        Index(_ltr.endIndex)
    }

    @inlinable
    public subscript(position: Index) -> Element {
        let element = _ltr[position._ltrIndex]
        return (left: element.key, right: element.value)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        Index(_ltr.index(after: i._ltrIndex))
    }

    @inlinable
    public func index(of element: Element) -> Index? {
        guard let index = _ltr.index(forKey: element.left), _ltr[index].value == element.right else { return nil }
        return Index(index)
    }

    @inlinable
    public func index(forLeft leftValue: Left) -> Index? {
        _ltr.index(forKey: leftValue).map(Index.init)
    }

    @inlinable
    public func index(forRight rightValue: Right) -> Index? {
        guard let leftValue = _rtl[rightValue] else { return nil }
        return _ltr.index(forKey: leftValue).map(Index.init)
    }

    @inlinable
    public var isEmpty: Bool {
        assert(_ltr.isEmpty == _rtl.isEmpty)
        return _ltr.isEmpty
    }

    @inlinable
    public var count: Int {
        assert(_ltr.count == _rtl.count)
        return _ltr.count
    }
}


// MARK: - Iterator

extension BidirectionalDictionary {
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        internal var _ltrIterator: Dictionary<Left, Right>.Iterator

        @usableFromInline
        internal init(_ ltrIterator: Dictionary<Left, Right>.Iterator) {
            self._ltrIterator = ltrIterator
        }

        @inlinable
        public mutating func next() -> Element? {
            guard let element = _ltrIterator.next() else { return nil }
            return (left: element.key, right: element.value)
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(_ltr.makeIterator())
    }
}

extension BidirectionalDictionary.Iterator: Sendable where Left: Sendable, Right: Sendable {}
extension BidirectionalDictionary.Index: Sendable where Left: Sendable, Right: Sendable {}


// MARK: - Codable

extension BidirectionalDictionary: Encodable where Left: Encodable, Right: Encodable {
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle(_ltr)
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
        self = bidirectionalDictionary._ltr
    }
}


// MARK: - Equatable / Hashable

extension BidirectionalDictionary: Hashable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._ltr == rhs._ltr
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_ltr)
    }
}

public extension BidirectionalDictionary {
    @inlinable
    static func == (lhs: Self, rhs: [Left: Right]) -> Bool {
        lhs._ltr == rhs
    }

    @inlinable
    static func == (lhs: [Left: Right], rhs: Self) -> Bool {
        lhs == rhs._ltr
    }
}


// MARK: - Sendable

extension BidirectionalDictionary: Sendable where Left: Sendable, Right: Sendable {}
extension BidirectionalDictionary: SendableMetatype {}


// MARK: - Reflection

extension BidirectionalDictionary: CustomReflectable {
    public var customMirror: Mirror {
        _ltr.customMirror
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
        internal func _invariantCheck() {
            assert(_ltr.count == _rtl.count, "Internal dictionaries should always have same count after update.")
            for (leftKey, leftValue) in _ltr {
                assert(
                    _rtl[leftValue] == leftKey,
                    "Internal dictionaries should have same key value pairs after update."
                )
            }
            for (rightKey, rightValue) in _rtl {
                assert(
                    _ltr[rightValue] == rightKey,
                    "Internal dictionaries should have same key value pairs after update."
                )
            }
        }
    #else
        @inlinable @inline(__always)
        internal func _invariantCheck() {}
    #endif
}

