//
//  ObjcDynamicLibrary.swift
//
//
//  Created by Florian Zand on 06.03.26.
//

import Foundation

/// A dynamic Objective-C library.
public struct ObjcDynamicLibrary: Hashable, Comparable {
    /// The URL to the dynamic library.
    public let url: URL
    /// The name of the dynamic library.
    public let name: String
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
    
    init?(_ path: String?) {
        guard let path = path else { return nil }
        url = URL(fileURLWithPath: path)
        name = url.deletingPathExtension().lastPathComponent
    }
}
