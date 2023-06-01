//
//  File.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public class KeyValueObserver<Object> where Object: NSObject {
    internal var observers: [String: NSKeyValueObservation] = [:]

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
    
    public func hasObservers() -> Bool {
        return self.observers.isEmpty != false
    }
    
    deinit {
        self.removeAll()
    }
}
