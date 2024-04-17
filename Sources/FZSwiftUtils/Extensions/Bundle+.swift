//
//  Bundle+.swift
//
//
//  Created by Florian Zand on 21.01.22.
//

#if os(macOS)
    import Foundation
    import AppKit
    import UniformTypeIdentifiers

    public extension Bundle {
        
        /// The platform of the bundle.
        var platform: BundlePlatform {
            executableURL?.path.contains("Wrapper") == true ? .maciOS : .macOS
        }
        
        /// The platform options for the bundle.
        enum BundlePlatform {
            /// macOS platform.
            case macOS
            /// maciOS platform.
            case maciOS
        }

        /// The URL of the executable directory, or `nil` if it couldn't be determined.
        var executableDirectoryURL: URL? {
            executableURL?.deletingLastPathComponent()
        }

        /// The URL of the contents directory, or `nil` if it couldn't be determined.
        var contentsDirectoryURL: URL? {
            if platform == .macOS {
                return bundleURL.appendingPathComponent("Contents")
            } else {
                return executableURL?.deletingLastPathComponent()
            }
        }
        
        /// The url of the icon.
        var iconURL: URL? {
            if let iconFile = iconFile {
                return urlForImageResource(iconFile)
            }
            if let iconName = iconName {
                return urlForImageResource(iconName)
            }
            return nil
        }

        /// The URL of the `Info.plist` file.
        var infoURL: URL? {
            contentsDirectoryURL?.appendingPathComponent("Info.plist")
        }
        
        /// The application info, constructed from the bundle’s `Info.plist` file.
        var info: ApplicationInfo? {
            infoDictionary?.toModel()
        }
        
        /// The name of the bundle.
        var bundleName: String? {
            object(forInfoDictionaryKey: "CFBundleName") as? String
        }
        
        /// The copyright string .
        var copyrightString: String? {
            object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
        }
        
        /// The displaying name.
        var displayingName: String? {
            object(forInfoDictionaryKey: "CFBundleDisplayName") as? String

        }

        /// The version string if available (e.g. 1.0.0)
        var versionString: String? {
            object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }

        /// The build string if available (e.g. 123)
        var buildString: String? {
            object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }
        
        /// The minimum system version.
        var minimumSystemVersion: String? {
            object(forInfoDictionaryKey: "LSMinimumSystemVersion") as? String
        }
        
        /// The name of the icon file.
        internal var iconFile: String? {
            object(forInfoDictionaryKey: "CFBundleIconFile") as? String
        }
        
        /// The name of the icon.
        internal var iconName: String? {
            object(forInfoDictionaryKey: "CFBundleIconName") as? String
        }
        
        /// The supported file types of the application.
        var supportedFileTypes: [FileTypeDefinition] {
            info?.supportedFileTypes ?? []
        }

        /// The supported file types for the specified file extension.
        func fileTypeDefinition(for extensionString: String) -> FileTypeDefinition? {
            supportedFileTypes.first(where: { $0.extensions.contains(extensionString.lowercased()) })
        }
        
        /// The supported file types for the specified content type.
        @available(macOS 11.0, *)
        func fileTypeDefinition(for type: UTType) -> FileTypeDefinition? {
            supportedFileTypes.first(where: { type.conforms(toAny: $0.contentTypes) })
        }
        
        /// A Boolean value indicating whether the application is running.
        var isRunning: Bool {
            !runningApplications.isEmpty
        }
        
        /// The running applications with the bundle's identifier.
        var runningApplications: [NSRunningApplication] {
            guard let identifier = bundleIdentifier else { return [] }
            return NSRunningApplication.runningApplications(withBundleIdentifier: identifier)
        }
        
        /// Opens the applications.
        func open() {
            NSWorkspace.shared.openApplication(at: bundleURL, configuration: .init(), completionHandler: nil)
        }

        /// Opens the specified URL asynchronously in the app.
        func openURL(_ url: URL, configuration: NSWorkspace.OpenConfiguration? = nil) {
            openURLs([url], configuration: configuration)
        }

        /// Opens the specified URLs asynchronously in the app.
        func openURLs(_ urls: [URL], configuration: NSWorkspace.OpenConfiguration? = nil) {
            NSWorkspace.shared.open(urls, withApplicationAt: bundleURL, configuration: configuration ?? NSWorkspace.OpenConfiguration())
        }
    }
#endif
