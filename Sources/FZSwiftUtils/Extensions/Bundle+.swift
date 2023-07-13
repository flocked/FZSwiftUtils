//
//  Bundle+.swift
//  
//
//  Created by Florian Zand on 21.01.22.
//

#if os(macOS)
import Foundation

public extension Bundle {
    
    /// The platform options for the bundle.
    enum BundlePlatform {
        /// macOS platform.
        case macOS
        
        /// maciOS platform.
        case maciOS
    }

    /**
     Checks if the bundle is an application bundle.
     
     - Returns: `true` if the bundle is an application bundle, `false` otherwise.
     */
    var isApplicationBundle: Bool {
        return bundlePath.lowercased().contains(".app")
    }

    /**
     The name of the bundle.
     
     - Returns: The name of the bundle.
     */
    var bundleName: String {
        return bundleURL.deletingPathExtension().lastPathComponent
    }

    /**
     The URL of the executable directory.
     
     - Returns: The URL of the executable directory, or `nil` if it couldn't be determined.
     */
    var executableDirectoryURL: URL? {
        return executableURL?.deletingLastPathComponent()
    }

    /**
     The name of the bundle excluding the file extension.
     
     - Returns: The name of the bundle excluding the file extension.
     */
    var bundleNameExcludingExtension: String {
        return bundleURL.deletingPathExtension().lastPathComponent
    }

    /**
     The platform of the bundle.
     
     - Returns: The platform of the bundle.
     */
    var platform: BundlePlatform {
        if let executableURL = executableURL {
            if executableURL.path.contains("Wrapper") {
                return .maciOS
            }
        }
        return .macOS
    }

    /**
     The URL of the contents directory.
     
     - Returns: The URL of the contents directory, or `nil` if it couldn't be determined.
     */
    var contentsDirectoryURL: URL? {
        if platform == .macOS {
            return bundleURL.appendingPathComponent("Contents")
        } else {
            return executableURL?.deletingLastPathComponent().deletingLastPathComponent()
        }
    }

    /**
     The URL of the Info.plist file.
     
     - Returns: The URL of the Info.plist file, or `nil` if it couldn't be determined.
     */
    var infoURL: URL? {
        return contentsDirectoryURL?.appendingPathComponent("Info.plist")
    }
}
#endif
