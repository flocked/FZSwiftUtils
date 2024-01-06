//
//  Defaults.swift
//
// Parts taken from:
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
    var userDefaults: UserDefaults
    lazy var observer = KeyValueObserver(self.userDefaults)

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
        get { return get(key) }
        set { set(newValue, for: key) }
    }
    
    public subscript(key: String) -> Any? {
        get { userDefaults.value(forKey: key) }
        set { 
            userDefaults.setValue(newValue, forKey: key)
            userDefaults.synchronize()
        }
    }
    
    public subscript<T: RawRepresentable>(key: String) -> T? where T.RawValue: Codable {
        get { return get(key) }
        set { set(newValue, for: key) }
    }

    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    func get<Value: Codable>(_ key: String) -> Value? {
        let key = Key<Value>(key)
        return get(key)
    }
    
    /**
     The value for the specified key, or `nil`if there isn't a value for the key.

     - Parameter key: The key.
     */
    func get<Value: RawRepresentable>(_ key: String) -> Value? where Value.RawValue: Codable {
        let convertedKey = Key<Value.RawValue>(key)
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
    func set<Value: Codable>(_ value: Value?, for key: String) {
        let key = Key<Value>(key)
        if let value = value {
            set(value, for: key)
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
    func set<Value: RawRepresentable>(_ value: Value?, for key: String) where Value.RawValue: Codable {
        if let value = value {
            let convertedKey = Key<Value.RawValue>(key)
            set(value.rawValue, for: convertedKey)
        } else {
            clear(key)
        }
    }
    
    /**
     Deletes the value associated with the specified key, if any.
     
     - Parameter key: The key.
     */
    func clear(_ key: String) {
        userDefaults.set(nil, forKey: key)
        userDefaults.synchronize()
    }
    
    /**
     A Boolean value indicating whether a value exists for the specified key.
     
     - Parameter key: The key for the value.
     */
    func has(_ key: String) -> Bool {
        return userDefaults.value(forKey: key) != nil
    }

    /**
     Removes given bundle's persistent domain.
     
     - Parameter type: Bundle.
     */
    public func removeAll(bundle: Bundle = Bundle.main) {
        guard let name = bundle.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)
    }
    
    /**
     Adds an observer for the value at the specified key which calls the handler.

     - Parameters:
        - key: The key to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the key value changes.
     */
    public func observeChanges<Value>(_ key: String, type: Value, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        self.observer.add(key, sendInitalValue: sendInitalValue) { old, new, _ in
            let old = old as! Value
            let new = new as! Value
            handler(old, new)
        }
    }
    
    /**
     Adds an observer for the value at the specified key which calls the handler.

     - Parameters:
        - key: The key to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the key value changes.
     */
    public func observeChanges<Value: Equatable>(_ key: String, type: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        self.observer.add(key, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues) { old, new, inital in
            let old = old as! Value
            let new = new as! Value
            if uniqueValues {
                if (old != new) || inital {
                    handler(old, new)
                }
            } else {
                handler(old, new)
            }
        }
        self[""] = "fdf"
        self.observeChanges("", type: String.self, handler: { old, new in })
    }
    
    /**
     Stops observation for the specified key.
     
     - Parameter key: The key to stop observing.
     */
    public func stopObserving(_ key: String) {
        self.observer.remove(key)
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
        get { return get(key) }
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
        if isSwiftCodableType(Value.self) || isFoundationCodableType(Value.self) {
            userDefaults.set(value, forKey: key._key)
            userDefaults.synchronize()
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
        self.clear(key._key)
    }
    
    /**
     A Boolean value indicating whether a value exists for the specified key.
     
     - Parameter key: The key for the value.
     */
    func has<Value>(_ key: Key<Value>) -> Bool {
        return userDefaults.value(forKey: key._key) != nil
    }
    
    /**
     Adds an observer for the value at the specified key which calls the handler.

     - Parameters:
        - key: The key to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the key value changes.
     */
    func observeChanges<Value>(for key: Key<Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        self.observer.add(key._key, sendInitalValue: sendInitalValue) { old, new, _ in
            let old = old as! Value
            let new = new as! Value
            handler(old, new)
        }
    }
    
    /**
     Adds an observer for the value at the specified key which calls the handler.
     
     - Parameters:
        - key: The key to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the key value changes.
     */
    func observeChanges<Value: Equatable>(for key: Key<Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        self.observer.add(key._key, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues) { old, new, inital in
            let old = old as! Value
            let new = new as! Value
            if uniqueValues {
                if (old != new) || inital {
                    handler(old, new)
                }
            } else {
                handler(old, new)
            }
        }
    }
    
    /**
     Stops observation for the specified key.
     
     - Parameter key: The key to stop observing.
     */
    func stopObserving<Value>(_ key: Key<Value>) {
        self.observer.remove(key._key)
    }
}
