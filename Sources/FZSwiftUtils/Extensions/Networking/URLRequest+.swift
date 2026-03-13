//
//  URLRequest+.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import Foundation

public extension URLRequest {
    /**
     The cookies attached to the request.
     
     Setting this value updates the request's `Cookie` header field.
     */
    var cookies: [HTTPCookie] {
        get {
            guard let url = url else { return [] }
            return HTTPCookie.cookies(withResponseHeaderFields: allHTTPHeaderFields ?? [:], for: url)
        }
        set {
            guard !newValue.isEmpty else {
                setValue(nil, forHTTPHeaderField: "Cookie")
                return
            }
            for (field, value) in HTTPCookie.requestHeaderFields(with: newValue) {
                setValue(value, forHTTPHeaderField: field)
            }
        }
    }
    
    /// Sets the cookies attached to the request by replacing the `Cookie` header field.
    func cookies(_ cookies: [HTTPCookie]) -> Self {
        var request = self
        request.cookies = cookies
        return request
    }
    
    /// Sets the HTTP request method.
    func httpMethod(_ method: HTTPMethod) -> Self {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }
    
    /**
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given `Data` object.

     This is useful for resuming interrupted downloads or uploads, allowing the server to send only the remaining bytes.

     - Parameters:
       - data: The existing partial `Data` to determine the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.
     */
    mutating func addRangeHeader(for data: Data, validator: String? = nil) {
        bytesRange = .from(UInt64(data.count))
        setValue(validator, forHTTPHeaderField: "If-Range")
    }


    /**
     Adds a `Range` HTTP header to the request, specifying that the request should continue from the end of the given file.

     This is useful for resuming file downloads or uploads from disk, allowing the server to send only the remaining bytes.

     - Parameters:
       - file: The file `URL` pointing to the partially downloaded file. It's current size is used to calculate the starting byte for the range.
       - validator: A validator (e.g. `ETag` or `last-modified date`). If provided, it will be added as the `If-Range` header to ensure the requested range is only served if the validator still matches.

     - Note: The file must be a local file `URL` with a valid file size.. If the file doesn't exist or the size is 'zero', this method does nothing.
     */
    mutating func addRangeHeader(for file: URL, validator: String? = nil) {
        guard let fileSize = file.resources.fileSize, fileSize != .zero else { return }
        bytesRange = .from(fileSize.bytes)
        setValue(validator, forHTTPHeaderField: "If-Range")
    }

    /**
     Adds multiple HTTP headers to the URLRequest.

     - Parameter headerValues: A dictionary of header field-value pairs to add to the URLRequest.

     This method provides the ability to add multiple values to header fields. If a value was previously set for the specified field, the supplied value is appended to the existing value using the appropriate field delimiter (a comma).
     Certain header fields are reserved (see Reserved HTTP Headers). Do not use this method to change such headers.
     */
    mutating func addHTTPHeaders(_ headerValues: [String: String]) {
        headerValues.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    /**
     Represents an HTTP byte range used by the `Range`  request header field.

     The `Range` header field allows a client to request only a portion of a resource instead of the entire body.
     */
    enum HTTPByteRange {
        /// Requests bytes between the specified start and end offsets, inclusive.
        case range(from: UInt64, to: UInt64)
        /// Requests all bytes starting at the specified offset until the end of the resource.
        case from(UInt64)
        /// Requests the specified number of bytes from the end of the resource.
        case last(UInt64)
    }
    
    /**
     The HTTP byte range requested by the `Range` header field.
     
     Setting this value updates the request's `Range` header field.
     */
    var bytesRange: HTTPByteRange? {
        get {
            guard let value = value(forHTTPHeaderField: "Range"), value.hasPrefix("bytes=") else { return nil }
            let parts = value.dropFirst("bytes=".count).split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
            switch (UInt64(parts[safe: 0] ?? ""), UInt64(parts[safe: 1] ?? "")) {
            case let (start?, end?):
                return .range(from: start, to: end)
            case let (start?, nil):
                return .from(start)
            case let (nil, end?):
                return .last(end)
            case (nil, nil):
                return nil
            }
        }
        set {
            switch newValue {
            case let .range(start, end):
                setValue("bytes=\(start)-\(end)", forHTTPHeaderField: "Range")
            case let .from(start):
                setValue("bytes=\(start)-", forHTTPHeaderField: "Range")
            case let .last(length):
                setValue("bytes=-\(length)", forHTTPHeaderField: "Range")
            case nil:
                setValue(nil, forHTTPHeaderField: "Range")
            }
        }
    }
    
    /**
     Returns the curl command equivalent of the request.

     The curl command string includes the URL, HTTP method, headers, and body (if present) of the request.
     
     - Parameter includeCookies: A Boolean value indicating whether to include the cookies of the request.
     - Returns: A string representing the curl command equivalent of the request.
     - Important: The generated curl command may not accurately represent all aspects of the request, such as multipart form data.
     */
      func curlString(includeCookies: Bool = false) -> String {
          guard let url else { return "" }
          
          func shellEscape(_ string: String) -> String {
              "'" + string.replacingOccurrences(of: "'", with: "'\\''") + "'"
          }
          
          var components = ["curl"]
                    
          if let method = httpMethod, method != "GET" {
              if method == "HEAD" {
                  components += "--head"
              } else {
                  components += "-X \(method)"
              }
          }
          
          if let headers = allHTTPHeaderFields {
              var shouldAddCompressed = false
              for (key, value) in headers.sorted(by: \.key, options: .localizedStandard) {
                  if !includeCookies && key.caseInsensitiveCompare("Cookie") == .orderedSame {
                      continue
                  }
                  if key.caseInsensitiveCompare("Accept-Encoding") == .orderedSame {
                      shouldAddCompressed = true
                  }
                  components += "-H \(shellEscape("\(key): \(value)"))"
              }
              if shouldAddCompressed {
                  components += "--compressed"
              }
          }
          
          if let bodyData = httpBody {
              if let body = String(data: bodyData, encoding: .utf8) {
                  components += "--data-raw \(shellEscape(body))"
              } else {
                  components += "--data-binary @<(echo \(shellEscape(bodyData.base64EncodedString())) | base64 --decode)"
              }
          } else if httpBodyStream != nil {
              components += "# Body is provided via httpBodyStream and cannot be represented"
          }
          
          components += shellEscape(url.absoluteString)
          return components.joined(separator: " \\\n\t")
      }

    /// A dictionary containing all of the HTTP header fields for a request.
    var httpHeaderFields: [HTTPRequestHeaderField: String] {
        get { allHTTPHeaderFields?.mapKeys({ HTTPRequestHeaderField($0) }) ?? [:] }
        set { allHTTPHeaderFields =  newValue.mapKeys({$0.rawValue}) }
    }
    
    internal func copy(as httpMethod: HTTPMethod) -> Self {
        var request = self
        request.httpMethod = httpMethod.rawValue
        request.httpBody = nil
        request.httpBodyStream = nil
        return request
    }
}

extension URLRequest: Codable {
    public init(from decoder: any Decoder) throws {
        self = try NSURLRequest.unarchive(decoder.decodeSingle()) as URLRequest
    }
    
