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
 Defaults.shared["isInitalStart"] = false

 if let isInitalStart: Bool = Defaults.shared["isInitalStart"] {

 }
 ```

 - Note: These should not be used to store sensitive information that could compromise the application or the user's security and privacy.
 */
public final class Defaults {
    let id = UUID()
    var userDefaults: UserDefaults
    var notificationKeys: [String: NotificationKey] = [:]

    /// Shared instance of `Defaults`, used for ad-hoc access to the user's defaults database throughout the app.
    public static let shared = Defaults()

    /**
     An instance of `Defaults` with the specified `UserDefaults` instance.

     - Parameter userDefaults: The UserDefaults.
     */
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public subscript<T: Codable>(key: String) -> T? {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    public subscript<T: Codable>(key: String, initalValue initalValue: T) -> T {
        get { get(key, initalValue: initalValue) }
        set { set(newValue, for: key) }
    }

    public subscript<T: RawRepresentable>(key: String) -> T? where T.RawValue: Codable {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    public subscript<T: RawRepresentable>(key: String, initialValue initialValue: T) -> T where T.RawValue: Codable {
        get { get(key, initalValue: initialValue) }
        set { set(newValue, for: key) }
    }
    
    public subscript(key: String) -> Any? {
        get { userDefaults.value(forKey: key) }
        set {
            if case Optional<Any>.none = newValue {
                userDefaults.setValue(newValue, forKey: key)
                userDefaults.synchronize()
            }
        }
    }

    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    public func get<Value: Codable>(_ key: String) -> Value? {
        let key = Key<Value>(key)
        return get(key)
    }
    
    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    public func get<Value: Codable>(_ key: String, initalValue: Value) -> Value {
        let key = Key<Value>(key)
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
        if let raw = get(Key<Value.RawValue>(key)) {
            return Value(rawValue: raw)
        }
        return nil
    }
    
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
            set(value, for: Key<Value>(key))
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
            set(value.rawValue, for: Key<Value.RawValue>(key))
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
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `DefaultsKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> DefaultsKeyValueObservation {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return DefaultsKeyValueObservation(notificationKey(for: key), handler: handler)
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
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `DefaultsKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value: Codable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> DefaultsKeyValueObservation where Value: Equatable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return DefaultsKeyValueObservation(notificationKey(for: key), unique: uniqueValues, handler: handler)
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
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `DefaultsKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false,  handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> DefaultsKeyValueObservation where Value.RawValue: Codable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return DefaultsKeyValueObservation(notificationKey(for: key), handler: handler)
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
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `DefaultsKeyValueObservation` object representing the observation.
     */

    public func observeChanges<Value: RawRepresentable>(for key: String, type _: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value?, _ newValue: Value?) -> Void)) -> DefaultsKeyValueObservation where Value.RawValue: Codable, Value: Equatable {
        if sendInitalValue {
            if let value: Value = get(key) {
                handler(value, value)
            } else {
                handler(nil, nil)
            }
        }
        return DefaultsKeyValueObservation(notificationKey(for: key), unique: uniqueValues, handler: handler)
    }
    
    class NotificationKey {
        let key: String
        let defaultsID: UUID
        init(_ key: String, defaultsID: UUID) {
            self.key = key
            self.defaultsID = defaultsID
        }
    }
        
    func postNotification(_ key: String, oldValue: Any?, value: Any?) {
        var userInfo: [AnyHashable : Any] = [:]
        if let oldValue = oldValue {
            userInfo["oldValue"] = oldValue
        }
        if let value = value {
            userInfo["value"] = value
        }
        NotificationCenter.default.post(name: .defaultsValueChanged, object: notificationKey(for: key), userInfo: userInfo)
    }
    
    func notificationKey(for key: String) -> NotificationKey {
        if let notificationKey =  notificationKeys[key] {
            return notificationKey
        }
        let notificationKey = NotificationKey(key, defaultsID: id)
        notificationKeys[key] = notificationKey
        return notificationKey
    }

    func isSwiftCodableType<Value>(_ type: Value.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type:
            return true
        default:
            return false
        }
    }

    func isFoundationCodableType<Value>(_ type: Value.Type) -> Bool {
        switch type {
        case is Date.Type:
            return true
        default:
            return false
        }
    }
}

// MARK: Defaults + Key

extension Defaults {
    /**
     Represents a `Key` with an associated generic value type conforming to the `Codable` protocol.

     Example:
     ```swift
     static let someKey = Key<Bool>("isInitalStart")
     ```
     */
    class Key<Value: Codable> {
        let _key: String
        public init(_ key: String) {
            _key = key
        }
    }

