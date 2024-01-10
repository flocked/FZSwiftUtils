//
//  KeyValueCodable.swift
//
//
//  Created by Florian Zand on 24.07.23.
//

import Foundation

/// A protocol for getting and setting values of an object by key.
public protocol KeyValueCodable {
    /// Returns the value for the property identified by a given key.
    func value(for key: String) -> Any?

    /// Sets the property of the receiver specified by a given key to a given value.
    func setValue(_ value: Any?, for key: String)

    /// Calls the selector with the specified name and values and returns its result.
    @discardableResult
    func call(_ name: String, values: [Any?]) -> Any?
}

public extension KeyValueCodable {
    func value(for _: String) -> Any? {
        nil
    }

    func value<V>(for key: String) -> V? {
        value(for: key) as? V
    }

    func setValue(_: Any?, for _: String) {}

    @discardableResult
    func call(_: String, values _: [Any?]) -> Any? {
        nil
    }

    /// Calls the selector with the specified name and values and returns its result.
    @discardableResult
    func call<V>(_ name: String, values: [Any?]) -> V? {
        call(name, values: values) as? V
    }

    subscript(key key: String) -> Any? {
        get { value(for: key) }
        set { setValue(newValue, for: key) }
    }

    subscript<V>(key key: String) -> V? {
        get { value(for: key) }
        set { setValue(newValue, for: key) }
    }
}

extension KeyValueCodable where Self: NSObject {
    func value(for key: String) -> Any? {
        value(forKeyPath: key)
    }

    func setValue(_ value: Any?, for key: String) {
        setValue(value, forKeyPath: key)
    }
}
