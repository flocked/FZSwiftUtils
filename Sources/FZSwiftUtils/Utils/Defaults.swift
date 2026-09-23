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
    private let notificationKeysLock = NSLock()

    /// The shared defaults instance backed by the standard user defaults.
    public static let shared = Defaults(userDefaults: .standard)

    /// Creates a defaults instance backed by the specified user defaults.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Removes all values from the specified bundle's persistent domain.
    public func removeAll(for bundle: Bundle = .main) {
        guard let bundleIdentifier = bundle.bundleIdentifier else { return }
        removeAll(forDomain: bundleIdentifier)
    }
    /// Removes all values from the specified persistent domain.
    public func removeAll(forDomain domainName: String) {
        let oldValues = userDefaults.persistentDomain(forName: domainName) ?? [:]
        userDefaults.removePersistentDomain(forName: domainName)
        for (key, value) in oldValues {
            postNotification(key, oldValue: value, value: nil)
        }
    }

    /// The value for the specified key.
    public subscript<T: Codable>(key: String) -> T? {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    /// The value for the specified key.
    public subscript<T: Codable>(key: String, initialValue initialValue: T) -> T {
        get { get(key, initialValue: initialValue) }
        set { set(newValue, for: key) }
    }

    /// The value for the specified key.
    public subscript<T: RawRepresentable>(key: String) -> T? where T.RawValue: Codable {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    /// The value for the specified key.
    public subscript<T: RawRepresentable>(key: String, initialValue initialValue: T) -> T where T.RawValue: Codable {
        get { get(key, initialValue: initialValue) }
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
    public func get<Value: Codable>(_ key: String, initialValue: Value) -> Value {
        if let value: Value = get(key) {
            return value
        }
        set(initialValue, for: key)
        return initialValue
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
    public func get<Value: RawRepresentable>(_ key: String, initialValue: Value) -> Value where Value.RawValue: Codable {
        if let value: Value = get(key) {
            return value
        }
        set(initialValue, for: key)
        return initialValue
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
            write(value, for: key, oldValue: oldValue, notificationValue: value)
        } else {
            clear(key, oldValue: get(key) as Value?)
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
            let oldValue: Value? = get(key)
            write(value.rawValue, for: key, oldValue: oldValue, notificationValue: value)
        } else {
            clear(key, oldValue: get(key) as Value?)
        }
    }

    private func write<StoredValue: Codable>(_ value: StoredValue, for key: String, oldValue: Any?, notificationValue: Any) {
        if isSwiftCodableType(StoredValue.self) {
            userDefaults.set(value, forKey: key)
            postNotification(key, oldValue: oldValue, value: notificationValue)
            return
        }
        do {
            let encoded = try JSONEncoder().encode(value)
            userDefaults.set(encoded, forKey: key)
            postNotification(key, oldValue: oldValue, value: notificationValue)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    /**
     Deletes the value associated with the specified key, if any.

     - Parameter key: The key.
     */
    public func clear(_ key: String) {
        clear(key, oldValue: userDefaults.value(forKey: key))
    }

    private func clear(_ key: String, oldValue: Any?) {
        userDefaults.set(nil, forKey: key)
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken {
        if sendInitialValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, postedBy: notificationKey(for: key)) { notification in
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value: Equatable {
        observeChanges(for: key, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: true, handler: handler)
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value: Equatable {
        if sendInitialValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, postedBy: notificationKey(for: key)) { notification in
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false,  handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable {
        if sendInitialValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, postedBy: notificationKey(for: key)) { notification in
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable, Value: Equatable {
        observeChanges(for: key, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: true, handler: handler)
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
        - sendInitialValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A notification token representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitialValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> NotificationToken where Value.RawValue: Codable, Value: Equatable {
        if sendInitialValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return NotificationCenter.default.observe(Defaults._valueUpdatedNotification, postedBy: notificationKey(for: key)) { notification in
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
        notificationKeysLock.lock()
        defer { notificationKeysLock.unlock() }
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

        private func configureCodableReset() where Value: Codable {
            resetAction = { [weak self] in
                guard let self else { return }
                let oldValue: Value? = self.defaults.get(self.name)
                self.defaults.clear(self.name, oldValue: oldValue)
            }
        }

        private func configureRawReset() where Value: RawRepresentable, Value.RawValue: Codable {
            resetAction = { [weak self] in
                guard let self else { return }
                let oldValue: Value? = self.defaults.get(self.name)
                self.defaults.clear(self.name, oldValue: oldValue)
            }
        }

        private func configureOptionalReset() {
            resetAction = { [weak self] in
                guard let self else { return }
                let oldValue = self.defaults.userDefaults.value(forKey: self.name)
                self.defaults.clear(self.name, oldValue: oldValue)
            }
        }

        public var defaultValue: Value { defaultValueGetter() }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
            configureCodableReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
            configureCodableReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard) where Value: OptionalProtocol, Value.Wrapped: Codable {
            defaultValueGetter = { nil }
            super.init(name: name, suite: suite)
            configureOptionalReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: RawRepresentable, Value.RawValue: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
            configureRawReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: Value) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = { defaultValue }
            super.init(name: name, suite: suite)
            configureOptionalReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: RawRepresentable, Value.RawValue: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
            configureRawReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard, default defaultValue: @escaping () -> Value) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = defaultValue
            super.init(name: name, suite: suite)
            configureOptionalReset()
        }
        
        public init(_ name: String, suite: UserDefaults = .standard) where Value: OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: Codable {
            defaultValueGetter = { nil }
            super.init(name: name, suite: suite)
            configureOptionalReset()
        }
    }

    /// Type-erased key.
    public class _AnyKey {
        public typealias Key = Defaults.Key

        public let name: String
        public let suite: UserDefaults
        let defaults: Defaults
        var resetAction: (() -> Void)?

        fileprivate init(name: String, suite: UserDefaults) {
            assert(name.starts(with: "@") || name.allSatisfy { $0 != "." && $0.isASCII }, "The key name must be ASCII, not start with @, and cannot contain a dot (.).")
            self.name = name
            self.suite = suite
            self.defaults = Defaults(userDefaults: suite)
        }

        /// Reset the item back to its default value.
        public func reset() {
            if let resetAction {
                resetAction()
            } else {
                defaults.clear(name)
            }
        }
    }

    public typealias Keys = _AnyKey
}

extension Defaults.Key where Value: Codable {
    /// A Boolean value indicating whether the value is written.
    public var isWritten: Bool {
        defaults.get(name) as Value? != nil
    }
    
    public func observe(sendInitialValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: true) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitialValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: uniqueValues) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitialValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue) { oldValue, newValue in
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
    
    public func observe(sendInitialValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: true) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitialValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken where Value: Equatable {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue, uniqueValues: uniqueValues) { oldValue, newValue in
            guard let oldValue = oldValue, let newValue = newValue else { return }
            handler(oldValue, newValue)
        }
    }
    
    public func observe(sendInitialValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) -> NotificationToken {
        defaults.observeChanges(for: name, type: Value.self, sendInitialValue: sendInitialValue) { oldValue, newValue in
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
        get { key.defaults.get(key.name, initialValue: key.defaultValue) }
        set { key.defaults.set(newValue, for: key.name) }
    }
    
    /// The value for the specified key.
    public static subscript<T: RawRepresentable>(key: Key<T>) -> T where T.RawValue: Codable {
        get { key.defaults.get(key.name, initialValue: key.defaultValue) }
        set { key.defaults.set(newValue, for: key.name) }
    }
    
    /// The value for the specified key.
    public static subscript<T: OptionalProtocol>(key: Key<T>) -> T.Wrapped? where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: Codable {
        get {
            guard let rawValue: T.Wrapped.RawValue = key.defaults.get(key.name, initialValue: key.defaultValue.optional?.rawValue) else { return nil }
            return T.Wrapped(rawValue: rawValue)
        }
        set { key.defaults.set(newValue.optional?.rawValue, for: key.name) }
    }
}
