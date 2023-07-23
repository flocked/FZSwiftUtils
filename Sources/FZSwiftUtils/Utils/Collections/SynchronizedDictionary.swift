//
//  SynchronizedDictionary.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

public class SynchronizedDictionary<V: Hashable,T>: Collection, ExpressibleByDictionaryLiteral {
    public required init(dictionaryLiteral elements: (T, V)...) {
        self.dictionary = [:]
        for element in elements {
            self.dictionary[element.1] = element.0
        }
    }
    
    public init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }
    
    private var dictionary: [V: T]
    private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedDictionary",
                                                attributes: .concurrent)
   
}

public extension SynchronizedDictionary {
    var startIndex: Dictionary<V, T>.Index {
        queue.sync {
            return self.dictionary.startIndex
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
    
    func forEach(_ body: ((key: V, value: T)) throws -> Void) rethrows {
        try queue.sync {
            try self.dictionary.forEach(body)
        }
    }
    
    var endIndex: Dictionary<V, T>.Index {
        queue.sync {
            return self.dictionary.endIndex
        }
    }

    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        queue.sync {
            return self.dictionary.index(after: i)
        }
    }
    
    var keys: [V] {
        queue.sync { return Array(self.dictionary.keys) }
    }
    
    var values: [T] {
        queue.sync {
            return Array(self.dictionary.values)
        }
    }
    
    var description: String {
        queue.sync { return self.dictionary.description }
    }

    subscript(key: V) -> T? {
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

    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        queue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: V) {
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
