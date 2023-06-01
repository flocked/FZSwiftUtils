//
//  KeyValueObserver.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public class KeyValueObserver<Object>: NSObject where Object: NSObject {
    internal var observers: [String: NSKeyValueObservation] = [:]
    internal var handlers: [String:  (_ oldValue: Any, _ newValue: Any)->()] = [:]
    public fileprivate(set) weak var object: Object?
    
    public init(_ object: Object) {
        self.object = object
        super.init()
    }
    
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let object = self.object else { return }
        guard let name = keyPath._kvcKeyPathString else { return }
        if self.observers[name] != nil {
            object.removeObserver(object, forKeyPath: name)
            self.observers[name] = nil
        }
    }
    
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        keyPaths.forEach({ self.remove($0) })
    }
    
    public func remove(_ keyPath: String) {
        guard let object = self.object else { return }
        if self.handlers[keyPath] != nil {
            object.removeObserver(self, forKeyPath: keyPath)
            self.handlers[keyPath] = nil
        }
    }
    
    public func removeAll() {
        self.observers.keys.forEach({ self.remove( $0) })
        self.handlers.keys.forEach({ self.remove( $0) })
    }
    
    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name) { old, new in
            guard let old = old as? Value, let new = new as? Value, old != new else { return }
            handler(old, new)
        }
        
        /*
        if (observers[name] == nil) {
            
            observers[name] = object?.observeChange(keyPath, handler: { _, old, new in   handler(old, new) })
        }
         */
    }
    
    public func add<Value>(_ keyPath: KeyPath<Object, Value>, handler: @escaping (( _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        
        self.add(name) { old, new in
            guard let old = old as? Value, let new = new as? Value else { return }
            handler(old, new)
        }
        /*
        if (observers[name] == nil) {
            observers[name] = object?.observeChange(keyPath, handler: { _, old, new in   handler(old, new) })
        }
         */
    }
    
    public func add(_ keypath: String, handler: @escaping ( _ oldValue: Any, _ newValue: Any)->()) {
        if (handlers[keypath] == nil) {
            handlers[keypath] = handler
            object?.addObserver(self, forKeyPath: keypath, options: [.old, .new], context: nil)
        }
    }
    
    public func hasObservers() -> Bool {
        return self.observers.isEmpty != false && self.handlers.isEmpty != false
    }
    
    public func isObserving(_ keypath: PartialKeyPath<Object>) -> Bool {
        guard let name = keypath._kvcKeyPathString else { return false }
        return self.isObserving(name)
    }
    
    public func isObserving(_ keypath: String) -> Bool {
        return self.observers[keypath] != nil || self.handlers[keypath] != nil
    }
    
    override public func observeValue(forKeyPath keyPath:String?, of object:Any?, change:[NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?) {
        guard
            self.object != nil,
            let keyPath = keyPath,
            let handler = self.handlers[keyPath],
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
