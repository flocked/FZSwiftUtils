//
//  Sequence+Concurrency.swift
//
//
//  Created by Florian Zand on 08.11.23.
//  Parts taken from:
//  Copyright (c) John Sundell 2021
//

import Foundation

// MARK: - ForEach

public extension Sequence {
    /**
     Calls the given closure on each element in the sequence asynchronous.
     
     - Parameters:
        - body: A closure that takes an element of the sequence as a parameter.
        - progress: The handler with the elements that completed iteration.
        - completion: The handler that gets called after iterating all elements.
     */
    func concurrentForEach(_ body: (_ element: Element)->(), progress: ((_ completed: [Element])->())? = nil, completion: (()->())? = nil) {
        let collection = Array(self)
        if progress != nil || completion != nil {
            var completed: [Element] = []
            let lock = DispatchQueue(label: "FZSwiftUtils.concurrentForEach")
            DispatchQueue.concurrentPerform(iterations: collection.count) { index in
                let element = collection[index]
                body(element)
                lock.sync {
                    completed += element
                    DispatchQueue.main.async {
                        progress?(completed)
                    }
                    if completed.count == collection.count {
                        DispatchQueue.main.async {
                            completion?()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.concurrentPerform(iterations: collection.count) { index in
                body(collection[index])
            }
        }
    }
}

// MARK: - ForEach (async)

public extension Sequence {
    /**
     Run an async closure for each element within the sequence.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter operation: The closure to run for each element.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncForEach(_ operation: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    /**
     Run an async closure for each element within the sequence.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to
         the async tasks that will perform the closure calls. The
         default is `nil` (meaning that the system picks a priority).
       - operation: The closure to run for each element.
     */
    func concurrentForEach(withPriority priority: TaskPriority? = nil, operation: @escaping (Element) async -> Void) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    await operation(element)
                }
            }
        }
    }

