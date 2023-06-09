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
     - Parameters completionHandler: The handler which gets called when all elements got collected.
     */
    func collect(completionHandler: @escaping ([Element]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let elements = reduce(into: [Element]()) { $0.append($1) }
            DispatchQueue.main.async {
                completionHandler(elements)
            }
        }
    }
}

public extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }

    func collect(completionHandler: @escaping ([Element]) -> Void) throws {
        Task {
            let elements = try await collect()
            completionHandler(elements)
        }
    }

    func collect() throws -> [Element] {
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            let elements = try await collect()
            return elements
        }
        semaphore.wait()
        return []
    }
}
