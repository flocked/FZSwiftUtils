//
//  URL+Redirect.swift
//
//
//  Created by Florian Zand on 09.12.22.
//

import Foundation

public extension URL {
    /**
     Retrieves the redirected URL for the current URL.

     - Throws: An error if the redirection process fails.
     - Returns: The redirected URL if available, `nil` otherwise.
     */
    func redirectedURL() throws -> URL? {
        var redirectedURL: URL?
        var error: Error?
        

        let semaphore = DispatchSemaphore(value: 0)
        self.redirectedURL {
            redirectedURL = $0
            error = $1
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)

        if let error = error {
            throw error
        }

        return redirectedURL
    }

    /**
     Retrieves the redirected URL for the current URL asynchronously.

     - Parameters:
        - completionHandler: A closure to be called with the redirected URL or an error.
     */
    func redirectedURL(complectionHandler: @escaping ((URL?, Error?) -> Void)) {
            let request = URLRequest(url: self)
            URLSession.shared.dataTask(with: request, completionHandler: { _, response, error in
                if let httpResponse = response as? HTTPURLResponse, let location = httpResponse.allHeaderFields["Location"] as? String, let locationURL = URL(string: location) {
                    complectionHandler(locationURL, error)
                }
            })
    }

    /**
     Retrieves the redirected URL for the current URL asynchronously.

     - Throws: An error if the redirection process fails.
     - Returns: The redirected URL if available, `nil` otherwise.
     */
    func redirectedURL() async throws -> URL? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                redirectedURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: url)
                    }
                }
            }
        } catch {
            return nil
        }
    }
}
