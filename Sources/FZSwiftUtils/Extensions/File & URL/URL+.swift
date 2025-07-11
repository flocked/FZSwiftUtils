//
//  URL+.swift
//  
//
//  Created by Florian Zand on 07.05.22.
//

import Foundation

public extension URL {
    /**
     Creates a file URL with the specified path components.

     - Parameter pathComponents: The path components of the URL.
     */
    init(fileURLWithComponents pathComponents: [String]) {
        self.init(fileURLWithPath: pathComponents.joined(separator: "/"))
    }
    
    /**
     Creates a `URL` from the provided string and query items.
     
     - Parameters:
        - string: The URL location.
        - queryItems: The query items.
     
     - Returns: The `URL`, or `nil` if the string is not a valid a url.
     */
    init?(string: String, @URLComponents.Builder queryItems: () -> [URLQueryItem]) {
        guard let url = URLComponents(string: string, queryItems: queryItems)?.url else { return nil }
        self = url
    }
    
    /**
     Creates a `URL` from the provided `URL` and query items.
     
     - Parameters:
        - url: The `URL` to parse.
        - resolve: A Boolean value indicating whether the initializer resolves the URL against its base URL before parsing. If `url` is a relative URL, setting resolve to `true` creates components using the `absoluteURL` property.
        - queryItems: The query items.
     
     - Returns: The `URL`, or `nil` if the url is not a valid a url.
     */
    init?(url: URL, resolvingAgainstBaseURL resolve: Bool, @URLComponents.Builder queryItems: () -> [URLQueryItem]) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: resolve, queryItems: queryItems)?.url else { return nil }
        self = url
    }
    
    /**
     Creates a file URL that references the local file or directory at path.
     
     - Parameters:
       - filePath: The location in the file system.
       - relativeTo: A URL that provides a file system location that the path extends.
     */
    @_disfavoredOverload
    static func file(_ path: String, relativeTo base: URL? = nil) -> URL {
        URL(fileURLWithPath: path, relativeTo: base)
    }
    
    /**
     Creates a file URL that references the local file or directory at path.

     - Parameters:
       - filePath: The location in the file system.
       - directoryHint: A hint indicating whether the file path represents a directory or a file.
       - relativeTo: A URL that provides a file system location that the path extends.
     
     If `base` is provided, the file path will be resolved relative to this base URL.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func file(_ path: String, directoryHint: DirectoryHint = .inferFromPath, relativeTo base: URL? = nil) -> URL {
        URL(filePath: path, directoryHint: directoryHint, relativeTo: base)
    }
    
    /**
     Creates a file URL with the specified path components.

     - Parameter pathComponents: The path components of the URL.
     */
    static func file(_ pathComponents: [String]) -> URL {
        URL(fileURLWithComponents: pathComponents)
    }
    
    /**
     Creates a URL instance from the provided string.
     
     - Parameter string: A URL location.
     */
    static func string(_ string: String) -> URL? {
        URL(string: string)
    }
    
    /**
     Creates a URL instance from the provided string, relative to another URL.
     
     - Parameters:
        - string: A URL location.
        - url: A URL that provides a base location that the string extends.
     */
    static func string(_ string: String, relativeTo url: URL?) -> URL? {
        URL(string: string, relativeTo: url)
    }
    
    /**
     Creates a URL that refers to the location specified by resolving an alias file.
     
     If the url argument doesn’t refer to an alias file (as defined by the [isAliasFileKey](https://developer.apple.com/documentation/foundation/urlresourcekey/isaliasfilekey)] property), the returned URL is the same as the url argument.
     
     This method doesn’t support the [withSecurityScope](https://developer.apple.com/documentation/foundation/nsurl/bookmarkcreationoptions/withsecurityscope) option.
     
     - Parameters:
        - url: URL to the alias file.
        - options: Options for resolving the url.
     - Throws: If the url argument is unreachable, the original file or directory is unknown or unreachable or the original file or directory is on a volume that the system can’t locate or can’t mount.
     */
    static func aliasFile(at url: URL, options: URL.BookmarkResolutionOptions = []) throws -> URL {
        try URL(resolvingAliasFileAt: url, options: options)
    }
    
    /**
     Creates a URL that refers to a location specified by resolving bookmark data.
     
     - Parameters:
        - url: The bookmark data used to construct a URL.
        - options: Options taken into account when resolving the bookmark data. To resolve a security-scoped bookmark to support App Sandbox, include the [withSecurityScope](https://developer.apple.com/documentation/foundation/nsurl/bookmarkcreationoptions/withsecurityscope) option.
        - url: The base URL that the bookmark data is relative to. If you’re resolving a security-scoped bookmark to obtain a security-scoped URL, use this parameter as follows: To resolve an app-scoped bookmark, use a value of nil. To resolve a document-scoped bookmark, use the absolute path (despite this parameter’s name) to the document from which you retrieved the bookmark.
     App Sandbox doesn’t restrict which URL values you can pass to this parameter.
        - bookmarkDataIsStale: On return, if `true`, the bookmark data is stale. Your app should create a new bookmark using the returned URL and use it in place of any stored copies of the existing bookmark.
     */
    static func bookmarkData(_ data: Data, options: URL.BookmarkResolutionOptions = [], relativeTo url: URL? = nil, bookmarkDataIsStale: inout Bool) throws -> URL {
        try URL(resolvingBookmarkData: data, options: options, relativeTo: url, bookmarkDataIsStale: &bookmarkDataIsStale)
    }
    
    /// Returns a URL constructed by changing the path extension.
    func pathExtension(_ pathExtension: String) -> URL {
        deletingPathExtension().appendingPathExtension(pathExtension)
    }
    
    /**
     Returns a URL constructed by changing the last path component.
     
     - Parameters:
        - pathComponent: The new path component.
        - includePathExtension: A Boolean value indicating whether the path extension should also be changed.
     */
    @_disfavoredOverload
    func lastPathComponent(_ pathComponent: String, includePathExtension: Bool = true) -> URL {
        let pathExtension = pathExtension
        let url = deletingLastPathComponent().appendingPathComponent(pathComponent)
        return includePathExtension ? url : url.appendingPathExtension(pathExtension)
    }
    
    /**
     Returns a URL constructed by changing the last path component.
     
     - Parameters:
        - pathComponent: The new path component.
        - directoryHint: A hint indicating whether the new path component represents a directory or a file.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func lastPathComponent(_ pathComponent: String, directoryHint: DirectoryHint = .inferFromPath) -> URL  {
        deletingLastPathComponent().appending(path: pathComponent, directoryHint: directoryHint)
    }
    
    /// Appends the path components to the URL.
    mutating func appendPathComponents(_ pathComponents: [String]) {
        pathComponents.forEach({ appendPathComponent($0) })
    }
    
    /// Returns a URL by appending the specified path components to self.
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        pathComponents.reduce(self) { $0.appendingPathComponent($1) }
    }

    ///  A Boolean value indicating whether the resource is a directory.
    var isDirectory: Bool {
        resources.isDirectory
    }

    ///  A Boolean value indicating whether the resource is a regular file rather than a directory or a symbolic link.
    var isFile: Bool {
        resources.isRegularFile
    }
    
    /**
     Returns a URL constructed by removing the last path components of self.
     
     If the URL has an empty path (e.g., http://www.example.com), then this function will return the URL unchanged.
     
     - Parameter amount: The number of path components to remove.
     */
    func deletingLastPathComponents(amount: Int) -> URL {
        pathComponents.reduce(self) { url,_ in url.deletingLastPathComponent() }
    }
    
    /**
     Returns a URL constructed by removing the last path components of self.
     
     If the URL has an empty path (e.g., `http://www.example.com`), then this function will return the URL unchanged.
     
     - Parameter amount: The number of path components to remove.
     */
    mutating func deleteLastPathComponents(amount: Int) {
        (0..<amount).forEach({ _ in deleteLastPathComponent() })
    }
    
    /// The path component at the specific index.
    subscript(pathComponent index: Int) -> String? {
        get { pathComponents[safe: index]}
        set {
            var pathComponents = pathComponents
            guard index < pathComponents.count else { return }
            pathComponents[safe: index] = newValue
            (index..<pathComponents.count).forEach({_ in deleteLastPathComponent() })
        }
    }
    
    /// The name of the url (`lastPathComponent`).
    var name: String {
        lastPathComponent
    }
    
    /// The name of the url (`lastPathComponent`) excluding the path extension.
    var nameExludingExtension: String {
        deletingPathExtension().lastPathComponent
    }

    /// A Boolean value indicating whether the URL’s resource exists and is reachable.
    var isReachable: Bool {
        (try? checkResourceIsReachable()) == true
    }

    /// The parent directory of the url, or `nil` if there isn't any parent.
    var parent: URL? {
        let parent = deletingLastPathComponent()
        if parent.path != path {
            return parent
        }
        return nil
    }

    ///  A Boolean value indicating whether the resource exist.
    var exists: Bool {
        FileManager.default.fileExists(at: self)
    }

    /**
     The components of the url.

     - Parameter resolve: A Boolean value indicating whether the url should be resolved against its base URL before parsing. If `true`, and if the url parameter contains a relative URL, the original URL is resolved against its base URL before parsing by calling the `absoluteURL` method. Otherwise, the string portion is used by itself.
     */
    func urlComponents(resolvingAgainstBase resolve: Bool = false) -> URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: resolve)
    }

    /// The query items for the url.
    var queryItems: [URLQueryItem]? {
        urlComponents()?.queryItems
    }

    /// Returns the url without it's [schema](https://developer.apple.com/documentation/foundation/url/scheme).
    func droppedScheme() -> URL? {
        if let scheme = scheme {
            let droppedScheme = String(absoluteString.dropFirst(scheme.count + 3))
            return URL(string: droppedScheme)
        }

        guard host != nil else { return self }

        let droppedScheme = String(absoluteString.dropFirst(2))
        return URL(string: droppedScheme)
    }
    
    /// A Boolean value indicating whether the url is a parent of the other url.
    func isParent(of url: URL) -> Bool {
        url.isChild(of: self)
    }
    
    /// A Boolean value indicating whether the url is a child of the other url.
    func isChild(of url: URL) -> Bool {
        childDepth(in: url) ?? 0 > 0
    }
    
    /// The child depth of the url inside the other url, or `nil` if the url isn't a child.
    func childDepth(in url: URL) -> Int? {
        let comp1 = url.canonicalized.pathComponents
        let comp2 = canonicalized.pathComponents
        let depth = comp2.count - comp1.count
        guard !zip(comp1, comp2).contains(where: !=), depth >= 0 else { return nil }
        return depth
    }
    
    #if os(macOS) || os(iOS)
    /// A Boolean value indicating whether the file is in the trash.
    var isTrashed: Bool {
        if #available(macOS 13.0, iOS 16.0, *) {
            return self.path.contains(Self.trashDirectory.path)
        }
         guard let trashURL = try? FileManager.default.url(for:.trashDirectory, in:.userDomainMask, appropriateFor:self, create:false) else { return false }
         return self.path.contains(trashURL.path)
     }
    #endif
    
    /**
     The url as a canonical absolute file system url.
     
     If the ``isFile`` is `false`, this method returns itself.
     */
    internal var canonicalized: URL {
        standardizedFileURL.resolvingSymlinksInPath()
    }
    
    internal func resourceValues(for key: URLResourceKey) throws -> URLResourceValues {
        try resourceValues(forKeys: [key])
    }
}

