//
//  File.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation

public extension FileManager {
    /**
     Moves an item to the trash.
     
     The actual name of the item may be changed when moving it to the trash.
     
     - Parameters url: The item to move to the trash.
     - Returns: Returns the url of the trashed item if itl was successfully moved to the trash, or `nil` if the item was not moved to the trash.
     */
    @discardableResult
    func trashItem(at url: URL) throws -> URL? {
        var trashedFileURL: NSURL? = nil
        try self.trashItem(at: url, resultingItemURL: &trashedFileURL)
        return trashedFileURL as? URL
    }
    
    /**
     Creates a temporary directory inside the file system's default temporary directory.
     - Throws: Throws if the temporary directory couldn't be created.
     */
    func createTemporaryDirectory() throws -> URL {
        let temporaryDirectoryURL: URL
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, *) {
            temporaryDirectoryURL = temporaryDirectory
        } else {
            temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = temporaryDirectoryURL.appendingPathComponent(folderName)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL
    }
    
#if os(macOS)
    /// The type of appliction support directory.
    enum ApplicationSupportDirectoryType {
        /// Uses the application identifier.
        case identifier
        /// Uses the application name.
        case name
    }
    
    /**
     Returns the application support directory for the specified type.
     
     - Parameters type: The type of application support directory (either identifier or name).
     - Parameters createIfNeeded: A bool indicating whether the directory should be created if it doesn't exist.
     */
    func applicationSupportDirectory(using type: ApplicationSupportDirectoryType = .name, createIfNeeded: Bool = false) -> URL? {
        if let appSupportURL = urls(for: .applicationSupportDirectory, in: .userDomainMask).first, let pathComponent = (type == .name) ? Bundle.main.bundleName : Bundle.main.bundleIdentifier {
            let directoryURL = appSupportURL.appendingPathComponent(pathComponent)
            if directoryExists(at: directoryURL) {
                return directoryURL
            } else if createIfNeeded {
                do {
                    try createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                    return directoryURL
                } catch {
                    Swift.print(error)
                }
            }
        }
        return nil
    }
#endif
    
    /**
     Returns a Boolean value that indicates whether a directory exists at a specified path.
     
     - Parameters path: The path of  directory. If path begins with a tilde (~), it must first be expanded with expandingTildeInPath, or this method will return false.
     - Returns:true if a directory at the specified path exists, or false if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = true
        return fileExists(atPath: path, isDirectory: &isDir)
    }
    
    /**
     Returns a Boolean value that indicates whether a file or directory exists at a specified url.
     
     - Parameters url: The url of a file or directory. If the url's path begins with a tilde (~), it must first be expanded with expandingTildeInPath, or this method will return false.
     - Returns:true if a file or directory at the specified url exists, or false if the file or directory does not exist or its existence could not be determined.
     */
    func fileExists(at url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether a directory exists at a specified url.
     
     - Parameters url: The url of a directory. If the url's path begins with a tilde (~), it must first be expanded with expandingTildeInPath, or this method will return false.
     - Returns:true if a directory at the specified url exists, or false if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(at url: URL) -> Bool {
        return directoryExists(atPath: url.path)
    }
}