    /**
     Run an async closure for each element within the sequence.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - operation: The closure to run for each element.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentForEach(withPriority priority: TaskPriority? = nil, _ operation: @escaping (Element) async throws -> Void) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    try await operation(element)
                }
            }

            // Propagate any errors thrown by the group's tasks:
            for try await _ in group {}
        }
    }
}

// MARK: - Map

public extension Sequence {
    /**
     Maps the sequence asynchronously to an array containing the results of mapping the given closure over the sequence’s elements.
     
     - Parameters:
        - transform: A mapping closure. transform accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentMap<T>(_ transform: @escaping (Element) -> T, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        let collection = Array(self)
        var results = Array<T?>(repeating: nil, count: collection.count)
        var completed: [Element] = []
        let lock = DispatchQueue(label: "FZSwiftUtils.concurrentMap")

        DispatchQueue.concurrentPerform(iterations: collection.count) { index in
            let element = collection[index]
            let transformed = transform(element)
            results[index] = transformed
            lock.sync {
                completed.append(element)
                DispatchQueue.main.async {
                    progress?(completed)
                }
                if completed.count == collection.count {
                    DispatchQueue.main.async {
                        completion(results.compactMap { $0 })
                    }
                }
            }
        }
    }
    
    /**
     Maps the sequence asynchronously to an array containing the results of mapping the given keypath element.
     
     - Parameters:
        - keyPath: The keypath to the element.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentMap<T>(_ keyPath: KeyPath<Element, T>, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        concurrentMap({ $0[keyPath: keyPath] }, progress: progress, completion: completion)
    }
}

// MARK: - Map (async)

public extension Sequence {
    /**
     Transform the sequence into an array of new values using an async closure.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
    
    /**
     Transform the sequence into an array of new values mapping each value for the given element keypath.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncMap<T>(_ keyPath: KeyPath<Element, T>) async -> [T] {
        await asyncMap({ $0[keyPath: keyPath] })
    }

    /**
     Transform the sequence into an array of new values using an async closure.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence.
     */
    func concurrentMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async -> T) async -> [T] {
        let tasks = map { element in
            Task(priority: priority) {
                await transform(element)
            }
        }

        return await tasks.asyncMap { task in
            await task.value
        }
    }

    /**
     Transform the sequence into an array of new values using an async closure.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async throws -> T) async throws -> [T] {
        let tasks = map { element in
            Task(priority: priority) {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
    
    /**
     Transform the sequence into an array of new values mapping each value for the given element keypath.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentMap<T>(withPriority priority: TaskPriority? = nil, _ keyPath: KeyPath<Element, T>) async -> [T] {
        await concurrentMap(withPriority: priority, { $0[keyPath: keyPath] })
    }
}

// MARK: - CompactMap

public extension Sequence {
    /**
     Maps the sequence asynchronously to an array containing the non-`nil` results of calling the given transformation with each element of this sequence.
     
     - Parameters:
        - transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentCompactMap<T>(_ transform: @escaping (Element) -> T?, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        let collection = Array(self)
        var results = Array<T?>(repeating: nil, count: collection.count)
        var completed: [Element] = []
        let lock = DispatchQueue(label: "FZSwiftUtils.concurrentCompactMap")
        DispatchQueue.concurrentPerform(iterations: collection.count) { index in
            let element = collection[index]
            let transformed = transform(element)
            results[index] = transformed

            lock.sync {
                completed.append(element)
                DispatchQueue.main.async {
                    progress?(completed)
                }
                if completed.count == collection.count {
                    DispatchQueue.main.async {
                        completion(results.compactMap { $0 })
                    }
                }
            }
        }
    }
    
    /**
     Maps the sequence asynchronously to an array containing the results of mapping the given keypath element.
     
     - Parameters:
        - keyPath: The keypath to the element.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentCompactMap<T>(_ keyPath: KeyPath<Element, T>, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        concurrentCompactMap({ $0[keyPath: keyPath] }, progress: progress, completion: completion)
    }
    
    /**
     Maps the sequence asynchronously to an array containing the non-`nil` results of mapping the given keypath element.
     
     - Parameters:
        - keyPath: The keypath to the element.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentCompactMap<T>(_ keyPath: KeyPath<Element, T?>, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        concurrentCompactMap({ $0[keyPath: keyPath] }, progress: progress, completion: completion)
    }
}

// MARK: - CompactMap (async)

public extension Sequence {
    /**
     Transform the sequence into an array of new values using an async closure that returns optional values. Only the non-`nil` return values will be included in the new array.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncCompactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            guard let value = try await transform(element) else {
                continue
            }

            values.append(value)
        }

        return values
    }
    
    /**
     Transform the sequence into an array of new values mapping each value for the given element keypath.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncCompactMap<T>(_ keyPath: KeyPath<Element, T>) async -> [T] {
        await asyncCompactMap({ $0[keyPath: keyPath] })
    }
    
    /**
     Transform the sequence into an array of new values mapping each non-`nil` value for the given element keypath.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncCompactMap<T>(_ keyPath: KeyPath<Element, T?>) async -> [T] {
        await asyncCompactMap({ $0[keyPath: keyPath] })
    }

    /**
     Transform the sequence into an array of new values using an async closure that returns optional values. Only the non-`nil` return values will be included in the new array.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     */
    func concurrentCompactMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async -> T?) async -> [T] {
        let tasks = map { element in
            Task(priority: priority) {
                await transform(element)
            }
        }

        return await tasks.asyncCompactMap { task in
            await task.value
        }
    }

    /**
     Transform the sequence into an array of new values using an async closure that returns optional values. Only the non-`nil` return values will be included in the new array.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentCompactMap<T>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async throws -> T?) async throws -> [T] {
        let tasks = map { element in
            Task(priority: priority) {
                try await transform(element)
            }
        }

        return try await tasks.asyncCompactMap { task in
            try await task.value
        }
    }
    
    /**
     Transform the sequence into an array of new values mapping each value for the given element keypath.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
        - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
        - keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentCompactMap<T>(withPriority priority: TaskPriority? = nil, _ keyPath: KeyPath<Element, T>) async -> [T] {
        await concurrentCompactMap(withPriority: priority, { $0[keyPath: keyPath] })
    }
    
    /**
     Transform the sequence into an array of new values mapping each non-`nil` value for the given element keypath.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
        - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
        - keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, except for the values that were transformed into `nil`.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentCompactMap<T>(withPriority priority: TaskPriority? = nil, _ keyPath: KeyPath<Element, T?>) async -> [T] {
        await concurrentCompactMap(withPriority: priority, { $0[keyPath: keyPath] })
    }
}

// MARK: - FlatMap

public extension Sequence {
    /**
     Maps the sequence asynchronously to an array containing the concatenated results of calling the given transformation with each element of this sequence.

     - Parameters:
        - transform: A closure that accepts an element of this sequence as its argument and returns a sequence or collection.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentFlatMap<T, S: Sequence<T>>(_ transform: @escaping (Element) -> S, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        let collection = Array(self)
        var resultChunks = Array<S?>(repeating: nil, count: collection.count)
        var completed: [Element] = []
        let lock = DispatchQueue(label: "FZSwiftUtils.concurrentFlatMap")

        DispatchQueue.concurrentPerform(iterations: collection.count) { index in
            let element = collection[index]
            let transformed = transform(element)
            resultChunks[index] = transformed
            lock.sync {
                completed.append(element)
                DispatchQueue.main.async {
                    progress?(completed)
                }
                if completed.count == collection.count {
                    DispatchQueue.main.async {
                        completion(resultChunks.compactMap { $0 }.flatMap { $0 })
                    }
                }
            }
        }
    }
    
    
    /**
     Maps the sequence asynchronously to an array containing the concatenated results of mapping the given keypath element sequence.

     - Parameters:
        - keyPath: The keypath to the element.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentFlatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S>, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        concurrentFlatMap({ $0[keyPath: keyPath] }, progress: progress, completion: completion)
    }
    
    /**
     Maps the sequence asynchronously to an array containing the concatenated results of mapping the given keypath element sequence.

     - Parameters:
        - keyPath: The keypath to the element.
        - progress: The handler with the elements that completed mapping.
        - completion: The completion handler that returns the mapped array.
     */
    func concurrentFlatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S?>, progress: ((_ completed: [Element]) -> ())? = nil, completion: @escaping (([T]) -> ())) {
        concurrentFlatMap({ if let sequence = $0[keyPath: keyPath] { return Array(sequence) } else { return [T]() } }, progress: progress, completion: completion)
    }
}

