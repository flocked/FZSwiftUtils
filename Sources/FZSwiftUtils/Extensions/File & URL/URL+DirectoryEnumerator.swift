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

internal extension FileManager.DirectoryEnumerationOptions {
    init(_ options: Set<URL.DirectoryEnumerationOption>) {
        var opt: FileManager.DirectoryEnumerationOptions = []
        if !options.contains(.includeHiddenFiles) { opt.insert(.skipsHiddenFiles) }
        if !options.contains(.includeSubdirectoryDescendants) { opt.insert(.skipsSubdirectoryDescendants) }
        if !options.contains(.includePackageDescendants) { opt.insert(.skipsPackageDescendants) }
        self = opt
    }
}

public extension URL {
    /// Options for enumerating the contents of directories.
    enum DirectoryEnumerationOption: Hashable {
        /// An option to treat packages like files and descend into their contents.
        case includePackageDescendants
        /// An option to perform a shallow enumeration that descend into directories.
        case includeSubdirectoryDescendants
        /// An option to include hidden files.
        case includeHiddenFiles
        /// An option that specified the depth of enumation.
        case maxDepth(Int)
        internal var depth: Int? {
            switch self {
            case let .maxDepth(value): return value
            default: return nil
            }
        }
    }

    /// A sequence of urls.
    struct URLSequence: Sequence {
        public typealias Predicate = DirectoryIterator.Predicate
        public typealias Options = Set<DirectoryEnumerationOption>

        private var url: URL
        private var options: Options
        private var predicate: Predicate

        public init(url: URL, options: Options, predicate: @escaping Predicate) {
            self.url = url
            self.options = options
            self.predicate = predicate
        }

        public func makeIterator() -> DirectoryIterator {
            return DirectoryIterator(url: url, options: options, predicate: predicate)
        }
    }

    /// A iterator of a directory.
    struct DirectoryIterator: IteratorProtocol {
        public typealias Element = URL
        public typealias Predicate = (Self.Element) -> Bool
        public typealias Options = Set<DirectoryEnumerationOption>

        let url: URL
        let predicate: Predicate
        let directoryEnumerator: FileManager.DirectoryEnumerator?
        let maxLevel: Int?

        init(url: URL, options: Options = [], predicate: Predicate? = nil) {
            self.url = url
            self.predicate = predicate ?? { _ in true }
            maxLevel = options.compactMap { $0.depth }.first
            var options = FileManager.DirectoryEnumerationOptions(options)
            if maxLevel != nil {
                options.remove(.skipsSubdirectoryDescendants)
            }
            directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
        }

        public func next() -> URL? {
            if let directoryEnumerator = directoryEnumerator {
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else if predicate(nextURL) == true {
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

        public var level: Int? {
            directoryEnumerator?.level
        }
    }
    
    /**
     Iterate items with the specified enumeration options.
     
     - Parameters:
        - options: Options for enumerating the contents of directories.
     */
    func iterate(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return URLSequence(url: self, options: options, predicate: { _ in true })
    }
    
    /**
     Iterate items with the specified enumeration options.
     
     - Parameters:
        - options: Options for enumerating the contents of directories.
     */
    func iterate( _ options: DirectoryEnumerationOption...) -> URLSequence {
        return iterate(options: Set(options))
    }

    /**
     Iterate items that satisfies the given predicate.
     
     - Parameters:
        - predicate: A closure that takes an item url as its argument and returns a Boolean value indicating whether the url is a match.
        - options: Options for enumerating the contents of directories.
     */
    func iterate(predicate: ((URL) -> Bool)? = nil, options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        let predicate = predicate ?? { _ in true }
        return URLSequence(url: self, options: options, predicate: predicate)
    }

    /**
     Iterate items that satisfies the given predicate.
     
     - Parameters:
        - predicate: A closure that takes an item url as its argument and returns a Boolean value indicating whether the url is a match.
        - options: Options for enumerating the contents of directories.
     */
    func iterate(predicate: ((URL) -> Bool)? = nil, _ options: DirectoryEnumerationOption...) -> URLSequence {
        iterate(predicate: predicate, options: Set(options))
    }

    /**
     Iterate files with the specified enumeration options.
     
     - Parameters options: Options for enumerating the contents of directories.
     */
    func iterateFiles(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            $0.isFile
        }, options: options)
    }

    /**
     Iterate files with the specified enumeration options.
     
     - Parameters options: Options for enumerating the contents of directories.
     */
    func iterateFiles(_ options: DirectoryEnumerationOption...) -> URLSequence {
        return iterateFiles(options: Set(options))
    }

