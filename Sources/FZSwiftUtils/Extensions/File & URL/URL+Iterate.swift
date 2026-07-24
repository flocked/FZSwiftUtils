//
//  URL+DirectoryEnumerator.swift
//
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
    /**
     Returns a sequence for enumerating the contents of this directory.

     By default, the sequence skips hidden items, package contents, and subdirectory descendants.
     
     Use the returned sequence’s modifiers to enable recursive enumeration, include hidden items, include package contents, filter results, prune descendant traversal, or prefetch resource values:
          
     - ``Foundation/URL/URLSequence/recursive``: Includes the contents of all subdirectories, recursively.
     - ``Foundation/URL/URLSequence/recursive(maxDepth:)``: Includes the contents of subdirectories up to the specified depth.
     - ``Foundation/URL/URLSequence/includingHidden``: Includes hidden files and directories.
     - ``Foundation/URL/URLSequence/includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     
     Example usage:
     ```swift
     for url in folder.iterate().recursive {
     
     }
     ```
     */
    func iterate() -> URLSequence {
        URLSequence(url: self)
    }
    
    /**
     Returns a sequence for enumerating files in this directory.

     By default, only top-level, non-hidden files are returned.
     
     Use the returned sequence’s modifiers to recurse into subdirectories, include hidden items, include package contents, filter by extension or type, prune descendant traversal, or prefetch resource values:
     
     - ``Foundation/URL/FileURLSequence/recursive``: Includes files in all subdirectories, recursively.
     - ``Foundation/URL/FileURLSequence/recursive(maxDepth:)``: Includes files in subdirectories up to the specified depth.
     - ``Foundation/URL/FileURLSequence/includingHidden``: Includes hidden files and files in hidden directories.
     - ``Foundation/URL/FileURLSequence/includingPackageContents``: Includes files in package directories (e.g., .app, .bundle, etc.).
     
     You can also add:
          
     - ``Foundation/URL/FileURLSequence/extensions(_:)-([String])``: The file extensions to iterate.
     - ``Foundation/URL/FileURLSequence/types(_:)-([FileType])``: The file types to iterate.
     - ``Foundation/URL/FileURLSequence/contentTypes(_:)-([UTType])``: The file content types to iterate.
     
     Example usage:
     
     ````swift
     for file in folder.iterateFiles().types(.video, .image).recursive {
     
     }
     ````
     */
    func iterateFiles() -> FileURLSequence {
        FileURLSequence(url: self)
    }

    /**
     Returns a sequence for enumerating folders in this directory.

     By default, only top-level, non-hidden folders are returned.
     
     Use the returned sequence’s modifiers to recurse into subdirectories, include hidden folders, include package contents, filter results, prune descendant traversal, or prefetch resource values:
                    
     - ``Foundation/URL/URLSequence/recursive``: Includes folders in all subdirectories, recursively.
     - ``Foundation/URL/URLSequence/recursive(maxDepth:)``: Includes folders in subdirectories up to the specified depth.
     - ``Foundation/URL/URLSequence/includingHidden``: Includes hidden folders.
     - ``Foundation/URL/URLSequence/includingPackageContents``: Includes folders in package directories (e.g., .app, .bundle, etc.).
     
     Example usage:
     
     ````swift
     for folder in folder.iterateFolders().recursive {
     
     }
     ````
     */
    func iterateFolders() -> URLSequence {
        URLSequence(url: self, folderOnly: true)
    }
    
    /// A sequence of URLs.
    struct URLSequence: Sequence {
        private let url: URL
        private var shouldSkip: ((URL)->Bool)?
        private var predicate: ((URL, Int, inout Bool) -> Bool)?
        private var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        private var maxDepth: Int?
        private var resourceKeys: [URLResourceKey] = []
        private let folderOnly: Bool
        
        init(url: URL, folderOnly: Bool = false) {
            self.url = url
            self.folderOnly = folderOnly
        }

        public func makeIterator() -> Iterator {
            Iterator(.init(url: url, keys: (resourceKeys + URLResources.prefetchedKeys(for: predicate) + (folderOnly ? [.isDirectoryKey] : [])).uniqued(), options: options, maxLevel: maxDepth, predicate: predicate, shouldSkip: shouldSkip, includeURL: folderOnly ? { $0.isDirectory } : nil))
        }
        
        /// Iterator of a URL sequence.
        public struct Iterator: IteratorProtocol {
            fileprivate var core: URLSequenceIterator
            
            fileprivate init(_ core: URLSequenceIterator) {
                self.core = core
            }

            public mutating func next() -> URL? {
                core.next()
            }

            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                core.skipDescendants()
            }

            /// The current depth level in the directory hierarchy relative to the root URL.
            public var level: Int {
                core.level
            }
        }
    }
}

