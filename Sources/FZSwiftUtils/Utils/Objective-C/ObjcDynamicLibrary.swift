//
//  ObjCDynamicLibrary.swift
//
//
//  Created by Florian Zand on 06.03.26.
//

import Foundation

/// An Objective-C framework or dynamic library.
public struct ObjCDynamicLibrary: Hashable, Comparable, Codable {
    /// The URL to the framework or dynamic library.
    public let url: URL
    /// The name of the framework or dynamic library.
    public let name: String
    
    /// All the classes within the framework or dynamic library.
    public var classes: [ObjCClass] {
        var count: UInt32 = 0
        guard let list = objc_copyClassNamesForImage(url.path, &count) else { return [] }
        defer { free(list) }
        return list.buffer(count: count).map { $0.string }.sorted().compactMap { ObjCClass($0) }
    }
    
    init(_ url: URL) {
        self.url = url
        self.name = url.deletingPathExtension().lastPathComponent
    }
    
    /// Returns the loaded Objective-C framework or dynamic library with the specified name.
    public init?(_ name: String) {
        guard let image = Self.loaded().first(where: {
            $0.name.caseInsensitiveCompare(name).isEqual
        }) else { return nil }
        self = image
        return
    }
    
    /// Returns all loaded Objective-C frameworks and dynamic libraries.
    public static func loaded() -> [Self] {
        var count: UInt32 = 0
        let list = objc_copyImageNames(&count)
        defer { free(list) }
        return list.buffer(count: count).map { .init(.file($0.string)) }.sorted()
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
}
