//
//  URL+DirectoryEnumerator.swift
//
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public extension URL {
    /**
     Iterate files and folders of the directory.
          
     Example:
     ```swift
     for url in folder.iterate().recursive {
     
     }
     ```
     
     You can add the following to the returned sequence:
     
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     */
    func iterate() -> URLSequence {
        URLSequence(url: self)
    }
    
    /**
     Iterate files of the directory.

     Example usage:
     
     ````swift
     for file in folder.iterateFiles().types(.video, .image).recursive {
     
     }
     ````
     
     You can add the following to the returned sequence:
          
     - ``Foundation/URL/FileURLSequence/extensions(_:)-21sdu``: The file extensions to iterate.
     - ``Foundation/URL/FileURLSequence/types(_:)-6zcyj``: The file types to iterate.
     - ``Foundation/URL/FileURLSequence/contentTypes(_:)-68ng``: The file content types to iterate.

     And these :
     
     - ``Foundation/URL/FileURLSequence/recursive``: Includes the files of all subdirectories, recursively.
     - ``Foundation/URL/FileURLSequence/recursive(maxDepth:)``: Includes subdirectory files up to the specified depth.
     - ``Foundation/URL/FileURLSequence/includingHidden``: Includes hidden files.
     - ``Foundation/URL/FileURLSequence/includingPackageContents``: Includes files of package directories (e.g., .app, .bundle, etc.).
     */
    func iterateFiles() -> FileURLSequence {
        FileURLSequence(url: self)
    }

    /**
     Iterate folders of the directory.
          
     Example usage:
     
     ````swift
     for url in folder.iterateFolders().recursive {
     
     }
     ````
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     */
    func iterateFolders() -> URLSequence {
        URLSequence(url: self, folderOnly: true)
    }
    
    /// A sequence of URLs.
    struct URLSequence: Sequence {
        private let url: URL
        private var predicate: (URL, Int, inout Bool) -> Bool = { _,_,_ in true }
        private var prefetchID: String?
        private var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        private var maxDepth: Int?
        private var resourceKeys: [URLResourceKey] = []
        private let folderOnly: Bool
        
        init(url: URL, folderOnly: Bool = false) {
            self.url = url
            self.folderOnly = folderOnly
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// Iterator of a URL sequence.
        public struct Iterator: IteratorProtocol {
            private let predicate: (URL, Int, inout Bool) -> Bool
            private let folderOnly: Bool
            private let directoryEnumerator: FileManager.DirectoryEnumerator?
            private let maxLevel: Int?
            var maximumLevel = 0
            
            init(_ sequence: URLSequence) {
                predicate = sequence.predicate
                folderOnly = sequence.folderOnly
                maxLevel = sequence.maxDepth
                let resourceKeys = (sequence.resourceKeys + URL.sequenceResourceKeys(for: predicate, prefetchID: sequence.prefetchID) + (sequence.folderOnly ? [.isDirectoryKey] : [])).uniqued()
                directoryEnumerator = FileManager.default.enumerator(at: sequence.url, includingPropertiesForKeys: resourceKeys.uniqued(), options: sequence.options)
            }

            public mutating func next() -> URL? {
                guard let directoryEnumerator = directoryEnumerator else { return nil }
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else {
                        if folderOnly, !nextURL.isDirectory { continue }
                        var shouldSkipDescendants = false
                        let includeURL = predicate(nextURL, level, &shouldSkipDescendants)
                        if shouldSkipDescendants {
                            skipDescendants()
                        }
                        guard includeURL else { continue }
                        maximumLevel = Swift.max(maximumLevel, level)
                        return nextURL
                    }
                }
                return nil
            }

            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                directoryEnumerator?.skipDescendants()
            }

            /// The current depth level in the directory hierarchy relative to the root URL.
            public var level: Int {
                directoryEnumerator?.level ?? 0
            }
        }
    }
}

