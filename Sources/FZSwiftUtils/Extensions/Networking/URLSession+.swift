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
     Creates a download task to resume a previously canceled or failed download with the specified resume data and `URL` request object.

     - Parameters:
        - resumeData: The data necessary to resume a download.
        - request: The custom request to set for the download task.
     - Returns: The new session download task.
     */
    func downloadTask(withResumeData resumeData: Data, request: URLRequest) -> URLSessionDownloadTask {
        let downloadTask = downloadTask(withResumeData: resumeData)
        downloadTask.setRequest(request)
        return downloadTask
    }

    /**
     Returns the response for the specified URL

     A HEAD request retrieves the same response headers that would be returned by a GET request, but does not include the response body. This allows callers to inspect metadata such as the content type, expected content length, and other headers without downloading the resource.

     - Parameters:
        - request: The `URL` request of the remote resource whose response headers should be retrieved.
        - completion: A closure called with the resulting response, or an error if the request fails.
     - Returns: The data task that retrieves the response.
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
     Loads the response headers for the specified request using an HTTP HEAD request.

     - Parameter request: The request whose response headers should be retrieved.
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
     Creates a task that retrieves the data of a URL based on the specified URL request, and calls a handler upon completion.

     - Parameters:
        - request: An `URL` request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - completion: The completion handler that is called with the data, or an error if the image couldn't be retrieved.
     - Returns: The data task that retrieves the data.
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
     Loads the contents of the specified request.

     - Parameter request: The request whose contents should be retrieved.
     - Returns: The data returned by the server.
     - Throws: An error if the request fails or no data is returned.
     */
    func data(for request: URLRequest) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            data(for: request) {
                continuation.resume(with: $0)
            }
        }
    }

    /**
     Creates a task that retrieves the string of a URL based on the specified URL request, and calls a handler upon completion.

     - Parameters:
        - request: An `URL` request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - encoding: The encoding of the string.
        - completion: The completion handler that is called with the html string, or an error if the string couldn't be retrieved.
     - Returns: The data task that retrieves the string.
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
     Loads the contents of the specified request and decodes the result as a string.

     - Parameters:
       - request: The request whose contents should be retrieved.
       - encoding: The encoding used to decode the response data.
     - Returns: A string created from the response data.
     - Throws: An error if the request fails or the data cannot be decoded as `String` using the specified encoding.
     */
    func string(for request: URLRequest, encoding: String.Encoding = .utf8) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            string(for: request, encoding: encoding) {
                continuation.resume(with: $0)
            }
        }
    }

    /**
     Creates a task that retrieves the decodable type from JSON of a URL based on the specified URL request, and calls a handler upon completion.

     - Parameters:
        - request: An `URL` request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - decoder: The JSON decoder that decodes the content of the URL.
        - completion: The completion handler that is called with the decodable type, or an error if the type couldn't be retrieved.
     - Returns: The data task that retrieves the decodable type.
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
     Loads the contents of the specified request and decodes the result into the specified type.

     - Parameters:
       - request: The request whose contents should be retrieved.
       - type: The type to decode from the response data.
       - decoder: The decoder used to decode the response data.
     - Returns: An instance of the specified type.
     - Throws: An error if the request fails or the response data cannot be decoded.
     */
    func decodedObject<Value: Decodable>(for request: URLRequest, as type: Value.Type = Value.self, decoder: JSONDecoder = JSONDecoder()) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            decodedObject(for: request, as: type, decoder: decoder) {
                continuation.resume(with: $0)
            }
        }
    }

    /**
     Creates a task that retrieves the decodable type from JSON of a URL based on the specified URL request, and calls a handler upon completion.

     - Parameters:
        - request: An `URL` request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - dateDecodingStrategy: The strategy that the JSON deooder should use to decode dates.
        - keyDecodingStrategy: The strategy that the JSON decoder should use to decode keys.
        - dataDecodingStrategy: The strategy that the JSON decoder should use to decode raw data.
        - completion: The completion handler that is called with the decodable type, or an error if the type couldn't be retrieved.
     - Returns: The data task that retrieves the decodable type.
     */
    @discardableResult
    func decodedObject<Value: Decodable>(for request: URLRequest, as type: Value.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, completion: @escaping (_ result: Result<Value, Error>) -> ()) -> URLSessionDataTask {
        decodedObject(for: request, as: type, decoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy), completion: completion)
    }
    
    /**
     Loads the contents of the specified request and decodes the result into the specified type.

     - Parameters:
       - request: The request whose contents should be retrieved.
       - type: The type to decode from the response data.
       - dateDecodingStrategy: The strategy used to decode date values.
       - keyDecodingStrategy: The strategy used to decode keyed values.
       - dataDecodingStrategy: The strategy used to decode data values.
     - Returns: An instance of the specified type.
     - Throws: An error if the request fails or the response data cannot be decoded.
     */
    func decodedObject<Value: Decodable>(for request: URLRequest, as type: Value.Type = Value.self, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            decodedObject(for: request, as: type, dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy) {
                continuation.resume(with: $0)
            }
        }
    }
    
    #if os(macOS) || canImport(UIKit)
    /**
     Creates a task that retrieves the image of a URL based on the specified URL request, and calls a handler upon completion.

     - Parameters:
        - request: An `URL` request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - completion: The completion handler that is called with the image, or an error if the image couldn't be retrieved.
     - Returns: The data task that retrieves the image.
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
     Loads an image using the specified request.

     - Parameter request: The request used to retrieve the image.
     - Returns: An image created from the downloaded data.
     - Throws: A ``URLSessionError`` if the response does not contain a valid image or returns an unsuccessful status code.
     */
    func image(for request: URLRequest) async throws -> NSUIImage {
        try await withCheckedThrowingContinuation { continuation in
            image(for: request) {
                continuation.resume(with: $0)
            }
        }
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
