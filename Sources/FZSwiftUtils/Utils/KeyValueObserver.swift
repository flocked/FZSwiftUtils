//
//  KeyValueObserver.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

/**
 Observes multiple properties of an object.
 
 When the instances are deallocated, the KVO is automatically unregistered.
 */
public class KeyValueObserver<Object>: NSObject where Object: NSObject {
    typealias Observer = (handler: ((_ oldValue: Any?, _ newValue: Any)->()), sendInital: Bool, sendUnique: Bool)
    internal var observers: [String:  Observer] = [:]
    /// The object to register for KVO notifications.
    public fileprivate(set) weak var observedObject: Object?
    
    /**
    Creates a key-value observer with the specifed observed object.
     - Parameter observedObject: The object to register for KVO notifications.
     - Returns: The  key-value observer.
     */
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
     
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - sendUniqueOnly: A Boolean value indicating whether the handler should only be called if the new value isn't equal to the previous value.
        - handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, sendUniqueOnly: Bool, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        if sendUniqueOnly {
            self.add(keyPath, sendInitalValue: sendInitalValue, handler: handler)
        } else {
            guard let name = keyPath._kvcKeyPathString else { return }
            self.add(name, sendInitalValue: sendInitalValue) { old, new in
                if let new = new as? Value, let old = old as? Value {
                    handler(old, new)
                }
            }
        }
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
          
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the keypath value changes to a new value that isn't equal to the previous value. If you want to the handler to get called on all changes, use ``add(_:sendInitalValue:sendUniqueOnly:handler:)`` and set `sendUniqueOnly` to `false`.
     */
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name, sendInitalValue: sendInitalValue, sendUniqueOnly: true) { old, new in
            if let new = new as? Value, let old = old as? Value {
                handler(old, new)
            }
        }
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
     
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the keypath value changes.
     */
    public func add<Value>(_ keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name, sendInitalValue: sendInitalValue) { old, new in
            if let new = new as? Value, let old = old as? Value {
                handler(old, new)
            }
        }
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
     
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the keypath value changes.
     */
    public func add(_ keypath: String, sendInitalValue: Bool = false, handler: @escaping ( _ oldValue: Any?, _ newValue: Any)->()) {
        self.add(keypath, sendInitalValue: sendInitalValue, sendUniqueOnly: false, handler: handler)
    }
    
    func add(_ keypath: String, sendInitalValue: Bool = false, sendUniqueOnly: Bool = false, handler: @escaping ( _ oldValue: Any?, _ newValue: Any)->()) {
        if observers[keypath] == nil || observers[keypath]?.sendInital != sendInitalValue || observers[keypath]?.sendUnique != sendUniqueOnly {
            observers[keypath] = (handler, sendInitalValue, sendUniqueOnly)
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
            observedObject?.addObserver(self, forKeyPath: keypath, options: options, context: nil)
        } else {
            observers[keypath] = (handler, sendInitalValue, sendUniqueOnly)
        }
    }
    
    /**
     Adds observers for the properties at the specified keypaths which calls the specified handler whenever any of the keypaths properties changes.
     
     - Parameters:
        - keyPaths: The keypaths to the values to observe.
        - handler: The handler to be called whenever any of keypaths values changes.
     */
    public func add(_ keyPaths: [PartialKeyPath<Object>], handler: @escaping ((_ keyPath: PartialKeyPath<Object>)->())) {
        for keyPath in keyPaths {
            if let name = keyPath._kvcKeyPathString {
                self.add(name) { old, new in
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
     Removes the observer for the property at the specified keypath.
     
     - Parameter keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.remove(name)
    }
    
    /**
     Removes the observer for the property at the specified keypath.
     
     - Parameter keyPath: The keypath to remove.
     */
    public func remove(_ keyPath: String) {
        guard let observedObject = self.observedObject else { return }
        if self.observers[keyPath] != nil {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            self.observers[keyPath] = nil
        }
    }
    
    /**
     Removes the observers for the properties at the specified keypaths.
     
     - Parameter keyPaths: The keypaths to remove.
     */
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        keyPaths.compactMap({$0._kvcKeyPathString}).forEach({ self.remove($0) })
    }
    
    /// Removes all observers.
    public func removeAll() {
        self.observers.keys.forEach({ self.remove($0) })
    }
    
    /// A Boolean value indicating whether any value is observed.
    public func isObserving() -> Bool {
        return  self.observers.isEmpty != false
    }
    
    /**
     A Boolean value indicating whether the property at the specified keypath is observed.
     
     - Parameter keyPath: The keypath to the value.
     */
    public func isObserving(_ keyPath: PartialKeyPath<Object>) -> Bool {
        guard let name = keyPath._kvcKeyPathString else { return false }
        return self.isObserving(name)
    }
    
    /**
     A Boolean value indicating whether the property at the specified keypath is observed.
     
     - Parameter keyPath: The keypath to the value.
     */
    public func isObserving(_ keyPath: String) -> Bool {
        return self.observers[keyPath] != nil
    }
    
    func observer<Value>(for keyPath: KeyPath<Object, Value>) ->  ((_ oldValue: Value, _ newValue: Value)->())? {
        guard let name = keyPath._kvcKeyPathString else { return nil }
        return self.observers[name]?.handler as? ((_ oldValue: Value, _ newValue: Value)->())
    }
    
    override public func observeValue(forKeyPath keyPath:String?, of object:Any?, change:[NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?) {
        guard
            self.observedObject != nil,
            let keyPath = keyPath,
            let observer = self.observers[keyPath],
            let change = change,
            let newValue = change[NSKeyValueChangeKey.newKey] else {
           // super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
      //  Swift.print("here", change[NSKeyValueChangeKey.oldKey]  ?? "nil", change[NSKeyValueChangeKey.newKey]  ?? "nil")
        if let oldValue = change[NSKeyValueChangeKey.oldKey] {
            if observer.sendUnique == false {
                observer.handler(oldValue, newValue)
            } else if let oldValue = oldValue as? (any Equatable), let newValue = newValue as? (any Equatable), oldValue.isEqual(newValue) == false {
                observer.handler(oldValue, newValue)
            }
        } else {
            observer.handler(newValue, newValue)
        }
    }
    
    deinit {
        self.removeAll()
    }
}

public extension KeyValueObserver {
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
          
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: The handler to be called whenever the keypath value changes to a new value that isn't equal to the previous value.
     */
    subscript<Value: Equatable>(keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, sendUniqueOnly: Bool) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get { observer(for: keyPath) }
        set {
            if let handler = newValue {
                self.add(keyPath, sendInitalValue: sendInitalValue, sendUniqueOnly: sendUniqueOnly, handler: handler)
            } else {
                self.remove(keyPath)
            }
        }
        
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
     
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the keypath value changes.
     */
    subscript<Value>(keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get { observer(for: keyPath) }
        set {
            if let handler = newValue {
                self.add(keyPath, sendInitalValue: sendInitalValue, handler: handler)
            } else {
                self.remove(keyPath)
            }
        }
    }
    
    /**
     Adds an observer for the property at the specified keypath which calls the specified handler.
     
     - Parameters:
        - keyPath: The keypath to the value to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should be called with the inital value of the observed property. The default value is `false`.
        - handler: The handler to be called whenever the keypath value changes.
     */
    subscript(keyPath: String, sendInitalValue: Bool = false) -> ((_ oldValue: Any, _ newValue: Any)->())? {
        get { self.observers[keyPath]?.handler }
        set {
            if let newValue = newValue {
                self.add(keyPath, sendInitalValue: sendInitalValue, handler: newValue)
            } else {
                self.remove(keyPath)
            }
        }
    }
}