// MARK: - FlatMap (async)

public extension Sequence {
    /**
     Transform the sequence into an array of new values using an async closure that returns sequences. The returned sequences will be flattened into the array returned from this function.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncFlatMap<T: Sequence>(_ transform: (Element) async throws -> T) async rethrows -> [T.Element] {
        var values = [T.Element]()

        for element in self {
            try await values.append(contentsOf: transform(element))
        }

        return values
    }
    
    /**
     Transform the sequence into an array containing the concatenated results of mapping each element's sequence for the specified element keypath.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncFlatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S>) async -> [T] {
        await asyncFlatMap({ $0[keyPath: keyPath] })
    }
    
    /**
     Transform the sequence into an array containing the concatenated results of mapping each element's non-`nil` sequence for the specified element keypath.

     The closure calls will be performed in order, by waiting for each call to complete before proceeding with the next one. If any of the closure calls throw an error, then the iteration will be terminated and the error rethrown.

     - Parameter keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func asyncFlatMap<T, S: Sequence<T>>(_ keyPath: KeyPath<Element, S?>) async -> [T] {
        await asyncFlatMap({
            if let sequence = $0[keyPath: keyPath] {
                return Array(sequence)
            } else {
                return []
            }
        })
    }

    /**
     Transform the sequence into an array of new values using an async closure that returns sequences. The returned sequences will be flattened into the array returned from this function.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     */
    func concurrentFlatMap<T: Sequence>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async -> T) async -> [T.Element] {
        let tasks = map { element in
            Task(priority: priority) {
                await transform(element)
            }
        }

        return await tasks.asyncFlatMap { task in
            await task.value
        }
    }

    /**
     Transform the sequence into an array of new values using an async closure that returns sequences. The returned sequences will be flattened into the array returned from this function.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - transform: The transform to run on each element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentFlatMap<T: Sequence>(withPriority priority: TaskPriority? = nil, _ transform: @escaping (Element) async throws -> T) async throws -> [T.Element] {
        let tasks = map { element in
            Task(priority: priority) {
                try await transform(element)
            }
        }

        return try await tasks.asyncFlatMap { task in
            try await task.value
        }
    }
    
    /**
     Transform the sequence into an array containing the concatenated results of mapping each element's sequence for the specified element keypath.
     
     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentFlatMap<T, S: Sequence<T>>(withPriority priority: TaskPriority? = nil, _ keyPath: KeyPath<Element, S>) async -> [T] {
        await concurrentFlatMap(withPriority: priority, { $0[keyPath: keyPath] })
    }
    
    /**
     Transform the sequence into an array containing the concatenated results of mapping each element's non-`nil` sequence for the specified element keypath.

     The closure calls will be performed concurrently, but the call to this function won't return until all of the closure calls have completed. If any of the closure calls throw an error, then the first error will be rethrown once all closure calls have completed.

     - Parameters:
       - priority: Any specific `TaskPriority` to assign to the async tasks that will perform the closure calls. The default is `nil` (meaning that the system picks a priority).
       - keyPath: The keypath of the element.
     - Returns: The transformed values as an array. The order of the transformed values will match the original sequence, with the results of each closure call appearing in-order within the returned array.
     - Throws: Rethrows any error thrown by the passed closure.
     */
    func concurrentFlatMap<T, S: Sequence<T>>(withPriority priority: TaskPriority? = nil, _ keyPath: KeyPath<Element, S?>) async -> [T] {
        await concurrentFlatMap(withPriority: priority, {
            if let sequence = $0[keyPath: keyPath] {
                return Array(sequence)
            } else {
                return []
            }
        })
    }
}

/*
#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension Collection {
    /* Transform the sequence into an array of new values asynchronously amd returning it a completionHandler.
     */
    func asyncMap<R>(_ block: (Element, @escaping (R) -> Void) -> Void, completion: @escaping ([R]) -> Void) {
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        var results = [R?](repeating: nil, count: count)
        for (index, object) in enumerated() {
            group.enter()
            block(object) { result in
                semaphore.wait()
                results[index] = result
                semaphore.signal()
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global(qos: .default)) {
            completion(results as! [R])
        }
    }

    /* Transform the sequence into an array of new values asynchronously amd returning it a completionHandler.
     */
    func asyncCompactMap<R>(_ block: (Element, @escaping (R?) -> Void) -> Void, completion: @escaping ([R]) -> Void) {
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        var results = [R?](repeating: nil, count: count)
        for (index, object) in enumerated() {
            group.enter()
            block(object) { result in
                guard let result = result else {
                    group.leave()
                    return
                }
                semaphore.wait()
                results[index] = result
                semaphore.signal()
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global(qos: .default)) {
            completion(results.compactMap { $0 })
        }
    }
}
*/
