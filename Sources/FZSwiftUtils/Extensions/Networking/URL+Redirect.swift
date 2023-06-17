//
//  URLRedirect.swift
//  Recurbate
//
//  Created by Florian Zand on 09.12.22.
//

import Foundation

public extension URL {
    func redirectedURL() throws -> URL? {
        try URLRedirection.redirectedURL(for: self)
    }
    
    func redirectedURL(complectionHandler: @escaping ((URL?, Error?) -> ())) {
        URLRedirection.redirectedURL(for: self, completionHandler: complectionHandler)
    }
}

public class URLRedirection: NSObject, URLSessionTaskDelegate {
    static let shared: URLRedirection = {
        let instance = URLRedirection()
        return instance
    }()
    
    
    internal lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    
    public static func redirectedURL(for url: URL, completionHandler: @escaping (URL?, Error?)->()) {
        
        let request = URLRequest(url: url)
        
        let task = Self.shared.session.dataTask(with: request, completionHandler: { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, let location = httpResponse.allHeaderFields["Location"] as? String, let locationURL = URL(string: location) {
                completionHandler(locationURL, error)
                
                completionHandler(locationURL, error)
            } else {
                completionHandler(nil, error)
            }
        })
        task.resume()
    }

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
