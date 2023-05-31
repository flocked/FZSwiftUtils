//
//  NSObject+onChanged.swift
//    Adds convenience API for KVO Combine publishers
//  Copyright ©2020 Peter Baumgartner. All rights reserved.
//

import Foundation

public extension NSObjectProtocol where Self: NSObject {
    func observeChange<Value: Equatable>(_ keyPath: KeyPath<Self, Value>, handler: @escaping ((Self, _ oldValue: Value, _ newValue: Value) -> ())) -> NSKeyValueObservation {
        return self.observe(keyPath, options: [.old, .new]) { object, change in
            if let newValue = change.newValue, let oldValue = change.oldValue {
                if  change.newValue != change.oldValue {
                    handler(object, oldValue, newValue)
                }
            }
        }
    }
    
    func observeChange<Value>(_ keyPath: KeyPath<Self, Value>, handler: @escaping ((Self, _ oldValue: Value, _ newValue: Value) -> ())) -> NSKeyValueObservation {
        return self.observe(keyPath, options: [.old, .new]) { object, change in
            if let newValue = change.newValue, let oldValue = change.oldValue {
                    handler(object, oldValue, newValue)
            }
        }
    }
}

#if canImport(Combine)
import Combine

@available(macOS 10.15.2, iOS 13.2, tvOS 13, watchOS 6, *)
public extension NSObjectProtocol where Self: NSObject {
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = [.old, .new], handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates(by: { ($0 == $1) })
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, options: NSKeyValueObservingOptions = [.old, .new], handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates(by: { ($0 == $1) })
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = [ .new], handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value>(_ keypath: KeyPath<Self, Value?>, options: NSKeyValueObservingOptions = [.new], handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = .new, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates { $0 == $1 }
            .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, options: NSKeyValueObservingOptions = .new, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates { $0 == $1 }
            .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = .new, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates { $0 == $1 }
            .debounce(for: interval, scheduler: DispatchQueue.main)
            .sink(receiveValue: handler)
    }
    
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, options: NSKeyValueObservingOptions = .new, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .removeDuplicates { $0 == $1 }
            .debounce(for: interval, scheduler: DispatchQueue.main)
            .sink(receiveValue: handler)
    }
}
#endif