//
//  FileManager+.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation

public extension FileManager {
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

        #if os(macOS) || os(iOS)
        /**
         Moves an item to the trash.

         The actual name of the item may be changed when moving it to the trash.

         - Parameter url: The item to move to the trash.
         - Throws: Throws an error if the item couldn't be moved to the trash.
         - Returns: Returns the url of the trashed item.
         */
        @discardableResult
        func trashItem(at url: URL) throws -> URL {
            var trashedFileURL: NSURL?
            try trashItem(at: url, resultingItemURL: &trashedFileURL)
            guard let fileURL = trashedFileURL as? URL else {
                throw Errors.failedToMoveToTrash
            }
            return fileURL
        }
    
        /// An enumeration of file manager errors.
        internal enum Errors: Error {
            /// The file couldn't be moved to the trash.
            case failedToMoveToTrash
            /// The file doesn't exist.
            case fileNotExisting
        }
        #endif

    #if os(macOS)
        /// The type of appliction support directory.
        enum AppSupportDirectoryType {
            /// Uses the application identifier.
            case identifier
            /// Uses the application name.
            case name
        }

        /**
         Returns the application support directory for the current app.
         
         - Parameters:
            - type: The type of application support directory (either identifier or name).
            - createIfNeeded: A Boolean value indicating whether the directory should be created if it doesn't exist.
         */
        func appSupportDirectory(using type: AppSupportDirectoryType = .name, createIfNeeded: Bool = false) -> URL? {
            let appSupportURL: URL
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                appSupportURL = .applicationSupportDirectory
            } else {
                guard let url = urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
                appSupportURL = url
            }
            guard let name = type == .identifier ? Bundle.main.bundleIdentifier ?? Bundle.main.bundleName : Bundle.main.bundleName ?? Bundle.main.bundleIdentifier else { return nil }
            let directoryURL = appSupportURL.appendingPathComponent(name)
            if FileManager.default.directoryExists(at: directoryURL) {
                return directoryURL
            } else if createIfNeeded {
                do {
                    try createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                    return directoryURL
                } catch {
                    debugPrint(error)
                }
            }
            return nil
        }
    #endif
    /**
     Returns a Boolean value that indicates whether a file or directory exists at a specified url.

     - Parameter url: The url of a file or directory. If the url's path begins with a tilde (~), it must first be expanded with `expandingTildeInPath`, or this method will return `false`.
     - Returns: `true` if a file or directory at the specified url exists, or `false` if the file or directory does not exist or its existence could not be determined.
     */
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }

    /**
     Returns a Boolean value that indicates whether a directory exists at a specified path.

     - Parameter path: The path of  directory. If path begins with a tilde (~), it must first be expanded with `expandingTildeInPath`, or this method will return false.
     - Returns:`true` if a directory at the specified path exists, or `false` if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = true
        return fileExists(atPath: path, isDirectory: &isDir)
    }

    /**
     Returns a Boolean value that indicates whether a directory exists at a specified url.

     - Parameter url: The url of a directory. If the url's path begins with a tilde (~), it must first be expanded with `expandingTildeInPath`, or this method will return false.
     - Returns: `true` if a directory at the specified url exists, or `false if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(at url: URL) -> Bool {
        directoryExists(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether the files or directories in specified paths have the same contents.
     
     - Parameters:
        - url1: The url of a file or directory to compare with the contents of `url2`.
        - url2: The url of a file or directory to compare with the contents of `url1`.
     - Returns: `true` if file or directory specified in `url1` has the same contents as that specified in `url2`, otherwise `false`.
     
     If `url1` and `url2` are directories, the contents are the list of files and subdirectories each contains—contents of subdirectories are also compared. For files, this method checks to see if they’re the same file, then compares their size, and finally compares their contents. This method does not traverse symbolic links, but compares the links themselves.
     */
    func contentsEqual(at url1: URL, and url2: URL) -> Bool {
        contentsEqual(atPath: url1.path, andPath: url2.path)
    }
}
