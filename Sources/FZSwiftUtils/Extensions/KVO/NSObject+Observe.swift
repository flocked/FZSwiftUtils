//
//  NSObject+Observe.swift
//
//  Adopted from:
//  Copyright ©2020 Peter Baumgartner. All rights reserved.
//
//  Created by Florian Zand on 10.10.22.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {    
    /**
     Observes changes for the specified property.
          
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
               
     Example usage:
     
     ```swift
     let label = UILabel()
     let observation = label.observeChanges(for: \.text) {
     oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        KeyValueObservation(self, keyPath: keyPath, sendInitalValue: sendInitalValue, handler: handler)
    }
    
    /**
     Observes changes for the specified property.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     let observation = label.observeChanges(for: \.text) {
     oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        observeChanges(for: keyPath, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Observes changes for a property identified by the given key path.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
     
     Example usage:
     
     ```swift
     let label = UILabel()
     let observation = label.observeChanges(for: \.text, uniqueValues: true) {
     oldValue, newValue in
        // handle changed value
     }
     ```
     
     - Parameters:
        -  keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        KeyValueObservation(self, keyPath: keyPath, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues, handler: handler)
    }
    
    /**
     Observes will change for the specified property.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.

     Example usage:
     
     ```swift
     let label = UILabel()
     let observation = label.observeWillChange(for: \.text) {
     oldValue in
        // handle will change
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - handler: A closure that will be called when the property value changes. It takes the old value.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeWillChange<Value>(_ keyPath: KeyPath<Self, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) -> KeyValueObservation? {
        KeyValueObservation(self, keyPath: keyPath, handler: handler)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes for the specified property.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
     
     - Parameters:
        - keyPath: The name of the key path of the property to observe.
        - type: The value type of the property.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value>(for keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation {
        KeyValueObservation(self, keyPath: keyPath, initial: sendInitalValue, handler: handler)
    }
    
    /**
     Observes changes for the specified property.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
     
     - Parameters:
        - keyPath: The name key path of the property to observe.
        - type: The value type of the property.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value: Equatable>(for keyPath: String, type: Value.Type, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation {
        observeChanges(for: keyPath, type: type, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
    }
    
    /**
     Observes changes for a property identified by the given key path.
     
     When the returned ``KeyValueObservation`` is deinited or invalidated, it will stop observing.
     
     - Parameters:
        -  keyPath: The key path of the property to observe.
        - type: The value type of the property.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeChanges<Value: Equatable>(for keyPath: String, type: Value.Type, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation {
        KeyValueObservation(self, keyPath: keyPath, initial: sendInitalValue, uniqueValues: uniqueValues, handler: handler)
    }
    
    /**
     Observes will change for the specified property.
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - type: The value type of the property.
        - handler: A closure that will be called when the property value changes. It takes the old value.
     
     - Returns: A ``KeyValueObservation`` object representing the observation.
     */
    public func observeWillChange<Value>(_ keyPath: String, type: Value.Type, handler: @escaping ((_ oldValue: Value) -> Void)) -> KeyValueObservation {
        KeyValueObservation(self, keyPath: keyPath, willChange: handler)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes the deinitialization of the object and calls the specified handler.
     
     Example:
     
     ```swift
     let deinitObservation = textField.observeDeinit {
        // handle deinitialization
     }
     ```
     
     - Parameter handler: A closure that will be called when the object deinitializes.
     
     - Returns: The object that observes the deinitialization. To stop the observations, deinitializate the object.
     */
    func observeDeinit(_ handler: @escaping () -> ()) -> DeinitObservation {
        let observation = DeinitObservation(object: self)
        deinitCallback.callbacks[observation.id] = handler
        return observation
    }
    
    fileprivate var deinitCallback: DeinitCallback {
        get { getAssociatedValue("deinitCallback", initialValue: DeinitCallback()) }
    }
}


extension NSObject {
    
    /**
     An object that observe the deinitialization of a `NSObject`.
     
     To observe the deinitialization of an object, use ``observeDeinit(_:)``.
          
     ```swift
     let deinitObservation = view.observeDeinit(handler: {
        // handle deinitialization
     })
     ```
     */
    public class DeinitObservation: NSObject {
        weak var object: NSObject?
        let id = UUID()
        
        /// Invalidates the deinitialization observation.
        public func invalidate() {
            object?.deinitCallback.callbacks.removeValue(forKey: id)
        }
        
        init(object: NSObject) {
            self.object = object
        }
        
        deinit {
            invalidate()
        }
    }
    
    class DeinitCallback: NSObject {
        var callbacks: [UUID: () -> ()] = [:]

        deinit {
            callbacks.forEach({$0.value() })
        }
    }
}

#if canImport(Combine)
import Combine

@available(macOS 10.15.2, iOS 13.2, tvOS 13, watchOS 6, *)
public extension NSObjectProtocol where Self: NSObject {
    /**
     Observes changes to a property identified by the given key path using Combine publishers.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text, uniqueValues: true) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        if uniqueValues {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .removeDuplicates(by: { $0 == $1 })
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .sink(receiveValue: handler)
        }
    }

    /**
     Observes changes to a property identified by the given key path using Combine publishers.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new]).sink(receiveValue: handler)
    }
        
    /**
     Observes changes to a property identified by the given key path using Combine publishers with throttling.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text, throttle: .milliseconds(50)) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
            .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: handler)
    }

    /**
     Observes changes to a property identified by the given key path using Combine publishers with throttling.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text.obChanged(\.stringValue, throttle: .milliseconds(50)) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, throttle interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        if uniqueValues {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .removeDuplicates { $0 == $1 }
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .throttle(for: interval, scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: handler)
        }
    }
        
    /**
     Observes changes to an optional property identified by the given key path using Combine publishers with throttling.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text, debounce: .milliseconds(50)) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the optional property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
            .debounce(for: interval, scheduler: DispatchQueue.main)
            .sink(receiveValue: handler)
    }

    /**
     Observes changes to an optional property identified by the given key path using Combine publishers with throttling.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.obChanged(\.text, debounce: .milliseconds(50)) {
        newValue in
        // handle changed value
     }
     ```

     - Parameters:
        - keypath: The key path of the optional property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property. The default value is `false`.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - interval: The time interval used for throttling.
        - handler: A closure that will be called when the property value changes. It takes the new value as a parameter.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, debounce interval: DispatchQueue.SchedulerTimeType.Stride, handler: @escaping ((Value) -> Void)) -> AnyCancellable {
        if uniqueValues {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .removeDuplicates { $0 == $1 }
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        } else {
            return publisher(for: keypath, options: sendInitalValue ? [.new, .initial] : [.new])
                .debounce(for: interval, scheduler: DispatchQueue.main)
                .sink(receiveValue: handler)
        }
    }
        
    /**
     Observes changes to a property identified by the given key path using Combine publishers.

     Example usage:

     ```swift
     let label = UILabel()
     let observation = label.onPriorChange(\.text) {
        oldValue in
        // handle
     }
     ```

     - Parameters:
        - keypath: The key path of the property to observe.
        - handler: A closure that will be called before the property value changes.

     - Returns: An `AnyCancellable` object representing the observation. It can be used to cancel the observation.
     */
    func onPriorChange<Value>(_ keypath: KeyPath<Self, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) -> AnyCancellable {
        publisher(for: keypath, options: [.old, .prior]).sink(receiveValue: handler)
    }
}
#endif
