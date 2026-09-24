//
//  SynchronizedStorage.swift
//
//
//  Created by Florian Zand on 23.09.26.
//

import Foundation

final class SynchronizedStorage<Value> {
    private let backend: any StorageBackend<Value>
    let usesMutex: Bool

    init(_ value: consuming Value, usingMutex: Bool = false) {
        usesMutex = usingMutex
        if usingMutex {
            backend = MutexBackend(value)
        } else {
            backend = QueueBackend(value)
        }
    }

    func read<Result>(_ body: (borrowing Value) throws -> Result) rethrows -> Result {
        try backend.read(body)
    }

    func write<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        try backend.write(body)
    }

    private final class MutexBackend: StorageBackend {
        private let mutex: Mutex<Value>

        init(_ value: consuming Value) {
            mutex = Mutex(value)
        }

        func read<Result>(_ body: (borrowing Value) throws -> Result) rethrows -> Result {
            try mutex.withLock { try body($0) }
        }

        func write<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
            try mutex.withLock { try body(&$0) }
        }
    }

    private final class QueueBackend: StorageBackend {
        private let queue = DispatchQueue(label: "com.FZSwiftUtils.SynchronizedStorage", attributes: .concurrent)
        private var value: Value

        init(_ value: consuming Value) {
            self.value = value
        }

        func read<Result>(_ body: (borrowing Value) throws -> Result) rethrows -> Result {
            try queue.sync { try body(value) }
        }

        func write<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
            try queue.sync(flags: .barrier) { try body(&value) }
        }
    }
}

fileprivate protocol StorageBackend<Value> {
    associatedtype Value

    func read<Result>(_ body: (borrowing Value) throws -> Result) rethrows -> Result
    func write<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result
}
