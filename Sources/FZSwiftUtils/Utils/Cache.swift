//
//  Cache.swift
//
//
//  Created by Florian Zand on 19.06.26.
//

import Foundation

/// A mutable collection you use to temporarily store transient key-value pairs that are subject to eviction when resources are low.
public class Cache<Key: AnyObject, Value: AnyObject> {
    private let cache = NSCache<Key, Value>()
    
    public init(name: String = "") {
        self.name = name
    }
    
    /**
     The name of the cache.
     
     The default value is an empty string (`””`).
     */
    public var name: String {
        get { cache.name }
        set { cache.name = newValue }
    }
    
    /// Sets the name of the cache.
    @discardableResult
    public func name(_ name: String) -> Self {
        self.name = name
        return self
    }
    
    /**
     The maximum number of objects the cache should hold.
     
     If `0`, there is no count limit. The default value is `0`.
     
     This is not a strict limit—if the cache goes over the limit, an object in the cache could be evicted instantly, later, or possibly never, depending on the implementation details of the cache.
     */
    public var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
    
    /// Sets the maximum number of objects the cache should hold.
    @discardableResult
    public func countLimit(_ limit: Int) -> Self {
        self.countLimit = limit
        return self
    }
    
    /**
     The maximum total cost that the cache can hold before it starts evicting objects.
     
     If `0`, there is no total cost limit. The default value is `0`.
     
     When you add an object to the cache, you may pass in a specified cost for the object, such as the size in bytes of the object. If adding this object to the cache causes the cache’s total cost to rise above totalCostLimit, the cache may automatically evict objects until its total cost falls below `totalCostLimit`. The order in which the cache evicts objects is not guaranteed.
     
     This is not a strict limit, and if the cache goes over the limit, an object in the cache could be evicted instantly, at a later point in time, or possibly never, all depending on the implementation details of the cache.
     */
    public var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }
    
    /// Sets the maximum total cost that the cache can hold before it starts evicting objects.
    @discardableResult
    public func totalCostLimit(_ limit: Int) -> Self {
        self.totalCostLimit = limit
        return self
    }
    
    /**
     A Boolean value indicating whether the cache will automatically evict discardable-content objects whose content has been discarded.
     
     If `true`, the cache will evict a discardable-content object after its content is discarded. If `false`, it will not.
     
     The default value is `true`.
     */
    public var evictsObjectsWithDiscardedContent: Bool {
        get { cache.evictsObjectsWithDiscardedContent }
        set { cache.evictsObjectsWithDiscardedContent = newValue }
    }
    
    /// Sets the Boolean value indicating whether the cache will automatically evict discardable-content objects whose content has been discarded.
    @discardableResult
    public func evictsObjectsWithDiscardedContent(_ evicts: Bool) -> Self {
        self.evictsObjectsWithDiscardedContent = evicts
        return self
    }
    
    /// Returns the value associated with the specified key.
    public subscript(key: Key, cost cost: Int? = nil) -> Value? {
        get { getValue(for: key) }
        set { setValue(newValue, for: key, cost: cost) }
    }
    
    /**
     Returns the value associated with the specified key.
     
     - Parameter key: The key identifying the value.
     - Returns: The value associated with `key`, or `nil` if no value is associated with `key`.
     */
    public func getValue(for key: Key) -> Value? {
        cache.object(forKey: key)
    }
    
    /**
     Sets the value of the specified key in the cache, and associates the key-value pair with the specified cost.
     
     - Parameters:
        - value: The object to store in the cache, or `nil` to remove the value for the specified key.
        - key: The key with which to associate the value.
        - count: The cost with which to associate the key-value pair.
     
     The `cost` value is used to compute a sum encompassing the costs of all the objects in the cache. When memory is limited or when the total cost of the cache eclipses the maximum allowed total cost, the cache could begin an eviction process to remove some of its elements. However, this eviction process is not in a guaranteed order. As a consequence, if you try to manipulate the cost values to achieve some specific behavior, the consequences could be detrimental to your program.
     
     Typically, the obvious cost is the size of the value in bytes. If that information is not readily available, you should not go through the trouble of trying to compute it, as doing so will drive up the cost of using the cache. Pass in `0` for the cost value if you otherwise have nothing useful to pass, or simply use `nil` for the cost value.
     */
    public func setValue(_ value: Value?, for key: Key, cost: Int? = nil) {
        if let value = value {
            if let cost = cost {
                cache.setObject(value, forKey: key, cost: cost)
            } else {
                cache.setObject(value, forKey: key)
            }
        } else {
            removeValue(for: key)
        }
    }
    
    /**
     Removes the value of the specified key in the cache.
     
     - Parameter key: The key identifying the value to be removed.
     */
    public func removeValue(for key: Key) {
        cache.removeObject(forKey: key)
    }
    
    /// Empties the cache.
    public func removeAll() {
        cache.removeAllObjects()
    }
    
    /// The handler that is called when a value is about to be evicted or removed from the cache.
    public var willEvictHandler: ((_ value: Value)->())? {
        didSet {
            delegate = willEvictHandler.map({ Delegate(handler: $0) })
            cache.delegate = delegate
        }
    }
    
    /// Sets the handler that is called when a value is about to be evicted or removed from the cache.
    @discardableResult
    public func willEvictHandler(_ handler: ((_ value: Value)->())?) -> Self {
        willEvictHandler = handler
        return self
    }
    
    private var delegate: Delegate?
    
    private class Delegate: NSObject, NSCacheDelegate {
        let handler: ((_ value: Value)->())
        
        init(handler: @escaping (Value) -> ()) {
            self.handler = handler
        }
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let value = obj as? Value else { return }
            handler(value)
        }
    }
}

