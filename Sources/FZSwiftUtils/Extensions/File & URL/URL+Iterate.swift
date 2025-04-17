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
        URLSequence(url: self, predicate: { _,_,_ in true })
    }

    /**
     Iterate files and folders of the directory that satisfy the given predicate.
          
     Example:
     ```swift
     for url in folder.iterate { $0.lastPathComponent.contains("data") }.recursive {
         
     }
     ```
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).

     - Parameter predicate: A closure that takes an item url as its argument and returns a Boolean value indicating whether the url is a match.
     */
    func iterate(predicate: @escaping ((URL) -> Bool)) -> URLSequence {
        URLSequence(url: self, predicate: { url,_,_ in return predicate(url)  })
    }
    
    /**
     Iterate files and folders of the directory that satisfy the given predicate.
          
     Example:
     ```swift
     let urls = folder.iterate { url, level, skipDescendants in
        skipDescendants = url.lastPathComponent == "framework"
        return url.pathExtension == "swift"
     }.recursive
     
     for url in urls {
     
     }
     ```
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     
     - Parameter predicate: The predicate that determinates whether to include the url in the sequence. It provides:
        - url: The current url.
        - depth: The url's depth level relative to the root.
        - skipDescendants: A Boolean value that you can set indicating whether to skip recusion of the url's content if it's a folder.
     */
    func iterate(predicate: @escaping ((_ url: URL, _ level: Int, _ skipDescendants: inout Bool) -> Bool)) -> URLSequence {
        URLSequence(url: self, predicate: predicate)
    }
    
    /**
     Iterate files of the directory.

     Example usage:
     
     ````swift
     for file in folder.iterateFiles().recursive {
     
     }
     ````
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     */
    func iterateFiles() -> URLSequence {
        iterate { $0.isFile }
    }

    /**
     Iterate files of the directory with the specified file types.
     
          
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(types: [.video, .image]).recursive {
     
     }
     ````
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).
     
     - Parameter types: The file types to enumerate.
     */
    func iterateFiles(types: [FileType]) -> URLSequence {
        types.isEmpty ? iterateFiles() : iterate {
            if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false }
        }
    }

    /**
     Iterate files of the directory with the specified content types.
          
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(contentTypes: [.video, .image]).recursive {
     
     }
     ````
     
     You can add the following to the returned sequence:
          
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).

     - Parameter contentTypes: The file content types to enumerate.
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    func iterateFiles(contentTypes: [UTType]) -> URLSequence {
        contentTypes.isEmpty ? iterateFiles() : iterate {
            if let type = $0.contentType, contentTypes.contains(type) || type.conforms(toAny: contentTypes) { return true } else { return false }
        }
    }

    /**
     Iterate files of the directory with the specified file extensions.
          
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(extensions: ["pdf", "doc"]).recursive {
     
     }
     ````
     
     - ``recursive``: Includes the contents of all subdirectories, recursively.
     - ``recursive(maxDepth:)``: Includes subdirectory contents up to the specified depth.
     - ``includingHidden``: Includes hidden files and directories.
     - ``includingPackageContents``: Includes the contents of package directories (e.g., .app, .bundle, etc.).

     - Parameter extensions: The file extensions to enumerate.
     */
    func iterateFiles(extensions: [String]) -> URLSequence {
        let extensions = extensions.compactMap { $0.lowercased() }.uniqued()
        guard !extensions.isEmpty else { return iterateFiles() }
        return iterate { extensions.contains($0.pathExtension.lowercased()) }
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
        iterate { $0.isDirectory }
    }
    
    /// A sequence of URLs.
    struct URLSequence: Sequence {
        let url: URL
        var predicate: (URL, Int, inout Bool) -> Bool
        var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        var maxDepth: Int? = nil
        var resourceKeys: [URLResourceKey] = []
        
        public enum Decision: ExpressibleByBooleanLiteral {
            case include
            case skip
            case includeAndSkipDescendants
            case skipAndSkipDescendants
            
            public init(booleanLiteral value: BooleanLiteralType) {
                self = value ? .include : .skip
            }
        }
        
        init(url: URL, predicate: @escaping (URL, Int, inout Bool) -> Bool) {
            self.url = url
            self.predicate = predicate
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// Iterator of a URL sequence.
        public struct Iterator: IteratorProtocol {
            let predicate: (URL, Int, inout Bool) -> Bool
            let directoryEnumerator: FileManager.DirectoryEnumerator?
            let maxLevel: Int?
            var maximumLevel = 0
            
            init(_ sequence: URLSequence) {
                predicate = sequence.predicate
                maxLevel = sequence.maxDepth
                directoryEnumerator = FileManager.default.enumerator(at: sequence.url, includingPropertiesForKeys: sequence.resourceKeys, options: sequence.options)
            }

            public mutating func next() -> URL? {
                guard let directoryEnumerator = directoryEnumerator else { return nil }
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else {
                        var shouldSkipDescendants = false
                        let includeURL = predicate(nextURL, level, &shouldSkipDescendants)
                        if shouldSkipDescendants {
                            skipDescendants()
                        }
                        if includeURL {
                            return nextURL
                        }
                    }
                }
                return nil
            }

            /// Skip recursion into the most recently obtained subdirectory.
            public func skipDescendants() {
                directoryEnumerator?.skipDescendants()
            }

            /// The number of levels deep the iterator is in the directory hierarchy being enumerated.
            public var level: Int {
                directoryEnumerator?.level ?? 0
            }
        }
    }
}

extension URL.URLSequence {
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
    
    /// The maximum enumeration depth of the found URLs.
    public var depth: Int {
        var iterator = makeIterator()
        while iterator.next() != nil { }
        return iterator.maximumLevel
    }
}
