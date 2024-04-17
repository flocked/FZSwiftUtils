//
//  NSWorkspace+AppBundle.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
    import AppKit
    import UniformTypeIdentifiers

    @available(macOS 12.0, *)
    public extension NSWorkspace {
        /// Applications that can open the specified file extension.
        func applications(toOpen fileExtension: String) -> [Bundle] {
            if let uttype = UTType(filenameExtension: fileExtension.lowercased()) {
                return applications(toOpen: uttype)
            }
            return []
        }

        /// Applications that can open the specified content type.
        func applications(toOpen uttype: UTType) -> [Bundle] {
            urlsForApplications(toOpen: uttype).compactMap { Bundle(url: $0) }
        }

        /// File definitions for the specified file extension.
        func fileDefinitions(for fileExtension: String) -> [FileTypeDefinition] {
            UTType(filenameExtension: fileExtension.lowercased())?.definitions ?? []
        }

        /// File definitions for the specified content type.
        func fileDefinitions(for uttype: UTType) -> [FileTypeDefinition] {
            uttype.definitions
        }
    }
#endif
