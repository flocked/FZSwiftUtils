//
//  KeyValueObserver.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public class KeyValueObserver<Object>: NSObject where Object: NSObject {
    internal var observers: [String: NSKeyValueObservation] = [:]
    internal var handlers: [String:  (Any?,Any?)->()] = [:]

    public fileprivate(set) weak var object: Object?
    
    public init(_ object: Object) {
        self.object = object
        super.init()
    }
    
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.remove(name)
    }
    
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        let names = keyPaths.compactMap({$0._kvcKeyPathString})
        names.forEach({ self.remove($0) })
    }
    
    public func remove(_ keyPath: String) {
        guard let object = self.object else { return }
        if self.observers[keyPath] != nil {
            object.removeObserver(object, forKeyPath: keyPath)
            self.observers[keyPath] = nil
        }
        
        if self.handlers[keyPath] != nil {
            object.removeObserver(self, forKeyPath: keyPath)
            self.handlers[keyPath] = nil
        }
    }
    
    public func removeAll() {
        self.observers.keys.forEach({ self.remove( $0) })
        self.handlers.keys.forEach({ self.remove( $0) })
    }

    public func add<Value: Equatable>(_ keyPath: KeyPath<Object, Value>, handler: @escaping ((Object, _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keyPath._kvcKeyPathString else { return }
        if (observers[name] == nil) {
            observers[name] = object?.observeChange(keyPath, handler: handler)
        }
    }
    
    public func add<Value>(_ keypath: KeyPath<Object, Value>, handler: @escaping ((Object, _ oldValue: Value, _ newValue: Value)->())) {
        guard let name = keypath._kvcKeyPathString else { return }
        if (observers[name] == nil) {
            observers[name] = object?.observeChange(keypath, handler: handler)
        }
    }
    
    public func add(_ keypath: String, handler: @escaping (Any?, Any?)->()) {
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
        return self.observers[name] != nil
    }
    
    public func isObserving(_ keypath: String) -> Bool {
        return self.handlers[keypath] != nil
    }
    
    public func isObserving<S: Sequence<PartialKeyPath<Object>>>(_ keypaths: S) -> Bool {
        let names = keypaths.compactMap({$0._kvcKeyPathString})
        var isObserving = true
        names.forEach({
            if (self.isObserving($0) == false) {
                isObserving = false
            }
        })
        return isObserving
    }
    
    override public func observeValue(forKeyPath keyPath:String?, of object:Any?, change:[NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath, let handler = self.handlers[keyPath] else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            var oldValue:Any? = nil
            var newValue:Any? = nil
            
            if let change = change {
                oldValue = change[NSKeyValueChangeKey.oldKey]
                newValue = change[NSKeyValueChangeKey.newKey]
            }
        handler(oldValue,newValue)
        }
    
    deinit {
        self.removeAll()
    }
}