public extension URL.URLSequence {
    /// Filteres the sequence to files/folders matching the specified predicate.
    func filter(_ isIncluded: @escaping (URL) -> Bool) -> Self {
        var sequence = self
        sequence.predicate = { url, _, _ in isIncluded(url) }
        return sequence
    }
    
    /**
     Filters the sequence to files and folders matching the specified predicate.

     - Parameters:
       - isIncluded: A closure that determines whether to include the URL in the sequence. It provides:
         - url: The current URL.
         - depth: The current depth level in the directory hierarchy relative to the root URL.
         - skipDescendants: A Boolean value that you can set to `true` to skip recursion into the URL’s contents if it’s a folder.
     - Returns: `true` if the URL should be included; otherwise, `false`.
     */
    func filter(_ isIncluded: @escaping ((_ url: URL, _ level: Int, _ skipDescendants: inout Bool) -> Bool)) -> Self {
        var sequence = self
        sequence.predicate = { isIncluded($0, $1, &$2) }
        return sequence
    }
    
    /// Includes the contents of all subdirectories, recursively.
    var recursive: Self {
        var sequence = self
        sequence.options.remove(.skipsSubdirectoryDescendants)
        return sequence
    }
            
    /**
     Includes subdirectory contents up to the specified depth.
     
     - Parameter maxDepth: The maximum directory depth to descend. A value of `0` includes only the top-level directory contents.
     */
    func recursive(maxDepth: Int) -> Self {
        var sequence = recursive
        sequence.maxDepth = maxDepth.clamped(min: 0) + 1
        return sequence
    }
    
    /// Recurses only into directories that match the specified predicate.
    func includingDescendants(of shouldInclude: @escaping (URL) -> Bool) -> Self {
        skippingDescendants(of: { !shouldInclude($0) })
    }
    
    /// Recurses only into subfolders with any of the specified names.
    func includingDescendants(of subfolderNames: [String]) -> Self {
        let subfolderNames = Set(subfolderNames)
        return includingDescendants { subfolderNames.contains($0.lastPathComponent) }
    }
    
    /// Recurses only into subfolders with any of the specified names.
    func includingDescendants(of subfolderNames: String...) -> Self {
        includingDescendants(of: subfolderNames)
    }
    
    /// Recurses only into the specified subfolders.
    func includingDescendants(of subfolders: [URL]) -> Self {
        let subfolders = Set(subfolders.map(\.standardizedFileURL))
        return includingDescendants {
            subfolders.contains($0.standardizedFileURL)
        }
    }
    
    /// Recurses only into the specified subfolders.
    func includingDescendants(of subfolders: URL...) -> Self {
        includingDescendants(of: subfolders)
    }
    
    /// Skips recursion into directories that match the specified predicate.
    func skippingDescendants(of shouldSkip: @escaping (URL) -> Bool) -> Self {
        var sequence = self
        sequence.shouldSkip = shouldSkip
        return sequence
    }
    
