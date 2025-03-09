//
//  Defaults.swift
//
//  Parts taken from:
//  Copyright (c) 2017 - 2018 Nuno Manuel Dias
//  Created by Florian Zand on 19.01.23.
//

import Foundation

/**
 Provides strongly typed values associated with the lifetime of an application. Apropriate for user preferences.

 Example usage:
 ```swift
 let isInitalAppStart = Defaults.shared["isInitalAppStart", initialValue: true]
 
 Defaults.shared["isInitalAppStart"] = false
 ```

 - Note: These should not be used to store sensitive information that could compromise the application or the user's security and privacy.
 */
public final class Defaults {
    let id = UUID()
    let userDefaults: UserDefaults
    var notificationKeys: [String: NotificationKey] = [:]

    /// Shared instance of `Defaults`, used for ad-hoc access to the user's defaults database throughout the app.
    public static let shared = Defaults()

    /**
     An instance of `Defaults` with the specified `UserDefaults` instance.

     - Parameter userDefaults: The `UserDefaults`.
     */
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    /// The value for the specified key.
    public subscript<T: Codable>(key: String) -> T? {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    /// The value for the specified key.
    public subscript<T: Codable>(key: String, initalValue initalValue: T) -> T {
        get { get(key, initalValue: initalValue) }
        set { set(newValue, for: key) }
    }

    /// The value for the specified key.
    public subscript<T: RawRepresentable>(key: String) -> T? where T.RawValue: Codable {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    /// The value for the specified key.
    public subscript<T: RawRepresentable>(key: String, initialValue initialValue: T) -> T where T.RawValue: Codable {
        get { get(key, initalValue: initialValue) }
        set { set(newValue, for: key) }
    }

    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    public func get<Value: Codable>(_ key: String) -> Value? {
        if isSwiftCodableType(Value.self) {
            return userDefaults.value(forKey: key) as? Value
        }

        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Value.self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
        return nil
    }
    
    /**
     The value for the specified key.

     - Parameters:
        - key: The key.
        - initialValue: The initial value for the key.
     */
    public func get<Value: Codable>(_ key: String, initalValue: Value) -> Value {
        if let value: Value = get(key) {
            return value
        }
        set(initalValue, for: key)
        return initalValue
    }

    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    public func get<Value: RawRepresentable>(_ key: String) -> Value? where Value.RawValue: Codable {
        if let raw: Value.RawValue = get(key) {
            return Value(rawValue: raw)
        }
        return nil
    }
    
    /**
     The value for the specified key.

     - Parameters:
        - key: The key.
        - initialValue: The initial value for the key.
     */
    public func get<Value: RawRepresentable>(_ key: String, initalValue: Value) -> Value where Value.RawValue: Codable {
        if let value: Value = get(key) {
            return value
        }
        set(initalValue, for: key)
        return initalValue
    }

    /**
     Sets a value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key.
     */
    public func set<Value: Codable>(_ value: Value?, for key: String) {
        if let value = value {
            let oldValue: Value? = get(key)
            if isSwiftCodableType(Value.self) {
                userDefaults.set(value, forKey: key)
                userDefaults.synchronize()
                postNotification(key, oldValue: oldValue, value: value)
                return
            }
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(value)
                userDefaults.set(encoded, forKey: key)
                userDefaults.synchronize()
                postNotification(key, oldValue: oldValue, value: value)
            } catch {
                #if DEBUG
                    print(error)
                #endif
            }
        } else {
            clear(key)
        }
    }

    /**
     Sets a value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key.
     */
    public func set<Value: RawRepresentable>(_ value: Value?, for key: String) where Value.RawValue: Codable {
        if let value = value {
            set(value.rawValue, for: key)
        } else {
            clear(key)
        }
    }

    /**
     Deletes the value associated with the specified key, if any.

     - Parameter key: The key.
     */
    public func clear(_ key: String) {
        let oldValue = userDefaults.value(forKey: key)
        userDefaults.set(nil, forKey: key)
        userDefaults.synchronize()
        postNotification(key, oldValue: oldValue, value: nil)
    }

    /**
     A Boolean value indicating whether a value exists for the specified key.

     - Parameter key: The key for the value.
     */
    public func has(_ key: String) -> Bool {
        userDefaults.value(forKey: key) != nil
    }

    /**
     Removes given bundle's persistent domain.

     - Parameter type: Bundle.
     */
    public func removeAll(bundle: Bundle = Bundle.main) {
        var oldValues: [String: Any] = [:]
        for key in userDefaults.dictionaryRepresentation().keys {
            oldValues[key] = userDefaults.value(forKey: key)
        }
        guard let name = bundle.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)
        for oldValue in oldValues {
            postNotification(oldValue.key, oldValue: oldValue.value, value: nil)
        }
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, object: notificationKey(for: key)) { notification in
            handler(notification.userInfo?["oldValue"] as? Value, notification.userInfo?["value"] as? Value)
        }
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value: Equatable {
        observeChanges(for: key, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value: Equatable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, object: notificationKey(for: key)) { notification in
            let oldValue = notification.userInfo?["oldValue"] as? Value
            let value = notification.userInfo?["value"] as? Value
            if !uniqueValues || (uniqueValues && oldValue != value) {
                handler(oldValue, value)
            }
        }
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false,  handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, object: notificationKey(for: key)) { notification in
            handler(notification.userInfo?["oldValue"] as? Value, notification.userInfo?["value"] as? Value)
        }
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable, Value: Equatable {
        observeChanges(for: key, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Observes changes for the value with specified key.
     
     Example usage:
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - key: The key of the property to observe.
        - type: The type of the observed value.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable, Value: Equatable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, object: notificationKey(for: key)) { notification in
            let oldValue = notification.userInfo?["oldValue"] as? Value
            let value = notification.userInfo?["value"] as? Value
            if !uniqueValues || (uniqueValues && oldValue != value) {
                handler(oldValue, value)
            }
        }
    }
        
