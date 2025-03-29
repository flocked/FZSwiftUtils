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
    
    /**
     Searches for duplicate files for the specified file URLs asynchronous.
     
     - Parameters:
        - urls: The file URLs to search duplicates.
        - updateHandler: The handler that gets called whenever duplicates are found. It returns the duplicate files sorted by file size, the non-duplicate files and the search progress.
     */
    public static func findDuplicateFiles(for urls: [URL], updateHandler: (_ duplicates: [[HashedFile]], _ nonDuplicates: [HashedFile], _ progress: Progress) -> ()) {
        findDuplicateFiles(for: urls.map({ HashedFile($0) }), updateHandler: updateHandler)
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
}

/// A hashed file.
public class HashedFile: Equatable {
    private var _hash: OSHash?
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
    
    /// Creates a hashed file for the specified file URL.
    public init(_ url: URL) {
        self.url = url
    }
    
    public static func == (lhs: HashedFile, rhs: HashedFile) -> Bool {
        lhs.hash != nil && lhs.hash == rhs.hash
    }
}
