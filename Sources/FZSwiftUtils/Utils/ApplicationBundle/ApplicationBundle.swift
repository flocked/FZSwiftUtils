//
//  ApplicationBundle.swift
//  ATest
//
//  Created by Florian Zand on 15.01.22.
//

#if os(macOS)
import AppKit
import Foundation
import UniformTypeIdentifiers

public extension NSRunningApplication {
    var bundle: ApplicationBundle? {
        return ApplicationBundle(runningApplication: self)
    }
}

public class ApplicationBundle: Bundle {
    override public init?(path: String) {
        super.init(path: path)
        if infoURL?.fileExists == false || !isApplicationBundle {
            return nil
        }
    }

    public convenience init?(url: URL) {
        self.init(url: url)
        if infoURL?.fileExists == false || !isApplicationBundle {
            return nil
        }
    }

    public convenience init?(runningApplication: NSRunningApplication) {
        if let path = runningApplication.bundleURL?.path {
            self.init(path: path)
        } else {
            return nil
        }
    }

    private lazy var info: ApplicationInfo = .init(dic: self.infoDictionary!)!

    public var name: String {
        if let name = info.name {
            return name
        } else if let displayName = info.displayName {
            return displayName
        }
        return bundleNameExcludingExtension
    }

    public var displayName: String {
        if let displayName = info.displayName {
            return displayName
        }
        return name
    }

    public var iconURL: URL? {
        if let iconFile = info.iconFile {
            return urlForImageResource(iconFile)
        }
        if let iconName = info.iconName {
            return urlForImageResource(iconName)
        }
        return nil
    }

    public var iconPath: String? {
        return iconURL?.path
    }

    public var shortVersion: String? {
        return info.shortVersion
    }

    public var version: String? {
        return info.version
    }

    public var isRunning: Bool {
        if let bundleIndentifer = bundleIdentifier, NSRunningApplication.runningApplications(withBundleIdentifier: bundleIndentifer).isEmpty == false {
            return true
        }
        return false
    }

    public var supportedFileTypes: [FileTypeDefinition] {
        return info.supportedFileTypes
    }

    @available(macOS 11.0, iOS 14.0, *)
    public var supportedFileExtensions: [String] {
        return (supportedFileTypes.flatMap { $0.extensions }).uniqued().sorted()
    }

    public func open() {
        NSWorkspace.shared.openApplication(at: bundleURL, configuration: .init(), completionHandler: nil)
    }

    public func openFile(_ url: URL) {
        NSWorkspace.shared.open([url], withApplicationAt: bundleURL, configuration: NSWorkspace.OpenConfiguration())
    }

    public func openFiles(_ urls: [URL]) {
        NSWorkspace.shared.open(urls, withApplicationAt: bundleURL, configuration: NSWorkspace.OpenConfiguration())
    }

    @available(macOS 11.0, *)
    internal func fileTypeDefinition(for type: UTType) -> FileTypeDefinition? {
        return supportedFileTypes.first(where: { type.conforms(toAny: $0.contentTypes) })
    }

    internal func fileTypeDefinition(for extensionString: String) -> FileTypeDefinition? {
        return supportedFileTypes.first(where: { $0.extensions.contains(extensionString.lowercased()) })
    }
}

#endif