extension URL.URLSequence {
    /// Filteres the sequence to files/folders matching the specified predicate.
    public func filter(_ isIncluded: @escaping (URL) -> Bool) -> Self {
        var sequence = self
        sequence.predicate = { url,_,_ in isIncluded(url) }
        sequence.prefetchID = UUID().uuidString
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
    public func filter(_ isIncluded: @escaping ((_ url: URL, _ level: Int, _ skipDescendants: inout Bool) -> Bool)) -> Self {
        var sequence = self
        sequence.predicate = { isIncluded($0, $1, &$2) }
        sequence.prefetchID = UUID().uuidString
        return sequence
    }
        
    /// Includes the contents of all subdirectories, recursively.
    public var recursive: Self {
        var sequence = self
        sequence.options.remove(.skipsSubdirectoryDescendants)
        return sequence
    }
            
    /**
     Includes subdirectory contents up to the specified depth.
     
     - Parameter maxDepth: The maximum directory depth to descend. A value of `0` includes only the top-level directory contents.
     */
    public func recursive(maxDepth: Int) -> Self {
        var sequence = recursive
        sequence.maxDepth = maxDepth.clamped(min: 0) + 1
        return sequence
    }

    /// Includes hidden files and directories.
    public var includingHidden: Self {
        var sequence = self
        sequence.options.remove(.skipsHiddenFiles)
        return sequence
    }
    
    /// Includes the contents of package directories (e.g., .app, .bundle, etc.).
    public var includingPackageContents: Self {
        var sequence = self
        sequence.options.remove(.skipsPackageDescendants)
        return sequence
    }
    
    /// Pre-fetches the URL resources values for the specified keys. The values for these keys are cached in the corresponding ``resources`` property.
    public func prefetchingProperties(_ keys: [URLResourceKey]) -> Self {
        var sequence = self
        let keys = keys.uniqued()
        sequence.resourceKeys = keys
        return sequence
    }
        
    /// The number of URLs in the sequence.
    public var count: Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    /// The maximum directory depth of the found URLs relative to the root directory.
    public var depth: Int {
        var iterator = makeIterator()
        while iterator.next() != nil { }
        return iterator.maximumLevel
    }
}

extension URL {
    /// A sequence of file URLs.
    public struct FileURLSequence: Sequence {
        private let url: URL
        private var predicate: (URL, Int, inout Bool) -> Bool = { _,_,_ in true }
        private var prefetchID: String?
        private var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        private var maxDepth: Int? = nil
        private var resourceKeys: [URLResourceKey] = []
        private var contentTypesFilter: ((URL)->Bool)?
        private var extensionsFilter: ((URL)->Bool)?
        private var typesFilter: ((URL)->Bool)?
        
        init(url: URL) {
            self.url = url
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// Iterator of a file URL sequence.
        public struct Iterator: IteratorProtocol {
            private let predicate: (URL, Int, inout Bool) -> Bool
            private let typePredicate: ((URL)->Bool)
            private let directoryEnumerator: FileManager.DirectoryEnumerator?
            private let maxLevel: Int?
            var maximumLevel = 0
            
            init(_ sequence: FileURLSequence) {
                predicate = sequence.predicate
                if sequence.extensionsFilter != nil || sequence.contentTypesFilter != nil || sequence.typesFilter != nil {
                    typePredicate = { sequence.extensionsFilter?($0) == true || sequence.typesFilter?($0) == true || sequence.contentTypesFilter?($0) == true }
                } else {
                    typePredicate = { _ in true }
                }
                maxLevel = sequence.maxDepth
                var resourceKeys = sequence.resourceKeys + URL.sequenceResourceKeys(for: predicate, prefetchID: sequence.prefetchID) + [.isRegularFileKey]
                #if os(macOS) || os(iOS) || os(tvOS)
                if sequence.contentTypesFilter != nil, #available(macOS 11.0, *) {
                    resourceKeys += .contentTypeKey
                }
                #endif
                directoryEnumerator = FileManager.default.enumerator(at: sequence.url, includingPropertiesForKeys: resourceKeys.uniqued(), options: sequence.options)
            }

            public mutating func next() -> URL? {
                guard let directoryEnumerator = directoryEnumerator else { return nil }
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else {
                        guard nextURL.isFile, typePredicate(nextURL) else { continue }
                        var shouldSkipDescendants = false
                        let includeURL = predicate(nextURL, level, &shouldSkipDescendants)
                        if shouldSkipDescendants {
                            skipDescendants()
                        }
                        guard includeURL else { continue }
                        maximumLevel = Swift.max(level, maximumLevel)
                        return nextURL
                    }
                }
                return nil
            }

            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                directoryEnumerator?.skipDescendants()
            }

            /// The current depth level in the directory hierarchy relative to the root URL.
            public var level: Int {
                directoryEnumerator?.level ?? 0
            }
        }
    }
}