    subscript<T: Codable>(key: Key<T>) -> T? {
        get { get(key) }
        set { set(newValue, for: key) }
    }

    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    func get<Value>(_ key: Key<Value>) -> Value? {
        if isSwiftCodableType(Value.self) || isFoundationCodableType(Value.self) {
            return userDefaults.value(forKey: key._key) as? Value
        }

        guard let data = userDefaults.data(forKey: key._key) else {
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
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    func get<Value: RawRepresentable>(for key: Key<Value>) -> Value? where Value.RawValue: Codable {
        let convertedKey = Key<Value.RawValue>(key._key)
        if let raw = get(convertedKey) {
            return Value(rawValue: raw)
        }
        return nil
    }

    /**
     Sets a value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key.
     */
    func set<Value>(_ value: Value?, for key: Key<Value>) {
        let oldValue: Value? = get(key)
        if isSwiftCodableType(Value.self) || isFoundationCodableType(Value.self) {
            userDefaults.set(value, forKey: key._key)
            userDefaults.synchronize()
            postNotification(key._key, oldValue: oldValue, value: value)
            return
        }

        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(value)
            userDefaults.set(encoded, forKey: key._key)
            userDefaults.synchronize()
            postNotification(key._key, oldValue: oldValue, value: value)
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
    }

    /**
     Sets a value for the specified key.

     - Parameters:
        - value: The value to set.
        - key: The key.
     */
    func set<Value: RawRepresentable>(_ value: Value, for key: Key<Value>) where Value.RawValue: Codable {
        let convertedKey = Key<Value.RawValue>(key._key)
        set(value.rawValue, for: convertedKey)
    }

    /**
     Deletes the value associated with the specified key, if any.

     - Parameter key: The key.
     */
    func clear<Value>(_ key: Key<Value>) {
        clear(key._key)
    }

    /**
     A Boolean value indicating whether a value exists for the specified key.

     - Parameter key: The key for the value.
     */
    func has<Value>(_ key: Key<Value>) -> Bool {
        userDefaults.value(forKey: key._key) != nil
    }
}

extension Notification.Name {
    static let defaultsValueChanged = Notification.Name("defaultsValueChanged")
}

extension Defaults {
    /**
     An object that observes a `Defaults` value.
     
     To observe the value of a property use ``Defaults/observeChanges(for:type:sendInitalValue:handler:)-3q8ou``
     
     ```swift
     Defaults.shared.observeChanges(for: "DownloadFolder", type: URL.self) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     To stop the observation of the property, either call ``invalidate()```, or deinitalize the object.
     */
    public class DefaultsKeyValueObservation {
        
        /// The key of the observed property.
        public let key: String
        
        /// Invalidates the observation.
        public func invalidate() {
            token = nil
        }
        
        var token: NotificationToken?
        
        init<Value: RawRepresentable>(_ key: NotificationKey, handler: @escaping (Value?, Value?) -> Void) where Value.RawValue: Codable {
            self.key = key.key
            self.token = NotificationCenter.default.observe(.defaultsValueChanged, object: key) { notification in
                handler(notification.userInfo?["oldValue"] as? Value, notification.userInfo?["Value"] as? Value)
            }
        }
        
        init<Value: RawRepresentable>(_ key: NotificationKey, unique: Bool, handler: @escaping (Value?, Value?) -> Void) where Value.RawValue: Codable, Value: Equatable {
            self.key = key.key
            self.token = NotificationCenter.default.observe(.defaultsValueChanged, object: key) { notification in
                let oldValue = notification.userInfo?["oldValue"] as? Value
                let value = notification.userInfo?["Value"] as? Value
                if !unique || (unique && oldValue != value) {
                    handler(oldValue, value)
                }
            }
        }
        
        init<Value: Codable>(_ key: NotificationKey, handler: @escaping (Value?, Value?) -> Void) {
            self.key = key.key
            self.token = NotificationCenter.default.observe(.defaultsValueChanged, object: key) { notification in
                handler(notification.userInfo?["oldValue"] as? Value, notification.userInfo?["Value"] as? Value)
            }
        }
        
        init<Value: Codable>(_ key: NotificationKey, unique: Bool, handler: @escaping (Value?, Value?) -> Void) where Value: Equatable {
            self.key = key.key
            self.token = NotificationCenter.default.observe(.defaultsValueChanged, object: key) { notification in
                let oldValue = notification.userInfo?["oldValue"] as? Value
                let value = notification.userInfo?["Value"] as? Value
                if !unique || (unique && oldValue != value) {
                    handler(oldValue, value)
                }
            }
        }
    }
}
