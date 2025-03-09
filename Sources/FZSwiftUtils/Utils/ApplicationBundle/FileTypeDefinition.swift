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
        public var appBundleURL: URL?
        //  var isPackage: Bool?
        @available(macOS 11.0, iOS 14.0, *)
        public var contentTypes: [UTType] {
            contentTypeIdentifiers.compactMap { UTType($0) }
        }
        public var icon: NSUIImage? {
            guard let iconName = iconName, let appBundle = appBundle else { return nil }
            return appBundle.image(forResource: iconName)
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self._extensions = try container.decode(DefaultCodable<PropertyWrapperStrategies.DefaultEmptyArrayStrategy<String>>.self, forKey: .extensions)
            self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.appBundleURL = try container.decodeIfPresent(URL.self, forKey: .appBundleURL)
            self.role = try container.decodeIfPresent(String.self, forKey: .role)
            self._contentTypeIdentifiers = try container.decode(DefaultCodable<PropertyWrapperStrategies.DefaultEmptyArrayStrategy<String>>.self, forKey: .contentTypeIdentifiers)
        }

        public var appBundle: Bundle? {
            if let appBundleURL = appBundleURL {
                return Bundle(url: appBundleURL)
            } else {
                return nil
            }
        }

        public enum CodingKeys: String, CodingKey {
            case extensions = "CFBundleTypeExtensions"
            case iconName = "CFBundleTypeIconFile"
            case name = "CFBundleTypeName"
            case appBundleURL = "appBundleURL"
            case role = "CFBundleTypeRole"
            case contentTypeIdentifiers = "LSItemContentTypes"
        }
    }

#endif