    /**
     Iterate files with the specified file types.
     
     - Parameters:
        - types: The file types to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(types: [FileType], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            if types.isEmpty { return $0.isFile }
            if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false }
        }, options: options)
    }

    /**
     Iterate files with the specified file types.
     
     - Parameters:
        - types: The file types to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(types: [FileType], _ options: DirectoryEnumerationOption...) -> URLSequence {
        iterateFiles(types: types, options: Set(options))
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /**
     Iterate files with the specified file UTTypes.
     
     - Parameters:
        - contentTypes: The file content types to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(contentTypes: [UTType], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            if contentTypes.isEmpty { return $0.isFile }
            if let type = $0.contentType, (contentTypes.contains(type) || type.conforms(toAny: contentTypes))  {
                return true
            } else { return false }
        }, options: options)
    }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /**
     Iterate files with the specified file UTTypes.
     
     - Parameters:
        - contentTypes: The file content types to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(contentTypes: [UTType], _ options: DirectoryEnumerationOption...) -> URLSequence {
        iterateFiles(contentTypes: contentTypes, options: Set(options))
    }

    /**
     Iterate files with the specified file extensions.
     
     - Parameters:
        - extensions: The file extensions to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(extensions: [String], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        let extensions = extensions.compactMap { $0.lowercased() }
        return iterate(predicate: {
            if extensions.isEmpty { return $0.isFile }
            return extensions.contains($0.pathExtension.lowercased())
        }, options: options)
    }

    /**
     Iterate files with the specified file extensions.
     
     - Parameters:
        - extensions: The file extensions to enumerate.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(extensions: [String], options: DirectoryEnumerationOption...) -> URLSequence {
        return iterateFiles(extensions: extensions, options: Set(options))
    }

    /**
     Iterate directories with the specified enumeration options.
     
     - Parameters options: Options for enumerating the contents of directories.
     */
    func iterateDirectories(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: { $0.pathExtension == "" }, options: options)
    }

    /**
     Iterate directories with the specified enumeration options.
     
     - Parameters options: Options for enumerating the contents of directories.
     */
    func iterateDirectories(_ options: DirectoryEnumerationOption...) -> URLSequence {
        iterateDirectories(options: Set(options))
    }
}

internal extension FileManager.DirectoryEnumerationOptions {
    static var `default`: FileManager.DirectoryEnumerationOptions {
        [.skipsHiddenFiles, .skipsPackageDescendants]
    }

    static var defaultSkippingSubdirectories: FileManager.DirectoryEnumerationOptions {
        [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
    }
}

internal extension Dictionary where Key == FileAttributeKey {
    var fileType: FileAttributeType? {
        if let typeString = self[.type] as? String {
            return FileAttributeType(rawValue: typeString)
        }
        return nil
    }

    var isDirectory: Bool? {
        fileType == .typeDirectory
    }

    var isRegularFile: Bool? {
        fileType == .typeRegular
    }
}

/*
public extension URL {
    func iterateFiles(by enumerationOptions: [FileEnumerationOption], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: enumerationOptions.predicate(), options: options)
    }

    func iterateFiles(by enumerationOptions: FileEnumerationOption..., options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterateFiles(by: enumerationOptions, options: options)
    }

    struct FileEnumerationOption {
        internal let predicate: (URL) -> Bool
        internal init(_ predicate: @escaping (URL) -> Bool) {
            self.predicate = predicate
        }

        public static func extensions(_ extensions: [String]) -> Self {
            let extensions = extensions.compactMap { $0.lowercased() }
            return Self {
                if extensions.isEmpty { return $0.isFile }
                return extensions.contains($0.pathExtension.lowercased())
            }
        }

        public static func extensions(_ extensions: String...) -> Self {
            return self.extensions(extensions)
        }

        public static func types(_ types: [FileType]) -> Self {
            return Self {
                if types.isEmpty { return $0.isFile }
                if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false }
            }
        }

        public static func types(_ types: FileType...) -> Self {
            return self.types(types)
        }

        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func uttypes(_ types: [UTType]) -> Self {
            return Self {
                if types.isEmpty { return $0.isFile }
                if let type = $0.contentType, types.contains(type) { return true } else { return false }
            }
        }

        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func uttypes(_ types: UTType...) -> Self {
            return uttypes(types)
        }

        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func conforming(to types: [UTType]) -> Self {
            return Self {
                if types.isEmpty { return $0.isFile }
                return $0.contentType?.conforms(toAny: types) ?? false
            }
        }

        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func conforming(to types: UTType...) -> Self {
            return conforming(to: types)
        }
    }
}


internal extension Sequence where Element == URL.FileEnumerationOption {
    func predicate() -> ((URL) -> Bool) {
        return { url in
            guard url.isFile == true else { return false }
            return self.contains(where: { $0.predicate(url) == true })
        }
    }
}
*/
