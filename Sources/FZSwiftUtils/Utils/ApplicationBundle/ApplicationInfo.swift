//
//  ApplicationInfo.swift
//
//
//  Created by Florian Zand on 15.01.22.
//

#if os(macOS)

    import AppKit
    import Foundation
    import SwiftUI
    import UniformTypeIdentifiers

    struct ApplicationInfo: Codable {
        var identifier: String
        var executable: String

        var name: String?
        var displayName: String?
        var iconFile: String?
        var iconName: String?
        var version: String?
        var shortVersion: String?
        let minimumSystemVersion: String?
        var supportedFileTypes: [FileTypeDefinition]

        var url: URL?
        init?(url: URL) {
            do {
                let data = try Data(contentsOf: url)
                var info = try PropertyListDecoder().decode(ApplicationInfo.self, from: data)
                info.url = url
                self = info
            } catch {
                return nil
            }
        }

        init?(path: String) {
            self.init(url: URL(fileURLWithPath: path))
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
            identifier = try container.decode(String.self, forKey: .identifier)
            iconFile = try container.decodeIfPresent(String.self, forKey: .iconFile)
            iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
            executable = try container.decode(String.self, forKey: .executable)
            shortVersion = try container.decodeIfPresent(String.self, forKey: .shortVersion)
            version = try container.decodeIfPresent(String.self, forKey: .version)
            minimumSystemVersion = try container.decodeIfPresent(String.self, forKey: .minimumSystemVersion)

            let supportedTypes = try container.decodeIfPresent([FileTypeDefinition].self, forKey: .supportedFileTypes) ?? []
            var supportedFileTypes: [FileTypeDefinition] = []
            for var supportedType in supportedTypes {
                supportedType.applicationURL = url
                supportedFileTypes.append(supportedType)
            }
            self.supportedFileTypes = supportedFileTypes
        }

        init?(dic: [String: Any]) {
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: .init())
                let info = try JSONDecoder().decode(ApplicationInfo.self, from: data)
                self = info
            } catch {
                return nil
            }
        }

        private enum CodingKeys: String, CodingKey {
            case name = "CFBundleName"
            case displayName = "CFBundleDisplayName"
            case identifier = "CFBundleIdentifier"
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
