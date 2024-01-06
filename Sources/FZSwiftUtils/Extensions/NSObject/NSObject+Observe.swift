//
//  NSObject+onChanged.swift
//
//  Adopted from:
//  Copyright ©2020 Peter Baumgartner. All rights reserved.
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes for a property identified by the given key path.
     
     Example usage:
     
     ```swift
     let textField = NSTextField()
     
     let stringValueObservation = textField.observeChanges(for: \.stringValue) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> ())) -> NSKeyValueObservation {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
        return self.observe(keyPath, options: options) { object, change in
            if let newValue = change.newValue {
                handler(change.oldValue ?? newValue, newValue)
            }
        }
    }
    
    /**
     Observes changes for a property identified by the given key path.
     
     Example usage:
     
     ```swift
     let textField = NSTextField()
     
     let stringValueObservation = textField.observeChanges(for: \.stringValue, uniqueValues: true) {
        oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> ())) -> NSKeyValueObservation {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
        return self.observe(keyPath, options: options) { object, change in
            if let newValue = change.newValue {
                if let oldValue = change.oldValue {
                    if uniqueValues == false {
                        handler(oldValue, newValue)
                    } else if newValue != oldValue {
                        handler(oldValue, newValue)
                    }
                } else {
                    handler(newValue, newValue)
                }
            }
        }
    }
}

#if canImport(Combine)
import Combine
import AppKit

@available(macOS 10.15.2, *)
func test() {
    let textField = NSTextField()
    
    let stringValueObservation = textField.onChanged(\.stringValue) { newValue in }
}

@available(macOS 10.15.2, iOS 13.2, tvOS 13, watchOS 6, *)
public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes to a property identified by the given key path using Combine publishers.
     
     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates(by: { ($0 == $1) })
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .sink(receiveValue: handler)
        }
    }
    
    /**
     Observes changes in to optional property identified by the given key path using Combine publishers.
     
     - Parameters:
        - keypath: The key path of the optional property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates(by: { ($0 == $1) })
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .sink(receiveValue: handler)
        }
    }
    
    /**
     Observes changes to a property identified by the given key path using Combine publishers.
     
     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        return publisher(for: keypath, options: options)
            .sink(receiveValue: handler)
    }
    
    /**
     Observes changes to an optional property identified by the given key path using Combine publishers.
     
     - Parameters:
        - keypath: The key path of the optional property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value>(_ keypath: KeyPath<Self, Value?>, sendInitalValue: Bool = false, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        return publisher(for: keypath, options: options)
            .sink(receiveValue: handler)
    }
    
    /**
     Observes changes to a property identified by the given key path using Combine publishers with throttling.
     
     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates { $0 == $1 }
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        }
    }
    
    /**
     Observes changes to a property identified by the given key path using Combine publishers with throttling.
     
     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, sendInitalValue: Bool = false, uniqueValues: Bool, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates { $0 == $1 }
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        }
    }
    
    /**
     Observes changes to an optional property identified by the given key path using Combine publishers with throttling.
     
     - Parameters:
        - keypath: The key path of the optional property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates { $0 == $1 }
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        }
    }
    
    /**
     Observes changes to a property identified by the given key path using Combine publishers with debouncing.
     
     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for debouncing.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.
     
     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value?>, sendInitalValue: Bool = false, uniqueValues: Bool, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
        if uniqueValues {
            return publisher(for: keypath, options: options)
                .removeDuplicates { $0 == $1 }
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: options)
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        }
    }
}
#endif
