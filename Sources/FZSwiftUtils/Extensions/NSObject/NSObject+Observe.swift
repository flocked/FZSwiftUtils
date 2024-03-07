//
//  NSObject+Observe.swift
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
     
     let stringValueObservation = textField.observe(\.stringValue) {
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
    func observe<Value>(_ keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> NSKeyValueObservation? {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        let options: NSKeyValueObservingOptions = sendInitalValue ? [.old, .new, .initial] : [.old, .new]
        return observe(keyPath, options: options) { _, change in
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
     
     let stringValueObservation = textField.observe(\.stringValue, uniqueValues: true) {
     oldValue, newValue in
     // handle changed value
     }
     ```
     
     - Parameters:
        -  keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    func observe<Value: Equatable>(_ keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> NSKeyValueObservation? {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        if sendInitalValue == false {
            return observe(keyPath, handler: handler)
        }
        return observe(keyPath, options: [.old, .new, .initial]) { _, change in
            if let newValue = change.newValue {
                if let oldValue = change.oldValue, newValue != oldValue {
                    handler(oldValue, newValue)
                } else {
                    handler(newValue, newValue)
                }
            }
        }
    }
    
    /**
     Observes the deinitialization of the object and calls the specified handler.
     
     Example:
     
     ```swift
     let deinitObservation = textField.observeDeinit(handler: {
        // handle deinitialization
     })
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
        get { getAssociatedValue(key: "deinitCallback", object: self, initialValue: DeinitCallback()) }
    }
}

extension NSObject {
    
    /**
     An object that observe the deinitialization of a `NSObject`.
     
     To observe the deinitialization of an object, use ``observeDeinit(_:)``.
          
     ```swift
     let deinitObservation = textField.observeDeinit(handler: {
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
        
        init(object: NSObject? = nil) {
            self.object = object
        }
        
        deinit {
           invalidate()
        }
    }
}


@objc class DeinitCallback: NSObject {
    var callbacks: [UUID: () -> ()] = [:]

  deinit {
      callbacks.forEach({$0.value() })
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
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.stringValue, uniqueValues: true) {
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
        func onChanged<Value: Equatable>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
            if uniqueValues {
                return publisher(for: keypath, options: options)
                    .removeDuplicates(by: { $0 == $1 })
                    .sink(receiveValue: handler)
            } else {
                return publisher(for: keypath, options: options)
                    .sink(receiveValue: handler)
            }
        }

        /**
         Observes changes in to optional property identified by the given key path using Combine publishers.

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.placeholderString, uniqueValues: true) {
            newValue in
            // handle changed value
         }
         ```

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
                    .removeDuplicates(by: { $0 == $1 })
                    .sink(receiveValue: handler)
            } else {
                return publisher(for: keypath, options: options)
                    .sink(receiveValue: handler)
            }
        }

        /**
         Observes changes to a property identified by the given key path using Combine publishers.

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.stringValue) {
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
        func onChanged<Value>(_ keypath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
            let options: NSKeyValueObservingOptions = sendInitalValue ? [.new, .initial] : [.new]
            return publisher(for: keypath, options: options)
                .sink(receiveValue: handler)
        }

        /**
         Observes changes to an optional property identified by the given key path using Combine publishers.

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.placeholderString) {
            newValue in
            // handle changed value
         }
         ```

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

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.stringValue, throttle: .milliseconds(50)) {
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

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.placeholderString, throttle: .milliseconds(50)) {
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

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.stringValue, debounce: .milliseconds(50)) {
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

         Example usage:

         ```swift
         let textField = NSTextField()

         let stringValueObservation = textField.obChanged(\.placeholderString, debounce: .milliseconds(50)) {
            newValue in
            // handle changed value
         }
         ```

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
