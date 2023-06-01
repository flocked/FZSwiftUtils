//
//  File.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public class KeyValueObserver<Object> where Object: NSObject {
    internal var observers: [String: NSKeyValueObservation] = [:]
    internal var handlers: [String: ((Object, _ oldValue: Any, _ newValue: Any)->())] = [:]

    public fileprivate(set) weak var object: Object?
    
    public init(_ object: Object) {
        self.object = object
    }
    
    internal func remove(_ keyPath: String) {
        if let observer = self.observers[keyPath] {
            self.object?.removeObserver(observer, forKeyPath: keyPath)
            self.observers[keyPath] = nil
        }
    }
    
    public func remove(_ keyPath: PartialKeyPath<Object>) {
        guard let name = keyPath._kvcKeyPathString else { return }
        self.remove(name)
    }
    
    public func remove<S: Sequence<PartialKeyPath<Object>>>(_ keyPaths: S)  {
        let names = keyPaths.compactMap({$0._kvcKeyPathString})
        names.forEach({ self.remove($0) })
    }
    
    public func removeAll() {
        self.observers.keys.forEach({ self.remove( $0) })
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
    
    subscript<Value>(keypath: KeyPath<Object, Value>) -> ((Object, _ oldValue: Value, _ newValue: Value)->())? {
        get {
            guard let name = keypath._kvcKeyPathString else { return nil }
            guard let handler = handlers[name] else { return nil }
            return handler as ((Object, _ oldValue: Value, _ newValue: Value)->())
        }
        set {
            guard let name = keypath._kvcKeyPathString else { return }
            if (observers[name] != nil) {
                self.remove(keypath)
            }
            guard let newValue = newValue else { return }
            self.add(keypath, handler: newValue)
        }
    }
    
}
