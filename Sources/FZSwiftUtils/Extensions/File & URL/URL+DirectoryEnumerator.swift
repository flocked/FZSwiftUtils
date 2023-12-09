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
     
     - Parameter options: Options for enumerating the contents of directories.
     */
    func iterateFiles(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            $0.isFile
        }, options: options)
    }

    /**
     Iterate files with the specified enumeration options.
     
     - Parameter options: Options for enumerating the contents of directories.
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
     
     - Parameter options: Options for enumerating the contents of directories.
     */
    func iterateDirectories(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: { $0.isDirectory == true }, options: options)
    }

    /**
     Iterate directories with the specified enumeration options.
     
     - Parameter options: Options for enumerating the contents of directories.
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


public extension URL {
    /**
     Iterate files with the specified file enumeration.
     
     - Parameters:
        - fileEnumation: The file enumeration. To combine file enumerations use `||` as OR.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(by fileEnumation: FileEnumerationOption, options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: fileEnumation.predicate, options: options)
    }
    
    /**
     Iterate files with the specified file enumeration.
     
     - Parameters:
        - fileEnumation: The file enumeration. To combine file enumerations use `||` as OR.
        - options: Options for enumerating the contents of directories.
     */
    func iterateFiles(by fileEnumation: FileEnumerationOption, _ options: DirectoryEnumerationOption...) -> URLSequence {
        return iterate(predicate: fileEnumation.predicate, options: Set(options))
    }
    
    /**
     Options for iterating files. To combine file enumerations use `||` as OR.
     
     Example:
     
     ```swift
     url.iterateFiles(by: .type(.document) || .extension("ctf"))
     ```
     */
    struct FileEnumerationOption {
        /// Iterate files with the specified file extension.
        public static func `extension`(_ value: String) -> Self {
            self.extensions([value])
        }
        
        /// Iterate files with the specified file extensions.
        public static func extensions(_ extensions: [String]) -> Self {
            let extensions = extensions.compactMap { $0.lowercased() }
            return Self {
                if extensions.isEmpty { return $0.isFile }
                return extensions.contains($0.pathExtension.lowercased())
            }
        }
        
        /// Iterate files with the specified file extensions.
        public static func extensions(_ extensions: String...) -> Self {
            self.extensions(extensions)
        }
        
        /// Iterate files with the specified file type.
        public static func type(_ type: FileType) -> Self {
            self.types([type])
        }
        
        /// Iterate files with the specified file types.
        public static func types(_ types: [FileType]) -> Self {
            Self {
                if types.isEmpty { return $0.isFile }
                if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false }
            }
        }
        
        /// Iterate files with the specified file types.
        public static func types(_ types: FileType...) -> Self {
            self.types(types)
        }
        
        
        /// Iterate files with the specified UTType.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func contentType(_ type: UTType) -> Self {
            self.contentTypes([type])
        }
        
        /// Iterate files with the specified UTTypes.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func contentTypes(_ types: [UTType]) -> Self {
            Self {
                if types.isEmpty { return $0.isFile }
                if let type = $0.contentType, types.contains(type) { return true } else { return false }
            }
        }
        
        /// Iterate files with the specified UTTypes.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func contentTypes(_ types: UTType...) -> Self {
            contentTypes(types)
        }
        
        /// Iterate files conforming to the specified UTTypes.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func conforming(to types: [UTType]) -> Self {
            Self {
                if types.isEmpty { return $0.isFile }
                return $0.contentType?.conforms(toAny: types) ?? false
            }
        }
        
        /// Iterate files conforming to the specified UTTypes.
        @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        public static func conforming(to types: UTType...) -> Self {
            conforming(to: types)
        }
        
        /// Iterate files which file names contain the specified string.
        public static func name(contains string: String) -> Self {
            Self {
                $0.lastPathComponent.contains(string)
            }
        }
        
        /// Iterate files which file names begin with the specified string.
        public static func name(beginsWith string: String) -> Self {
            Self {
                $0.lastPathComponent.hasPrefix(string)
            }
        }
        
        /// Iterate files which file names end with the specified string.
        public static func name(endsWith string: String) -> Self {
            Self {
                $0.deletingPathExtension().lastPathComponent.hasSuffix(string)
            }
        }
        
        
        /// Iterate files whose file sizes are larger or equal than the specified file size.
        public static func fileSize(isLargerOrEqualTo size: DataSize) -> Self {
            Self {
                $0.resources.fileSize ?? .zero >= size
            }
        }
        
        /// Iterate files whose file sizes are larger or equal than the specified file size.
        public static func fileSize(isLessOrEqualTo size: DataSize) -> Self {
            Self {
                $0.resources.fileSize ?? .zero <= size
            }
        }
        
        /// Iterate files whose file sizes are larger or equal than the specified file size.
        public static func fileSize(isBetween range: ClosedRange<DataSize>) -> Self {
            Self {
                $0.resources.fileSize ?? .zero <= range.upperBound && $0.resources.fileSize ?? .zero >= range.lowerBound
            }
        }
        
        /// Iterate files whose creation date was before the specified date.
        public static func creationDate(before date: Date) -> Self {
            Self {
                $0.resources.creationDate ?? .distantFuture < date
            }
        }
        
        /// Iterate files whose creation date was after the specified date.
        public static func creationDate(after date: Date) -> Self {
            Self {
                $0.resources.creationDate ?? .distantFuture > date
            }
        }
        
        /// Iterate files whose creation date is between the specified date internval.
        public static func creationDate(between interval: DateInterval) -> Self {
            Self {
                interval.contains($0.resources.creationDate ?? .distantFuture)
            }
        }
        
        /// Iterate files whose content modification date was before the specified date.
        public static func contentModificationDate(before date: Date) -> Self {
            Self {
                $0.resources.contentModificationDate ?? .distantFuture < date
            }
        }
        
        /// Iterate files whose content modification date was after the specified date.
        public static func contentModificationDate(after date: Date) -> Self {
            Self {
                $0.resources.contentModificationDate ?? .distantFuture > date
            }
        }
        
        /// Iterate files whose content modification date is between the specified date internval.
        public static func contentModificationDate(between interval: DateInterval) -> Self {
            Self {
                interval.contains($0.resources.contentModificationDate ?? .distantFuture)
            }
        }
        
        /// Iterate files which content access date was before the specified date.
        public static func contentAccessDate(before date: Date) -> Self {
            Self {
                $0.resources.contentAccessDate ?? .distantFuture < date
            }
        }
        
        /// Iterate files which content access date was after the specified date.
        public static func contentAccessDate(after date: Date) -> Self {
            Self {
                $0.resources.contentAccessDate ?? .distantFuture > date
            }
        }
        
        /// Iterate files whose content access date is between the specified date internval.
        public static func contentAccessDate(between interval: DateInterval) -> Self {
            Self {
                interval.contains($0.resources.contentAccessDate ?? .distantFuture)
            }
        }
        
        internal let predicate: (URL) -> Bool
        internal init(_ predicate: @escaping (URL) -> Bool) {
            self.predicate = predicate
        }
        
        public static func || (lhs: Self, rhs: Self) -> Self {
            Self {
                lhs.predicate($0) || rhs.predicate($0)
            }
        }
    }
}
