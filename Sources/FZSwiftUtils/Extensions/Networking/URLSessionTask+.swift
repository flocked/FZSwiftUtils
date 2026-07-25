//
//  URLSessionTask+.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import Foundation

public extension URLSessionTask {
    /**
     Sets a custom URL request for the URLSessionTask.

     - Parameter request: The custom URL request to set.
     */
    func setRequest(_ request: URLRequest) {
        guard state == .suspended else { return }
        setValue(safely: request, forKeyPath: "originalRequest")
        setValue(safely: request, forKeyPath: "currentRequest")
    }

    /// The expected length of the content.
    var expectedContentLength: Int64? {
        var fileSize = countOfBytesExpectedToReceive
        if fileSize < 1 {
            fileSize = response?.expectedContentLength ?? fileSize
        }
        guard fileSize > 0 else { return nil }
        return fileSize
    }
    
    /// The expected content size.
    var expectedContentSize: DataSize? {
        guard let bytes = expectedContentLength else { return nil }
        return .bytes(bytes)
    }
    
    /// Sets the relative priority at which you’d like a host to handle the task, specified as a floating point value between 0.0 (lowest priority) and 1.0 (highest priority).
    @discardableResult
    func priority(_ priority: Float) -> Self {
        self.priority = priority
        return self
    }

    /// Sets the app-provided string value for the current task.
    @discardableResult
    func taskDescription(_ description: String?) -> Self {
        self.taskDescription = description
        return self
    }

    /// Sets the earliest date at which the network load should begin.
    @discardableResult
    func earliestBeginDate(_ date: Date?) -> Self {
        self.earliestBeginDate = date
        return self
    }

    /// Sets the delegate specific to the task.
    @discardableResult
    func delegate(_ delegate: (any URLSessionTaskDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }

    /// Sets the best-guess upper bound on the number of bytes the client expects to receive.
    @discardableResult
    func countOfBytesClientExpectsToReceive(_ count: Int64) -> Self {
        self.countOfBytesClientExpectsToReceive = count
        return self
    }

    /// Sets the best-guess upper bound on the number of bytes the client expects to send.
    @discardableResult
    func countOfBytesClientExpectsToSend(_ count: Int64) -> Self {
        self.countOfBytesClientExpectsToSend = count
        return self
    }

    /// Sets the Boolean value indicating whether the task prefers incremental deleviery.
    @discardableResult
    func prefersIncrementalDelivery(_ prefers: Bool) -> Self {
        self.prefersIncrementalDelivery = prefers
        return self
    }
}
