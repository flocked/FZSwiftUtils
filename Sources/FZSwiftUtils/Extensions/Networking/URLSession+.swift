//
//  URLSession+.swift
//
//
//  Created by Florian Zand on 01.03.23.
//

import Foundation
import UniformTypeIdentifiers

public extension URLSession {
    /**
     Creates a download task to resume a previously canceled or failed download with the specified URL request object and saves the results to a file.
     Creates a download task with resume data and sets a custom request for the task.

     - Parameters:
        - resumeData: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
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
       - url: The URL of the remote resource whose response headers should be retrieved.
       - completion: A closure called with the resulting response, or an error if the request fails.
     - Returns: The data task that retrieves the response.
     */
    @discardableResult
    func headResponse(for request: URLRequest, completion: @escaping (Result<URLResponse, Error>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: request.copy(as: .head)) { _, response, error in
            if let error {
                completion(.failure(error))
            } else if let response = response {
                completion(.success(response))
            } else {
                completion(.failure(URLError(.badServerResponse)))
            }
        }
        task.resume()
        return task
    }
    
    /**
     Returns the response for the specified URL
     
     A HEAD request retrieves the same response headers that would be returned by a GET request, but does not include the response body. This allows callers to inspect metadata such as the content type, expected content length, and other headers without downloading the resource.

     - Parameter url: The URL of the remote resource whose response headers should be retrieved.
     */
    func headResponse(for request: URLRequest) async throws -> URLResponse {
        try await withCheckedThrowingContinuation { continuation in
            headResponse(for: request) { continuation.resume(with: $0) }
        }
    }
}

extension URLSession {
    /**
     Creates a task that retrieves the html string of a URL based on the specified URL request, and calls a handler upon completion.
     
     - Parameters:
        - request: An URL request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - completion: The completion handler that is called with the html string, or an error if the html string couldn't be retrieved.
     - Returns: The data task that retrieves the html string.
     */
    @discardableResult
    func htmlString(for request: URLRequest, completion: @escaping (Result<String, Error>)->()) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in
            guard let response = response else {
                completion(.failure(NetworkError(.invalidResponse)))
                return
            }
            guard response.http?.isSuccessful == true else {
                completion(.failure(NetworkError(.badStatusCode)))
                return
            }
            guard response.contentType == .html else {
                completion(.failure(NetworkError(.invalidContentType)))
                return
            }
            guard let data = data, let string = String(data: data, encoding: .utf8) else {
                completion(.failure(NetworkError(.contentDecodingFailed)))
                return
            }
            completion(.success(string))
        }
        task.resume()
        return task
    }
    
    /**
     Creates a task that retrieves the decodable type from JSON of a URL based on the specified URL request, and calls a handler upon completion.
     
     - Parameters:
        - request: An URL request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - decoder: The JSON decoder that decodes the content of the URL.
        - completion: The completion handler that is called with the decodable type, or an error if the type couldn't be retrieved.
     - Returns: The data task that retrieves the decodable type.
     */
    @discardableResult
    func decodeJSON<D: Decodable>(for request: URLRequest, type: D.Type, decoder: JSONDecoder, completion: @escaping (Result<D, Error>)->()) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in
            guard let response = response else {
                completion(.failure(NetworkError(.invalidResponse)))
                return
            }
            guard response.http?.isSuccessful == true else {
                completion(.failure(NetworkError(.badStatusCode)))
                return
            }
            guard response.contentType == .json else {
                completion(.failure(NetworkError(.invalidContentType)))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError(.contentDecodingFailed)))
                return
            }
            do {
                completion(.success(try decoder.decode(D.self, from: data)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
        return task
    }
    
    /**
     Creates a task that retrieves the decodable type from JSON of a URL based on the specified URL request, and calls a handler upon completion.
     
     - Parameters:
        - request: An URL request that provides the URL, cache policy, request type, body data or body stream, and so on.
        - dateDecodingStrategy: The strategy that the JSON deooder should use to decode dates.
        - keyDecodingStrategy: The strategy that the JSON decoder should use to decode keys.
        - dataDecodingStrategy: The strategy that the JSON decoder should use to decode raw data.
        - completion: The completion handler that is called with the decodable type, or an error if the type couldn't be retrieved.
     - Returns: The data task that retrieves the decodable type.
     */
    @discardableResult
    func decodeJSON<D: Decodable>(for request: URLRequest, type: D.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64, completion: @escaping (Result<D, Error>)->()) -> URLSessionDataTask {
        decodeJSON(for: request, type: type, decoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy), completion: completion)
    }
}
