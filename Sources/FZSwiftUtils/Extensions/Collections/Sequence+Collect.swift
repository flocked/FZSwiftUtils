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
        reduce(into: []) { $0.append($1) }
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
    func collect(completion: @escaping ([Element]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let elements: [Element] = reduce(into: []) { $0.append($1) }
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
     Returns an array of all elements to the specified completion handler.

     - Parameter completion: The handler that is called when all elements have been collected.
     */
    func collect(completion: @escaping (_ result: Result<[Element], Error>) -> Void) {
        Task {
            do {
                completion(.success(try await collect()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Returns an array of all elements.
    func collect() throws -> [Element] {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[Element], Error>?
        collect {
            result = $0
            semaphore.signal()
        }
        semaphore.wait()
        return try result!.get()
    }
}