#if os(macOS)
@available(macOS, obsoleted: 11.0, message: "Use contentType instead")
public extension URL {
    /// The content type identifier of the url.
    var contentTypeIdentifier: String? { resources._contentTypeIdentifier }
    /// The content type identifier tree of the url.
    var contentTypeIdentifierTree: [String] { resources._contentTypeIdentifierTree }
}
#endif

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

public extension URL {
    /// A hint for determining whether a file path represents a directory.
    @available(macOS, obsoleted: 13.0)
    @available(iOS, obsoleted: 16.0)
    @available(tvOS, obsoleted: 16.0)
    @available(watchOS, obsoleted: 9.0)
    enum FilePathDirectoryHint {
        /**
         Infers the type based on the file path string.
         
         A trailing slash (`/`) in the file path is used to guess whether the path represents a directory.
         */
        case inferFromPath
        /// Indicates that the file path should be treated as a directory.
        case isDirectory
        /// Indicates that the file path should not be treated as a directory.
        case notDirectory
        /**
         Checks the filesystem to determine if the file path represents a directory.
         
         This case uses `FileManager` to inspect the actual file system, which may incur a performance cost.
         */
        case checkFileSystem
    }
    
    /**
     Creates a file URL that references the local file or directory at path.

     - Parameters:
       - filePath: The location in the file system.
       - directoryHint: A hint indicating whether the file path represents a directory or a file.
       - relativeTo: A URL that provides a file system location that the path extends.
     
     If `base` is provided, the file path will be resolved relative to this base `URL`.
     */
    @available(macOS, obsoleted: 13.0)
    @available(iOS, obsoleted: 16.0)
    @available(tvOS, obsoleted: 16.0)
    @available(watchOS, obsoleted: 9.0)
    static func file(_ path: String, isDirectory directoryHint: FilePathDirectoryHint, relativeTo base: URL? = nil) -> URL {
        URL(filePath: path, isDirectory: directoryHint, relativeTo: base)
    }
    
