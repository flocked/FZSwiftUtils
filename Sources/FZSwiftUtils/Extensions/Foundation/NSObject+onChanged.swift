//
//  NSObject+onChanged.swift
//    Adds convenience API for KVO Combine publishers
//  Copyright ©2020 Peter Baumgartner. All rights reserved.
//

#if canImport(Combine)
import Combine
import Foundation

@available(macOS 10.15.2, iOS 13.2, *)
public extension NSObjectProtocol where Self: NSObject {
    func onChanged<Value>(_ keypath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions = .new, handler: @escaping ((Value) -> Void)) -> AnyCancellable? {
        return publisher(for: keypath, options: options)
            .sink(receiveValue: handler)
    }

    func onChanged<Value>(_ keypath: KeyPath<Self, Value?>, options: NSKeyValueObservingOptions = .new, handler: @escaping ((Value?) -> Void)) -> AnyCancellable? {
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
