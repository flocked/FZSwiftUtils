//
//  HTTPRequestHeaders.swift
//  
//
//  Created by Florian Zand on 04.06.26.
//

import Foundation
import UniformTypeIdentifiers

/// A strongly typed representation of HTTP request header fields.
public struct HTTPRequestHeaders {
    /// The media types acceptable for the response.
    public var accept: [String] {
        get { headers[.accept]?.commaSeperated ?? [] }
        set { headers[.accept] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The character sets acceptable for the response.
    public var acceptCharset: [String] {
        get { headers[.acceptCharset]?.commaSeperated ?? [] }
        set { headers[.acceptCharset] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The content encodings acceptable for the response.
    public var acceptEncoding: [String] {
        get { headers[.acceptEncoding]?.commaSeperated ?? [] }
        set { headers[.acceptEncoding] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The natural languages preferred for the response.
    public var acceptLanguage: [String] {
        get { headers[.acceptLanguage]?.commaSeperated ?? [] }
        set { headers[.acceptLanguage] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The patch document formats accepted by the client.
    public var acceptPatch: [String] {
        get { headers[.acceptPatch]?.commaSeperated ?? [] }
        set { headers[.acceptPatch] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The headers that will be used in a cross-origin request.
    public var accessControlRequestHeaders: [String] {
        get { headers[.accessControlRequestHeaders]?.commaSeperated ?? [] }
        set { headers[.accessControlRequestHeaders] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The HTTP method that will be used in a cross-origin request.
    public var accessControlRequestMethod: String? {
        get { headers[.accessControlRequestMethod] }
        set { headers[.accessControlRequestMethod] = newValue }
    }

    /// The directives controlling caching behavior for the request.
    public var cacheControl: String? {
        get { headers[.cacheControl] }
        set { headers[.cacheControl] = newValue }
    }

    /// The cookies included with the request.
    public var cookie: String? {
        get { headers[.cookie] }
        set { headers[.cookie] = newValue }
    }

    /// The Content-MD5 digest value for the request body.
    public var contentMD5: String? {
        get { headers[.contentMD5] }
        set { headers[.contentMD5] = newValue }
    }

    /// The presentation information for the request content.
    public var contentDisposition: String? {
        get { headers[.contentDisposition] }
        set { headers[.contentDisposition] = newValue }
    }

    /// The Uniform Type Identifier corresponding to the Content-Type header.
    public var contentType: UTType? {
        get {
            guard let mimeType = headers[.contentType]?.split(separator: ";").first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
            return UTType(mimeType: mimeType)
        }
        set {
            guard let newValue else {
                headers[.contentType] = nil
                return
            }
            var value = newValue.preferredMIMEType ?? newValue.identifier
            if !contentTypeParameters.isEmpty {
                value += ";" + contentTypeParameters.map { "\($0.key)=\($0.value)" }.joined(separator: ";")
            }
            headers[.contentType] = value
        }
    }

    /// The parameters associated with the Content-Type header.
    public var contentTypeParameters: [String: String] {
        get { headers[.contentType]?.contentTypeParameters ?? [:] }
        set {
            guard let contentType else { return }
            var value = contentType.preferredMIMEType ?? contentType.identifier
            if !newValue.isEmpty {
                value += ";" + newValue.map { "\($0.key)=\($0.value)" }.joined(separator: ";")
            }
            headers[.contentType] = value
        }
    }

    /// The natural languages of the request content.
    public var contentLanguage: [String] {
        get { headers[.contentLanguage]?.commaSeperated ?? [] }
        set { headers[.contentLanguage] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The date and time at which the request originated.
    public var date: Date? {
        get { headers[.date]?.httpDate }
        set { headers[.date] = newValue?.httpString }
    }

    /// The user's tracking preference.
    public var dnt: String? {
        get { headers[.dnt] }
        set { headers[.dnt] = newValue }
    }

    /// The entity tag associated with the request.
    public var eTag: String? {
        get { headers[.etag] }
        set { headers[.etag] = newValue }
    }

    /// The expectations that must be met by the server before processing the request.
    public var expect: String? {
        get { headers[.expect] }
        set { headers[.expect] = newValue }
    }

    /// Information about intermediary proxies through which the request was forwarded.
    public var forwarded: String? {
        get { headers[.forwarded] }
        set { headers[.forwarded] = newValue }
    }

    /// The email address of the user making the request.
    public var from: String? {
        get { headers[.from] }
        set { headers[.from] = newValue }
    }

    /// The entity tags that must match for the request to succeed.
    public var ifMatch: String? {
        get { headers[.ifMatch] }
        set { headers[.ifMatch] = newValue }
    }

    /// The date and time after which the resource must have been modified.
    public var ifModifiedSince: Date? {
        get { headers[.ifModifiedSince]?.httpDate }
        set { headers[.ifModifiedSince] = newValue?.httpString }
    }

    /// The entity tags that must not match for the request to succeed.
    public var ifNoneMatch: String? {
        get { headers[.ifNoneMatch] }
        set { headers[.ifNoneMatch] = newValue }
    }

    /// The validator that must match when processing a range request.
    public var ifRange: String? {
        get { headers[.ifRange] }
        set { headers[.ifRange] = newValue }
    }

    /// The date and time before which the resource must not have been modified.
    public var ifUnmodifiedSince: Date? {
        get { headers[.ifUnmodifiedSince]?.httpDate }
        set { headers[.ifUnmodifiedSince] = newValue?.httpString }
    }

    /// The relationships between the target resource and other resources.
    public var link: String? {
        get { headers[.link] }
        set { headers[.link] = newValue }
    }

    /// The maximum number of intermediary forwards permitted.
    public var maxForwards: Int? {
        get { headers[.maxForwards].flatMap(Int.init) }
        set { headers[.maxForwards] = newValue.map(String.init) }
    }

    /// The origin from which the request was initiated.
    public var origin: URL? {
        get { headers[.origin].flatMap(URL.init(string:)) }
        set { headers[.origin] = newValue?.absoluteString }
    }

    /// Legacy cache-control directives for HTTP/1.0 servers.
    public var pragma: String? {
        get { headers[.pragma] }
        set { headers[.pragma] = newValue }
    }

    /// The byte range being requested from the resource.
    public var range: String? {
        get { headers[.range] }
        set { headers[.range] = newValue }
    }

    /// The URI of the resource from which the request originated.
    public var referer: URL? {
        get { headers[.referer].flatMap(URL.init(string:)) }
        set { headers[.referer] = newValue?.absoluteString }
    }

    /// The amount of time the client should wait before retrying the request.
    public var retryAfter: String? {
        get { headers[.retryAfter] }
        set { headers[.retryAfter] = newValue }
    }

    /// The transfer codings accepted in trailer fields.
    public var te: [String] {
        get { headers[.te]?.commaSeperated ?? [] }
        set { headers[.te] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The transfer codings applied to the request body.
    public var transferEncoding: [String] {
        get { headers[.transferEncoding]?.commaSeperated ?? [] }
        set { headers[.transferEncoding] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The protocols supported for upgrading the connection.
    public var upgrade: [String] {
        get { headers[.upgrade]?.commaSeperated ?? [] }
        set { headers[.upgrade] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// Information identifying the client software.
    public var userAgent: String? {
        get { headers[.userAgent] }
        set { headers[.userAgent] = newValue }
    }

    /// Information about intermediate protocols and recipients.
    public var via: [String] {
        get { headers[.via]?.commaSeperated ?? [] }
        set { headers[.via] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// Additional warning information associated with the request.
    public var warning: [String] {
        get { headers[.warning]?.commaSeperated ?? [] }
        set { headers[.warning] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The value identifying the mechanism used to make the request.
    public var xRequestedWith: String? {
        get { headers[.xRequestedWith] }
        set { headers[.xRequestedWith] = newValue }
    }

    /// The chain of client IP addresses through which the request was forwarded.
    public var xForwardedFor: [String] {
        get { headers[.xForwardedFor]?.commaSeperated ?? [] }
        set { headers[.xForwardedFor] = newValue.isEmpty ? nil : newValue.joined(separator: ", ") }
    }

    /// The original protocol used by the client before proxy forwarding.
    public var xForwardedProto: String? {
        get { headers[.xForwardedProto] }
        set { headers[.xForwardedProto] = newValue }
    }

    /// The original client IP address reported by a proxy.
    public var xRealIP: String? {
        get { headers[.xRealIP] }
        set { headers[.xRealIP] = newValue }
    }
    
    var headers: [HTTPRequestHeaderField: String]

    init(headers: [HTTPRequestHeaderField: String]) {
        self.headers = headers
    }
}

fileprivate extension String {
    static let httpDateFormatter = DateFormatter("EEE',' dd MMM yyyy HH':'mm':'ss z").locale(.init(identifier: "en_US_POSIX")).timeZone(TimeZone(secondsFromGMT: 0))
    
    var httpDate: Date? {
        Self.httpDateFormatter.date(from: self)
    }
    
    var commaSeperated: [String] {
        split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    var contentTypeParameters: [String: String] {
        var contentTypeParameters: [String: String] = [:]
        for match in matches(pattern: #";\s*([^=;]+)=("(?:\\.|[^"])*"|[^;]*)"#) {
            guard let key = match.groups.nonNil[safe: 0]?.string.trimmingCharacters(in: .whitespaces).lowercased(), var value = match.groups.nonNil[safe: 1]?.string else { continue }
            if value.hasPrefix("\""), value.hasSuffix("\"") {
                value.removeFirst()
                value.removeLast()
                value = value.replacingOccurrences(of: #"\\(.)"#, with: "$1", options: .regularExpression)
            }
            contentTypeParameters[key] = value.trimmingCharacters(in: .whitespaces)
        }
        return contentTypeParameters
    }
}

fileprivate extension Date {
    var httpString: String {
        String.httpDateFormatter.string(from: self)
    }
}