    func postNotification(_ key: String, oldValue: Any?, value: Any?) {
        var userInfo: [AnyHashable : Any] = ["key":key]
        if let oldValue = oldValue {
            userInfo["oldValue"] = oldValue
        }
        if let value = value {
            userInfo["value"] = value
        }
        NotificationCenter.default.post(name: Self.valueUpdatedNotification, object: self, userInfo: userInfo)
        NotificationCenter.default.post(name: Self._valueUpdatedNotification, object: notificationKey(for: key), userInfo: userInfo)
    }
    
    func notificationKey(for key: String) -> NotificationKey {
        if let notificationKey =  notificationKeys[key] {
            return notificationKey
        }
        let notificationKey = NotificationKey(key, defaultsID: id)
        notificationKeys[key] = notificationKey
        return notificationKey
    }
    
    class NotificationKey {
        let value: String
        let defaultsID: UUID
        init(_ value: String, defaultsID: UUID) {
            self.value = value
            self.defaultsID = defaultsID
        }
    }

    func isSwiftCodableType<Value>(_ type: Value.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type, is URL.Type, is Date.Type:
            return true
        default:
            return false
        }
    }
    
    /**
     Posted whenever a value of `Defaults` updates.
     
     The notification object is the `Defaults` object whose value has changed. The `userInfo` dictionary contains the following information:
     - **key**: The key of the changed value.
     - **oldValue**: The previous value.
     - **value**: The new value.
     */
    public static let valueUpdatedNotification = Notification.Name("valueUpdatedNotification")
    
    static let _valueUpdatedNotification = Notification.Name("_valueUpdatedNotification")
}

fileprivate extension [AnyHashable : Any] {
    var oldValue: Any? { self["oldValue"] }
    var newValue: Any? { self["newValue"] }
    var key: String { self["key"] as! String }
}

extension Defaults {
    public class Key<Value>: _AnyKey {
        let defaultValueGetter: () -> Value

        public var defaultValue: Value { defaultValueGetter() }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard) where Value: OptionalProtocol, Value.Wrapped: Codable {
            defaultValueGetter = { nil }
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: RawRepresentable, Value.RawValue: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: RawRepresentable, Value.RawValue: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
        }
        
        public init(_ name: String, suite: UserDefaults = .standard) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = { nil }
            super.init(name: name, suite: suite)
        }
    }

    /// Type-erased key.
    public class _AnyKey: @unchecked Sendable {
        public typealias Key = Defaults.Key

        public let name: String
        public let suite: UserDefaults
        
        var defaults: Defaults {
            .init(userDefaults: suite)
        }

        fileprivate init(name: String, suite: UserDefaults) {
            assert(!(!name.starts(with: "@") && name.allSatisfy { $0 != "." && $0.isASCII }), "The key name must be ASCII, not start with @, and cannot contain a dot (.).")
            self.name = name
            self.suite = suite
        }

        /// Reset the item back to its default value.
        public func reset() {
            suite.removeObject(forKey: name)
        }
    }

    public typealias Keys = _AnyKey
}

extension Defaults.Key where Value: Codable {
    /// A Boolean value indicating whether the value is written.
    public var isWritten: Bool {
        defaults.get(name) as Value? != nil
    }
    
    public func observe(sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: true) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
}

extension Defaults.Key where Value: RawRepresentable, Value.RawValue: Codable {
    /// A Boolean value indicating whether the value is written.
    public var isWritten: Bool {
        defaults.get(name) as Value? != nil
    }
    
    public func observe(sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: true) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken {
        defaults.observeChanges(for: name, type: Value.self, sendInitalValue: sendInitalValue) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
}

extension Defaults.Key where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
    /// A Boolean value indicating whether the value is written.
    public var isWritten: Bool {
        defaults.get(name) as Value.Wrapped? != nil
    }
}


extension Defaults {
    /// The value for the specified key.
    public static subscript<T: Codable>(key: Key<T>) -> T {
        get { key.defaults.get(key.name, initalValue: key.defaultValue) }
        set { key.defaults.set(newValue, for: key.name) }
    }
    
    /// The value for the specified key.
    public static subscript<T: RawRepresentable>(key: Key<T>) -> T where T.RawValue: Codable {
        get { key.defaults.get(key.name, initalValue: key.defaultValue) }
        set { key.defaults.set(newValue, for: key.name) }
    }
    
    /// The value for the specified key.
    public static subscript<T: OptionalProtocol>(key: Key<T>) -> T.Wrapped? where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: Codable {
        get {
            guard let rawValue: T.Wrapped.RawValue = key.defaults.get(key.name, initalValue: key.defaultValue.optional?.rawValue) else { return nil }
            return T.Wrapped(rawValue: rawValue)
        }
        set { key.defaults.set(newValue.optional?.rawValue, for: key.name) }
    }
}
