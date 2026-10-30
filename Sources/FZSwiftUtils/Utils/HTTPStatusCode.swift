//
//  HTTPStatusCode.swift
//
//
//  Created by Florian Zand on 13.03.26.
//

import Foundation

/// A value representing an HTTP status code.
public struct HTTPStatusCode: ExpressibleByIntegerLiteral, RawRepresentable, Sendable, Hashable, CustomStringConvertible {
    /// The numeric value of the HTTP status code.
    public let rawValue: Int

    /// Creates an HTTP status code with the specified numeric value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Creates an HTTP status code with the specified numeric value.
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
    
    /// The category of an HTTP status code.
    public enum Category: String, Sendable, CustomStringConvertible, CaseIterable {
        /// An informational response (`100...199`).
        case informational = "Informational"
        /// A successful response (`200...299`).
        case successful = "Success"
        /// A redirection response (`300...399`).
        case redirection = "Redirection"
        /// A client error response (`400...499`).
        case clientError = "Client Error"
        /// A server error response (`500...599`).
        case serverError = "Server Error"
        /// A value outside the valid HTTP status code range (`100...599`).
        case undefined = "Undefined"
        
        /// A Boolean value indicating whether the category represents an error response.
        public var isError: Bool {
            self == .clientError || self == .serverError
        }
        
        /// A Boolean value indicating whether the category represents a valid HTTP status code range.
        public var isValid: Bool {
            self != .undefined
        }
                
        /// The range of HTTP status codes represented by the category.
        public var range: ClosedRange<Int>? {
            switch self {
            case .informational: 100...199
            case .successful: 200...299
            case .redirection: 300...399
            case .clientError: 400...499
            case .serverError: 500...599
            case .undefined: nil
            }
        }
        
        /// Creates a category for the specified HTTP status code.
        public init(statusCode: Int) {
            self = switch statusCode {
            case 100...199: .informational
            case 200...299: .successful
            case 300...399: .redirection
            case 400...499: .clientError
            case 500...599: .serverError
            default: .undefined
            }
        }
        
        public var description: String { rawValue }
        
        var statusText: String? { self != .undefined ? rawValue : nil }
    }

    /// The category of the HTTP status code.
    public var category: Category {
        Category(statusCode: rawValue)
    }
    