    /// Skips recursion into subfolders with any of the specified names.
    func skippingDescendants(of subfolderNames: [String]) -> Self {
        let subfolderNames = Set(subfolderNames)
        return skippingDescendants { subfolderNames.contains($0.lastPathComponent) }
    }
    
    /// Skips recursion into subfolders with any of the specified names.
    func skippingDescendants(of subfolderNames: String...) -> Self {
        skippingDescendants(of: subfolderNames)
    }
    
    /// Skips recursion into the specified subfolders.
    func skippingDescendants(of subfolders: [URL]) -> Self {
        let subfolders = Set(subfolders.map(\.standardizedFileURL))
        return skippingDescendants {
            subfolders.contains($0.standardizedFileURL)
        }
    }
    
    /// Skips recursion into the specified subfolders.
    func skippingDescendants(of subfolders: URL...) -> Self {
        skippingDescendants(of: subfolders)
    }

    /// Includes hidden files and directories.
    var includingHidden: Self {
        var sequence = self
        sequence.options.remove(.skipsHiddenFiles)
        return sequence
    }
    
    /// Includes the contents of package directories (e.g., .app, .bundle, etc.).
    var includingPackageContents: Self {
        var sequence = self
        sequence.options.remove(.skipsPackageDescendants)
        return sequence
    }
    
    /// Pre-fetches the specified URL resources values. The values for these keys are cached in ``Foundation/URL/resources`` property of each url.
    func prefetching(_ keys: [URLResources.Keys]) -> Self {
        var sequence = self
        sequence.resourceKeys = keys.uniqued().map { $0.rawValue }
        return sequence
    }
    
    /// Pre-fetches the specified URL resources values. The values for these keys are cached in ``Foundation/URL/resources`` property of each url.
    func prefetching(_ keys: URLResources.Keys...) -> Self {
        prefetching(keys)
    }
        
    /// The number of URLs in the sequence.
    var count: Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    /// The maximum directory depth of the found URLs relative to the root directory.
    var depth: Int {
        var iterator = makeIterator()
        while iterator.next() != nil {}
        return iterator.core.maximumLevel
    }
}

public extension URL {
    /// A sequence of file URLs.
    struct FileURLSequence: Sequence {
        private let url: URL
        private var predicate: ((URL, Int, inout Bool) -> Bool)?
        private var shouldSkip: ((URL)->Bool)?
        private var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        private var maxDepth: Int?
        private var requiredKeys: Set<URLResourceKey> = [.isRegularFileKey]
        private var resourceKeys: [URLResourceKey] = []
        private var filters: [String: (URL) -> Bool] = [:]
        
        init(url: URL) {
            self.url = url
        }

        public func makeIterator() -> Iterator {
            Iterator(.init(url: url, keys: (resourceKeys + requiredKeys + URLResources.prefetchedKeys(for: predicate)).uniqued(), options: options, maxLevel: maxDepth, predicate: predicate, shouldSkip: shouldSkip, includeURL: filters.isEmpty ? { $0.isFile } : { url in url.isFile && filters.values.contains { $0(url) } }))
        }
        
        /// The iterator of a file URL sequence.
        public struct Iterator: IteratorProtocol {
            fileprivate var core: URLSequenceIterator
            
            fileprivate init(_ core: URLSequenceIterator) {
                self.core = core
            }

            public mutating func next() -> URL? {
                core.next()
            }

            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                core.skipDescendants()
            }

            /// The current depth level in the directory hierarchy relative to the root URL.
            public var level: Int {
                core.level
            }
        }
    }
}

public extension URL.FileURLSequence {
    /// Filteres the sequence to files matching the specified predicate.
    func filter(_ isIncluded: @escaping (_ url: URL) -> Bool) -> Self {
        var sequence = self
        sequence.predicate = { url, _, _ in isIncluded(url) }
        return sequence
    }
    
