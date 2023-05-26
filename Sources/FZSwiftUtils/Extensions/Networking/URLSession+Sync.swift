//
//  File.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension URLSession {
    internal enum Errors: Error {
        case downloadError
    }

    func downloadTask(with request: URLRequest) throws -> (location: URL, response: URLResponse?) {
        var location: URL?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)
        let downloadTask = self.downloadTask(with: request) {
            location = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        downloadTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        if let error = error {
            throw error
        }
        guard let location = location else { throw Errors.downloadError }
        return (location, response)
    }

    func dataTask(with request: URLRequest) throws -> (data: Data, response: URLResponse?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: request) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        if let error = error {
            throw error
        }
        guard let data = data else { throw Errors.downloadError }
        return (data, response)
    }
}
