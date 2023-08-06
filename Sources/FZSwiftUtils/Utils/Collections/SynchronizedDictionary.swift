//
//  SynchronizedDictionary.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

/// A synchronized dictionary.
public class SynchronizedDictionary< Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
    public required init(dictionaryLiteral elements: (Value, Key)...) {
        self.dictionary = [:]
        for element in elements {
            self.dictionary[element.1] = element.0
        }
    }
    
    public init(dict: [Key: Value] = [Key:Value]()) {
        self.dictionary = dict
    }
    
    private var dictionary: [Key:Value]
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedDictionary",
                                                attributes: .concurrent)
}

public extension SynchronizedDictionary {
    var synchronized: [Key:Value] {
        var dictionary: [Key:Value] = [:]
        queue.sync {
            dictionary = self.dictionary
        }
        return dictionary
    }
    
    func edit(_ edit: @escaping (inout [Key:Value])->()) {
        queue.async(flags: .barrier) {
            edit(&self.dictionary)
        }
    }
    
    var startIndex: Dictionary<Key, Value>.Index {
        queue.sync {
            return self.dictionary.startIndex
        }
    }
    
    var endIndex: Dictionary<Key, Value>.Index {
        queue.sync {
            return self.dictionary.endIndex
        }
    }
    
    var isEmpty: Bool {
        queue.sync {
            return self.dictionary.isEmpty
        }
    }
    
    var count: Int {
        queue.sync {
            return self.dictionary.count
        }
    }
    
    func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        try queue.sync {
            try self.dictionary.forEach(body)
        }
    }
    
    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        queue.sync {
            return self.dictionary.index(after: i)
        }
    }
    
    func filter(_ isIncluded: ((_ key: Key, _ value: Value) throws -> Bool)) rethrows -> [Key: Value] {
        try queue.sync {
            return try self.dictionary.filter(isIncluded)
        }
    }
    
    func map(_ transform: ((_ key: Key, _ value: Value) throws -> Value)) rethrows -> [Value] {
        try queue.sync {
            return try self.dictionary.map(transform)
        }
    }
    
    var keys: [Key] {
        queue.sync { return Array(self.dictionary.keys) }
    }
    
    var values: [Value] {
        queue.sync {
            return Array(self.dictionary.values)
        }
    }
    
    var description: String {
        queue.sync { return self.dictionary.description }
    }

    subscript(key: Key) -> Value? {
        set(newValue) {
            queue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            queue.sync {
                return self.dictionary[key]
            }
        }
    }

    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        queue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll(keepingCapacity: Bool = false) {
        queue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll(keepingCapacity: keepingCapacity)
        }
    }
}
