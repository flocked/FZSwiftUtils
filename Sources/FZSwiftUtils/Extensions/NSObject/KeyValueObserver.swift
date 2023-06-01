//
//  KeyValueObserver.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

/**
 Observes multiple keypaths of an object.
 
 When the instances are deallocated, the KVO is automatically unregistered.
 */
public class KeyValueObserver<Object>: NSObject where Object: NSObject {

    internal var observers: [String:  (_ oldValue: Any, _ newValue: Any)->()] = [:]
    public fileprivate(set) weak var observedObject: Object?
        
    public init(_ observedObject: Object) {
        self.observedObject = observedObject
        super.init()
    }
    
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.remove(name)
    }
    
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        keyPaths.compactMap({$0._kvcKeyPathString}).forEach({ self.remove($0) })
    }
    
    public func remove(_ keyPath: String) {
        guard let observedObject = self.observedObject else { return }
        if self.observers[keyPath] != nil {
            observedObject.removeObserver(self, forKeyPath: keyPath)
            self.observers[keyPath] = nil
        }
    }
    
    public func removeAll() {
        self.observers.keys.forEach({ self.remove( $0) })
    }
    
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.add(name) { old, new in
            guard let old = old as? Value, let new = new as? Value, old != new else { return }
            handler(old, new)
        }
    }
    
    public func add<Value>(_ keyPath: KeyPath<Object, Value>, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name) { old, new in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
    }
    
    public func add(_ keypath: String, handler: @escaping ( _ oldValue: Any, _ newValue: Any)->()) {
        if (observers[keypath] == nil) {
            observers[keypath] = handler
            observedObject?.addObserver(self, forKeyPath: keypath, options: [.old, .new], context: nil)
        }
    }
    
    public func isObserving() -> Bool {
        return  self.observers.isEmpty != false
    }
    
    public func isObserving(_ keypath: PartialKeyPath<Object>) -> Bool {
        guard let name = keypath._kvcKeyPathString else { return false }
        return self.isObserving(name)
    }
    
    public func isObserving(_ keypath: String) -> Bool {
        return self.observers[keypath] != nil
    }
    
    override public func observeValue(forKeyPath keyPath:String?, of object:Any?, change:[NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?) {
        guard
            self.observedObject != nil,
            let keyPath = keyPath,
            let handler = self.observers[keyPath],
            let change = change,
            let oldValue = change[NSKeyValueChangeKey.oldKey],
            let newValue = change[NSKeyValueChangeKey.newKey] else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        handler(oldValue, newValue)
    }
    
    deinit {
        self.removeAll()
    }
}

public extension KeyValueObserver {
    subscript<Value: Equatable>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return self.observers[name] as ((_ oldValue: Value, _ newValue: Value)->())?
        }
        set {
            if let newValue = newValue {
                guard let name = keyPath._kvcKeyPathString else { return }
                if self.observers[name] == nil {
                    self.add(keyPath, handler: newValue)
                } else {
                    self.observers[name] = { old, new in
                        guard let old = old as? Value, let new = new as? Value, old != new else { return }
                        newValue(old, new)
                    }
                }
            } else {
                self.remove(keyPath)
            }
        }
        
    }
    
    subscript<Value>(keyPath: KeyPath<Object, Value>) -> ((_ oldValue: Value, _ newValue: Value)->())? {
        get {
            guard let name = keyPath._kvcKeyPathString else { return nil }
            return self.observers[name] as ((_ oldValue: Value, _ newValue: Value)->())?
        }
        set {
            if let newValue = newValue {
                guard let name = keyPath._kvcKeyPathString else { return }
                if self.observers[name] == nil {
                    self.add(keyPath, handler: newValue)
                } else {
                    self.observers[name] = { old, new in
                        guard let old = old as? Value, let new = new as? Value else { return }
                        newValue(old, new)
                    }
                }
            } else {
                self.remove(keyPath)
            }
        }
    }
    
    subscript(keyPath: String) -> ((_ oldValue: Any, _ newValue: Any)->())? {
        get { self.observers[keyPath] }
        set {
            self.remove(keyPath)
            if let newValue = newValue {
                if self.observers[keyPath] == nil {
                    self.add(keyPath, handler: newValue)
                } else {
                    self.observers[keyPath] = newValue
                }
            } else {
                self.remove(keyPath)
            }
        }
    }
}
