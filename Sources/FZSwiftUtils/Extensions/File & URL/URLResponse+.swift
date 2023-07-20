//
//  File.swift
//  
//
//  Created by Florian Zand on 20.07.23.
//

import Foundation

public extension URLResponse {
    
    /// The validator which identifies the current state of the resource on the server.
    var validator: String? {
        guard let response = self as? HTTPURLResponse,
              response.statusCode == 200 /* OK */ || response.statusCode == 206, /* Partial Content */
              let acceptRanges = response.allHeaderFields["Accept-Ranges"] as? String,
              acceptRanges.lowercased() == "bytes" else { return nil  }
        
        if let entityTag = response.allHeaderFields["ETag"] as? String {
            return entityTag
        }
        // There seems to be a bug with ETag where HTTPURLResponse would canonicalize
        // it to Etag instead of ETag
        // https://bugs.swift.org/browse/SR-2429
        if let entityTag = response.allHeaderFields["Etag"] as? String {
            return entityTag
        }
        if let lastModified = response.allHeaderFields["Last-Modified"] as? String {
            return lastModified
        }
        return nil
    }
}
