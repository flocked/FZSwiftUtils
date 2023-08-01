//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     Adds a range HTTP header for the specified data. This e.g. allows to resume a data download.

     - Parameter data: The data used for the HTTP header.
     - Parameter validator: A validator to ensure the requested data hasn't changed on the server since the last request. You can obtain the validator on previous url responses via `URLResponse` `validator`.
     */
    mutating func addRangeHeader(for data: Data, validator: String? = nil) {
        var headers = self.allHTTPHeaderFields ?? [:]
        headers["Range"] = "bytes=\(data.count)-"
        if let validator = validator {
            headers["If-Range"] = validator
        }
        self.allHTTPHeaderFields = headers
    }
    
    /**
     Adds a range HTTP header for the specified file. This e.g. allows to resume downloading the file.

     - Parameter file: A local file used for the HTTP header.
     - Parameter validator: A validator to ensure the requested data hasn't changed on the server since the last request. You can obtain the validator on previous url responses via `URLResponse` `validator`.
     */
    mutating func addRangeHeader(for file: URL, validator: String? = nil) {
        guard let fileSize = file.resources.fileSize, fileSize != .zero else { return }
        var headers = self.allHTTPHeaderFields ?? [:]
        headers["Range"] = "bytes=\(fileSize.bytes)-"
        if let validator = validator {
            headers["If-Range"] = validator
        }
        self.allHTTPHeaderFields = headers
    }
    
    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.
     
     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     Certain header fields are reserved (see Reserved HTTP Headers). Do not use this method to change such headers.
     */
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
    }

    /**
     The range of bytes specified in the "Range" header field of the request.

     The range is represented as a closed range of integer values, indicating the start and end positions of the byte range.
     */
    var bytesRanges: ClosedRange<Int>? {
        get {
            if let string = allHTTPHeaderFields?["Range"] {
                let matches = string.matches(regex: "bytes=(\\d+)-(\\d+)").compactMap({$0.string})
                if matches.count == 2, let from = Int(matches[0]), let to = Int(matches[1]) {
                    return from ... to
                }
            }
            return nil
        }
        set {
            if let byteRange = newValue {
                // bytes=345234-34555
                setValue("bytes=\(byteRange.lowerBound)-\(byteRange.upperBound)", forHTTPHeaderField: "Range")
            } else {
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }

    /**
     Returns the curl command equivalent of the URLRequest.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the URLRequest.

     - Important: The generated curl command may not accurately represent all aspects of the URLRequest, such as multipart form data.

     - Returns: A string representing the curl command equivalent of the URLRequest.
     */
    var curlString: String {
        guard let url = url else { return "" }

        var baseCommand = "curl \(url.absoluteString)"
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]
        if let method = httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody,
           let body = String(data: data, encoding: .utf8)
        {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }
    
    /// A dictionary containing all of the HTTP header fields for a request.
    var allHTTPHeaderFieldsMapped: [HTTPRequestHeaderFieldKey: String]? {
        get {
            guard let allHTTPHeaderFields = self.allHTTPHeaderFields else { return nil }
            var dic: [HTTPRequestHeaderFieldKey: String] = [:]
            for key in allHTTPHeaderFields.keys.compactMap({HTTPRequestHeaderFieldKey(rawValue: $0)}) {
                dic[key] = allHTTPHeaderFields[key.rawValue]
            }
            return dic
        }
        set {
            guard let newValue = newValue else {
            self.allHTTPHeaderFields = nil
            return
        }
            self.allHTTPHeaderFields = [:]
            for key in newValue.keys {
                self.allHTTPHeaderFields?[key.rawValue] = newValue[key]
            }
        }
    }
}

/// Enumeration of all HTTP request header field keys.
public enum HTTPRequestHeaderFieldKey: String {
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case authorization = "Authorization"
    case cacheControl = "Cache-Control"
    case connection = "Connection"
    case cookie = "Cookie"
    case contentLength = "Content-Length"
    case contentMD5 = "Content-MD5"
    case contentType = "Content-Type"
    case date = "Date"
    case expect = "Expect"
    case forwarded = "Forwarded"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifRange = "If-Range"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case maxForwards = "Max-Forwards"
    case pragma = "Pragma"
    case proxyAuthorization = "Proxy-Authorization"
    case range = "Range"
    case referer = "Referer"
    case TE = "TE"
    case transferEncoding = "Transfer-Encoding"
    case upgrade = "Upgrade"
    case userAgent = "User-Agent"
    case via = "Via"
    case warning = "Warning"
}