    /// A Boolean value indicating whether the status code is in the informational (`1xx`) range.
    public var isInformational: Bool { (100...199).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the successful (`2xx`) range.
    public var isSuccessful: Bool { (200...299).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the redirection (`3xx`) range.
    public var isRedirection: Bool { (300...399).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the client error (`4xx`) range.
    public var isClientError: Bool { (400...499).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the server error (`5xx`) range.
    public var isServerError: Bool { (500...599).contains(rawValue) }
    /// A Boolean value indicating whether the status code represents an error response.
    public var isError: Bool { category.isError }
    /// A Boolean value indicating whether the status code is within the valid HTTP status code range (`100...599`).
    public var isValid: Bool { category.isValid }


    /// A localized string of the status code.
    public var localizedString: String {
        HTTPURLResponse.localizedString(forStatusCode: rawValue)
    }
    
    /// The textual description of the status code, if available.
    public var statusText: String? {
        Self.descriptions[rawValue] ?? category.statusText
    }
    
    /// A textual representation of the HTTP status code including its standard reason phrase when known.
    public var description: String {
        guard let statusText else { return "\(rawValue)" }
        return "\(rawValue) \(statusText)"
    }
    
    private static let descriptions: [Int: String] = [
        // Informational
        100: "Continue",
        101: "Switching Protocols",
        102: "Processing",
        103: "Early Hints",
        104: "Upload Resumption Supported",
        // Success
        200: "OK",
        201: "Created",
        202: "Accepted",
        203: "Non-Authoritative Information",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        207: "Multi-Status",
        208: "Already Reported",
        226: "IM Used",
        // Redirection
        300: "Multiple Choices",
        301: "Moved Permanently",
        302: "Found",
        303: "See Other",
        304: "Not Modified",
        305: "Use Proxy",
        307: "Temporary Redirect",
        308: "Permanent Redirect",
        // Client Error
        400: "Bad Request",
        401: "Unauthorized",
        402: "Payment Required",
        403: "Forbidden",
        404: "Not Found",
        405: "Method Not Allowed",
        406: "Not Acceptable",
        407: "Proxy Authentication Required",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        411: "Length Required",
        412: "Precondition Failed",
        413: "Content Too Large",
        414: "URI Too Long",
        415: "Unsupported Media Type",
        416: "Range Not Satisfiable",
        417: "Expectation Failed",
        421: "Misdirected Request",
        422: "Unprocessable Content",
        423: "Locked",
        424: "Failed Dependency",
        425: "Too Early",
        426: "Upgrade Required",
        428: "Precondition Required",
        429: "Too Many Requests",
        431: "Request Header Fields Too Large",
        451: "Unavailable For Legal Reasons",
        // Server Error
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
        505: "HTTP Version Not Supported",
        506: "Variant Also Negotiates",
        507: "Insufficient Storage",
        508: "Loop Detected",
        510: "Not Extended",
        511: "Network Authentication Required"
    ]
    
    // MARK: - Informational (1xx)

    /// The initial part of the request has been received and the client should continue sending the request.
    public static let `continue`: Self = 100
    /// The server is switching protocols as requested by the client.
    public static let switchingProtocols: Self = 101
    /// The server has received and is processing the request but no response is available yet.
    public static let processing: Self = 102
    /// The server sends preliminary response headers before the final response.
    public static let earlyHints: Self = 103
    /// The server supports resumable uploads using the upload resumption protocol.
    public static let uploadResumptionSupported: Self = 104

    // MARK: - Successful (2xx)

    /// The request succeeded.
    public static let ok: Self = 200
    /// The request succeeded and resulted in the creation of a new resource.
    public static let created: Self = 201
    /// The request has been accepted for processing but the processing has not been completed.
    public static let accepted: Self = 202
    /// The request succeeded but the returned representation was modified by a transforming proxy.
    public static let nonAuthoritativeInformation: Self = 203
    /// The request succeeded and there is no additional content to send in the response body.
    public static let noContent: Self = 204
    /// The request succeeded and the client should reset the document view.
    public static let resetContent: Self = 205
    /// The server is delivering only part of the requested representation due to a range request.
    public static let partialContent: Self = 206
    /// The response contains multiple status values for different parts of the request.
    public static let multiStatus: Self = 207
    /// Members of a DAV binding have already been enumerated in a previous response.
    public static let alreadyReported: Self = 208
    /// The server fulfilled the request using one or more instance manipulations.
    public static let imUsed: Self = 226

    // MARK: - Redirection (3xx)

    /// The requested resource corresponds to multiple possible representations.
    public static let multipleChoices: Self = 300
    /// The requested resource has been permanently moved to a new location.
    public static let movedPermanently: Self = 301
    /// The requested resource resides temporarily under a different URI.
    public static let found: Self = 302
    /// The client should retrieve the resource using a GET request at another URI.
    public static let seeOther: Self = 303
    /// The resource has not been modified since the last request and the cached representation may be used.
    public static let notModified: Self = 304
    /// The requested resource must be accessed through the proxy specified by the response.
    public static let useProxy: Self = 305
    /// The request should be repeated at another URI without changing the request method.
    public static let temporaryRedirect: Self = 307
    /// The request should be repeated at another URI without changing the request method and the redirection is permanent.
    public static let permanentRedirect: Self = 308

    // MARK: - Client Error (4xx)

    /// The server cannot process the request due to invalid request syntax or framing.
    public static let badRequest: Self = 400
    /// The request requires authentication.
    public static let unauthorized: Self = 401
    /// Payment is required to access the requested resource.
    public static let paymentRequired: Self = 402
    /// The server understood the request but refuses to fulfill it.
    public static let forbidden: Self = 403
    /// The server cannot find the requested resource.
    public static let notFound: Self = 404
    /// The request method is not supported for the requested resource.
    public static let methodNotAllowed: Self = 405
    /// The server cannot produce a response matching the client's acceptable response criteria.
    public static let notAcceptable: Self = 406
    /// Authentication with a proxy is required.
    public static let proxyAuthenticationRequired: Self = 407
    /// The server timed out waiting to receive the request.
    public static let requestTimeout: Self = 408
    /// The request conflicts with the current state of the resource.
    public static let conflict: Self = 409
    /// The requested resource is no longer available and is likely to remain unavailable.
    public static let gone: Self = 410
    /// The server refuses to accept the request without a defined content length.
    public static let lengthRequired: Self = 411
    /// A precondition given in the request evaluated to false.
    public static let preconditionFailed: Self = 412
    /// The request content is larger than the server is willing or able to process.
    public static let contentTooLarge: Self = 413
    /// The request URI is longer than the server is willing to interpret.
    public static let uriTooLong: Self = 414
    /// The request content is in a format not supported by the server.
    public static let unsupportedMediaType: Self = 415
    /// The requested range cannot be satisfied by the resource.
    public static let rangeNotSatisfiable: Self = 416
    /// The expectation given in the request cannot be met by the server.
    public static let expectationFailed: Self = 417
    /// The request was directed at a server that is unable or unwilling to produce a response for the target URI.
    public static let misdirectedRequest: Self = 421
    /// The request content is syntactically correct but cannot be processed due to semantic errors.
    public static let unprocessableContent: Self = 422
    /// The resource being accessed is locked.
    public static let locked: Self = 423
    /// The request failed because it depended on another request that failed.
    public static let failedDependency: Self = 424
    /// The server is unwilling to process a request that might be replayed.
    public static let tooEarly: Self = 425
    /// The client should switch to a different protocol.
    public static let upgradeRequired: Self = 426
    /// The origin server requires the request to be conditional.
    public static let preconditionRequired: Self = 428
    /// The client has sent too many requests in a given amount of time.
    public static let tooManyRequests: Self = 429
    /// The server refuses to process the request because its header fields are too large.
    public static let requestHeaderFieldsTooLarge: Self = 431
    /// The requested resource is unavailable due to legal reasons.
    public static let unavailableForLegalReasons: Self = 451

    // MARK: - Server Error (5xx)

    /// The server encountered an unexpected condition that prevented it from fulfilling the request.
    public static let internalServerError: Self = 500
    /// The server does not support the functionality required to fulfill the request.
    public static let notImplemented: Self = 501
    /// The server received an invalid response from an upstream server.
    public static let badGateway: Self = 502
    /// The server is currently unable to handle the request due to temporary overload or maintenance.
    public static let serviceUnavailable: Self = 503
    /// The server did not receive a timely response from an upstream server.
    public static let gatewayTimeout: Self = 504
    /// The server does not support the HTTP protocol version used in the request.
    public static let httpVersionNotSupported: Self = 505
    /// Transparent content negotiation resulted in a circular reference.
    public static let variantAlsoNegotiates: Self = 506
    /// The server is unable to store the representation needed to complete the request.
    public static let insufficientStorage: Self = 507
    /// The server detected an infinite loop while processing the request.
    public static let loopDetected: Self = 508
    /// Further extensions to the request are required for the server to fulfill it.
    public static let notExtended: Self = 510
    /// The client must authenticate to gain network access.
    public static let networkAuthenticationRequired: Self = 511
}
