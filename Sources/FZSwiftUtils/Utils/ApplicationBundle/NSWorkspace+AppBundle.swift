//
//  NSWorkspace+ApplicationBundle.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

public extension NSWorkspace {
    @available(macOS 12.0, *)
    func applications(toOpen fileExtension: String) -> [ApplicationBundle] {
        if let uttype = UTType(filenameExtension: fileExtension.lowercased()) {
            return applications(toOpen: uttype)
        }
        return []
    }

    @available(macOS 12.0, *)
    func applications(toOpen uttype: UTType) -> [ApplicationBundle] {
        urlsForApplications(toOpen: uttype).compactMap { ApplicationBundle(url: $0) }
    }

    @available(macOS 12.0, *)
    func fileDefinitions(for fileExtension: String) -> [FileTypeDefinition] {
        return UTType(filenameExtension: fileExtension.lowercased())?.definitions ?? []
    }

    @available(macOS 12.0, *)
    func fileDefinitions(for uttype: UTType) -> [FileTypeDefinition] {
        return uttype.definitions
    }
}
#endif
