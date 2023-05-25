//
//  URL+Extension.swift
//  FZCollection
//
//  Created by Florian Zand on 07.05.22.
//

import Foundation

public extension URL {
    var contentTypeIdentifier: String? { resources.contentTypeIdentifier }

    var contentTypeIdentifierTree: [String] { resources.contentTypeIdentifierTree }

    var isDirectory: Bool {
        resources.isDirectory
    }

    var isFile: Bool {
        pathExtension != ""
    }

    var isReachable: Bool {
        (try? checkResourceIsReachable()) == true
    }

    internal func resourceValues(for key: URLResourceKey) throws -> URLResourceValues {
        return try resourceValues(forKeys: [key])
    }

    var parent: URL? {
        let parent = deletingLastPathComponent()
        if parent.path != path {
            return parent
        }
        return nil
    }

    var fileExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    func urlComponents(resolvingAgainstBase _: Bool = false) -> URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }

    var queryItems: [URLQueryItem]? {
        return urlComponents()?.queryItems
    }

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

#if canImport(UniformTypeIdentifiers)
    import UniformTypeIdentifiers
    @available(macOS 11.0, iOS 14.0, *)
    public extension URL {
        var contentType: UTType? {
            UTType(url: self)
        }
    }
#endif