    /**
     Filters the sequence to files matching the specified predicate.
     
     - Parameters:
       - isIncluded: A closure that determines whether to include the URL in the sequence. It provides:
         - url: The current URL.
         - depth: The current depth level in the directory hierarchy relative to the root URL.
         - skipDescendants: A Boolean value that you can set to `true` to skip recursion into the next directory.
     - Returns: `true` if the URL should be included; otherwise, `false`.
     */
    func filter(_ isIncluded: @escaping ((_ url: URL, _ level: Int, _ skipDescendants: inout Bool) -> Bool)) -> Self {
        var sequence = self
        sequence.predicate = { isIncluded($0, $1, &$2) }
        return sequence
    }
    
    /// Includes the contents of all subdirectories, recursively.
    var recursive: Self {
        var sequence = self
        sequence.options.remove(.skipsSubdirectoryDescendants)
        return sequence
    }
            
    /**
     Includes subdirectory contents up to the specified depth.

     - Parameter maxDepth: The maximum directory depth to descend. A value of `0` includes only the files of the top-level directory.
     */
    func recursive(maxDepth: Int) -> Self {
        var sequence = recursive
        sequence.maxDepth = maxDepth.clamped(min: 0) + 1
        return sequence
    }
    
    /// Recurses only into directories that match the specified predicate.
    func includingDescendants(of shouldInclude: @escaping (URL) -> Bool) -> Self {
        skippingDescendants(of: { !shouldInclude($0) })
    }
    
    /// Recurses only into subfolders with any of the specified names.
    func includingDescendants(of subfolderNames: [String]) -> Self {
        let subfolderNames = Set(subfolderNames)
        return includingDescendants { subfolderNames.contains($0.lastPathComponent) }
    }
    
    /// Recurses only into subfolders with any of the specified names.
    func includingDescendants(of subfolderNames: String...) -> Self {
        includingDescendants(of: subfolderNames)
    }
    
    /// Recurses only into the specified subfolders.
    func includingDescendants(of subfolders: [URL]) -> Self {
        let subfolders = Set(subfolders.map(\.standardizedFileURL))
        return includingDescendants {
            subfolders.contains($0.standardizedFileURL)
        }
    }
    
    /// Recurses only into the specified subfolders.
    func includingDescendants(of subfolders: URL...) -> Self {
        includingDescendants(of: subfolders)
    }
    
    /// Skips recursion into directories that match the specified predicate.
    func skippingDescendants(of shouldSkip: @escaping (URL) -> Bool) -> Self {
        var sequence = self
        sequence.shouldSkip = shouldSkip
        return sequence
    }
    
    /// Skips recursion into subfolders with any of the specified names.
    func skippingDescendants(of subfolderNames: [String]) -> Self {
        let subfolderNames = Set(subfolderNames)
        return skippingDescendants { subfolderNames.contains($0.lastPathComponent) }
    }
    
    /// Skips recursion into subfolders with any of the specified names.
    func skippingDescendants(of subfolderNames: String...) -> Self {
        skippingDescendants(of: subfolderNames)
    }
    
    /// Skips recursion into the specified subfolders.
    func skippingDescendants(of subfolders: [URL]) -> Self {
        let subfolders = Set(subfolders.map(\.standardizedFileURL))
        return skippingDescendants {
            subfolders.contains($0.standardizedFileURL)
        }
    }
    
    /// Skips recursion into the specified subfolders.
    func skippingDescendants(of subfolders: URL...) -> Self {
        skippingDescendants(of: subfolders)
    }

    /// Includes hidden files and directories.
    var includingHidden: Self {
        var sequence = self
        sequence.options.remove(.skipsHiddenFiles)
        return sequence
    }
    
    /// Includes the contents of package directories (e.g., .app, .bundle, etc.).
    var includingPackageContents: Self {
        var sequence = self
        sequence.options.remove(.skipsPackageDescendants)
        return sequence
    }
    
    /// Pre-fetches the specified URL resources values. The values for these keys are cached in ``Foundation/URL/resources`` property of each url.
    func prefetching(_ keys: [URLResources.Keys]) -> Self {
        var sequence = self
        sequence.resourceKeys = keys.uniqued().map(\.rawValue)
        return sequence
    }
    