    /**
     Creates a file URL that references the local file or directory at path.

     - Parameters:
       - filePath: The location in the file system.
       - directoryHint: A hint indicating whether the file path represents a directory or a file.
       - relativeTo: A URL that provides a file system location that the path extends.
     
     If `base` is provided, the file path will be resolved relative to this base `URL`.
     */
    @available(macOS, obsoleted: 13.0)
    @available(iOS, obsoleted: 16.0)
    @available(tvOS, obsoleted: 16.0)
    @available(watchOS, obsoleted: 9.0)
    init(filePath path: String, isDirectory directoryHint: FilePathDirectoryHint = .inferFromPath, relativeTo base: URL? = nil) {
        if let base = base {
            switch directoryHint {
            case .isDirectory:
                self = base.appendingPathComponent(path, isDirectory: true)
            case .notDirectory:
                self = base.appendingPathComponent(path, isDirectory: false)
            case .inferFromPath:
                self = base.appendingPathComponent(path, isDirectory: path.hasSuffix("/"))
            case .checkFileSystem:
                self = base.appendingPathComponent(path, isDirectory: FileManager.default.directoryExists(at: base.appendingPathComponent(path)))
            }
        } else {
            switch directoryHint {
            case .isDirectory:
                self.init(fileURLWithPath: path, isDirectory: true)
            case .notDirectory:
                self.init(fileURLWithPath: path, isDirectory: false)
            case .inferFromPath:
                self.init(fileURLWithPath: path)
            case .checkFileSystem:
                if !path.hasSuffix("/") {
                    self.init(fileURLWithPath: path, isDirectory: URL(fileURLWithPath: path).resources.isDirectory)
                } else {
                    self.init(fileURLWithPath: path, isDirectory: true)
                }
            }
        }
    }
}
