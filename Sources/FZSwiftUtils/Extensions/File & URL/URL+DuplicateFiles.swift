//
//  URL+DuplicateFiles.swift
//
//
//  Created by Florian Zand on 29.03.25.
//

import Foundation

extension URL {
    /**
     Returns the duplicate files for the specified file URLs.
     
     - Parameter urls: The file URLs to search duplicates.
     - Returns: The duplicate files sorted by file size and the non-duplicate files.
     */
    public static func findDuplicateFiles(for urls: [URL]) -> (duplicates: [[HashedFile]], nonDuplicates: [HashedFile]) {
        let found = findDuplicateFiles(for: urls.map({ HashedFile($0) }))
        let duplicates = found.duplicates
        let nonDuplicates = found.nonDuplicates
        return (duplicates, nonDuplicates)
    }
    
    public static func findDuplicateFiles(in directories: [URL], maxDepth: Int = 0) -> (duplicates: [[HashedFile]], nonDuplicates: [HashedFile]) {
        return findDuplicateFiles(for: directories.flatMap({$0.iterateFiles().recursive(maxDepth: maxDepth).collect()}))
    }
    
    public static func findDuplicateFiles(in directory: URL, maxDepth: Int = 0) -> (duplicates: [[HashedFile]], nonDuplicates: [HashedFile]) {
        findDuplicateFiles(in: [directory], maxDepth: maxDepth)
    }
    
    /**
     Searches for duplicate files for the specified file URLs asynchronous.
     
     - Parameters:
        - urls: The file URLs to search duplicates.
        - updateHandler: The handler that gets called whenever duplicates are found. It returns the duplicate files sorted by file size, the non-duplicate files and the search progress.
     */
    public static func findDuplicateFiles(for urls: [URL], updateHandler: (_ duplicates: [[HashedFile]], _ nonDuplicates: [HashedFile], _ progress: Progress) -> ()) {
        findDuplicateFiles(for: urls.map({ HashedFile($0) }), updateHandler: updateHandler)
    }
    
    public static func findDuplicateFiles(in directories: [URL], maxDepth: Int = 0, updateHandler: (_ duplicates: [[HashedFile]], _ nonDuplicates: [HashedFile], _ progress: Progress) -> ()) {
        var duplicates: [OSHash: [HashedFile]] = [:]
        var nonDuplicates: [HashedFile] = []
        let progress = Progress(totalUnitCount: 0)
        var directories = directories
        func getDuplicates() {
            if !directories.isEmpty {
                let directory = directories.removeFirst()
                let urls = directory.iterateFiles().recursive(maxDepth: maxDepth).collect()
                findDuplicateFiles(for: urls.map({ HashedFile($0) }), current: (duplicates, nonDuplicates, progress)) { _duplicates, _nonDuplicates, progress, isFinished in
                    duplicates = _duplicates
                    nonDuplicates = _nonDuplicates
                    getDuplicates()
                }
            } else {
                
            }
        }
        getDuplicates()
    }
    
    private static func findDuplicateFiles(for urls: [HashedFile]) -> (duplicates: [[HashedFile]], nonDuplicates: [HashedFile]) {
        let filesBySize = Dictionary(grouping: urls, by: \.url.resources.fileSize)
        var nonDuplicates = filesBySize[nil] ?? []
        var duplicates: [[HashedFile]] = []
        for files in filesBySize.filter({$0.key != nil}).values {
            if files.count > 1 {
                let filesByHash = Dictionary(grouping: files, by: \.hash )
                nonDuplicates += filesByHash[nil] ?? []
                for filesHashes in filesByHash {
                    if filesHashes.key != nil {
                        if filesHashes.value.count > 1 {
                            duplicates += filesHashes.value
                        } else {
                            nonDuplicates += filesHashes.value
                        }
                    }
                }
            } else {
                nonDuplicates += files
            }
        }
        duplicates = duplicates.sorted(by: \.first?.url.resources.fileSize, .smallestFirst)
        return (duplicates, nonDuplicates)
    }
    
    private static func findDuplicateFiles(for urls: [HashedFile], updateHandler: (_ duplicates: [[HashedFile]], _ nonDuplicates: [HashedFile], _ progress: Progress) -> ()) {
        let filesBySize = Dictionary(grouping: urls, by: \.url.resources.fileSize)
        var nonDuplicates = filesBySize[nil] ?? []
        var duplicates: [OSHash: [HashedFile]] = [:]
        let progress = Progress(totalUnitCount: Int64(urls.count))
        progress.completedUnitCount = Int64(nonDuplicates.count)
        if !nonDuplicates.isEmpty {
            updateHandler([], nonDuplicates, progress)
        }
        func callHandler() {
            updateHandler(Array(duplicates.filter({$0.value.count > 1}).values), nonDuplicates + duplicates.filter({$0.value.count == 1}).flatMap({$0.value}), progress)
        }
        for files in filesBySize.filter({$0.key != nil}).values {
            for file in files {
                if let hash = file.hash {
                    let dups = duplicates[hash, default: []] + file
                    duplicates[hash] = dups
                    if dups.count > 1 {
                        callHandler()
                    }
                } else {
                    nonDuplicates += file
                }
                progress.completedUnitCount += 1
            }
        }
        callHandler()
    }
    
    private static func findDuplicateFiles(for urls: [HashedFile], current: (duplicates: [OSHash: [HashedFile]], nonDuplicates: [HashedFile], progress: Progress), updateHandler: (_ duplicates: [OSHash:[HashedFile]], _ nonDuplicates: [HashedFile], _ progress: Progress, _ isFInished: Bool) -> ()) {
        let filesBySize = Dictionary(grouping: urls, by: \.url.resources.fileSize)
        var nonDuplicates = current.nonDuplicates + (filesBySize[nil] ?? [])
        var duplicates: [OSHash: [HashedFile]] = current.duplicates
        let progress = current.progress
        progress.totalUnitCount += Int64(urls.count)
        progress.completedUnitCount += Int64(nonDuplicates.count)
        func callHandler(isFinished: Bool = false) {
        }
        for url in urls {
            if let hash = url.hash {
                let dups = duplicates[hash, default: []] + url
                duplicates[hash] = dups
                if dups.count > 1 {
                    callHandler()
                }
            } else {
                nonDuplicates += url
            }
            progress.completedUnitCount += 1
        }
        callHandler()
    }
}

/// A hashed file.
public class HashedFile: Equatable {
    private var _hash: OSHash?
    private var _fileSize: DataSize?
    private var didCalculateHash = false
    
    /// The URL of the file.
    public let url: URL

    /// The hash of the file.
    public var hash: OSHash? {
        if !didCalculateHash {
            _hash = try? OSHash(url: url)
            didCalculateHash = true
        }
        return _hash
    }
    
    /// The size of the file.
    public var fileSize: DataSize? {
        if _fileSize == nil {
            _fileSize = url.resources.fileSize
        }
        return _fileSize
    }
    
    /// Creates a hashed file for the specified file URL.
    public init(_ url: URL) {
        self.url = url
    }
    
    public static func == (lhs: HashedFile, rhs: HashedFile) -> Bool {
        lhs.hash != nil && lhs.hash == rhs.hash
    }
}
