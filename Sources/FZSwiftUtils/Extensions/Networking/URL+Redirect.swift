//
//  URLRedirect.swift
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
        try URLRedirection.redirectedURL(for: self)
    }
    
    /**
     Retrieves the redirected URL for the current URL asynchronously.
     
     - Parameters:
        - completionHandler: A closure to be called with the redirected URL or an error.
     */
    func redirectedURL(complectionHandler: @escaping ((URL?, Error?) -> ())) {
        URLRedirection.redirectedURL(for: self, completionHandler: complectionHandler)
    }
}

/**
 A class for receiving URL redirections.
 */
public class URLRedirection: NSObject, URLSessionTaskDelegate {
    
    /// The shared instance of `URLRedirection`.
    public static let shared: URLRedirection = {
        let instance = URLRedirection()
        return instance
    }()
    
    /// The URL session used for handling the redirection.
    internal lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    /**
     Retrieves the redirected URL for the specified URL asynchronously.
     
     - Parameters:
        - url: The original URL to be redirected.
        - completionHandler: A closure to be called with the redirected URL or an error.
     */
    public static func redirectedURL(for url: URL, completionHandler: @escaping (URL?, Error?) -> ()) {
        let request = URLRequest(url: url)
        
        let task = Self.shared.session.dataTask(with: request, completionHandler: { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, let location = httpResponse.allHeaderFields["Location"] as? String, let locationURL = URL(string: location) {
                completionHandler(locationURL, error)
            } else {
                completionHandler(nil, error)
            }
        })
        task.resume()
    }

    /**
     Retrieves the redirected URL for the specified URL synchronously.
     
     - Parameters:
        - url: The original URL to be redirected.
     
     - Throws: An error if the redirection process fails.
     
     - Returns: The redirected URL if available, `nil` otherwise.
     */
    public static func redirectedURL(for url: URL) throws -> URL? {
        var redirectedURL: URL?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)

        Self.redirectedURL(for: url) {
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
}
