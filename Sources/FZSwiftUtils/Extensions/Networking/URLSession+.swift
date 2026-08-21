//
//  URLSession+.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension URLSession {
    /**
     Creates a download task that resumes a canceled or failed download with custom request information.

     - Parameters:
       - resumeData: The resume data from a previously canceled or failed download.
       - request: The request to associate with the download task.
     - Returns: A new download task.
     */
    func downloadTask(withResumeData resumeData: Data, request: URLRequest) -> URLSessionDownloadTask {
        let downloadTask = downloadTask(withResumeData: resumeData)
        downloadTask.setRequest(request)
        return downloadTask
    }

    /**
     Creates and starts a task that retrieves the response for the specified request using the HTTP `HEAD` method.

     A `HEAD` request retrieves the same response headers that a `GET` request would return, without downloading the response body.

     - Parameters:
       - request: The request for the resource whose response headers you want to retrieve.
       - completion: The completion handler to call with the response, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func headResponse(for request: URLRequest, completion: @escaping (_ result: Result<URLResponse, Error>) -> ()) -> URLSessionDataTask {
        let task = dataTask(with: request.copy(as: .head)) { _, response, error in
            if let error {
                completion(.failure(error))
            } else if let response = response {
                completion(.success(response))
            } else {
                completion(.failure(URLSessionError.missingResponse))
            }
        }
        task.resume()
        return task
    }

    /**
     Creates and starts a task that retrieves the response for the specified URL using the HTTP `HEAD` method.

     - Parameters:
       - url: The URL for the resource whose response headers you want to retrieve.
       - completion: The completion handler to call with the response, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func headResponse(for url: URL, completion: @escaping (_ result: Result<URLResponse, Error>) -> ()) -> URLSessionDataTask {
        headResponse(for: URLRequest(url: url), completion: completion)
    }

    /**
     Retrieves the response for the specified request using the HTTP `HEAD` method.

     - Parameter request: The request for the resource whose response headers you want to retrieve.
     - Returns: The response returned by the server.
     - Throws: An error if the request fails or no response is returned.
     */
    func headResponse(for request: URLRequest) async throws -> URLResponse {
        try await withCheckedThrowingContinuation { continuation in
            headResponse(for: request) {
                continuation.resume(with: $0)
            }
        }
    }

    /**
     Retrieves the response for the specified URL using the HTTP `HEAD` method.

     - Parameter url: The URL for the resource whose response headers you want to retrieve.
     - Returns: The response returned by the server.
     - Throws: An error if the request fails or no response is returned.
     */
    func headResponse(for url: URL) async throws -> URLResponse {
        try await headResponse(for: URLRequest(url: url))
    }

    /**
     Creates and starts a task that retrieves data for the specified request.

     - Parameters:
       - request: The request that provides the URL, cache policy, HTTP method, and other loading information.
       - completion: The completion handler to call with the retrieved data, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func data(for request: URLRequest, completion: @escaping (_ result: Result<Data, Error>) -> ()) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let httpResponse = response?.http, !httpResponse.isSuccessful {
                completion(.failure(URLSessionError.invalidStatusCode(httpResponse.statusCode)))
                return
            }
            guard let data, !data.isEmpty else {
                completion(.failure(URLSessionError.noData))
                return
            }
            completion(.success(data))
        }
        task.resume()
        return task
    }

    /**
     Creates and starts a task that retrieves data from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - completion: The completion handler to call with the retrieved data, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func data(for url: URL, completion: @escaping (_ result: Result<Data, Error>) -> ()) -> URLSessionDataTask {
        data(for: URLRequest(url: url), completion: completion)
    }

    /**
     Creates and starts a task that retrieves and decodes a string for the specified request.

     - Parameters:
       - request: The request that provides the URL, cache policy, HTTP method, and other loading information.
       - encoding: The string encoding to use when decoding the response data.
       - completion: The completion handler to call with the decoded string, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func string(for request: URLRequest, encoding: String.Encoding = .utf8, completion: @escaping (_ result: Result<String, Error>) -> ()) -> URLSessionDataTask {
        data(for: request) { result in
            guard let data = result.value else {
                completion(.failure(result.error!))
                return
            }
            guard let string = String(data: data, encoding: encoding) else {
                completion(.failure(URLSessionError.noString))
                return
            }
            completion(.success(string))
        }
    }

    /**
     Creates and starts a task that retrieves and decodes a string from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - encoding: The string encoding to use when decoding the response data.
       - completion: The completion handler to call with the decoded string, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func string(for url: URL, encoding: String.Encoding = .utf8, completion: @escaping (_ result: Result<String, Error>) -> ()) -> URLSessionDataTask {
        string(for: URLRequest(url: url), encoding: encoding, completion: completion)
    }

    /**
     Retrieves and decodes a string for the specified request.

     - Parameters:
       - request: The request to retrieve.
       - encoding: The string encoding to use when decoding the response data.
     - Returns: A string created from the response data.
     - Throws: An error if the request fails or the data can't be decoded as a string.
     */
    func string(for request: URLRequest, encoding: String.Encoding = .utf8) async throws -> String {
        guard let string = try String(data: (await data(for: request)).0, encoding: .utf8) else {
            throw URLSessionError.noString
        }
        return string
    }

    /**
     Retrieves and decodes a string from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - encoding: The string encoding to use when decoding the response data.
     - Returns: A string created from the response data.
     - Throws: An error if the request fails or the data can't be decoded as a string.
     */
    func string(for url: URL, encoding: String.Encoding = .utf8) async throws -> String {
        try await string(for: URLRequest(url: url), encoding: encoding)
    }

    /**
     Creates and starts a task that retrieves and parses JSON for the specified request.

     - Parameters:
       - request: The request that provides the URL, cache policy, HTTP method, and other loading information.
       - completion: The completion handler to call with the parsed JSON object, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func json(for request: URLRequest, completion: @escaping (_ result: Result<Any, Error>) -> ()) -> URLSessionDataTask {
        data(for: request) { result in
            guard let data = result.value else {
                completion(.failure(result.error!))
                return
            }
            do {
                try completion(.success(JSONSerialization.jsonObject(with: data, options: [])))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /**
     Creates and starts a task that retrieves and parses JSON from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - completion: The completion handler to call with the parsed JSON object, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func json(for url: URL, completion: @escaping (_ result: Result<Any, Error>) -> ()) -> URLSessionDataTask {
        json(for: URLRequest(url: url), completion: completion)
    }

    /**
     Retrieves and parses JSON for the specified request.

     - Parameter request: The request to retrieve.
     - Returns: The parsed JSON object.
     - Throws: An error if the request fails or the response data can't be parsed as JSON.
     */
    func json(for request: URLRequest) async throws -> Any {
        try JSONSerialization.jsonObject(with: (await data(for: request)).0, options: [])
    }

    /**
     Retrieves and parses JSON from the specified URL.

     - Parameter url: The URL to retrieve.
     - Returns: The parsed JSON object.
     - Throws: An error if the request fails or the response data can't be parsed as JSON.
     */
    func json(for url: URL) async throws -> Any {
        try await json(for: URLRequest(url: url))
    }

    /**
     Creates and starts a task that retrieves and decodes a value for the specified request.

     - Parameters:
       - request: The request that provides the URL, cache policy, HTTP method, and other loading information.
       - type: The type to decode from the response data.
       - decoder: The decoder to use when decoding the response data.
       - completion: The completion handler to call with the decoded value, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func decodedObject<Value: Decodable>(for request: URLRequest, as type: Value.Type, decoder: JSONDecoder, completion: @escaping (_ result: Result<Value, Error>) -> ()) -> URLSessionDataTask {
        data(for: request) { result in
            guard let data = result.value else {
                completion(.failure(result.error!))
                return
            }
            do {
                try completion(.success(decoder.decode(Value.self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /**
     Creates and starts a task that retrieves and decodes a value from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - type: The type to decode from the response data.
       - decoder: The decoder to use when decoding the response data.
       - completion: The completion handler to call with the decoded value, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func decodedObject<Value: Decodable>(for url: URL, as type: Value.Type, decoder: JSONDecoder, completion: @escaping (_ result: Result<Value, Error>) -> ()) -> URLSessionDataTask {
        decodedObject(for: URLRequest(url: url), as: type, decoder: decoder, completion: completion)
    }

    /**
     Retrieves and decodes a value for the specified request.

     - Parameters:
       - request: The request to retrieve.
       - type: The type to decode from the response data.
       - decoder: The decoder to use when decoding the response data.
     - Returns: A decoded value of the specified type.
     - Throws: An error if the request fails or the response data can't be decoded.
     */
    func decodedObject<Value: Decodable>(for request: URLRequest, as type: Value.Type = Value.self, decoder: JSONDecoder = JSONDecoder()) async throws -> Value {
        try decoder.decode(Value.self, from: (await data(for: request)).0)
    }

    /**
     Retrieves and decodes a value from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - type: The type to decode from the response data.
       - decoder: The decoder to use when decoding the response data.
     - Returns: A decoded value of the specified type.
     - Throws: An error if the request fails or the response data can't be decoded.
     */
    func decodedObject<Value: Decodable>(for url: URL, as type: Value.Type = Value.self, decoder: JSONDecoder = JSONDecoder()) async throws -> Value {
        try await decodedObject(for: URLRequest(url: url), as: type, decoder: decoder)
    }

    #if os(macOS) || canImport(UIKit)
    /**
     Creates and starts a task that retrieves and decodes an image for the specified request.

     - Parameters:
       - request: The request that provides the URL, cache policy, HTTP method, and other loading information.
       - completion: The completion handler to call with the decoded image, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func image(for request: URLRequest, completion: @escaping (_ result: Result<NSUIImage, Error>) -> ()) -> URLSessionDataTask {
        data(for: request) { result in
            guard let data = result.value else {
                completion(.failure(result.error!))
                return
            }
            guard let image = NSUIImage(data: data) else {
                completion(.failure(URLSessionError.invalidImageData))
                return
            }
            completion(.success(image))
        }
    }

    /**
     Creates and starts a task that retrieves and decodes an image from the specified URL.

     - Parameters:
       - url: The URL to retrieve.
       - completion: The completion handler to call with the decoded image, or an error if the request fails.
     - Returns: The started data task.
     */
    @discardableResult
    func image(for url: URL, completion: @escaping (_ result: Result<NSUIImage, Error>) -> ()) -> URLSessionDataTask {
        image(for: URLRequest(url: url), completion: completion)
    }

    /**
     Retrieves and decodes an image for the specified request.

     - Parameter request: The request to retrieve.
     - Returns: An image created from the response data.
     - Throws: An error if the request fails or the response data can't be decoded as an image.
     */
    func image(for request: URLRequest) async throws -> NSUIImage {
        guard let image = try NSUIImage(data: (await data(for: request)).0) else {
            throw URLSessionError.invalidImageData
        }
        return image
    }

    /**
     Retrieves and decodes an image from the specified URL.

     - Parameter url: The URL to retrieve.
     - Returns: An image created from the response data.
     - Throws: An error if the request fails or the response data can't be decoded as an image.
     */
    func image(for url: URL) async throws -> NSUIImage {
        try await image(for: URLRequest(url: url))
    }

    private enum URLSessionError: LocalizedError {
        case noData
        case noString
        case invalidImageData
        case invalidStatusCode(Int)
        case missingResponse

        public var errorDescription: String? {
            switch self {
            case .noData:
                "The response did not contain any data."
            case .noString:
                "The response data could not be decoded as a string."
            case .invalidImageData:
                "The response data could not be decoded as an image."
            case .invalidStatusCode(let statusCode):
                "The server returned an invalid HTTP status code (\(statusCode))."
            case .missingResponse:
                "The request completed without returning a response."
            }
        }

        public var failureReason: String? {
            switch self {
            case .noData:
                "No response body was returned."
            case .noString:
                "The data is not valid text."
            case .invalidImageData:
                "The data is not a valid image format."
            case .invalidStatusCode:
                "The request was not successful."
            case .missingResponse:
                "Neither a response nor an error was returned by the URL loading system."
            }
        }
    }
    #endif
}
