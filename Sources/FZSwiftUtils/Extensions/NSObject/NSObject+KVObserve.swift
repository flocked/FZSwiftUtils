//
//  KeyValueObserver.swift
//  Icon Extractor
//
//  Created by Florian Zand on 09.03.24.
//

import AppKit

extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes for a property identified by the given key path.
     
     Example usage:
     
     ```swift
     let textField = NSTextField()
     
     let stringValueObservation = textField.observeChanges(for: \.stringValue) {
     oldValue, newValue in
     // handle changed value
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        guard let observer = KVObserver(self, keyPath: keyPath, sendInitalValue: sendInitalValue, handler: handler) else {
            return nil
        }
        return KeyValueObservation(observer)
    }
    
    /**
     Observes changes for a property identified by the given key path.
     
     Example usage:
     
     ```swift
     let textField = NSTextField()
     
     let stringValueObservation = textField.observeChanges(for: \.stringValue, uniqueValues: true) {
     oldValue, newValue in
     // handle changed value
     }
     ```
     
     - Parameters:
        -  keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? where Value: Equatable {
       guard let observer = KVObserver(self, keyPath: keyPath, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues, handler: handler) else {
           return nil
       }
       return KeyValueObservation(observer)
    }
    
    public func deactivateAllObservations() {
        NotificationCenter.default.post(name: Self.deactivateObservation, object: self)
    }
    
    public func activateAllObservations() {
        NotificationCenter.default.post(name: Self.activateObservation, object: self)
    }
}

extension NSObject {
    static let deactivateObservation = NSNotification.Name("com.fzuikit.deactivateObservation")
    
    static let activateObservation = NSNotification.Name("com.fzuikit.activateObservation")
}

/**
 An object that observes the value of a key-value compatible property,
 
 To observe the value of a property that is key-value compatible, use `observeChanges(for:)`
 
 ```swift
 let observation = textField.observeChanges(for: \.stringValue) 
 { oldValue, newValue in
    // handle changes
 }
 ```
 To stop the observation of the property, either call ``invalidate()```, or deinitalize the object.
 */
public class KeyValueObservation: NSObject {

    /// Invalidates the observation.
    public func invalidate() {
        observer.deactivate()
        tokens.removeAll()
    }
    
    /// The keypath of the observed property.
    public var keyPath: String {
        observer._keyPath
    }
    
    ///  A Boolean value indicating whether the observation is active.
    public var isObserving: Bool {
        observer.isObserving
    }
    
    let observer: KVOObservation
    var tokens: [NotificationToken] = []
    
    func setupNotifications() {
        tokens.append(NotificationCenter.default.observe(Self.activateObservation, object: observer._object, using: { [weak self] notification in
            guard let self = self else { return }
            self.observer.activate()
            if self.observer._object == nil {
                self.invalidate()
            }
        }))
        tokens.append(NotificationCenter.default.observe(Self.deactivateObservation, object: observer._object, using: { [weak self] notification in
            guard let self = self else { return }
            self.observer.deactivate()
            if self.observer._object == nil {
                self.invalidate()
            }
        }))
    }
    
    init(_ observer: KVOObservation) {
        self.observer = observer
        super.init()
        setupNotifications()
    }
    
    deinit {
        invalidate()
    }
}

class KVObserver<Object: NSObject, Value>: NSObject, KVOObservation {
    
    weak var object: Object?
    var _object: NSObject? { object }
    let keyPath: KeyPath<Object, Value>
    var _keyPath: String { keyPath.stringValue }
    let handler: (_ oldValue: Value, _ newValue: Value) -> Void
    var observation: NSKeyValueObservation?
    var isObserving: Bool { object != nil && observation != nil }

    func activate() {
        guard object != nil, observation == nil else { return }
        setupObservation()
    }
    
    func deactivate() {
        observation?.invalidate()
        observation = nil
    }
    
    func setupObservation(sendInital: Bool = false) {
        guard let object = object else { return }
        let options: NSKeyValueObservingOptions = sendInital ? [.old, .new, .initial] : [.old, .new]
        observation = object.observe(keyPath, options: options) { [ weak self] _, change in
            guard let self = self else { return }
            guard let newValue = change.newValue else { return }
            self.handler(change.oldValue ?? newValue, newValue)
        }
    }
    
    init?(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        self.object = object
        self.keyPath = keyPath
        self.handler = handler
        super.init()
        setupObservation(sendInital: sendInitalValue)
    }
    
    init?(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        self.object = object
        self.keyPath = keyPath
        self.handler = !uniqueValues ? handler : { old, new in
            guard old != new else { return }
            handler(old, new)
        }
        super.init()
        setupObservation(sendInital: sendInitalValue)
    }
    
    deinit {
        deactivate()
    }
}

protocol KVOObservation: NSObject {
    func activate()
    func deactivate()
    var _object: NSObject? { get }
    var _keyPath: String { get }
    var isObserving: Bool { get }
}
