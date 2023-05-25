//
//  URLRedirect.swift
//  Recurbate
//
//  Created by Florian Zand on 09.12.22.
//

import Foundation

public extension URL {
    func redirectedURL(complectionHandler: @escaping ((URL?, Error?)->())) {
        URLRedirect.shared.redirectedURL(for: self, complectionHandler: complectionHandler)
    }
}

internal class URLRedirect: NSObject, URLSessionTaskDelegate {
    static let shared: URLRedirect = {
        let instance = URLRedirect()
        return instance
    }()
    
    lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    func redirectedURL(for url: URL, complectionHandler: @escaping ((URL?, Error?)->())) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, let location = httpResponse.allHeaderFields["Location"] as? String, let locationURL = URL(string: location) {
                    complectionHandler(locationURL, error)
                } else {
                    complectionHandler(nil, error)
            }
        })
        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