extension URL.FileURLSequence {
    /// Filteres the sequence to files matching the specified predicate.
    public func filter(_ isIncluded: @escaping (URL) -> Bool) -> Self {
        var sequence = self
        sequence.predicate = { url,_,_ in isIncluded(url) }
        sequence.prefetchID = UUID().uuidString
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
    public func filter(_ isIncluded: @escaping ((_ url: URL, _ level: Int, _ skipDescendants: inout Bool) -> Bool)) -> Self {
        var sequence = self
        sequence.predicate = { isIncluded($0, $1, &$2) }
        sequence.prefetchID = UUID().uuidString
        return sequence
    }
    
    /// Includes the contents of all subdirectories, recursively.
    public var recursive: Self {
        var sequence = self
        sequence.options.remove(.skipsSubdirectoryDescendants)
        return sequence
    }
            
    /**
     Includes subdirectory contents up to the specified depth.

     - Parameter maxDepth: The maximum directory depth to descend. A value of `0` includes only the files of the top-level directory.
     */
    public func recursive(maxDepth: Int) -> Self {
        var sequence = recursive
        sequence.maxDepth = maxDepth.clamped(min: 0) + 1
        return sequence
    }

    /// Includes hidden files and directories.
    public var includingHidden: Self {
        var sequence = self
        sequence.options.remove(.skipsHiddenFiles)
        return sequence
    }
    
    /// Includes the contents of package directories (e.g., .app, .bundle, etc.).
    public var includingPackageContents: Self {
        var sequence = self
        sequence.options.remove(.skipsPackageDescendants)
        return sequence
    }
    
    /// Pre-fetches the URL resources values for the specified keys. The values for these keys are cached in the corresponding ``resources`` property.
    public func prefetchingProperties(_ keys: [URLResourceKey]) -> Self {
        var sequence = self
        let keys = keys.uniqued()
        sequence.resourceKeys = keys
        return sequence
    }
        
    /// The file content types of the files to iterate.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public func contentTypes(_ contentTypes: [UTType]) -> Self {
        var copy = self
        copy.typesFilter = contentTypes.isEmpty ? nil : { if let type = $0.contentType, contentTypes.contains(type) || type.conforms(toAny: contentTypes) { return true } else { return false } }
        return copy
    }
    
    /// The file content types of the files to iterate.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public func contentTypes(_ contentTypes: UTType...) -> Self {
        self.contentTypes(contentTypes)
    }
    
    /// The file types of the files to iterate.
    public func types(_ fileTypes: [FileType]) -> Self {
        var copy = self
        copy.typesFilter = fileTypes.isEmpty ? nil : { if let fileType = $0.fileType, fileTypes.contains(fileType) { return true } else { return false } }
        return copy
    }
    
    /// The file types of the files to iterate.
    public func types(_ fileTypes: FileType...) -> Self {
        types(fileTypes)
    }
    
    /// The file extensions of the files to iterate.
    public func extensions(_ fileExtensions: [String]) -> Self {
        var copy = self
        copy.typesFilter = fileExtensions.isEmpty ? nil : { fileExtensions.contains($0.pathExtension) }
        return copy
    }
    
    /// The file extensions of the files to iterate.
    public func extensions(_ fileExtensions: String...) -> Self {
        extensions(fileExtensions)
    }
    
    /// The number of URLs in the sequence.
    public var count: Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    /// The maximum enumeration depth of the found URLs.
    public var depth: Int {
        var iterator = makeIterator()
        while iterator.next() != nil { }
        return iterator.maximumLevel
    }
}

fileprivate extension URL {
    static func sequenceResourceKeys(for predicate:(URL, Int, inout Bool) -> Bool, prefetchID: String?) -> [URLResourceKey] {
        guard let prefetchID = prefetchID else { return [] }
        if let resourceKeys = URLResources.iteratorKeys[prefetchID] {
            return Array(resourceKeys)
        } else {
            var shouldStop = false
            _ = predicate(.file("_prefetchCheck_\(prefetchID)"), 0, &shouldStop)
            return Array(URLResources.iteratorKeys[prefetchID, default: []])
        }
    }
}

/*
 public enum FilterDecision: ExpressibleByBooleanLiteral {
     /// Include the URL.
     case include
     /// Include the URL and skip recursion into the next folder.
     case includeAndSkipDescendants
     /// Skip the URL.
     case skip
     /// Skip the URL and skip recursion into the next folder.
     case skipAndSkipDescendants
    
     public init(booleanLiteral value: BooleanLiteralType) {
         self = value ? .include : .skip
     }
 }
  */
