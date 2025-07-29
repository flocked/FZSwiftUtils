//
//  URLResponse+.swift
//
//
//  Created by Florian Zand on 20.07.23.
//

import Foundation

public extension URLResponse {
    /// The `HTTP` response, or `nil` if the reponse isn't `HTTP`.
    var http: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
    
    /// A suggested filename for the response data.
    var extendedSuggestedFilename: String? {
        guard var fileName = suggestedFilename else { return nil }
        guard !(fileName as NSString).pathExtension.isEmpty, let httpResponse = http, let contentType = httpResponse.allHeaderFields["Content-Type"] as? String else { return fileName }
        let components = contentType.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true).first?.split(separator: "/")
        if let subtype = components?.last, !subtype.isEmpty {
            let ext = subtype.trimmingCharacters(in: .whitespaces)
            fileName += ".\(ext)"
        }
        return fileName
    }
}
