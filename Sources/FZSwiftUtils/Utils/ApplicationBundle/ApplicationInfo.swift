//
//  ApplicationInfo.swift
//
//
//  Created by Florian Zand on 15.01.22.
//

#if os(macOS)

    import Foundation
    import UniformTypeIdentifiers

    /// The application info, constructed from the bundle’s `Info.plist` file.
    public struct ApplicationInfo: Codable {
        /// The url of the `info.plist`.
        public internal(set) var url: URL?
        
        var appBundleURL: URL? {
            didSet { supportedFileTypes.editEach({$0.appBundleURL = appBundleURL }) }
        }
                
        /// The bundle identifier.
        public let bundleIdentifier: String
        
        /// The bundle name.
        public let bundleName: String?
        
        /// The name of the executable.
        public let executable: String

        /// The display name.
        public let displayName: String?
        
        /// The version.
        public let version: String?
        
        /// The short version.
        public let shortVersion: String?
        
        /// The minimum version.
        public let minimumSystemVersion: String?
        
        /// The supported file types.
        public var supportedFileTypes: [FileTypeDefinition]
        
        /// The name of the icon file.
        public let iconFile: String?
        
        /// The name of the icon.
        public let iconName: String?
        
        init?(url: URL) {
            do {
                self = try PropertyListDecoder().decode(Self.self, from: try Data(contentsOf: url))
                self.url = url
            } catch {
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            bundleName = try container.decodeIfPresent(String.self, forKey: .bundleName)
            displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
            bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
            iconFile = try container.decodeIfPresent(String.self, forKey: .iconFile)
            iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
            executable = try container.decode(String.self, forKey: .executable)
            shortVersion = try container.decodeIfPresent(String.self, forKey: .shortVersion)
            version = try container.decodeIfPresent(String.self, forKey: .version)
            minimumSystemVersion = try container.decodeIfPresent(String.self, forKey: .minimumSystemVersion)

            let supportedTypes = try container.decodeIfPresent([FileTypeDefinition].self, forKey: .supportedFileTypes) ?? []
            var supportedFileTypes: [FileTypeDefinition] = []
            for var supportedType in supportedTypes {
                supportedType.appBundleURL = url
                supportedFileTypes.append(supportedType)
            }
            self.supportedFileTypes = supportedFileTypes
        }

        private enum CodingKeys: String, CodingKey {
            case bundleName = "CFBundleName"
            case displayName = "CFBundleDisplayName"
            case bundleIdentifier = "CFBundleIdentifier"
            case iconFile = "CFBundleIconFile"
            case iconName = "CFBundleIconName"
            case executable = "CFBundleExecutable"
            case shortVersion = "CFBundleShortVersionString"
            case version = "CFBundleVersionString"
            case supportedFileTypes = "CFBundleDocumentTypes"
            case minimumSystemVersion = "LSMinimumSystemVersion"
        }
    }

#endif
