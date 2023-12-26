//
//  URL+.swift
//  FZCollection
//
//  Created by Florian Zand on 07.05.22.
//

import Foundation


public extension URL {
    /**
     Creates a file URL that references the local file or directory at path.

     If the path is an empty string, the system interprets it as “.”.
     
     - parameter path: The location in the file system.
     */
    static func file(_ path: String) -> URL {
        URL(fileURLWithPath: path)
    }
    
    ///  A Boolean value indicating whether the resource is a directory.
    var isDirectory: Bool {
        resources.isDirectory
    }

    ///  A Boolean value indicating whether the resource is a file.
    var isFile: Bool {
        resources.isRegularFile
    }

    /// A Boolean value indicating whether the URL’s resource exists and is reachable.
    var isReachable: Bool {
        (try? checkResourceIsReachable()) == true
    }

    internal func resourceValues(for key: URLResourceKey) throws -> URLResourceValues {
        return try resourceValues(forKeys: [key])
    }

    /// The parent directory of the url.
    var parent: URL? {
        let parent = deletingLastPathComponent()
        if parent.path != path {
            return parent
        }
        return nil
    }

    ///  A Boolean value indicating whether the resource exist.
    var fileExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    /**
     The components of the url.
     
     - Parameter resolve: Controls whether the URL should be resolved against its base URL before parsing. If true, and if the url parameter contains a relative URL, the original URL is resolved against its base URL before parsing by calling the absoluteURL method. Otherwise, the string portion is used by itself.
     - Returns: A `URLComponents` for the url.
     */
    func urlComponents(resolvingAgainstBase resolve: Bool = false) -> URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: resolve)
    }

    /// An array of query items for the URL in the order in which they appear in the original query string.
    var queryItems: [URLQueryItem]? {
        return urlComponents()?.queryItems
    }

    /// Returns the url without schema.
    func droppedScheme() -> URL? {
        if let scheme = scheme {
            let droppedScheme = String(absoluteString.dropFirst(scheme.count + 3))
            return URL(string: droppedScheme)
        }

        guard host != nil else { return self }

        let droppedScheme = String(absoluteString.dropFirst(2))
        return URL(string: droppedScheme)
    }
}

@available(macOS, deprecated: 11.0, message: "Use contentType instead")
@available(iOS, deprecated: 14.0, message: "Use contentType instead")
@available(macCatalyst, deprecated: 14.0, message: "Use contentType instead")
@available(tvOS, deprecated: 14.0, message: "Use contentType instead")
@available(watchOS, deprecated: 7.0, message: "Use contentType instead")
public extension URL {
    /// The content type identifier of the url.
    var contentTypeIdentifier: String? { resources.contentTypeIdentifier }
    /// The content type identifier tree of the url.
    var contentTypeIdentifierTree: [String] { resources.contentTypeIdentifierTree }
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension URL {
    /// The content type of the url.
    var contentType: UTType? {
        UTType(url: self)
    }
}
#endif
