//
//  FileTypeDefinition.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
    import Foundation
    import UniformTypeIdentifiers

    public struct FileTypeDefinition: Codable, Hashable {
        public var iconName: String?
        public var name: String?
        public var role: String?
        @DefaultEmptyArray var extensions: [String]
        @DefaultEmptyArray private var contentTypeIdentifiers: [String]
        public var applicationURL: URL?
        //  var isPackage: Bool?
        @available(macOS 11.0, iOS 14.0, *)
        public var contentTypes: [UTType] {
            contentTypeIdentifiers.compactMap { UTType($0) }
        }

        public var application: Bundle? {
            if let applicationURL = applicationURL {
                return Bundle(url: applicationURL)
            } else {
                return nil
            }
        }

        public enum CodingKeys: String, CodingKey {
            case extensions = "CFBundleTypeExtensions"
            case iconName = "CFBundleTypeIconFile"
            case name = "CFBundleTypeName"
            case applicationURL = "ApplicationBundleURL"
            case role = "CFBundleTypeRole"
            case contentTypeIdentifiers = "LSItemContentTypes"
        }
    }

#endif
