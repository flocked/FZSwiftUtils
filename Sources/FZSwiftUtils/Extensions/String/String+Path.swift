//
//  String+Path.swift
//
//
//  Created by Florian Zand on 21.10.26.
//

import Foundation

public extension String {
    /// Provides filesystem path operations for the string.
    var path: Path {
        Path(self)
    }
    
    /**
     Provides filesystem path operations for a string.
     
     Access the operations by using the  `path` property of a string.
     */
    struct Path {
        private let string: NSString

        init(_ string: String) {
            self.string = string as NSString
        }

        /// The path extension, excluding the final period.
        public var `extension`: String {
            string.pathExtension
        }

        /// The path with its final extension removed.
        public var deletingExtension: String {
            string.deletingPathExtension
        }

        /// The individual components of the path.
        public var components: [String] {
            string.pathComponents
        }

        /// The last component of the path.
        public var lastComponent: String {
            string.lastPathComponent
        }

        /// The path with its last component removed.
        public var deletingLastComponent: String {
            string.deletingLastPathComponent
        }

        /**
         The standardized path.

         Removes redundant separators and resolves relative components
         such as `.` and `..`.
         */
        public var standardized: String {
            string.standardizingPath
        }

        /// The path with an initial tilde expanded to the home directory.
        public var tildeExpanded: String {
            string.expandingTildeInPath
        }

        /// The path with the current home directory abbreviated to a tilde.
        public var tildeAbbreviated: String {
            string.abbreviatingWithTildeInPath
        }

        /// The path with symbolic links resolved and path components standardized.
        public var symlinksResolved: String {
            string.resolvingSymlinksInPath
        }

        /// Whether the path is absolute.
        public var isAbsolute: Bool {
            string.isAbsolutePath
        }

        /// Returns the path with the specified component appended.
        public func appending(_ component: String) -> String {
            string.appendingPathComponent(component)
        }

        /// Returns paths created by appending each specified path.
        public func appending(_ paths: [String]) -> [String] {
            string.strings(byAppendingPaths: paths)
        }
        
        /**
         Returns the path with the specified extension appended.
         
         Returns `nil` if the extension cannot be appended.
         */
        public func appendingExtension(_ extension: String) -> String? {
            string.appendingPathExtension(`extension`)
        }

        /// Creates a path by joining the specified components.
        public static func joining(_ components: [String]) -> String {
            NSString.path(withComponents: components)
        }
         
        /**
         Attempts to complete the path using matching filesystem entries.

         - Parameters:
           - caseSensitive: Whether matching is case-sensitive.
           - filterTypes: The file extensions to include, or `nil` to include all types.
         - Returns: The completed path and matching paths, or `nil` if no matches were found.
         */
        public func completing(caseSensitive: Bool = true, filterTypes: [String]? = nil) -> (path: String?, matches: [String])? {
            var completedPath: NSString?
            var matches: NSArray?
            let count = string.completePath(into: &completedPath, caseSensitive: caseSensitive, matchesInto: &matches, filterTypes: filterTypes)
            guard count > 0 else { return nil }
            return (completedPath as String?, matches as? [String] ?? [])
        }
        
        /**
         Provides access to the path's null-terminated filesystem representation.

         The pointer is valid only for the duration of the closure.
         */
        public func withFileSystemRepresentation<R>(_ body: (UnsafePointer<CChar>) throws -> R) rethrows -> R {
            try body(string.fileSystemRepresentation)
        }
    }
}

