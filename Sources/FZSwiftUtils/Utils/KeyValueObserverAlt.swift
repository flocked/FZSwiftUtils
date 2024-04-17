//
//  KeyValueObserverAlt.swift
//  
//
//  Created by Florian Zand on 17.04.24.
//

import Foundation

open class KeyValueObserverAlt<Object>: NSObject where Object: NSObject {
    
    /// The object to register for KVO notifications.
    public fileprivate(set) weak var observedObject: Object?
    
    private var observations: [String: Observation] = [:]
    private var actionvationTokens: [NotificationToken] = []
    private var isActive: Bool = true
    
    /**
     Creates a key-value observer with the specifed observed object.
     
      - Parameter observedObject: The object to register for KVO notifications.
      - Returns: The  key-value observer.
      */
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
        setupActionNotificationObservation()
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only be called if the new value isn't equal to the previous value.
        - handler: The handler to be called whenever the keypath value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        if uniqueValues {
            return add(keyPath, sendInitalValue: sendInitalValue, handler: handler)
        } else {
            guard let keyPath = keyPath._kvcKeyPathString else { return false }
            add(keyPath, initial: sendInitalValue) { old, new, _ in
                guard let old = old as? Value, let new = new as? Value else { return }
                handler(old, new)
            }
            return true
        }
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes to a new value that isn't equal to the previous value. If you want to the handler to get called on all changes, use ``add(_:sendInitalValue:uniqueValues:handler:)`` and set `uniqueValues` to `false`.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        add(name, initial: sendInitalValue, unique: true) { old, new, inital in
            guard let old = old as? Value, let new = new as? Value, (inital || old != new) else { return }
            handler(old, new)
        }
        return true
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> Bool {
        guard let keyPath = keyPath._kvcKeyPathString else { return false }
        add(keyPath, initial: sendInitalValue, unique: false) { old, new, inital in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
        return true
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes.
     */
    open func add(_ keyPath: String, sendInitalValue: Bool = false, handler: @escaping (_ oldValue: Any, _ newValue: Any) -> Void) {
        add(keyPath, initial: sendInitalValue) { old, new, _ in
            handler(old, new)
        }
    }
    
    /**
     Adds observers for the properties at the specified keypaths which calls the specified handler whenever any of the keypaths properties changes.

     - Parameters:
        - keyPaths: The keypaths to the values to observe.
        - handler: The handler to be called whenever any of keypaths values changes.
     */
    open func add(_ keyPaths: [PartialKeyPath<Object>], handler: @escaping ((_ keyPath: PartialKeyPath<Object>) -> Void)) {
        for keyPath in keyPaths {
            if let name = keyPath._kvcKeyPathString {
                add(name, initial: false) { old, new, _  in
                    if let old = old as? any Equatable, let new = new as? any Equatable {
                        if old.isEqual(new) == false {
                            handler(keyPath)
                        }
                    } else {
                        handler(keyPath)
                    }
                }
            }
        }
    }
    
    /**
     Adds a willChange observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - handler: The handler to be called whenever the keypath value changes.
     - Returns: `true` when the property is observed, or `false` if the property couldn't be observed.
     */
    @discardableResult
    open func addWillChange<Value>(_ keyPath: KeyPath<Object, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        addWillChange(name) { old in
            guard let old = old as? Value else { return }
            handler(old)
        }
        return true
    }
    
    /**
     Adds a willChange observer for the property at the specified keypath which calls the specified handler.

     - Parameters:
        - keyPath: The keypath to the value to observe.
        - handler: The handler to be called whenever the keypath value changes.
     */
    open func addWillChange(_ keyPath: String, handler: @escaping ((Any) -> Void)) {
        var observation = observations[keyPath] ?? Observation(keyPath)
        removeObservation(for: keyPath)
        observation.willChange = handler
        addObservation(observation)
    }
    
    /**
     Removes the observer for the property at the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let keyPath = keyPath._kvcKeyPathString else { return }
        remove(keyPath)
    }
    
    /**
     Removes the observer for the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func remove(_ keyPath: String) {
        guard var observation = observations[keyPath] else { return }
        removeObservation(for: keyPath)
        observation.handler = nil
        addObservation(observation)
    }
    
    /**
     Removes the willChange observer for the property at the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func removeWillChange(_ keyPath: PartialKeyPath<Object>) {
        guard let keyPath = keyPath._kvcKeyPathString else { return }
        removeWillChange(keyPath)
    }
    
    /**
     Removes the willChange observer for the specified keypath.

     - Parameter keyPath: The keypath to remove.
     */
    open func removeWillChange(_ keyPath: String) {
        guard var observation = observations[keyPath] else { return }
        removeObservation(for: keyPath)
        observation.willChange = nil
        addObservation(observation)
    }
        
    /**
     Removes the observed object and stops observing it, while keeping the list of observed properties and handlers for a new object.
     
     When you add a new object to observe via ``replaceObservedObject(_:)``, all previous observed properties and handlers are used.
     
     */
    public func removeObservedObject() {
        guard let observedObject = observedObject else { return }
        for observation in observations {
            observedObject.removeObserver(self, forKeyPath: observation.key)
        }
        self.observedObject = nil
    }
    
    /**
     Replaces the observed object.
     
     All previous observed properties and handlers are used.
    */
    public func replaceObservedObject(with object: Object) {
        removeObservedObject()
        self.observedObject = object
        for observation in observations {
            object.addObserver(self, forKeyPath: observation.key, options: observation.value._options, context: nil)
        }
    }
    
    /**
     Removes the observer for the properties at the specified keypaths.

     - Parameter keyPaths: The keypaths to remove.
     */
    open func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S) {
        keyPaths.compactMap(\._kvcKeyPathString).forEach { removeObservation(for: $0) }
    }
    
    /// Removes all observers.
    open func removeAll() {
        observations.keys.forEach { removeObservation(for: $0) }
    }
    
    /// A Boolean value indicating whether any value is observed.
    open func isObserving() -> Bool {
        observations.isEmpty != false
    }

    /**
     A Boolean value indicating whether the property at the specified keypath is observed.

     - Parameter keyPath: The keypath to the property.
     */
    open func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return isObserving(name)
    }

    /**
     A Boolean value indicating whether the value at the specified keypath is observed.

     - Parameter keyPath: The keypath to the property.
     */
    open func isObserving(_ keyPath: String) -> Bool {
        observations[keyPath] != nil
    }
    
    private func add(_ keyPath: String, initial: Bool, unique: Bool = false, handler: @escaping (_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void) {
        var observation = observations[keyPath] ?? Observation(keyPath)
        removeObservation(for: keyPath)
        observation.handler = handler
        observation.options = initial ? [.old, .new, .initial] : [.old, .new]
        observation.unique = unique
        addObservation(observation)
    }
    
    private func addObservation(_ observation: Observation) {
        guard observation.willChange != nil || observation.handler != nil else { return }
        observedObject?.addObserver(self, forKeyPath: observation.keyPath, options: observation._options, context: nil)
        observations[observation.keyPath] = observation
    }
    
    private func removeObservation(for keyPath: String) {
        guard observations[keyPath] != nil else { return }
        observedObject?.removeObserver(self, forKeyPath: keyPath)
        observations[keyPath] = nil
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard observedObject != nil, let keyPath = keyPath, let change = change, let observation = observations[keyPath] else { return }
        if change[.notificationIsPriorKey] as? Bool != nil {
            if let oldValue = change[NSKeyValueChangeKey.oldKey], let willChange = observation.willChange {
                willChange(oldValue)
            }
        } else if let newValue = change[NSKeyValueChangeKey.newKey], let handler = observation.handler {
            if let oldValue = change[NSKeyValueChangeKey.oldKey] {
                handler(oldValue, newValue, false)
            } else {
                handler(newValue, newValue, true)
            }
        }
    }
    
    private func setupActionNotificationObservation() {
        actionvationTokens.append(NotificationCenter.default.observe(Self.activateObservation, object: observedObject, using: { [weak self] notification in
            guard let self = self else { return }
            self.activate()
        }))
        actionvationTokens.append(NotificationCenter.default.observe(Self.deactivateObservation, object: observedObject, using: { [weak self] notification in
            guard let self = self else { return }
            self.deactivate()
        }))
    }
    
    private func activate() {
        guard let observedObject = observedObject, !isActive else { return }
        isActive = true
        observations.forEach({ observedObject.addObserver(self, forKeyPath: $0.key, options: $0.value._options, context: nil) })
    }
    
    private func deactivate() {
        guard let observedObject = observedObject, isActive else { return }
        isActive = false
        observations.forEach({ observedObject.removeObserver(self, forKeyPath: $0.key) })
    }
    
    private struct Observation: Identifiable {
        let keyPath: String
        var id: String { keyPath }
        var options: NSKeyValueObservingOptions = [.old]
        var unique: Bool = false
        var handler: ((_ oldValue: Any, _ newValue: Any, _ isInital: Bool) -> Void)?
        var willChange: ((Any)->Void)?
        init(_ keyPath: String) {
            self.keyPath = keyPath
        }
        var _options: NSKeyValueObservingOptions {
            var options = options
            if willChange != nil { options.insert(.prior) }
            return options
        }
    }
}
