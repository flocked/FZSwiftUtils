//
//  KVObserver.swift
//  
//
//  Created by Florian Zand on 22.02.25.
//

import Foundation

/// An object that KVO observes another object.
protocol KVObserver: NSObject {
    var isActive: Bool { get set }
    var keyPathString: String { get }
}

extension KVObserver {
    var keyPathString: String { "" }
}

/*
extension NSObject {
    var kvoObservers: [WeakKVObserver] {
        get { getAssociatedValue("kvoObservers") ?? [] }
        set { setAssociatedValue(newValue.filter({$0.observation != nil}), key: "kvoObservers") }
    }
    
    class WeakKVObserver {
        weak var observation: KVObserver?

        var isActive: Bool {
            get { observation?.isActive ?? false }
            set { observation?.isActive = newValue }
        }
        
        init(_ observation: KVObserver) {
            self.observation = observation
        }
    }
}

extension Array where Element == NSObject.WeakKVObserver {
    mutating func add(_ observation: KVObserver) {
        guard !contains(where: { $0.observation === observation }) else { return }
        append(.init(observation))
    }
    
    mutating func remove(_ observation: KVObserver) {
        removeFirst(where: { $0.observation === observation })
    }
}
*/
