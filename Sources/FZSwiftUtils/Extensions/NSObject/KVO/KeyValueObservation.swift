//
//  KeyValueObservation.swift
//  
//
//  Created by Florian Zand on 22.02.25.
//

import Foundation

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
        observer.isActive = false
    }
    
    /// The keypath of the observed property.
    public var keyPath: String {
        observer.keyPathString
    }
    
    ///  A Boolean value indicating whether the observation is active.
    public var isObserving: Bool {
        get { observer.isActive }
        set { observer.isActive = newValue }
    }
    
    let observer: KVObserver
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = Observer(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                handler(old, new)
            } else {
                handler(new, new)
            }
        }
        if sendInitalValue {
            let value = object[keyPath: keyPath]
            handler(value, value)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = Observer(object, keyPath: keyPath) { change in
            guard let new = change.newValue else { return }
            if let old = change.oldValue {
                if !uniqueValues || old != new {
                    handler(old, new)
                }
            } else {
                handler(new, new)
            }
        }
        if sendInitalValue {
            let value = object[keyPath: keyPath]
            handler(value, value)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: KeyPath<Object, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        observer = Observer(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue else { return }
            handler(oldValue)
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, initial: Bool = false, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        guard object.isPropertyKeyValueObservable(keyPath: keyPath) else { return nil }
        observer = TypedObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let newValue = change.newValue as? Value else { return }
            handler(change.oldValue as? Value ?? newValue, newValue)
        }
    }
    
    init?<Object: NSObject, Value: Equatable>(_ object: Object, keyPath: String, initial: Bool = false, uniqueValues: Bool = true, handler: @escaping (_ oldValue: Value, _ newValue: Value)->()) {
        guard object.isPropertyKeyValueObservable(keyPath: keyPath) else { return nil }
        observer = TypedObserver(object, keyPath: keyPath, options: initial ? [.old, .new, .initial] : [.old, .new]) { change in
            guard let new = change.newValue as? Value else { return }
            if let old = change.oldValue as? Value {
                if !uniqueValues || old != new {
                    handler(old, new)
                }
            } else {
                handler(new, new)
            }
        }
    }
    
    init?<Object: NSObject, Value>(_ object: Object, keyPath: String, willChange: @escaping (_ oldValue: Value)->()) {
        guard object.isPropertyKeyValueObservable(keyPath: keyPath) else { return nil }
        observer = TypedObserver(object, keyPath: keyPath, options: [.old, .prior]) { change in
            guard change.isPrior, let oldValue = change.oldValue as? Value else { return }
            willChange(oldValue)
        }
    }
}

private extension KeyValueObservation {
    class Observer<Object: NSObject, Value>: NSObject, KVObserver {
        weak var object: Object?
        let keyPath: KeyPath<Object, Value>
        var keyPathString: String { keyPath._kvcKeyPathString ?? "" }
        var observation: NSKeyValueObservation?
        let handler: ((NSKeyValueObservedChange<Value>) -> Void)
        let options: NSKeyValueObservingOptions

        var isActive: Bool {
            get { object != nil && observation != nil }
            set {
                guard let object = object else { return }
                if newValue {
                    observation = object.observe(keyPath, options: options) { [ weak self] _, change in
                        guard let self = self else { return }
                        self.handler(change)
                    }
                    object.kvoObservers.add(self)
                } else {
                    observation?.invalidate()
                    observation = nil
                    object.kvoObservers.remove(self)
                }
            }
        }
        
        init(_ object: Object, keyPath: KeyPath<Object, Value>, options: NSKeyValueObservingOptions = [.old, .new], handler: @escaping ((NSKeyValueObservedChange<Value>) -> Void)) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.handler = handler
            super.init()
            self.isActive = true
        }
        
        deinit {
            isActive = false
        }
    }
    class TypedObserver: NSObject, KVObserver {
        weak var object: NSObject?
        let keyPath: String
        var keyPathString: String { keyPath }
        let options: NSKeyValueObservingOptions
        let handler: ([NSKeyValueChangeKey: Any])->()
        
        init(_ object: NSObject, keyPath: String, options: NSKeyValueObservingOptions, handler: @escaping ([NSKeyValueChangeKey: Any])->()) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.handler = handler
            super.init()
            isActive = true
        }
        
        var _isActive = false
        var isActive: Bool {
            get { object != nil && _isActive }
            set {
                guard newValue != isActive, let object = object else { return }
                _isActive = newValue
                if newValue {
                    object.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
                } else {
                    object.removeObserver(self, forKeyPath: keyPath)
                }
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
            guard object != nil, keyPath != nil, let change = change else { return }
            handler(change)
        }
    }
}
