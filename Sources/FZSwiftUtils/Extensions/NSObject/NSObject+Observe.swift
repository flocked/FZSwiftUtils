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
    public func observeChanges<Value>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        KVObserver(self, keyPath: keyPath, sendInitalValue: sendInitalValue, handler: handler)?.keyValueObservation
    }
    
    /**
     Observes changes for the specified property.
     
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
    public func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        observeChanges(for: keyPath, sendInitalValue: sendInitalValue, uniqueValues: true, handler: handler)
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
        -  keyPath: The key path of the property to observe.
        - sendInitalValue: A Boolean value indicating whether the handler should get called with the inital value of the observed property.
        - uniqueValues: A Boolean value indicating whether the handler should only get called when a value changes compared to it's previous value.
        - handler: A closure that will be called when the property value changes. It takes the old value, and the new value as parameters.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    public func observeChanges<Value: Equatable>(for keyPath: KeyPath<Self, Value>, sendInitalValue: Bool = false, uniqueValues: Bool, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) -> KeyValueObservation? {
        KVObserver(self, keyPath: keyPath, sendInitalValue: sendInitalValue, uniqueValues: uniqueValues, handler: handler)?.keyValueObservation
    }
    
    /**
     Observes will change for the specified property.

     Example usage:
     
     ```swift
     let textField = NSTextField()
     
     let stringValueObservation = textField.observeWillChange(for: \.stringValue) {
     oldValue in
     // handle will change
     }
     ```
     
     - Parameters:
        - keyPath: The key path of the property to observe.
        - handler: A closure that will be called when the property value changes. It takes the old value.
     
     - Returns: An `NSKeyValueObservation` object representing the observation.
     */
    public func observeWillChange<Value>(_ keyPath: KeyPath<Self, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) -> KeyValueObservation? {
        KVObserverPrior(self, keyPath: keyPath, handler: handler)?.keyValueObservation
    }
    
    /// Deactivates all key value observations of the object.
    public func deactivateAllObservations() {
        NotificationCenter.default.post(name: Self.deactivateObservation, object: self)
    }
    
    /// Activates all inactive key value observations of the object.
    public func activateAllObservations() {
        NotificationCenter.default.post(name: Self.activateObservation, object: self)
    }
}

extension NSObject {
    static let deactivateObservation = NSNotification.Name("com.fzuikit.deactivateObservation")
    static let activateObservation = NSNotification.Name("com.fzuikit.activateObservation")
}

/**
 An object that observes the value of a key-value compatible property,
 
 To observe the value of a property that is key-value compatible, use `observeChanges(for:)`
 
 ```swift
 let observation = textField.observeChanges(for: \.stringValue)
 { oldValue, newValue in
    // handle changes
 }
 ```
 To stop the observation of the property, either call ``invalidate()```, or deinitalize the object.
 */
public class KeyValueObservation: NSObject {

    /// Invalidates the observation.
    public func invalidate() {
        observer.isActive = false
        tokens.removeAll()
    }
    
    /// The keypath of the observed property.
    public var keyPath: String {
        observer._keyPath
    }
    
    ///  A Boolean value indicating whether the observation is active.
    public var isObserving: Bool {
        observer.isActive
    }
    
    let observer: KVOObservation
    var tokens: [NotificationToken] = []
    
    func setupNotifications() {
        tokens.append(NotificationCenter.default.observe(Self.activateObservation, object: observer._object, using: { [weak self] notification in
            guard let self = self else { return }
            self.observer.isActive = true
            if self.observer._object == nil {
                self.invalidate()
            }
        }))
        tokens.append(NotificationCenter.default.observe(Self.deactivateObservation, object: observer._object, using: { [weak self] notification in
            guard let self = self else { return }
            self.observer.isActive = false
            if self.observer._object == nil {
                self.invalidate()
            }
        }))
    }
    
    init(_ observer: KVOObservation) {
        self.observer = observer
        super.init()
        setupNotifications()
    }
    
    deinit {
        invalidate()
    }
}

class KVObserverPrior<Object: NSObject, Value>: NSObject, KVOObservation {
    weak var object: Object?
    var _object: NSObject? { object }
    let keyPath: KeyPath<Object, Value>
    var _keyPath: String { keyPath.stringValue }
    let handler: (_ oldValue: Value) -> Void
    var observation: NSKeyValueObservation?
    
    func setupObservation(sendInital: Bool = false) {
        guard let object = object, observation == nil else { return }
        observation = object.observe(keyPath, options: [.prior, .old]) { [ weak self] _, change in
            guard let self = self, change.isPrior, let oldValue = change.oldValue else { return }
            self.handler(oldValue)
        }
    }
    
    init?(_ object: Object, keyPath: KeyPath<Object, Value>, handler: @escaping ((_ oldValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        self.object = object
        self.keyPath = keyPath
        self.handler = handler
        super.init()
        setupObservation()
    }
    
    deinit {
        isActive = false
    }
}

class KVObserver<Object: NSObject, Value>: NSObject, KVOObservation {
    weak var object: Object?
    var _object: NSObject? { object }
    let keyPath: KeyPath<Object, Value>
    var _keyPath: String { keyPath.stringValue }
    let handler: (_ oldValue: Value, _ newValue: Value, _ inital: Bool) -> Void
    var observation: NSKeyValueObservation?
    
    func setupObservation(sendInital: Bool = false) {
        guard let object = object, observation == nil else { return }
        observation = object.observe(keyPath, options: sendInital ? [.old, .new, .initial] : [.old, .new]) { [ weak self] _, change in
            guard let self = self else { return }
            guard let newValue = change.newValue else { return }
            if let oldValue = change.oldValue {
                self.handler(oldValue, newValue, false)
            } else {
                self.handler(newValue, newValue, true)
            }
        }
    }
    
    init?(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        self.object = object
        self.keyPath = keyPath
        self.handler = { old, new, _ in handler(old, new) }
        super.init()
        setupObservation(sendInital: sendInitalValue)
    }
    
    init?(_ object: Object, keyPath: KeyPath<Object, Value>, sendInitalValue: Bool = false, uniqueValues: Bool = true, handler: @escaping ((_ oldValue: Value, _ newValue: Value) -> Void)) where Value: Equatable {
        guard keyPath._kvcKeyPathString != nil else { return nil }
        self.object = object
        self.keyPath = keyPath
        self.handler =  !uniqueValues ? { old, new, _ in handler(old, new) } : { old, new, inital in
            guard old != new || inital else { return }
            handler(old, new)
        }
        super.init()
        setupObservation(sendInital: sendInitalValue)
    }
    
    deinit {
        isActive = false
    }
}

protocol KVOObservation: NSObject {
    var _object: NSObject? { get }
    var _keyPath: String { get }
    var observation: NSKeyValueObservation? { get set }
    func setupObservation(sendInital: Bool)
}

extension KVOObservation {
    var isActive: Bool {
        get { _object != nil && observation != nil }
        set {
            if newValue {
                setupObservation(sendInital: false)
            } else {
                observation?.invalidate()
                observation = nil
            }
        }
    }
}

extension KVOObservation {
    var keyValueObservation: KeyValueObservation {
        KeyValueObservation(self)
    }
}

public extension NSObjectProtocol where Self: NSObject {
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
        get { getAssociatedValue("deinitCallback", initialValue: DeinitCallback()) }
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
