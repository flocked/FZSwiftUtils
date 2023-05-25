//
//  InfoPlist.swift
//  ATest
//
//  Created by Florian Zand on 15.01.22.
//

#if os(macOS)

import Foundation
import AppKit
import UniformTypeIdentifiers
import SwiftUI

internal struct ApplicationInfo: Codable {
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
    
    internal var url: URL?
    init?(url: URL) {
        do {
            let data = try Data.init(contentsOf: url)
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
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.iconFile = try container.decodeIfPresent(String.self, forKey: .iconFile)
        self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        self.executable = try container.decode(String.self, forKey: .executable)
        self.shortVersion = try container.decodeIfPresent(String.self, forKey: .shortVersion)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        self.minimumSystemVersion = try container.decodeIfPresent(String.self, forKey: .minimumSystemVersion)

        let supportedTypes = try container.decodeIfPresent([FileTypeDefinition].self, forKey: .supportedFileTypes) ?? []
        var supportedFileTypes: [FileTypeDefinition] = []
        for var supportedType in supportedTypes {
            supportedType.applicationURL = self.url
            supportedFileTypes.append(supportedType)
            }
            self.supportedFileTypes = supportedFileTypes
    }
    
    
    internal init?(dic: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: .init())
            let info = try JSONDecoder.init().decode(ApplicationInfo.self, from: data)
            self = info
        } catch {
            return nil
        }
    }
    
    private enum CodingKeys : String, CodingKey {
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
