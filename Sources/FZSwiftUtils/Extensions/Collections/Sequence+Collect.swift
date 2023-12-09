//
//  Sequence+Collect.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation

public extension Sequence {
    /// Returns an array of all elements.
    func collect() -> [Element] {
        return reduce(into: [Element]()) { $0.append($1) }
    }

    /// Returns an array of all elements.
    func collect() async -> [Element] {
        await withCheckedContinuation { continuation in
            collect { continuation.resume(returning: $0) }
        }
    }

    /**
     Returns an array of all elements to the specified completion handler
     
     - Parameter completion: The handler which gets called when all elements got collected.
     */
    func collect(completion: @escaping ([Element]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let elements = reduce(into: [Element]()) { $0.append($1) }
            DispatchQueue.main.async {
                completion(elements)
            }
        }
    }
}

public extension AsyncSequence {
    /// Returns an array of all elements.
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }

    /**
     Returns an array of all elements to the specified completion handler
     
     - Parameter completion: The handler which gets called when all elements got collected.
     */
    func collect(completion: @escaping ([Element]) -> Void) throws {
        Task {
            let elements = try await collect()
            completion(elements)
        }
    }

    /// Returns an array of all elements.
    func collect() throws -> [Element] {
        let semaphore = DispatchSemaphore(value: 0)
        var elements: [Element] = []
        try collect(completion: { ele in
            elements = ele
            semaphore.signal()
        })
        semaphore.wait()
        return elements
    }
}