extension Cache where Key == NSURL {
    /// Returns the value associated with the specified key.
    public subscript(key: URL, cost cost: Int? = nil) -> Value? {
        get { getValue(for: key) }
        set { setValue(newValue, for: key, cost: cost) }
    }
    
    /**
     Returns the value associated with the specified key.
     
     - Parameter key: The key identifying the value.
     - Returns: The value associated with `key`, or `nil` if no value is associated with `key`.
     */
    public func getValue(for key: URL) -> Value? {
        getValue(for: key as NSURL)
    }
    
    /**
     Sets the value of the specified key in the cache, and associates the key-value pair with the specified cost.
     
     - Parameters:
        - value: The object to store in the cache, or `nil` to remove the value for the specified key.
        - key: The key with which to associate the value.
        - count: The cost with which to associate the key-value pair.
     */
    public func setValue(_ value: Value?, for key: URL, cost: Int? = nil) {
        setValue(value, for: key as NSURL, cost: cost)
    }
    
    /**
     Removes the value of the specified key in the cache.
     
     - Parameter key: The key identifying the value to be removed.
     */
    public func removeValue(for key: URL) {
        removeValue(for: key as NSURL)
    }
}

extension Cache where Key == NSString {
    /// Returns the value associated with the specified key.
    public subscript(key: String, cost cost: Int? = nil) -> Value? {
        get { getValue(for: key) }
        set { setValue(newValue, for: key, cost: cost) }
    }
    
    /**
     Returns the value associated with the specified key.
     
     - Parameter key: The key identifying the value.
     - Returns: The value associated with `key`, or `nil` if no value is associated with `key`.
     */
    public func getValue(for key: String) -> Value? {
        getValue(for: key as NSString)
    }
    
    /**
     Sets the value of the specified key in the cache, and associates the key-value pair with the specified cost.
     
     - Parameters:
        - value: The object to store in the cache, or `nil` to remove the value for the specified key.
        - key: The key with which to associate the value.
        - count: The cost with which to associate the key-value pair.
     */
    public func setValue(_ value: Value?, for key: String, cost: Int? = nil) {
        setValue(value, for: key as NSString, cost: cost)
    }
    
    /**
     Removes the value of the specified key in the cache.
     
     - Parameter key: The key identifying the value to be removed.
     */
    public func removeValue(for key: String) {
        removeValue(for: key as NSString)
    }
}
