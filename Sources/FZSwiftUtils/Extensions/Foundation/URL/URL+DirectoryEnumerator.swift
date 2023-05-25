//
//  URL+DirectoryIrator.swift
//  ImageViewer
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


extension URL {
    public enum DirectoryEnumerationOption: Hashable {
        case includePackageDescendants
        case includeSubdirectoryDescendants
        case includeHiddenFiles
        case maxDepth(Int)
        internal var depth: Int? {
            switch self {
            case .maxDepth(let value): return value
            default: return nil
            }
        }
    }
    
    public typealias DirectoryEnumerationPredicate = DirectoryIterator.Predicate
    
    public struct URLSequence: Sequence {
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
    
    public struct DirectoryIterator: IteratorProtocol {
        public typealias Element = URL
        public typealias Predicate = ((Self.Element) -> Bool)
        public typealias Options = Set<DirectoryEnumerationOption>

        let url: URL
        let predicate: Predicate
        let directoryEnumerator: FileManager.DirectoryEnumerator?
        let maxLevel: Int?
                
        init(url: URL, options: Options = [], predicate: Predicate? = nil) {
            self.url = url
            self.predicate = predicate ?? {url in return true}
            self.maxLevel = options.compactMap({ $0.depth }).first
            var options = FileManager.DirectoryEnumerationOptions(options)
            if (self.maxLevel != nil) {
                options.remove(.skipsSubdirectoryDescendants)
            }
            self.directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)
        }
        
        public func next() -> URL? {
            if let directoryEnumerator = self.directoryEnumerator {
                while let nextURL = directoryEnumerator.nextObject() as? URL {
                    if let maxLevel = self.maxLevel, directoryEnumerator.level > maxLevel {
                        directoryEnumerator.skipDescendants()
                    } else if self.predicate(nextURL) == true {
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
        
    // iterate
    public func iterate(predicate: ((URL) -> Bool)? = nil, options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        let predicate = predicate ?? {_ in return true }
        return URLSequence(url: self, options: options, predicate: predicate)
    }

    public func iterate(predicate: ((URL) -> Bool)? = nil, _ options: DirectoryEnumerationOption...) -> URLSequence {
        self.iterate(predicate: predicate, options: Set(options))
    }
    
    
    // iterateFiles FileTypes
    public func iterateFiles(types: [FileType], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            if (types.isEmpty) { return $0.isFile }
            if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false } }, options: options)
    }
    
    public func iterateFiles(types: [FileType], _ options: DirectoryEnumerationOption...) -> URLSequence {
        self.iterateFiles(types: types, options: Set(options))
    }
    
    // iterateFiles UTTypes
    @available(macOS 11.0, iOS 14.0, *)
    public func iterateFiles(uttypes: [UTType], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            if (uttypes.isEmpty) { return $0.isFile }
            if let type = $0.contentType, uttypes.contains(type) { return true } else { return false } }, options: options)
    }
    
    @available(macOS 11.0, iOS 14.0, *)
    public func iterateFiles(uttypes: [UTType], _ options: DirectoryEnumerationOption...) -> URLSequence {
        self.iterateFiles(uttypes: uttypes, options: Set(options))
    }
    
    @available(macOS 11.0, iOS 14.0, *)
    public func iterateFiles(conformingTo types: [UTType], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: {
            if (types.isEmpty) { return $0.isFile }
            return $0.contentType?.conforms(toAny: types) ?? false }, options: options)
    }
    
    @available(macOS 11.0, iOS 14.0, *)
    public func iterateFiles(conformingTo types: [UTType], _ options: DirectoryEnumerationOption...) -> URLSequence {
        self.iterateFiles(conformingTo: types, options: Set(options))
    }
    
    
    // iterateFiles Extensions
    public func iterateFiles(extensions: [String] = [], options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        let extensions = extensions.compactMap({$0.lowercased()})
        return iterate(predicate: {
            if (extensions.isEmpty) { return $0.isFile }
            return extensions.contains($0.pathExtension.lowercased()) }, options: options)
    }
    
    public func iterateFiles(extensions: [String] = [], options: DirectoryEnumerationOption...) -> URLSequence {
        return iterateFiles(extensions: extensions, options: Set(options))
    }
    
    
    // iterateDirectories
    public func iterateDirectories(options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: { $0.pathExtension == "" }, options: options)
    }
    
    public func iterateDirectories(_ options: DirectoryEnumerationOption...) -> URLSequence {
        self.iterateDirectories(options: Set(options))
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
        self.fileType == .typeDirectory
    }
    
    var isRegularFile: Bool? {
        self.fileType == .typeRegular
    }
}

public extension URL {
    func iterateFiles(by enumerationOptions: [FileEnumerationOption],  options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterate(predicate: enumerationOptions.predicate(), options: options)
    }
    
    func iterateFiles(by enumerationOptions: FileEnumerationOption...,  options: Set<DirectoryEnumerationOption> = []) -> URLSequence {
        return iterateFiles(by: enumerationOptions, options: options)
    }
    
    struct FileEnumerationOption {
        internal let predicate: ((URL) -> Bool)
        internal init(_ predicate: @escaping (URL) -> Bool) {
            self.predicate = predicate
        }
        
        public static func extensions(_ extensions: [String]) -> Self {
            let extensions = extensions.compactMap({$0.lowercased()})
            return Self({
                if (extensions.isEmpty) { return $0.isFile }
                return extensions.contains($0.pathExtension.lowercased()) })
        }
        
        public static func extensions(_ extensions: String...) -> Self {
            return self.extensions(extensions)
        }
        
        public static func types(_ types: [FileType]) -> Self {
            return Self({
                if (types.isEmpty) { return $0.isFile }
                if let fileType = $0.fileType, types.contains(fileType) { return true } else { return false } })
        }
        
        public static func types(_ types: FileType...) -> Self {
            return self.types(types)
        }
        
        @available(macOS 11.0, iOS 14.0, *)
        public static func uttypes(_ types: [UTType]) -> Self {
            return Self({
                if (types.isEmpty) { return $0.isFile }
                if let type = $0.contentType, types.contains(type) { return true } else { return false } })
        }
        
        @available(macOS 11.0, iOS 14.0, *)
        public static func uttypes(_ types: UTType...) -> Self {
            return self.uttypes(types)
        }
        
        @available(macOS 11.0, iOS 14.0, *)
        public static func conforming(to types: [UTType]) -> Self {
            return Self({
                if (types.isEmpty) { return $0.isFile }
                return $0.contentType?.conforms(toAny: types) ?? false })
        }
        
        @available(macOS 11.0, iOS 14.0, *)
        public static func conforming(to types: UTType...) -> Self {
            return self.conforming(to: types)
        }
    }
}

internal extension Sequence where Element == URL.FileEnumerationOption {
    func predicate() -> ((URL) -> Bool) {
        return {url in
            guard url.isFile == true else { return false }
            return self.contains(where: {$0.predicate(url) == true}) }
    }
}