    public func encode(to encoder: any Encoder) throws {
        try encoder.encodeSingle((self as NSURLRequest).archivedData())
    }
}

/// A representation of HTTP request header fields.
public struct HTTPRequestHeaderField: RawRepresentable, ExpressibleByStringLiteral, Hashable {
    /// The name of the HTTP request header field as a string (e.g., `"Content-Type"`, `"User-Agent"`).
    public let rawValue: String

    /// Creates a HTTP request header field key.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// Creates a HTTP request header field key.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a HTTP request header field key.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Media types that are acceptable for the response.
    public static let accept: Self = "Accept"
    /// Character sets that are acceptable.
    public static let acceptCharset: Self = "Accept-Charset"
    /// List of acceptable encodings.
    public static let acceptEncoding: Self = "Accept-Encoding"
    /// List of acceptable human languages.
    public static let acceptLanguage: Self = "Accept-Language"
    /// Indicates the patch document media types accepted by the server.
    public static let acceptPatch: Self = "Accept-Patch"
    /// Names of headers used in CORS preflight request indicating requested headers.
    public static let accessControlRequestHeaders: Self = "Access-Control-Request-Headers"
    /// Indicates the HTTP method to be used in a CORS request.
    public static let accessControlRequestMethod: Self = "Access-Control-Request-Method"
    /// Directives for caching mechanisms.
    public static let cacheControl: Self = "Cache-Control"
    /// Cookies previously sent by the server.
    public static let cookie: Self = "Cookie"
    /// Base64-encoded 128-bit MD5 digest of the message body.
    public static let contentMD5: Self = "Content-MD5"
    /// Indicates how content should be presented (e.g., inline, attachment).
    public static let contentDisposition: Self = "Content-Disposition"
    /// The media type of the request body.
    public static let contentType: Self = "Content-Type"
    /// Describes the natural language(s) of the intended audience for the enclosed content.
    public static let contentLanguage: Self = "Content-Language"
    /// The date and time at which the message was originated.
    public static let date: Self = "Date"
    /// Indicates the user’s tracking preference ("Do Not Track").
    public static let dnt: Self = "DNT"
    /// Entity tag for cache validation.
    public static let etag: Self = "ETag"
    /// Indicates that particular server behaviors are required by the client.
    public static let expect: Self = "Expect"
    /// Discloses the client’s original IP address and other forwarding information.
    public static let forwarded: Self = "Forwarded"
    /// The email address of the user making the request.
    public static let from: Self = "From"
    /// A conditional request header matching the entity tag.
    public static let ifMatch: Self = "If-Match"
    /// A conditional request header checking the modification date.
    public static let ifModifiedSince: Self = "If-Modified-Since"
    /// A conditional request header checking if none match the given ETags.
    public static let ifNoneMatch: Self = "If-None-Match"
    /// A conditional request header used with range requests.
    public static let ifRange: Self = "If-Range"
    /// A conditional request header ensuring the resource hasn't changed.
    public static let ifUnmodifiedSince: Self = "If-Unmodified-Since"
    /// Used to describe relationships between resources.
    public static let link: Self = "Link"
    /// Limits the number of times a request can be forwarded.
    public static let maxForwards: Self = "Max-Forwards"
    /// Originating URI of the request initiating the fetch.
    public static let origin: Self = "Origin"
    /// Implementation-specific directives that might influence caching.
    public static let pragma: Self = "Pragma"
    /// Specifies the part(s) of a document that the server should return.
    public static let range: Self = "Range"
    /// The address of the previous web page from which a link to the current page was followed.
    public static let referer: Self = "Referer"
    /// Indicates how long the client should wait before making a follow-up request.
    public static let retryAfter: Self = "Retry-After"
    /// Indicates the transfer codings the user agent is willing to accept.
    public static let te: Self = "TE"
    /// The form of encoding used to safely transfer the payload body.
    public static let transferEncoding: Self = "Transfer-Encoding"
    /// Allows the client to specify which protocol upgrades it supports.
    public static let upgrade: Self = "Upgrade"
    /// The user agent string of the client software.
    public static let userAgent: Self = "User-Agent"
    /// Informs the server of intermediate protocols and recipients.
    public static let via: Self = "Via"
    /// General warnings about possible problems with the request.
    public static let warning: Self = "Warning"
    /// Identifies Ajax requests, commonly set to "XMLHttpRequest".
    public static let xRequestedWith: Self = "X-Requested-With"
    /// Identifies the originating IP address of a client connecting through a proxy.
    public static let xForwardedFor: Self = "X-Forwarded-For"
    /// Identifies the protocol (HTTP or HTTPS) used by the client connecting through a proxy.
    public static let xForwardedProto: Self = "X-Forwarded-Proto"
    /// Indicates the client’s real IP address when behind a reverse proxy.
    public static let xRealIP: Self = "X-Real-IP"
    /*
     /// Credentials for authenticating the client with the server.
     public static let authorization: Self = "Authorization"
     /// Options for the connection (e.g., keep-alive).
     public static let connection: Self = "Connection"
     /// The size of the request body in octets (8-bit bytes).
     public static let contentLength: Self = "Content-Length"
     /// The domain name of the server and optionally the port number.
     public static let host: Self = "Host"
     /// Credentials for authenticating with a proxy.
     public static let proxyAuthorization: Self = "Proxy-Authorization"
      */
}

/*
/// Creates and initializes a URL request with the given curl command.
init?(curlString: String) {
    func unescape(_ string: String) -> String {
        guard string.hasPrefix("'"), string.hasSuffix("'") else { return string }
        return String(string.dropFirst().dropLast()).replacingOccurrences(of: "'\\''", with: "'")
    }
    var method = "GET"
    var headers: [String:String] = [:]
    var body: Data?
    var urlString: String?
    
    let tokens = curlString
        .replacingOccurrences(of: "\\\n", with: " ")
        .split(separator: " ")
        .map(String.init)
    var i = 0
    while i < tokens.count {
        let token = tokens[i]
        switch token {
        case "curl":
            break
        case "-X":
            i += 1
            if i < tokens.count { method = tokens[i] }
        case "--head":
            method = "HEAD"
        case "-H":
            i += 1
            if i < tokens.count {
                let header = unescape(tokens[i])
                if let colon = header.firstIndex(of: ":") {
                    let key = String(header[..<colon])
                    let value = header[header.index(after: colon)...].trimmingCharacters(in: .whitespaces)
                    headers[key] = value
                }
            }
        case "--data-raw", "-d":
            i += 1
            if i < tokens.count {
                let bodyString = unescape(tokens[i])
                body = bodyString.data(using: .utf8)
                if method == "GET" { method = "POST" }
            }
        case "--data-binary":
            i += 1
            if i < tokens.count {
                let token = tokens[i]
                if let base64Range = token.range(of: "echo ") {
                    let base64 = token[base64Range.upperBound...]
                        .replacingOccurrences(of: "|", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    body = Data(base64Encoded: unescape(base64))
                }
                if method == "GET" { method = "POST" }
            }
        default:
            if token.hasPrefix("http://") || token.hasPrefix("https://") {
                urlString = unescape(token)
            }
        }
        i += 1
    }
    guard let urlString, let url = URL(string: urlString) else { return nil }
    self.init(url: url)
    httpMethod = method
    allHTTPHeaderFields = headers.isEmpty ? nil : headers
    httpBody = body
}
*/
