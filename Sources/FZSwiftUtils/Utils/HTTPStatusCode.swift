//
//  HTTPStatusCode.swift
//
//
//  Created by Florian Zand on 13.03.26.
//

import Foundation

/// A value representing an HTTP status code.
public struct HTTPStatusCode: RawRepresentable, Sendable, Hashable, CustomStringConvertible {
    /// The integer value of the HTTP status code as defined by the HTTP specification.
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// A Boolean value indicating whether the status code is in the informational (`1xx`) range.
    public var isInformational: Bool { (100..<200).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the successful (`2xx`) range.
    public var isSuccessful: Bool { (200..<300).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the redirection (`3xx`) range.
    public var isRedirection: Bool { (300..<400).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the client error (`4xx`) range.
    public var isClientError: Bool { (400..<500).contains(rawValue) }
    /// A Boolean value indicating whether the status code is in the server error (`5xx`) range.
    public var isServerError: Bool { (500..<600).contains(rawValue) }
    
    /// A localized string of the status code.
    public var localizedString: String {
        HTTPURLResponse.localizedString(forStatusCode: rawValue)
    }
    
    /// A textual representation of the HTTP status code including its standard reason phrase when known.
    public var description: String {
        switch rawValue {
        case 100: return "100 (continue)"
        case 101: return "101 (switching protocols)"
        case 102: return "102 (processing)"
        case 103: return "103 (early hints)"
        case 200: return "200 (ok)"
        case 201: return "201 (created)"
        case 202: return "202 (accepted)"
        case 203: return "203 (non-authoritative information)"
        case 204: return "204 (no content)"
        case 205: return "205 (reset content)"
        case 206: return "206 (partial content)"
        case 207: return "207 (multi-status)"
        case 208: return "208 (already reported)"
        case 226: return "226 (im used)"
        case 300: return "300 (multiple choices)"
        case 301: return "301 (moved permanently)"
        case 302: return "302 (found)"
        case 303: return "303 (see other)"
        case 304: return "304 (not modified)"
        case 305: return "305 (use proxy)"
        case 307: return "307 (temporary redirect)"
        case 308: return "308 (permanent redirect)"
        case 400: return "400 (bad request)"
        case 401: return "401 (unauthorized)"
        case 402: return "402 (payment required)"
        case 403: return "403 (forbidden)"
        case 404: return "404 (not found)"
        case 405: return "405 (method not allowed)"
        case 406: return "406 (not acceptable)"
        case 407: return "407 (proxy authentication required)"
        case 408: return "408 (request timeout)"
        case 409: return "409 (conflict)"
        case 410: return "410 (gone)"
        case 411: return "411 (length required)"
        case 412: return "412 (precondition failed)"
        case 413: return "413 (payload too large)"
        case 414: return "414 (uri too long)"
        case 415: return "415 (unsupported media type)"
        case 416: return "416 (range not satisfiable)"
        case 417: return "417 (expectation failed)"
        case 418: return "418 (i'm a teapot)"
        case 421: return "421 (misdirected request)"
        case 422: return "422 (unprocessable content)"
        case 423: return "423 (locked)"
        case 424: return "424 (failed dependency)"
        case 425: return "425 (too early)"
        case 426: return "426 (upgrade required)"
        case 428: return "428 (precondition required)"
        case 429: return "429 (too many requests)"
        case 431: return "431 (request header fields too large)"
        case 451: return "451 (unavailable for legal reasons)"
        case 500: return "500 (internal server error)"
        case 501: return "501 (not implemented)"
        case 502: return "502 (bad gateway)"
        case 503: return "503 (service unavailable)"
        case 504: return "504 (gateway timeout)"
        case 505: return "505 (http version not supported)"
        case 506: return "506 (variant also negotiates)"
        case 507: return "507 (insufficient storage)"
        case 508: return "508 (loop detected)"
        case 510: return "510 (not extended)"
        case 511: return "511 (network authentication required)"
        default: return "\(rawValue)"
        }
    }
    

    // MARK: - Informational (1xx)

    /// The initial part of a request has been received and the client should continue sending the request body.
    public static let `continue` = Self(rawValue: 100)
    /// The server is switching protocols as requested by the client.
    public static let switchingProtocols = Self(rawValue: 101)
    /// The server has received and is processing the request but no response is available yet.
    public static let processing = Self(rawValue: 102)
    /// The server sends preliminary response headers before the final response.
    public static let earlyHints = Self(rawValue: 103)

    // MARK: - Successful (2xx)

    /// The request succeeded and the response contains the requested representation.
    public static let ok = Self(rawValue: 200)
    /// The request succeeded and resulted in the creation of a new resource.
    public static let created = Self(rawValue: 201)
    /// The request has been accepted for processing but the processing has not been completed.
    public static let accepted = Self(rawValue: 202)
    /// The request succeeded but the returned representation was modified by a transforming proxy.
    public static let nonAuthoritativeInformation = Self(rawValue: 203)
    /// The request succeeded and there is no additional content to send in the response body.
    public static let noContent = Self(rawValue: 204)
    /// The request succeeded and the client should reset the document view.
    public static let resetContent = Self(rawValue: 205)
    /// The server delivers only part of the resource due to a range request.
    public static let partialContent = Self(rawValue: 206)
    /// The response contains multiple status values for different parts of the request.
    public static let multiStatus = Self(rawValue: 207)
    /// Members of a DAV binding have already been enumerated in a previous response.
    public static let alreadyReported = Self(rawValue: 208)
    /// The server fulfilled a request for the resource using instance manipulations.
    public static let imUsed = Self(rawValue: 226)

    // MARK: - Redirection (3xx)

    /// The requested resource corresponds to multiple possible representations.
    public static let multipleChoices = Self(rawValue: 300)
    /// The requested resource has been permanently moved to a new location.
    public static let movedPermanently = Self(rawValue: 301)
    /// The requested resource resides temporarily under a different URI.
    public static let found = Self(rawValue: 302)
    /// The client should retrieve the resource using a GET request at another URI.
    public static let seeOther = Self(rawValue: 303)
    /// The resource has not been modified since the last request and the cached version may be used.
    public static let notModified = Self(rawValue: 304)
    /// The requested resource must be accessed through the proxy given by the response.
    public static let useProxy = Self(rawValue: 305)
    /// The request should be repeated with another URI without changing the request method.
    public static let temporaryRedirect = Self(rawValue: 307)
    /// The request should be repeated with another URI and the redirection is permanent.
    public static let permanentRedirect = Self(rawValue: 308)

    // MARK: - Client Error (4xx)

    /// The server cannot understand the request due to invalid syntax.
    public static let badRequest = Self(rawValue: 400)
    /// The request requires user authentication.
    public static let unauthorized = Self(rawValue: 401)
    /// Payment is required to access the requested resource.
    public static let paymentRequired = Self(rawValue: 402)
    /// The client does not have permission to access the requested resource.
    public static let forbidden = Self(rawValue: 403)
    /// The server cannot find the requested resource.
    public static let notFound = Self(rawValue: 404)
    /// The request method is not supported for the requested resource.
    public static let methodNotAllowed = Self(rawValue: 405)
    /// The requested resource cannot generate a response acceptable to the client.
    public static let notAcceptable = Self(rawValue: 406)
    /// Authentication with a proxy is required.
    public static let proxyAuthenticationRequired = Self(rawValue: 407)
    /// The server timed out waiting for the request.
    public static let requestTimeout = Self(rawValue: 408)
    /// The request conflicts with the current state of the resource.
    public static let conflict = Self(rawValue: 409)
    /// The resource requested is no longer available and will not be available again.
    public static let gone = Self(rawValue: 410)
    /// The server refuses to accept the request without a defined Content-Length.
    public static let lengthRequired = Self(rawValue: 411)
    /// A precondition given in the request evaluated to false.
    public static let preconditionFailed = Self(rawValue: 412)
    /// The request entity is larger than the server is willing or able to process.
    public static let payloadTooLarge = Self(rawValue: 413)
    /// The URI provided is too long for the server to process.
    public static let uriTooLong = Self(rawValue: 414)
    /// The request media type is not supported by the server.
    public static let unsupportedMediaType = Self(rawValue: 415)
    /// The requested range cannot be satisfied by the resource.
    public static let rangeNotSatisfiable = Self(rawValue: 416)
    /// The expectation given in the request cannot be met by the server.
    public static let expectationFailed = Self(rawValue: 417)
    /// The server refuses to brew coffee because it is a teapot.
    public static let imATeapot = Self(rawValue: 418)
    /// The request was directed at a server unable to produce a response.
    public static let misdirectedRequest = Self(rawValue: 421)
    /// The request was well-formed but could not be processed due to semantic errors.
    public static let unprocessableContent = Self(rawValue: 422)
    /// The resource that is being accessed is locked.
    public static let locked = Self(rawValue: 423)
    /// The request failed because it depended on another request that failed.
    public static let failedDependency = Self(rawValue: 424)
    /// The server is unwilling to process a request that might be replayed.
    public static let tooEarly = Self(rawValue: 425)
    /// The client should switch to a different protocol.
    public static let upgradeRequired = Self(rawValue: 426)
    /// The origin server requires the request to be conditional.
    public static let preconditionRequired = Self(rawValue: 428)
    /// The user has sent too many requests in a given amount of time.
    public static let tooManyRequests = Self(rawValue: 429)
    /// The server refuses the request because its header fields are too large.
    public static let requestHeaderFieldsTooLarge = Self(rawValue: 431)
    /// The requested resource is unavailable due to legal reasons.
    public static let unavailableForLegalReasons = Self(rawValue: 451)

    // MARK: - Server Error (5xx)

    /// The server encountered an unexpected condition that prevented it from fulfilling the request.
    public static let internalServerError = Self(rawValue: 500)
    /// The server does not support the functionality required to fulfill the request.
    public static let notImplemented = Self(rawValue: 501)
    /// The server received an invalid response from an upstream server.
    public static let badGateway = Self(rawValue: 502)
    /// The server is currently unable to handle the request due to temporary overload or maintenance.
    public static let serviceUnavailable = Self(rawValue: 503)
    /// The server did not receive a timely response from an upstream server.
    public static let gatewayTimeout = Self(rawValue: 504)
    /// The server does not support the HTTP protocol version used in the request.
    public static let httpVersionNotSupported = Self(rawValue: 505)
    /// Transparent content negotiation resulted in a circular reference.
    public static let variantAlsoNegotiates = Self(rawValue: 506)
    /// The server is unable to store the representation needed to complete the request.
    public static let insufficientStorage = Self(rawValue: 507)
    /// The server detected an infinite loop while processing the request.
    public static let loopDetected = Self(rawValue: 508)
    /// Further extensions to the request are required for the server to fulfill it.
    public static let notExtended = Self(rawValue: 510)
    /// The client must authenticate to gain network access.
    public static let networkAuthenticationRequired = Self(rawValue: 511)
}
