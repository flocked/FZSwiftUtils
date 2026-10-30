//
//  DefaultStringInterpolation+.swift
//
//
//  Created by Florian Zand on 12.10.26.
//

import Foundation

public extension DefaultStringInterpolation {
    /// Interpolates the given value’s textual representation into the string literal being created.
    @_disfavoredOverload
    mutating func appendInterpolation(_ value: any CustomStringConvertible) {
        appendLiteral(value.description)
    }
    
    /// Interpolates the wrapped value’s textual representation if present.
    mutating func appendInterpolation<V>(_ value: V?) {
        guard let value else { return }
        appendInterpolation(value)
    }
    
    /// Interpolates the wrapped value’s textual representation if present, or `"nil"` otherwise.
    mutating func appendInterpolation<V>(nil value: V?) {
        if let value = value {
            appendInterpolation(value)
        } else {
            appendLiteral("nil")
        }
    }

    /// Interpolates the wrapped value’s textual representation if present, or the provided fallback string otherwise.
    mutating func appendInterpolation<V>(_ value: V?, or nilValue: @autoclosure () -> String) {
        if let value = value {
            appendInterpolation(value)
        } else {
            appendLiteral(nilValue())
        }
    }
    
    /// Interpolates the wrapped value’s textual representation if present, or the provided fallback value’s textual representation otherwise.
    @_disfavoredOverload
    mutating func appendInterpolation<V, N>(_ value: V?, or nilValue: @autoclosure () -> N) {
        if let value = value {
            appendInterpolation(value)
        } else {
            appendInterpolation(nilValue())
        }
    }
    
    /// Interpolates the given value’s debug representation into the string literal being created.
    @_disfavoredOverload
    mutating func appendInterpolation(reflecting value: any CustomDebugStringConvertible) {
        appendLiteral(value.debugDescription)
    }
    
    /// Interpolates the given value’s debug representation into the string literal being created.
    mutating func appendInterpolation<V>(reflecting value: V) {
        appendLiteral(String(reflecting: value))
    }
    
    /// Interpolates the wrapped value’s debug representation if present.
    mutating func appendInterpolation<V>(reflecting value: V?) {
        guard let value else { return }
        appendInterpolation(reflecting: value)
    }
    
    /// Interpolates the wrapped value’s debug representation if present, or `"nil"` otherwise.
    mutating func appendInterpolation<V>(reflectingNil value: V?) {
        if let value = value {
            appendInterpolation(reflecting: value)
        } else {
            appendLiteral("nil")
        }
    }
    
    /// Interpolates the wrapped value’s debug representation if present, or the provided fallback string otherwise.
    mutating func appendInterpolation<V>(reflecting value: V?, or nilValue: @autoclosure () -> String) {
        if let value = value {
            appendInterpolation(reflecting: value)
        } else {
            appendLiteral(nilValue())
        }
    }
    
    /// Interpolates the wrapped value’s debug representation if present, or the provided fallback value’s debug representation otherwise.
    @_disfavoredOverload
    mutating func appendInterpolation<V, N>(reflecting value: V?, or nilValue: @autoclosure () -> N) {
        if let value = value {
            appendInterpolation(reflecting: value)
        } else {
            appendInterpolation(reflecting: nilValue())
        }
    }
}
