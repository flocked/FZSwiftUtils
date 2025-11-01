//
//  KeyValueObserver.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

/// An object that observes multiple properties of a given object.
open class KeyValueObserver<Object>: NSObject where Object: NSObject {

    /**
     The observed object.
          
     Changing the object will automatically start observing the new object using the previously observed properties and handlers.
     
     Setting this value to `nil`, stops the observation of the object, while perserving the list of observed properties and handlers.
     */
    public weak var observedObject: Object? {
        willSet {
            guard newValue !== observedObject else { return }
            _isActive = isActive
            isActive = false
        }
        didSet {
            guard oldValue !== observedObject, observedObject != nil else { return }
            isActive = _isActive
        }
    }
    
    private var _isActive = false
    private var observations: [String: Observation] = [:]
    
    var isActive: Bool = true {
        didSet {
            guard oldValue != isActive, let observedObject = observedObject else { return }
            if isActive {
                observations.forEach({ observedObject.addObserver(self, forKeyPath: $0.key, options: $0.value.options, context: nil) })
            } else {
                observations.forEach({ observedObject.removeObserver(self, forKeyPath: $0.key) })
            }
        }
    }
    
    /**
     Creates a key-value observer with the specifed observed object.
     
      - Parameter observedObject: The object to register for KVO notifications.
     
      - Returns: The  key-value observer.
      */
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
    }
    
    // MARK: - Observation
        
    /**
     Adds an observer for the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: The handler to be called whenever the key path value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let keyPath = keyPath._kvcKeyPathString else { return false }
        add(keyPath, initial: sendInitalValue) { old, new, initial in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
        return true
    }
    
    /**
     Adds an observer for the property at the specified key path.
     
     The handler is called whenever the value of the property changes to a new value that isn't equal to it's previous. 
     
     If you want the handler to be called on all changes, use ``add(_:sendInitalValue:uniqueValues:handler:)`` and set `uniqueValues` to `false`.

     - Parameters:
        - keyPath: The key path to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - handler: The handler to be called.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        add(keyPath, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Adds an observer for the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only be called if the new value isn't equal to the previous value.
        - handler: The handler to be called whenever the key path value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let keyPath = keyPath._kvcKeyPathString else { return false }
        add(keyPath, type: Value.self, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues, handler: handler)
        return true
    }
    
    /**
     Observes changes for a property identified by the given key path.

     - Parameters:
        - keyPath: The key path to observe.
        - type: The value type of the key path.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed key path.
        - handler: A closure that will be called when the key path value changes. It takes the old value, and the new value as parameters.     
     */
    open func add<Value>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        add(keyPath, initial: sendInitalValue) { old, new, _ in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
    }
    
    /**
     Observes changes for a property identified by the given key path.

     - Parameters:
        - keyPath: The key path to observe.
        - type: The value type of the key path.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed key path.
        - handler: A closure that will be called when the key path value changes. It takes the old value, and the new value as parameters.
     */
    open func add<Value: Equatable>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        add(keyPath, type: type, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Observes changes for a property identified by the given key path.

     - Parameters:
        - keyPath: The key path to observe.
        - type: The value type of the key path.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the initial value of the observed key path.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the key path value changes. It takes the old value, and the new value as parameters.
     */
    open func add<Value: Equatable>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ oldValue: Value, _ newValue: Value) -> Void) {
        if !uniqueValues {
            add(keyPath, initial: sendInitalValue) { old, new, _ in
                guard let old = old as? Value, let new = new as? Value else { return }
                handler(old, new)
            }
        } else {
            add(keyPath, initial: sendInitalValue) { old, new, initial in
                guard let old = old as? Value, let new = new as? Value, old != new || initial else { return }
                handler(old, new)
            }
        }
    }
    
    /**
     Adds observers for the properties at the specified key paths which calls the specified handler whenever any of the key paths properties changes.

     - Parameters:
        - keyPaths: The key paths to the values to observe.
        - uniqueValues: A Boolean value indicating whether the handler should only be called if the new value for each key path isn't equal to the previous value.
        - handler: The handler to be called whenever any of key paths values changes.
     */
    open func add(_ keyPaths: [PartialKeyPath<Object>], uniqueValues: Bool = true, handler: @escaping ((_ keyPath: PartialKeyPath<Object>) -> Void)) {
        for keyPath in keyPaths {
            guard let name = keyPath._kvcKeyPathString else { continue }
            add(name, initial: false) { old, new, _  in
                if uniqueValues, let old = old as? any Equatable, let new = new as? any Equatable {
                    if !old.isEqual(new) {
                        handler(keyPath)
                    }
                } else {
                    handler(keyPath)
                }
            }
        }
    }
        
    /**
     Removes the observer for the property at the specified key path.

     - Parameter keyPath: The key path to remove.
     */
    open func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let keyPath = keyPath._kvcKeyPathString else { return }
        remove(keyPath)
    }
    
    /**
     Removes the observer for the specified key path.

     - Parameter keyPath: The key path to remove.
     */
    open func remove(_ keyPath: String) {
        guard var observation = observations[keyPath] else { return }
        observation.handler = nil
        addObservation(observation)
    }
    
    // MARK: - WillChange Observation
    
    /**
     Observes for changes to the specified property and calls the hand
     
     Adds a willChange observer for the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the value to observe.
        - handler: The handler to be called whenever the key path value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func addWillChange<Value>(_ keyPath: KeyPath<Object, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        addWillChange(name, type: Value.self, handler: handler)
        return true
    }
    
    /**
     Adds a willChange observer for the property at the specified key path.

     - Parameters:
        - keyPath: The key path to the value to observe.
        - type: The value type of the key path.
        - handler: The handler to be called whenever the key path value changes.
     */
    open func addWillChange<Value>(_ keyPath: String, type: Value.Type, handler: @escaping ((Value) -> Void)) {
        var observation = observations[keyPath] ?? Observation(keyPath)
        observation.willChange =  { value in
            guard let value = value as? Value else { return }
            handler(value)
        }
        addObservation(observation)
    }
    
    /**
     Removes the willChange observer for the property at the specified key path.

     - Parameter keyPath: The key path to remove.
     */
    open func removeWillChange(_ keyPath: PartialKeyPath<Object>) {
        guard let keyPath = keyPath._kvcKeyPathString else { return }
        removeWillChange(keyPath)
    }
    
    /**
     Removes the willChange observer for the specified key path.

     - Parameter keyPath: The key path to remove.
     */
    open func removeWillChange(_ keyPath: String) {
        guard var observation = observations[keyPath] else { return }
        observation.willChange = nil
        addObservation(observation)
    }
    
    /**
     Removes the observer for the properties at the specified key paths.

     - Parameter keyPaths: The key paths to remove.
     */
    open func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S) {
        keyPaths.forEach({ remove($0) })
    }
    
    /// Removes all observers.
    open func removeAll() {
        observations.keys.forEach { removeObservation(for: $0) }
    }
    
    /// A Boolean value indicating whether any value is observed.
    open var isObserving: Bool {
        observations.isEmpty != false
    }

    /**
     A Boolean value indicating whether the property at the specified key path is observed.

     - Parameter keyPath: The key path to the property.
     */
    open func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return isObserving(name)
    }

    /**
     A Boolean value indicating whether the value at the specified key path is observed.

     - Parameter keyPath: The key path to the property.
     */
    open func isObserving(_ keyPath: String) -> Bool {
        observations[keyPath] != nil
    }
    
    private func add(_ keyPath: String, initial: Bool, handler: @escaping (_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void) {
        var observation = observations[keyPath] ?? Observation(keyPath)
        observation.handler = handler
        observation.initial = initial
        addObservation(observation)
    }
    
    private func addObservation(_ observation: Observation) {
        removeObservation(for: observation.keyPath)
        guard observation.willChange != nil || observation.handler != nil else { return }
        observations[observation.keyPath] = observation
        if isActive {
            observedObject?.addObserver(self, forKeyPath: observation.keyPath, options: observation.options, context: nil)
        }
    }
    
    private func removeObservation(for keyPath: String) {
        guard observations[keyPath] != nil else { return }
        observedObject?.removeObserver(self, forKeyPath: keyPath)
        observations[keyPath] = nil
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard observedObject != nil, let keyPath = keyPath, let change = change, let observation = observations[keyPath] else { return }
        if change.isPrior, let oldValue = change.oldValue, let handler = observation.willChange {
            handler(oldValue)
        } else if let newValue = change.newValue, let handler = observation.handler {
            handler(change.oldValue ?? newValue, newValue, false)
        }
    }
    
    private struct Observation {
        let keyPath: String
        var handler: ((_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void)?
        var willChange: ((Any)->Void)?
        var initial = false
        
        var options: NSKeyValueObservingOptions {
            var options: NSKeyValueObservingOptions = [.old]
            options[.new] = handler != nil
            options[.initial] = handler != nil && initial
            options[.prior] = willChange != nil
            return options
        }
        
        init(_ keyPath: String) {
            self.keyPath = keyPath
        }
    }
    
    deinit {
        removeAll()
    }
}

extension [NSKeyValueChangeKey: Any] {
    var newValue: Any? { self[.newKey] }
    var oldValue: Any? { self[.oldKey] }
    var isPrior: Bool { self[.notificationIsPriorKey] as? Bool ?? false }
    var kind: NSKeyValueChange { .init(rawValue: self[.kindKey] as? UInt ?? 1) ?? .setting }
    var indexes: IndexSet? { self[.indexesKey] as? IndexSet }
}
