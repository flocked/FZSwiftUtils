//
//  UTType+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if canImport(UniformTypeIdentifiers)
    import Foundation
    import UniformTypeIdentifiers

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public extension UTType {
        /// A type that represents a AC3 audio.
        static var ac3: UTType { UTType("public.ac3-audio")! }
        /// A type that represents a 3GPP movie.
        static var mobile3GPP: UTType { UTType("public.3gpp")! }
        /// A type that represents a 3GPP2 movie.
        static var mobile3GPP2: UTType { UTType("public.3gpp2")! }

        /**
         Creates a type based on a file url..

         This initializer returns `nil` if the system doesn’t know the type identifier.

         - Parameters:
            - url:The file url.
         */
        init?(url: URL) {
            if FileManager.default.fileExists(at: url) {
                if url.resources.isAliasFile {
                    self.init(UTType.aliasFile.identifier)
                } else if url.resources.isSymbolicLink {
                    self.init(UTType.symbolicLink.identifier)
                } else if url.isDirectory {
                    self.init(UTType.directory.identifier)
                } else if let contentType = url.resources.contentType {
                    self.init(contentType.identifier)
                }
            }
            self.init(filenameExtension: url.pathExtension)
        }

        var fileType: FileType? {
            FileType(contentType: self)
        }

        /**
         The filename extensions for the type.

         The value of this property is equivalent to, but more efficient than:
         ```swift
         type.tags[.filenameExtension]
         ```
         */
        var filenameExtensions: [String] {
            tags[.filenameExtension]?.compactMap { $0.lowercased() } ?? [String]()
        }

        /**
         Returns a Boolean value that indicates whether a type conforms to any of the types.

         - Parameters:
            - types:UTType's.
         - Returns: true if the type directly or indirectly conforms to any of the types, or if it’s equal to.
         */
        func conforms<S: Sequence<UTType>>(toAny types: S) -> Bool {
            for uttype in types {
                if conforms(to: uttype) {
                    return true
                }
            }
            return false
        }
    }

    #if os(macOS)
        import AppKit

        @available(macOS 12.0, *)
        public extension UTType {
            /// An array of URLs to applications that support opening the `UTType`.
            var supportedApplicationURLs: [URL] {
                NSWorkspace.shared.urlsForApplications(toOpen: self)
            }

            /// An array of applications that support opening the `UTType`.
            var supportedApplications: [Bundle] {
                NSWorkspace.shared.applications(toOpen: self)
            }

            /// An array of all file definitions for the `UTType`.
            var definitions: [FileTypeDefinition] {
                supportedApplications.compactMap({ $0.fileTypeDefinition(for: self) })
            }
        }
    #endif

#endif
