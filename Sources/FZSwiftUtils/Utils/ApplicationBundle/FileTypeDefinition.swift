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
        public var role: Role?
        public var handlerRank: HandlerRank?
        public var extensions: [String]
        private var contentTypeIdentifiers: [String]
        public var appBundleURL: URL?
        //public var isPackage: Bool?
        @available(macOS 11.0, iOS 14.0, *)
        public var contentTypes: [UTType] { contentTypeIdentifiers.compactMap { UTType($0) } }
        public var icon: NSUIImage? {
            guard let iconName = iconName, let appBundle = appBundle else { return nil }
            return appBundle.image(forResource: iconName)
        }
        public var appBundle: Bundle? {
            guard let appBundleURL = appBundleURL else { return nil }
            return Bundle(url: appBundleURL)
        }
        
        public enum Role: String, Codable, Hashable {
            case editor = "Editor"
            case viewer = "Viewer"
            case shell = "Shell"
            case qlGenerator = "QLGenerator"
            case none = "None"
        }
        
        public enum HandlerRank: String, Codable, Hashable {
            case owner = "Owner"
            case alternate = "Alternate"
            case `default` = "Default"
            case none = "None"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.extensions = try container.decodeIfPresent([String].self, forKey: .extensions) ?? []
            self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.appBundleURL = try container.decodeIfPresent(URL.self, forKey: .appBundleURL)
            self.role = try container.decodeIfPresent(Role.self, forKey: .role)
            // self.isPackage = try container.decodeIfPresent(Bool.self, forKey: .isPackage)
            self.handlerRank = try container.decodeIfPresent(HandlerRank.self, forKey: .handlerRank)
            self.contentTypeIdentifiers = try container.decodeIfPresent([String].self, forKey: .contentTypeIdentifiers) ?? []
        }

        public enum CodingKeys: String, CodingKey {
            case extensions = "CFBundleTypeExtensions"
            case iconName = "CFBundleTypeIconFile"
            case name = "CFBundleTypeName"
            case appBundleURL = "appBundleURL"
            case role = "CFBundleTypeRole"
            case contentTypeIdentifiers = "LSItemContentTypes"
            //case isPackage = "LSTypeIsPackage"
            case handlerRank = "LSHandlerRank"
        }
    }

#endif
