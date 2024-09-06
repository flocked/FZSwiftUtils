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
    func iterate() -> URLSequence {
        URLSequence(url: self, predicate: { _ in true })
    }

    /**
     Iterate files and folders that satisfy the given predicate.
     
     Example:
     ```swift
     for url in folder.iterate { $0.lastPathComponent.contains("data_") } {
         
     }
     ```

     - Parameter predicate: A closure that takes an item url as its argument and returns a Boolean value indicating whether the url is a match.
     */
    func iterate(predicate: @escaping ((URL) -> Bool)) -> URLSequence {
        URLSequence(url: self, predicate: predicate)
    }
    
    /**
     Iterate files.
     
     To include files inside folders use ``URLSequence/recursive`` and to include hidden files use ``URLSequence/includingHidden``.
     
     Example usage:
     
     ````swift
     for file in folder.iterateFiles().recursive {
     
     }
     ````
     */
    func iterateFiles() -> URLSequence {
        iterate { $0.isFile }
    }

    /**
     Iterate files with the specified file types.
     
     To include files inside folders use ``URLSequence/recursive`` and to include hidden files use ``URLSequence/includingHidden``.
     
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(types: [.video, .image]).recursive {
     
     }
     ````

     - Parameter types: The file types to enumerate.
     */
    func iterateFiles(types: [FileType]) -> URLSequence {
        types.isEmpty ? iterateFiles() : iterate {
            if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false }
        }
    }

    /**
     Iterate files with the specified file UTTypes.
     
     To include files inside folders use ``URLSequence/recursive`` and to include hidden files use ``URLSequence/includingHidden``.
     
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(contentTypes: [.video, .image]).recursive {
     
     }
     ````

     - Parameter contentTypes: The file content types to enumerate.
     */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    func iterateFiles(contentTypes: [UTType]) -> URLSequence {
        contentTypes.isEmpty ? iterateFiles() : iterate {
            if let type = $0.contentType, contentTypes.contains(type) || type.conforms(toAny: contentTypes) { return true } else { return false }
        }
    }

    /**
     Iterate files with the specified file extensions.
     
     To include files inside folders use ``URLSequence/recursive`` and to include hidden files use ``URLSequence/includingHidden``.
     
     Example usage:
     
     ````swift
     for file in folder.iterateFiles(extensions: ["pdf", "doc"]).recursive {
     
     }
     ````

     - Parameter extensions: The file extensions to enumerate.
     */
    func iterateFiles(extensions: [String]) -> URLSequence {
        guard !extensions.isEmpty else { return iterateFiles() }
        let extensions = extensions.compactMap { $0.lowercased() }
        return iterate { extensions.contains($0.pathExtension.lowercased()) }
    }

    /**
     Iterate folders.
     
     To include folders inside folders use ``URLSequence/recursive`` and to include hidden folders use ``URLSequence/includingHidden``.
     
     Example usage:
     
     ````swift
     for url in folder.iterateFolders().recursive {
     
     }
     ````
     */
    func iterateFolders() -> URLSequence {
        iterate { $0.isDirectory == true }
    }
    
    /// A sequence of urls.
    struct URLSequence: Sequence {
        
        let url: URL
        let predicate: (URL) -> Bool
        var options: FileManager.DirectoryEnumerationOptions = [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        var maxDepth: Int? = nil
        
        
        
        public init(url: URL, predicate: @escaping (URL) -> Bool) {
            self.url = url
            self.predicate = predicate
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// Iterator of a url sequence.
        public struct Iterator: IteratorProtocol {
            let predicate: (URL) -> Bool
            let directoryEnumerator: FileManager.DirectoryEnumerator?
            let maxLevel: Int?
            let levelCount = LevelCount()
            
            class LevelCount {
                var level = 0 { didSet { if oldValue > level { level = oldValue } } }
            }

            init(_ sequence: URLSequence) {
                predicate = sequence.predicate
                maxLevel = sequence.maxDepth
                directoryEnumerator = FileManager.default.enumerator(at: sequence.url, includingPropertiesForKeys: nil, options: sequence.options)
            }

            public func next() -> URL? {
                guard let directoryEnumerator = directoryEnumerator else { return nil }
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else if predicate(nextURL) == true {
                        self.levelCount.level = level
                        return nextURL
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
    /// The number of urls in the sequence.
    public var count: Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    public var depth: Int {
        let iterator = makeIterator()
        var depth = 0
        while iterator.next() != nil {
            depth = iterator.levelCount.level
        }
        return depth
    }
    
    /// Returns a new instance of the sequence that'll traverse the folder's contents recursively.
    public var recursive: Self {
        recursive(true)
    }
            
    /**
     Returns a new instance of the sequence that'll traverse the folder's contents recursively up to the specified maximum depth.
     
     - Parameter maxDepth: The maximum depth of enumeration.
     */
    public func recursive(maxDepth: Int) -> Self {
        var sequence = self
        sequence.maxDepth = maxDepth.clamped(min: 0)
        sequence.options[.skipsSubdirectoryDescendants] = false
        return sequence
    }

    /// Returns a new instance of the sequence that'll include all hidden all hidden (dot) files/folders.
    public var includingHidden: Self {
        includingHidden(true)
    }
    
    /// Returns a new instance of the sequence that'll treat packages like folders and will traverse their contents.
    public var includingPackageDescendants: Self {
        includingPackageDescendants(true)
    }
    
    /// Returns a new instance of the sequence that'll traverse the folder's contents recursively.
    public func recursive(_ recursive: Bool) -> Self {
        var sequence = self
        sequence.options[.skipsSubdirectoryDescendants] = !recursive
        return sequence
    }
    
    /// Returns a new instance of the sequence that'll include all hidden all hidden (dot) files/folders.
    public func includingHidden(_ include: Bool) -> Self {
        var sequence = self
        sequence.options[.skipsHiddenFiles] = !include
        return sequence
    }
    
    /// Returns a new instance of the sequence that'll treat packages like folders and will traverse their contents.
    public func includingPackageDescendants(_ include: Bool) -> Self {
        var sequence = self
        sequence.options[.skipsPackageDescendants] = !include
        return sequence
    }
}

extension URL.URLSequence {
    /// Enumeration options.
    public enum EnumerationOptions: Hashable {
        /// Include hidden files/folders.
        case includingHidden
        ///  Treat packages like folders and will traverse their contents.
        case includingPackageDescendants
        /// Traverse the folder's contents recursively up to the specified maximum depth.
        case recursive(maxDepth: Int?)
        /// Traverse the folder's contents recursively.
        public static var recursive: EnumerationOptions { .recursive(maxDepth: nil) }
        
        var depth: Int? {
            switch self {
            case .recursive(let value): return value
            default: return nil
            }
        }
        
        var recursive: Bool {
            switch self {
            case .recursive: return true
            default: return false
            }
        }
    }
    
    /// Returns a new instance of the sequence with the specified enumeration options.
    public func options(_ options: Set<EnumerationOptions>) -> Self {
        var sequence = self
        sequence.options[.skipsHiddenFiles] = !options.contains(.includingHidden)
        sequence.options[.skipsPackageDescendants] = !options.contains(.includingPackageDescendants)
        sequence.options[.skipsSubdirectoryDescendants] = !options.contains(where: {$0.recursive == true })
        sequence.maxDepth = options.compactMap({$0.depth}).first
        return sequence
    }
    
    /// Returns a new instance of the sequence with the specified enumeration options.
    public func options(_ options: EnumerationOptions...) -> Self {
        self.options(Set(options))
    }
}