    /// Pre-fetches the specified URL resources values. The values for these keys are cached in ``Foundation/URL/resources`` property of each url.
    func prefetching(_ keys: URLResources.Keys...) -> Self {
        prefetching(keys)
    }
        
    /// The file content types of the files to iterate.
    func contentTypes(_ contentTypes: [UTType]) -> Self {
        var copy = self
        let contentTypes = contentTypes.uniqued()
        copy.requiredKeys[.contentTypeKey] = !contentTypes.isEmpty
        copy.filters["contentType"] = contentTypes.isEmpty ? nil : {
            $0.contentType?.conforms(toAny: contentTypes) == true }
        return copy
    }
    
    /// The file content types of the files to iterate.
    func contentTypes(_ contentTypes: UTType...) -> Self {
        self.contentTypes(contentTypes)
    }
    
    /// The file types of the files to iterate.
    func types(_ fileTypes: [FileType]) -> Self {
        var copy = self
        let fileTypes = Set(fileTypes.uniqued())
        copy.filters["types"] = fileTypes.isEmpty ? nil : { $0.fileType.map({ fileTypes.contains($0) }) ?? false }
        return copy
    }
    
    /// The file types of the files to iterate.
    func types(_ fileTypes: FileType...) -> Self {
        types(fileTypes)
    }
    
    /// The file extensions of the files to iterate.
    func extensions(_ fileExtensions: [String]) -> Self {
        var copy = self
        let fileExtensions = Set(fileExtensions.uniqued())
        copy.filters["extensions"] = fileExtensions.isEmpty ? nil : { fileExtensions.contains($0.pathExtension) }
        return copy
    }
    
    /// The file extensions of the files to iterate.
    func extensions(_ fileExtensions: String...) -> Self {
        extensions(fileExtensions)
    }
    
    /// The number of URLs in the sequence.
    var count: Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    /// The maximum enumeration depth of the found URLs.
    var depth: Int {
        var iterator = makeIterator()
        while iterator.next() != nil { }
        return iterator.core.maximumLevel
    }
}

fileprivate struct URLSequenceIterator: IteratorProtocol {
    private let predicate: (((URL, Int, inout Bool) -> Bool))?
    private let includeURL: ((URL) -> Bool)?
    private let shouldSkip: ((URL) -> Bool)?
    private let enumerator: FileManager.DirectoryEnumerator?
    private let maxLevel: Int?
    var maximumLevel = 0
    
    init(url: URL, keys: [URLResourceKey], options: FileManager.DirectoryEnumerationOptions, maxLevel: Int?, predicate:  (((URL, Int, inout Bool) -> Bool))?, shouldSkip: (((URL) -> Bool))?,  includeURL: (((URL) -> Bool))?) {
        self.predicate = predicate
        self.shouldSkip = shouldSkip
        self.includeURL = includeURL
        self.maxLevel = maxLevel
        self.enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys, options: options)
    }
        
    mutating func next() -> URL? {
        guard let enumerator = enumerator else { return nil }
        while let nextURL = enumerator.next() {
            if let maxLevel = maxLevel, enumerator.level > maxLevel {
                skipDescendants()
                continue
            }
            if shouldSkip?(nextURL) == true {
                skipDescendants()
            }
            guard includeURL?(nextURL) ?? true else { continue }
            var shouldSkipDescendants = false
            let shouldIncludeURL = predicate?(nextURL, enumerator.level, &shouldSkipDescendants) ?? true
            if shouldSkipDescendants {
                skipDescendants()
            }
            guard shouldIncludeURL else { continue }
            maximumLevel.formMax(enumerator.level)
            return nextURL
        }
        return nil
    }
        
    func skipDescendants() {
        enumerator?.skipDescendants()
    }
        
    var level: Int {
        enumerator?.level ?? 0
    }
}
