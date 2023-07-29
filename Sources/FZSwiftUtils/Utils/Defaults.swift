//
//  Defaults.swift
//
// Parts taken from:
//  Copyright (c) 2017 - 2018 Nuno Manuel Dias
//  Created by Florian Zand on 19.01.23.
//

import Foundation

public class DefaultsKey {}

public extension Defaults {
    /// Represents a `Key` with an associated generic value type conforming to the
    /// `Codable` protocol.
    ///
    ///     static let someKey = Key<ValueType>("someKey")
    final class Key<ValueType: Codable>: DefaultsKey {
        fileprivate let _key: String
        public init(_ key: String) {
            _key = key
        }
    }
}

/// Provides strongly typed values associated with the lifetime
/// of an application. Apropriate for user preferences.
/// - Warning
/// These should not be used to store sensitive information that could compromise
/// the application or the user's security and privacy.
public final class Defaults {
    private var userDefaults: UserDefaults

    /// Shared instance of `Defaults`, used for ad-hoc access to the user's
    /// defaults database throughout the app.
    public static let shared = Defaults()

    /// An instance of `Defaults` with the specified `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The UserDefaults.
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    /// Deletes the value associated with the specified key, if any.
    ///
    /// - Parameter key: The key.
    public func clear<ValueType>(_ key: Key<ValueType>) {
        userDefaults.set(nil, forKey: key._key)
        userDefaults.synchronize()
    }

    /// Checks if there is a value associated with the specified key.
    ///
    /// - Parameter key: The key to look for.
    /// - Returns: A boolean value indicating if a value exists for the specified key.
    public func has<ValueType>(_ key: Key<ValueType>) -> Bool {
        return userDefaults.value(forKey: key._key) != nil
    }

    public subscript<T: Codable>(key: Key<T>) -> T? {
        get { get(for: key) }
        set {
            if let newValue = newValue {
                set(newValue, for: key)
            } else {
                clear(key)
            }
        }
    }

    public subscript<T: Codable>(key: String) -> T? {
        get {
            let key = Key<T>(key)
            return get(for: key)
        }
        set {
            let key = Key<T>(key)
            if let newValue = newValue {
                set(newValue, for: key)
            } else {
                clear(key)
            }
        }
    }

    /*
     public func get<ValueType: Codable>(for key: String) -> ValueType? {
         let key: Key<ValueType> = Key<ValueType>(key)
         return self.get(for: key)
     }

     public func set<ValueType: Codable>(_ value: ValueType, for key: String) {
         let key: Key<ValueType> = Key<ValueType>(key)
         self.set(value, for: key)
     }

     */

    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: The key.
    /// - Returns: A `ValueType` or nil if the key was not found.
    public func get<ValueType>(for key: Key<ValueType>) -> ValueType? {
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            return userDefaults.value(forKey: key._key) as? ValueType
        }

        guard let data = userDefaults.data(forKey: key._key) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ValueType.self, from: data)
            return decoded
        } catch {
            #if DEBUG
            print(error)
            #endif
        }

        return nil
    }

    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    public func set<ValueType>(_ value: ValueType, for key: Key<ValueType>) {
        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            userDefaults.set(value, forKey: key._key)
            return
        }

        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(value)
            userDefaults.set(encoded, forKey: key._key)
            userDefaults.synchronize()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    public func get<ValueType: Codable>(for key: String) -> ValueType? {
        let key = Key<ValueType>(key)
        return get(for: key)
    }

    public func set<ValueType: Codable>(_ value: ValueType?, for key: String) {
        let key = Key<ValueType>(key)
        if let value = value {
            set(value, for: key)
        } else {
            clear(key)
        }
    }

    /// Removes given bundle's persistent domain
    ///
    /// - Parameter type: Bundle.
    public func removeAll(bundle: Bundle = Bundle.main) {
        guard let name = bundle.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)
    }

    /// Checks if the specified type is a Codable from the Swift standard library.
    ///
    /// - Parameter type: The type.
    /// - Returns: A boolean value.
    private func isSwiftCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type:
            return true
        default:
            return false
        }
    }

    /// Checks if the specified type is a Codable, from the Swift's core libraries
    /// Foundation framework.
    ///
    /// - Parameter type: The type.
    /// - Returns: A boolean value.
    private func isFoundationCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is Date.Type:
            return true
        default:
            return false
        }
    }
}

// MARK: ValueType with RawRepresentable conformance

public extension Defaults {
    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: The key.
    /// - Returns: A `ValueType` or nil if the key was not found.
    func get<ValueType: RawRepresentable>(for key: Key<ValueType>) -> ValueType? where ValueType.RawValue: Codable {
        let convertedKey = Key<ValueType.RawValue>(key._key)
        if let raw = get(for: convertedKey) {
            return ValueType(rawValue: raw)
        }
        return nil
    }

    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    func set<ValueType: RawRepresentable>(_ value: ValueType, for key: Key<ValueType>) where ValueType.RawValue: Codable {
        let convertedKey = Key<ValueType.RawValue>(key._key)
        set(value.rawValue, for: convertedKey)
    }
}
