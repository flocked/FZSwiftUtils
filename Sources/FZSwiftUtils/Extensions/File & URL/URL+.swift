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
     Creates a `URL` from the provided string and query items.
     
     - Parameters:
        - string: The URL location.
        - queryItems: The query items.
     
     - Returns: The `URL`, or `nil` if the string is not a valid a url.
     */
    init?(string: String, resolvingAgainstBaseURL resolve: Bool, queryItems: [URLQueryItem]) {
        guard let url = URLComponents(string: string)?.queryItems(queryItems).url else { return nil }
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
     Creates a `URL` from the provided `URL` and query items.
     
     - Parameters:
        - url: The `URL` to parse.
        - resolve: A Boolean value indicating whether the initializer resolves the URL against its base URL before parsing. If `url` is a relative URL, setting resolve to `true` creates components using the `absoluteURL` property.
        - queryItems: The query items.
     
     - Returns: The `URL`, or `nil` if the url is not a valid a url.
     */
    init?(url: URL, resolvingAgainstBaseURL resolve: Bool, queryItems: [URLQueryItem]) {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: resolve)?.queryItems(queryItems).url else { return nil }
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
    func pathExtension(_ pathExtension: String? = nil) -> URL {
        deletingPathExtension().appendingPathExtension(pathExtension ?? "nil")
    }
    
    /// Changes the path extension of the url
    mutating func pathExtension(_ pathExtension: String? = nil) {
        self = self.pathExtension(pathExtension)
    }
    
    /**
     Returns a URL constructed by changing the last path component.
     
     - Parameters:
        - pathComponent: The new path component.
        - replacePathExtension: A Boolean value indicating whether the path extension should also be replaced.
     */
    @_disfavoredOverload
    func lastPathComponent(_ pathComponent: String, replacePathExtension: Bool = true) -> URL {
        let pathExtension = pathExtension
        let url = deletingLastPathComponent().appendingPathComponent(pathComponent)
        return replacePathExtension ? url : url.appendingPathExtension(pathExtension)
    }
    
    /**
     Changes the last path component of the url.
     
     - Parameters:
        - pathComponent: The new path component.
        - replacePathExtension: A Boolean value indicating whether the path extension should also be replaced.
     */
    @_disfavoredOverload
    mutating func lastPathComponent(_ pathComponent: String, replacePathExtension: Bool = true) {
        self = self.lastPathComponent(pathComponent, replacePathExtension: replacePathExtension)
    }
    
    /**
     Returns a URL constructed by changing the last path component.
     
     - Parameters:
        - pathComponent: The new path component.
        - directoryHint: A hint indicating whether the new path component represents a directory or a file.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func lastPathComponent(_ pathComponent: String, directoryHint: DirectoryHint = .inferFromPath) -> URL {
        deletingLastPathComponent().appending(path: pathComponent, directoryHint: directoryHint)
    }
    
    /**
     Changes the last path component of the url.
     
     - Parameters:
        - pathComponent: The new path component.
        - directoryHint: A hint indicating whether the new path component represents a directory or a file.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func lastPathComponent(_ pathComponent: String, directoryHint: DirectoryHint = .inferFromPath) {
        self = lastPathComponent(pathComponent, directoryHint: directoryHint)
    }
    
    /// Appends the path components to the URL.
    mutating func appendPathComponents(_ pathComponents: [String]) {
        pathComponents.forEach({ appendPathComponent($0) })
    }
    
    /// Returns a URL by appending the specified path components to self.
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        pathComponents.reduce(self) { $0.appendingPathComponent($1) }
    }
    
    /**
     Appends multiple path components to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func appending<S: Sequence>(components: S, directoryHint: DirectoryHint = .inferFromPath) -> URL where S.Element: StringProtocol {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint) })
        return url
    }
    
    /**
     Appends multiple path components to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    mutating func append<S: Sequence>(components: S, directoryHint: DirectoryHint = .inferFromPath) where S.Element: StringProtocol {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint) })
        self = url
    }

    ///  A Boolean value indicating whether the resource is a directory.
    var isDirectory: Bool {
        resources.isDirectory
    }

    ///  A Boolean value indicating whether the resource is a regular file rather than a directory or a symbolic link.
    var isFile: Bool {
        resources.isRegularFile
    }
    
    /// A Boolean value indicating whether the URL’s resource exists and is reachable.
    var isReachable: Bool {
        (try? checkResourceIsReachable()) == true
    }
    
    ///  A Boolean value indicating whether the resource exist.
    var exists: Bool {
        FileManager.default.fileExists(at: self)
    }
    
    #if os(macOS) || os(iOS)
    /// A Boolean value indicating whether the file is in the trash.
    var isTrashed: Bool {
        guard isFileURL else { return false }
        if #available(macOS 13.0, iOS 16.0, *) {
            return path.hasPrefix(URL.trashDirectory.path)
        }
        guard let trashURL = try? FileManager.default.url(for:.trashDirectory, in:. userDomainMask, appropriateFor: self, create:false) else { return false }
        return path.hasPrefix(trashURL.path)
    }
    #endif
    
    /**
     Returns a URL constructed by removing the last path components of self by the specified amount.
          
     - Parameter amount: The number of path components to remove.
     */
    func deletingLastPathComponents(amount: Int) -> URL {
        var url = self
        url.deleteLastPathComponents(amount: amount)
        return url
    }
    
    /**
     Returns a URL constructed by removing the last path components of self by the specified amount.
          
     - Parameter amount: The number of path components to remove.
     */
    mutating func deleteLastPathComponents(amount: Int) {
        (0..<amount).forEach({ _ in deleteLastPathComponent() })
    }
    
    /**
     Returns a descendant URL that is a specified number of levels below the first ancestor whose path contains the given component.

     For example:
     ```
     "/Users/Adam/Downloads/FZSwiftUtils/Package.swift"
     
     - ancestor(containing: "Adam")
        -> "/Users/Adam/"
     - ancestor(containing: "Adam", depthBelow: 2)
        -> "/Users/Adam/Downloads/FZSwiftUtils/"
     - ancestor(containing: "Adam", depthBelow: 100)
        -> nil
     ```
     
     - Parameters:
       - pathComponent: The name of the path component to search for among ancestor directories.
       - depthBelow: The number of levels below the found component to return.
     - Returns: A URL `depthBelow` levels beneath the ancestor containing `pathComponent`, or `nil` if not found.
     */
    func ancestor(containing pathComponent: String, depthBelow: Int = 0) -> URL? {
        let pathComponents = pathComponents
        guard let index = pathComponents.firstIndex(of: pathComponent), index + depthBelow < pathComponents.count else { return nil }
        return deletingLastPathComponents(amount: pathComponents.count - 1 - (index + depthBelow))
    }
    
    /// The path component at the specific index.
    subscript(pathComponent index: Int) -> String? {
        get { pathComponents[safe: index]}
        set {
            let pathComponents = pathComponents
            guard index >= 0, index < pathComponents.count else { return }
            (0..<(pathComponents.count - index)).forEach({ _ in deleteLastPathComponent() })
            guard let newValue = newValue else { return }
            appendPathComponent(newValue)
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
    
    /// The parent directory of the url, or `nil` if there isn't any parent.
    var parent: URL? {
        let parent = deletingLastPathComponent()
        guard parent.path != path else { return nil }
        return parent
    }

    /**
     The components of the url.

     - Parameter resolve: A Boolean value indicating whether the url should be resolved against its base URL before parsing. If `true`, and if the url parameter contains a relative URL, the original URL is resolved against its base URL before parsing by calling the [absoluteURL](https://developer.apple.com/documentation/foundation/url/absoluteurl) method. Otherwise, the string portion is used by itself.
     */
    func urlComponents(resolvingAgainstBase resolve: Bool = false) -> URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: resolve)
    }

    /// The query items for the url.
    var queryItems: [URLQueryItem]? {
        urlComponents()?.queryItems
    }

    /// Returns the url without it's [scheme](https://developer.apple.com/documentation/foundation/url/scheme).
    func droppedScheme() -> URL {
        if let scheme = scheme {
            return URL(string: String(absoluteString.dropFirst(scheme.count + 3))) ?? self
        }
        guard host != nil else { return self }
        return URL(string: String(absoluteString.dropFirst(2))) ?? self
    }
    
    /// Removes the [scheme](https://developer.apple.com/documentation/foundation/url/scheme).
    mutating func dropScheme() {
        self = droppedScheme()
    }
    
    /// A Boolean value indicating whether the file url is a parent of the other url.
    func isParent(of url: URL) -> Bool {
        guard isFileURL, url.isFileURL else { return false }
        let selfPath = standardizedFileURL.path
        return url.standardizedFileURL.path.hasPrefix(selfPath.hasSuffix("/") ? selfPath : selfPath + "/")
    }
    
    /// A Boolean value indicating whether the file url is a child of the other url.
    func isChild(of url: URL) -> Bool {
        url.isParent(of: self)
    }
    
    /// The child depth of the file url inside the other url, or `nil` if the url isn't a child.
    func childDepth(in url: URL) -> Int? {
        guard isChild(of: url) else { return nil }
        return standardizedFileURL.pathComponents.count - url.standardizedFileURL.pathComponents.count
    }
    
    static func + (lhs: URL, rhs: String) -> Self {
        lhs.appendingPathComponent(rhs)
    }
    
    static func += (lhs: inout URL, rhs: String) {
        lhs = lhs + rhs
    }
    
    static func + (lhs: URL, rhs: [String]) -> Self {
        lhs.appendingPathComponents(rhs)
    }
    
    static func += (lhs: inout URL, rhs: [String]) {
        lhs = lhs + rhs
    }
    
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func + (lhs: URL, rhs: URLQueryItem) -> Self {
        lhs.appending(queryItems: [rhs])
    }
    
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func += (lhs: inout URL, rhs: URLQueryItem) {
        lhs = lhs + rhs
    }
    
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func + (lhs: URL, rhs: [URLQueryItem]) -> Self {
        lhs.appending(queryItems: rhs)
    }
    
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func += (lhs: inout URL, rhs: [URLQueryItem]) {
        lhs = lhs + rhs
    }
    
    /**
     The url as a canonical absolute file system url.
     
     If the ``isFile`` is `false`, this method returns itself.
     */
    internal var canonicalized: URL {
        standardizedFileURL.resolvingSymlinksInPath()
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

@available(macOS, obsoleted: 13.0)
@available(iOS, obsoleted: 16.0)
@available(tvOS, obsoleted: 16.0)
@available(watchOS, obsoleted: 9.0)
public extension URL {
    /// A hint for determining whether a file path represents a directory.
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
    
    /**
     Returns a URL by appending the specified path to the URL, with a hint for handling directory awareness.
          
     - Parameters:
        - path: The path to add.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     - Returns: A new URL that appends the specified path to the original URL.
     */
    func appending<S: StringProtocol>(path: S, directoryHint: FilePathDirectoryHint = .inferFromPath) -> URL {
        var url = self
        for component in path.components(separatedBy: "/") {
            switch directoryHint {
            case .isDirectory:
                url = url.appendingPathComponent(component, isDirectory: true)
            case .notDirectory:
                url = url.appendingPathComponent(component, isDirectory: false)
            case .inferFromPath:
                url = url.appendingPathComponent(component, isDirectory: path.hasSuffix("/"))
            case .checkFileSystem:
                url = url.appendingPathComponent(component, isDirectory: FileManager.default.directoryExists(at: appendingPathComponent(component)))
            }
        }
        return url
    }
    
    /**
     Appends a path to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - path: The path to add.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    mutating func append<S: StringProtocol>(path: S, directoryHint: FilePathDirectoryHint = .inferFromPath) {
        for component in path.components(separatedBy: "/") {
            switch directoryHint {
            case .isDirectory:
                self = appendingPathComponent(component, isDirectory: true)
            case .notDirectory:
                self = appendingPathComponent(component, isDirectory: false)
            case .inferFromPath:
                self = appendingPathComponent(component, isDirectory: path.hasSuffix("/"))
            case .checkFileSystem:
                self = appendingPathComponent(component, isDirectory: FileManager.default.directoryExists(at: appendingPathComponent(component)))
            }
        }
    }
    
    /**
     Returns a URL by appending the specified path component to the URL, with a hint for handling directory awareness.
     
     This method percent-encodes any path separators (`/`) in the path component before appending the component to the path. If you don’t want this encoding, use ``Foundation/URL/appending(path:directoryHint:)`` instead.
     
     - Parameters:
        - component: The path component to add.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     - Returns: A new URL that appends the specified path to the original URL.
     */
    func appending<S: StringProtocol>(component: S, directoryHint: FilePathDirectoryHint = .inferFromPath) -> URL {
        let component = String(component)
        switch directoryHint {
        case .isDirectory:
            return appendingPathComponent(component, isDirectory: true)
        case .notDirectory:
            return appendingPathComponent(component, isDirectory: false)
        case .inferFromPath:
            return appendingPathComponent(component, isDirectory: path.hasSuffix("/"))
        case .checkFileSystem:
            return appendingPathComponent(component, isDirectory: FileManager.default.directoryExists(at: appendingPathComponent(component)))
        }
    }
    
    /**
     Appends a path component to the URL, with a hint for handling directory awareness.
     
     This method percent-encodes any path separators (`/`) in the path component before appending the component to the path. If you don’t want this encoding, use ``Foundation/URL/append(path:directoryHint:)`` instead.
     
     - Parameters:
        - component: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    mutating func append<S: StringProtocol>(component: S, directoryHint: FilePathDirectoryHint = .inferFromPath) {
        let component = String(component)
        switch directoryHint {
        case .isDirectory:
            self = appendingPathComponent(component, isDirectory: true)
        case .notDirectory:
            self = appendingPathComponent(component, isDirectory: false)
        case .inferFromPath:
            self = appendingPathComponent(component, isDirectory: path.hasSuffix("/"))
        case .checkFileSystem:
            self = appendingPathComponent(component, isDirectory: FileManager.default.directoryExists(at: appendingPathComponent(component)))
        }
    }
    
    /**
     Returns a new URL by appending multiple path components to the URL, with a hint for handling directory awareness.
          
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     - Returns: A new URL that appends the specified components to the original URL.
     */
    func appending<S: StringProtocol>(components: S..., directoryHint: FilePathDirectoryHint = .inferFromPath) -> URL {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint)})
        return url
    }
    
    /**
     Appends multiple path components to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    mutating func append<S: StringProtocol>(components: S..., directoryHint: FilePathDirectoryHint = .inferFromPath) {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint)})
        self = url
    }
    
    /**
     Appends multiple path components to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    func append<S: Sequence>(components: S, directoryHint: FilePathDirectoryHint = .inferFromPath) -> URL where S.Element: StringProtocol {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint)})
        return url
    }
    
    /**
     Appends multiple path components to the URL, with a hint for handling directory awareness.
     
     - Parameters:
        - components: The path components to add, as a variadic parameter.
        - directoryHint: A hint to the initializer to indicate whether the path is a directory, or to instruct the method to make this determination.
     */
    mutating func append<S: Sequence>(components: S, directoryHint: FilePathDirectoryHint = .inferFromPath) where S.Element: StringProtocol {
        var url = self
        components.forEach({ url = url.appending(component: $0, directoryHint: directoryHint)})
        self = url
    }
    
    /**
     Returns a URL constructed by changing the last path component.
     
     - Parameters:
        - pathComponent: The new path component.
        - directoryHint: A hint indicating whether the new path component represents a directory or a file.
     */
    func lastPathComponent(_ pathComponent: String, directoryHint: FilePathDirectoryHint = .inferFromPath) -> URL {
        deletingLastPathComponent().appending(component: pathComponent, directoryHint: directoryHint)
    }
    
    /**
     Changes the last path component of the url.
     
     - Parameters:
        - pathComponent: The new path component.
        - directoryHint: A hint indicating whether the new path component represents a directory or a file.
     */
    mutating func lastPathComponent(_ pathComponent: String, directoryHint: FilePathDirectoryHint = .inferFromPath) {
        self = lastPathComponent(pathComponent, directoryHint: directoryHint)
    }
}
