//
//  SynchronizedValue.swift
//
//
//  Created by Florian Zand on 24.09.26.
//

import Foundation

/// A value that provides synchronized access using a concurrent dispatch queue.
public final class SynchronizedValue<Value> {
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedValue", attributes: .concurrent)
    private var storage: Value

    /// Creates a synchronized value containing the specified value.
    public init(_ value: Value) {
        storage = value
    }

    /// The current value.
    public var value: Value {
        get { queue.sync { storage } }
        set { queue.sync(flags: .barrier) { storage = newValue } }
    }

    /// Performs the specified closure with synchronized access to the value.
    @discardableResult
    public func withValue<Result>(_ body: (borrowing Value) throws -> Result) rethrows -> Result {
        try queue.sync { try body(storage) }
    }

    /// Performs the specified closure with exclusive synchronized access to the value.
    @discardableResult
    public func withMutableValue<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        try queue.sync(flags: .barrier) { try body(&storage) }
    }
}

extension SynchronizedValue: @unchecked Sendable where Value: Sendable {}

extension SynchronizedValue: Equatable where Value: Equatable {
    /// Returns a Boolean value indicating whether two synchronized values contain equal values.
    public static func == (lhs: SynchronizedValue<Value>, rhs: SynchronizedValue<Value>) -> Bool {
        lhs.value == rhs.value
    }
}

extension SynchronizedValue: Hashable where Value: Hashable {
    /// Hashes the contained value by feeding it into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension SynchronizedValue: Decodable where Value: Decodable {
    /// Creates a synchronized value by decoding from the given decoder.
    public convenience init(from decoder: Decoder) throws {
        self.init(try Value(from: decoder))
    }
}

extension SynchronizedValue: Encodable where Value: Encodable {
    /// Encodes the contained value into the given encoder.
    public func encode(to encoder: Encoder) throws {
        try withValue { try $0.encode(to: encoder) }
    }
}

extension SynchronizedValue: CustomStringConvertible where Value: CustomStringConvertible {
    /// A textual representation of the contained value.
    public var description: String {
        withValue { $0.description }
    }
}

extension SynchronizedValue: CustomDebugStringConvertible where Value: CustomDebugStringConvertible {
    /// A textual representation of the contained value suitable for debugging.
    public var debugDescription: String {
        withValue { $0.debugDescription }
    }
}

extension SynchronizedValue: CustomReflectable {
    /// A mirror that reflects the contained value.
    public var customMirror: Mirror {
        withValue { Mirror(reflecting: $0) }
    }
}

extension SynchronizedValue: Comparable where Value: Comparable {
    /// Returns a Boolean value indicating whether the first value is ordered before the second value.
    public static func < (lhs: SynchronizedValue<Value>, rhs: SynchronizedValue<Value>) -> Bool {
        lhs.value < rhs.value
    }
}

extension SynchronizedValue: Identifiable where Value: Identifiable {
    /// The stable identity of the contained value.
    public var id: Value.ID {
        withValue { $0.id }
    }
}
