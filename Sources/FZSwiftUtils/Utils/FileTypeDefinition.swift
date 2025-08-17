//
//  FileTypeDefinition.swift
//
//
//  Created by Florian Zand on 07.06.22.
//

#if os(macOS)
import Foundation
import UniformTypeIdentifiers

/// A file type definition.
public struct FileTypeDefinition: Codable, Hashable {
    /// The name of the file type definition.
    public let name: String?
    
    /// The role of the file type definition.
    public let role: Role?
    
    /// The handler rank of the file type definition.
    public let handlerRank: HandlerRank?
    
    /// The file extension of the file type definition.
    public let extensions: [String]
    
    /// The content type identifiers of the file type definition.
    private let contentTypeIdentifiers: [String]
    
    //public var isPackage: Bool?
    
    /// The content types of the file type definition.
    @available(macOS 11.0, iOS 14.0, *)
    public var contentTypes: [UTType] {
        contentTypeIdentifiers.compactMap { UTType($0) }
    }
    
    /// The icon name of the file type definition.
    public let iconName: String?
    
    /// The icon of the file type definition.
    public var icon: NSUIImage? {
        guard let iconName = iconName, let appBundle = appBundle else { return nil }
        return appBundle.image(forResource: iconName)
    }
    internal var appBundleURL: URL?
    
    /// The application bundle of the file type definition.
    public var appBundle: Bundle? {
        guard let appBundleURL = appBundleURL else { return nil }
        return Bundle(url: appBundleURL)
    }

    /// Role of a file type definition.
    public enum Role: String, Codable, Hashable {
        /// Editor.
        case editor = "Editor"
        /// Viewer.
        case viewer = "Viewer"
        /// Shell.
        case shell = "Shell"
        /// QLGenerator.
        case qlGenerator = "QLGenerator"
        /// None.
        case none = "None"
    }

    /// Handler rank of a file type definition.
    public enum HandlerRank: String, Codable, Hashable {
        /// Owner.
        case owner = "Owner"
        /// Alternate.
        case alternate = "Alternate"
        /// Default.
        case `default` = "Default"
        /// None.
        case none = "None"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.extensions = try container.decodeIfPresent([String].self, forKey: .extensions) ?? []
        self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.appBundleURL = try container.decodeIfPresent(URL.self, forKey: .appBundleURL)
        self.role = try container.decodeIfPresent(Role.self, forKey: .role)
        self.handlerRank = try container.decodeIfPresent(HandlerRank.self, forKey: .handlerRank)
        self.contentTypeIdentifiers = try container.decodeIfPresent([String].self, forKey: .contentTypeIdentifiers) ?? []
        // self.isPackage = try container.decodeIfPresent(Bool.self, forKey: .isPackage)
    }

    public enum CodingKeys: String, CodingKey {
        case extensions = "CFBundleTypeExtensions"
        case iconName = "CFBundleTypeIconFile"
        case name = "CFBundleTypeName"
        case appBundleURL = "appBundleURL"
        case role = "CFBundleTypeRole"
        case contentTypeIdentifiers = "LSItemContentTypes"
        case handlerRank = "LSHandlerRank"
        //case isPackage = "LSTypeIsPackage"
    }
}

#endif
