//
//  SharedKeyValueObserver.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

/// An object that key value (`KVO`) observes multiple properties of a collection of objects.
open class SharedKeyValueObserver<Object>: NSObject where Object: NSObject {

    private let lock = NSRecursiveLock()
    private var weakObservedObjects: [Weak<Object>] = []
    private var _isActive = true
    private var observations: [String: Observation] = [:]
    private var context = 0
    
    /**
     The observed objects.
               
     Adding objects to the array starts observing them if ``isActive`` is `true`.
     
     Removing objects from the array, stops observing them.
     */
    public var observedObjects: [Object] {
        get { lock.locked { weakObservedObjects.compactMap({$0.object })  } }
        set {
            lock.locked {
                guard newValue.uniqued() != observedObjects else { return }
                _isActive = isActive
                deactivate()
                weakObservedObjects = newValue.map({ Weak($0) })
                isActive = _isActive
            }
        }
    }
    
    /// A Boolean value indicating if the observation of the objects is active.
    public var isActive: Bool {
        get { lock.locked { _isActive } }
        set {
            lock.locked {
                guard _isActive != newValue else { return }
                _isActive = newValue
                if newValue { activate() } else { deactivate() }
            }
        }
    }
    
    
    /**
     Creates a key-value observer for the specifed class.
     
      - Parameter observableClass: The class of the objects to observe.
      */
    public init(for observableClass: Object.Type) {
        super.init()
    }
    
    /**
     Creates a key-value observer that observes the specified object.
     
      - Parameter object: The object to observe.
      */
    public init(for object: [Object]) {
        super.init()
        defer { observedObjects = object }
    }
    
    /**
     Creates a key-value observer that observes the specified objects.
     
      - Parameter object: The objects to observe.
      */
    public init(for objectToObserve: Object) {
        super.init()
        defer { observedObjects = [objectToObserve] }
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
    open func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let keyPath = keyPath._kvcKeyPathString else { return false }
        add(keyPath, initial: sendInitalValue) { object, old, new, initial in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(object, old, new)
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
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
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
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
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
    open func add<Value>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping (_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void) {
        add(keyPath, initial: sendInitalValue) { object, old, new, _ in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(object, old, new)
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
    open func add<Value: Equatable>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping (_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void) {
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
    open func add<Value: Equatable>(_ keyPath: String, type: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping (_ object: Object, _ oldValue: Value, _ newValue: Value) -> Void) {
        if !uniqueValues {
            add(keyPath, initial: sendInitalValue) { object, old, new, _ in
                guard let old = old as? Value, let new = new as? Value else { return }
                handler(object, old, new)
            }
        } else {
            add(keyPath, initial: sendInitalValue) { object, old, new, initial in
                guard let old = old as? Value, let new = new as? Value, old != new || initial else { return }
                handler(object, old, new)
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
    open func add(_ keyPaths: [PartialKeyPath<Object>], uniqueValues: Bool = true, handler: @escaping ((_ object: Object, _ keyPath: PartialKeyPath<Object>) -> Void)) {
        for keyPath in keyPaths {
            guard let name = keyPath._kvcKeyPathString else { continue }
            add(name, initial: false) { object, old, new, _  in
                if uniqueValues, let old = old as? any Equatable, let new = new as? any Equatable {
                    if !old.isEqual(new) {
                        handler(object, keyPath)
                    }
                } else {
                    handler(object, keyPath)
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
        lock.locked {
            guard var observation = observations[keyPath] else { return }
            observation.handler = nil
            addObservation(observation)
        }
        
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
    open func addWillChange<Value>(_ keyPath: KeyPath<Object, Value>, handler: @escaping ((_ object: Object, _ oldValue: Value) -> Void)) -> Bool {
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
    open func addWillChange<Value>(_ keyPath: String, type: Value.Type, handler: @escaping ((_ object: Object, _ value: Value) -> Void)) {
        lock.locked {
            var observation = observations[keyPath] ?? Observation(keyPath)
            observation.willChange =  { object, value in
                guard let value = value as? Value else { return }
                handler(object, value)
            }
            addObservation(observation)
        }
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
        lock.locked {
            guard var observation = observations[keyPath] else { return }
            observation.willChange = nil
            addObservation(observation)
        }
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
        lock.locked {
            observations.keys.forEach { removeObservation(for: $0) }
        }
    }
    
    /// A Boolean value indicating whether any value is observed.
    open var isObserving: Bool {
        lock.locked {
            observations.isEmpty != false
        }
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
        lock.locked {
            observations[keyPath] != nil
        }
    }
    
    private func add(_ keyPath: String, initial: Bool, handler: @escaping (_ object: Object, _ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void) {
        lock.locked {
            var observation = observations[keyPath] ?? Observation(keyPath)
            observation.handler = handler
            observation.initial = initial
            addObservation(observation)
        }
    }
    
    private func addObservation(_ observation: Observation) {
        lock.locked {
            removeObservation(for: observation.keyPath)
            guard observation.willChange != nil || observation.handler != nil else { return }
            observations[observation.keyPath] = observation
            if isActive {
                for object in observedObjects {
                    object.addObserver(self, forKeyPath: observation.keyPath, options: observation.options, context: &context)
                }
            }
        }
    }
    
    private func removeObservation(for keyPath: String) {
        lock.locked {
            guard observations[keyPath] != nil else { return }
            for object in observedObjects {
                object.removeObserver(self, forKeyPath: keyPath, context: &context)
            }
            observations[keyPath] = nil
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &self.context, let object = object as? Object, let keyPath = keyPath, let change = change, let observation = observations[keyPath] else { return }
        if change.isPrior, let oldValue = change.oldValue, let handler = observation.willChange {
            handler(object, oldValue)
        } else if let newValue = change.newValue, let handler = observation.handler {
            handler(object, change.oldValue ?? newValue, newValue, false)
        }
    }
    
    private struct Observation {
        let keyPath: String
        var handler: ((_ object: Object, _ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void)?
        var willChange: ((_ object: Object, Any)->Void)?
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
    
    private func activate() {
        for key in observations.keys {
            activateObservation(key: key)
        }
    }
       
    private func deactivate() {
        for key in observations.keys {
            deactivateObservation(key: key)
        }
    }
    
    private func activateObservation(key: String) {
        guard let obs = observations[key] else { return }
        for object in observedObjects {
            object.addObserver(self, forKeyPath: key, options: obs.options, context: &context)
            if obs.options.contains(.initial), let handler = obs.handler, let value = object.value(forKeyPath: key) {
                handler(object, value, value, true)
            }
        }
    }
     
    private func deactivateObservation(key: String) {
        guard observations[key] != nil else { return }
        for object in observedObjects {
            object.removeObserver(self, forKeyPath: key, context: &context)
        }
    }
    
    deinit {
        deactivate()
    }
}
