//
//  URLSession+Sync.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import Foundation

public extension URLSession {
    /**
     Downloads a file from the request.

     - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
     - Throws: Throws when the file couln't be downloaded.
     - Returns: Returns the location of the downloaded file and the response metadata. The file is temporarly saved at the location and should be copied.
     */
    func downloadFile(with request: URLRequest) throws -> (location: URL, response: URLResponse?) {
        var location: URL?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)
        let downloadTask = downloadTask(with: request) {
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
        guard let location = location else { throw DownloadErrors.noFile }
        return (location, response)
    }

    /**
     Downloads data from the request.

     - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
     - Throws: Throws when the data couln't be downloaded.
     - Returns: Returns the downloaded data  and the response metadata.
     */
    func downloadData(with request: URLRequest) throws -> (data: Data, response: URLResponse?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = dataTask(with: request) {
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
        guard let data = data else { throw DownloadErrors.noData }
        return (data, response)
    }
    
    /// Download Errors.
    fileprivate enum DownloadErrors: LocalizedError {
        case noFile
        case noData

        public var errorDescription: String? {
            switch self {
            case .noFile: return "The file could not be downloaded."
            case .noData: return "No data was received from the server."
            }
        }

        public var failureReason: String? {
            switch self {
            case .noFile: return "The download task completed without providing a file location."
            case .noData: return "The data task completed without providing any data."
            }
        }
    }
}
