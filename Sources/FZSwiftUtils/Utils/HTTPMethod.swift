//
//  HTTPMethod.swift
//  
//
//  Created by Florian Zand on 12.03.26.
//

import Foundation

/**
 Represents an HTTP request method.
 
 The raw value corresponds to the exact token sent in an HTTP request line.
 */
public struct HTTPMethod: Sendable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
    
    /// Requests a representation of the specified resource.
    public static let get: Self = "GET"
    
    /// Submits data to be processed by the target resource.
    public static let post: Self = "POST"
    
    /// Replaces the target resource with the request payload.
    public static let put: Self = "PUT"
    
    /// Deletes the specified resource.
    public static let delete: Self = "DELETE"
    
    /// Returns the HTTP headers that a GET request would have returned.
    public static let head: Self = "HEAD"
    
    /// Describes the communication options for the target resource.
    public static let options: Self = "OPTIONS"
    
    /// Performs a message loop-back test along the path to the target resource.
    public static let trace: Self = "TRACE"
    
    /// Establishes a tunnel to the server identified by the target resource.
    public static let connect: Self = "CONNECT"
    
    /// Applies partial modifications to a resource.
    public static let patch: Self = "PATCH"
    
    /// Retrieves properties defined on the resource (WebDAV).
    public static let propfind: Self = "PROPFIND"
    
    /// Changes and deletes properties on a resource (WebDAV).
    public static let proppatch: Self = "PROPPATCH"
    
    /// Creates a new collection (directory) (WebDAV).
    public static let mkcol: Self = "MKCOL"
    
    /// Copies a resource (WebDAV).
    public static let copy: Self = "COPY"
    
    /// Moves a resource (WebDAV).
    public static let move: Self = "MOVE"
    
    /// Locks a resource (WebDAV).
    public static let lock: Self = "LOCK"
    
    /// Removes a lock from a resource (WebDAV).
    public static let unlock: Self = "UNLOCK"
    
    /// Creates a version-controlled resource (WebDAV Versioning).
    public static let versionControl: Self = "VERSION-CONTROL"
    
    /// Retrieves version history information (WebDAV Versioning).
    public static let report: Self = "REPORT"
    
    /// Updates a resource to a specific version (WebDAV Versioning).
    public static let update: Self = "UPDATE"
    
    /// Checks out a resource for editing (WebDAV Versioning).
    public static let checkout: Self = "CHECKOUT"
    
    /// Checks in a previously checked-out resource (WebDAV Versioning).
    public static let checkin: Self = "CHECKIN"
    
    /// Cancels a checkout operation (WebDAV Versioning).
    public static let uncheckout: Self = "UNCHECKOUT"
    
    /// Merges changes between versions (WebDAV Versioning).
    public static let merge: Self = "MERGE"
    
    /// Creates a new activity (WebDAV Versioning).
    public static let mkactivity: Self = "MKACTIVITY"
    
    /// Applies a label to a resource version (WebDAV Versioning).
    public static let label: Self = "LABEL"
    
    /// Creates a new binding to a resource (WebDAV Binding Extensions).
    public static let bind: Self = "BIND"
    
    /// Removes a binding to a resource (WebDAV Binding Extensions).
    public static let unbind: Self = "UNBIND"
    
    /// Rebinds a resource to a different path (WebDAV Binding Extensions).
    public static let rebind: Self = "REBIND"
    
    /// Used by UPnP discovery to search for devices.
    public static let mSearch: Self = "M-SEARCH"
    
    /// Sends event notifications (UPnP).
    public static let notify: Self = "NOTIFY"
    
    /// Subscribes to event notifications (UPnP).
    public static let subscribe: Self = "SUBSCRIBE"
    
    /// Cancels an event subscription (UPnP).
    public static let unsubscribe: Self = "UNSUBSCRIBE"
    
    /// Performs a query-based search on a resource.
    public static let search: Self = "SEARCH"
}
