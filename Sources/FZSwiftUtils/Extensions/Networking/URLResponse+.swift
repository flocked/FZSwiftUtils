//
//  URLResponse+.swift
//
//
//  Created by Florian Zand on 20.07.23.
//

import Foundation
import UniformTypeIdentifiers

public extension URLResponse {
    /// The response as `HTTPURLResponse` response, or `nil` if the reponse isn't `HTTP` based.
    var http: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
    
    /// The expected length of the response’s content.
    var expectedContentSize: DataSize? {
        guard expectedContentLength >= 0 else { return nil }
        return .bytes(expectedContentLength)
    }
    
    /// The content type type of the response.
    var contentType: UTType? {
        guard let mimeType = mimeType else { return nil }
        return UTType(mimeType: mimeType)
    }
    
    /*
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
     */
}
