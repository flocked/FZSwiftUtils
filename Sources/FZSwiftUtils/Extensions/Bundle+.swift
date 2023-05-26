//
//  Bundle+Extension.swift
//  ATest
//
//  Created by Florian Zand on 21.01.22.
//

#if os(macOS)
import Foundation

public extension Bundle {
    enum BundlePlatform {
        case macOS
        case maciOS
    }

    var isApplicationBundle: Bool {
        return bundlePath.lowercased().contains(".app")
    }

    var bundleName: String {
        return bundleURL.deletingPathExtension().lastPathComponent
    }

    var executableDirectoryURL: URL? {
        return executableURL?.deletingLastPathComponent()
    }

    var bundleNameExcludingExtension: String {
        return bundleURL.deletingPathExtension().lastPathComponent
    }

    var platform: BundlePlatform {
        if let executableURL = executableURL {
            if executableURL.path.contains("Wrapper") {
                return .maciOS
            }
        }
        return .macOS
    }

    var contentsDirectoryURL: URL? {
        if platform == .macOS {
            return bundleURL.appendingPathComponent("Contents")
        } else {
            return executableURL?.deletingLastPathComponent().deletingLastPathComponent()
        }
    }

    var infoURL: URL? {
        return contentsDirectoryURL?.appendingPathComponent("Info.plist")
    }
}
#endif
