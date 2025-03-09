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
        
        /**
         File definitions for the specified file extension.
         
         Each dictionary key represents the application bundle that can handle the file extension and each value represents the file type definitions for the file extension.
         */
        func fileDefinitions(for fileExtension: String) -> [Bundle: [FileTypeDefinition]] {
            Dictionary(uniqueKeysWithValues: applications(toOpen: fileExtension).map { ($0, $0.fileTypeDefinitions(for: fileExtension)) }).filter({!$0.value.isEmpty})

        }
        
        /**
         File definitions for the specified content type.
         
         Each dictionary key represents the application bundle that can handle the content type and each value represents the file type definitions for the content type.
         */
        func fileDefinitions(for uttype: UTType) -> [Bundle: [FileTypeDefinition]] {
            Dictionary(uniqueKeysWithValues: applications(toOpen: uttype).map { ($0, $0.fileTypeDefinitions(for: uttype)) }).filter({!$0.value.isEmpty})
        }
    }
#endif
