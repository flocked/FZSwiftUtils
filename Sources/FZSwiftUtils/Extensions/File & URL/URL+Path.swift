//
//  File.swift
//  
//
//  Created by Florian Zand on 03.11.24.
//

import Foundation

#if os(macOS)
import AppKit
#endif

extension URL {
    
    /// File system item representation of the url that can be used for various tasks like renaming, moving, deleting or replacing it.
    public var fileSystemItem: FileSystemItem {
        FileSystemItem(url: self)
    }
    
    /// An Item on the file system that can be used for various tasks like renaming, moving, deleting or replacing it.
    public struct FileSystemItem: Hashable {
        
        /// The url of the item.
        public let url: URL
        
        public let fileManager: FileManager
        
        public init(url: URL, fileManager: FileManager = .default) {
            self.url = url
            self.fileManager = fileManager
        }
        
        /// A Boolean value indicating whether to item exists.
        public var exists: Bool {
            fileManager.fileExists(atPath: url.path)
        }
        
        /**
         Creates the directory.
         
         - Parameters:
            - withIntermediateDirectories: A Boolean value indicating whether to create any nonexistent parent directories as part of creating the directory.
            - attributes: attributes: The file attributes for the new directory. You can set the owner and group numbers, file permissions, and modification date.
         
         - Throws: Throws an error if the directory couldn't be creates.
         */
        public func createDirectory(withIntermediateDirectories: Bool = true, attributes: [FileAttributeKey : Any]? = nil) throws {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
        }
        
        /**
         Renames the item to the specified name.
         
         - Parameters:
            - destionation: The new name of the item.
            - includesExtension: A Boolean value indicating whether the new name includes the file extension.
         
         - Throws: Throws an error if the item couldn't be renamed.
         */
        @discardableResult
        public func rename(to name: String, includesExtension: Bool = false) throws -> URL {
            var newURL = url.deletingLastPathComponent().appendingPathComponent(name)
            return try move(to: includesExtension ? newURL : newURL.appendingPathExtension(url.pathExtension))
        }
        
        /**
         Creates a symbolic link at the specified url.
         
         - Parameter destionation: The url for the symbolic link.
         
         - Throws: Throws an error if the symbolic link couldn't be created.
         */
        @discardableResult
        public func createSymbolicLink(at destionation: URL) throws -> URL {
            try fileManager.createSymbolicLink(at: url, withDestinationURL: destionation)
            return destionation
        }
        
        /**
         Creates a symbolic link at the specified directory.
         
         - Parameter directory: The url for the symbolic link.
         
         - Throws: Throws an error if the symbolic link couldn't be created.
         */
        @discardableResult
        public func createSymbolicLink(atDirectory directory: URL) throws -> URL {
            let newURL = directory.appendingPathComponent(url.lastPathComponent)
            return try createSymbolicLink(at: newURL)
        }
        
        /**
         Creates a finder alias at the specified url.
         
         - Parameter destionation: The url for the alias file.
         
         - Throws: Throws an error if the alias file couldn''t be created.
         */
        func createAlias(at destionation: URL) throws {
            let data = try url.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: nil)
            try URL.writeBookmarkData(data, to: destionation)
        }
        
        /**
         Moves the item to the specified url.
         
         - Parameter destionation: The new location for the item.
         - Throws: Throws an error if the item couldn't be moved to the new location.
         - Returns: Returns the new location of the item.
         */
        @discardableResult
        public func move(to destionation: URL) throws -> URL {
            try fileManager.moveItem(at: url, to: destionation)
            return destionation
        }
        
        /**
         Moves the item to the specified directory.
         
         - Parameter directory: The new directory for the item.
         - Throws: Throws an error if the item couldn't be moved to the new directory.
         - Returns: Returns the new location of the item.
         */
        @discardableResult
        public func move(toDirectory directory: URL) throws -> URL {
            let newURL = directory.appendingPathComponent(url.lastPathComponent)
            return try move(to: newURL)
        }
        
        /**
         Copies the item to the specified url.
         
         - Parameter destionation: The location for the copied item.
         - Throws: Throws an error if the item couldn't be copied.
         - Returns: Returns the location of the copied item.
         */
        @discardableResult
        public func copy(to destionation: URL) throws -> URL {
            try fileManager.copyItem(at: url, to: destionation)
            return destionation
        }
        
        /**
         Copies the item to the specified directory.
         
         - Parameter directory: The directory for the copied item.
         - Throws: Throws an error if the item couldn't be copied to the directory.
         - Returns: Returns the location of the copied item.
         */
        @discardableResult
        public func copy(toDirectory directory: URL) throws -> URL {
            let newURL = directory.appendingPathComponent(url.lastPathComponent)
            return try copy(to: newURL)
        }
        
        /**
         Replaces the item with the specified
         
         - Parameters:
            - replacement: The url of the item containing the new content for the current item. It is recommended that you put this item in a temporary directory. If a temporary directory is not available, put this item in a uniquely named directory that is in the same directory as the original item.
         
            - backupItemName: If provided, the name used to create a backup of the original item.
         
              The backup is placed in the same directory as the original item. If an error occurs during the creation of the backup item, the operation fails. If there is already an item with the same name as the backup item, that item will be removed.
         
              The backup item will be removed in the event of success unless the `withoutDeletingBackupItem` option is provided in options.
            - options: The options to use during the replacement.
         
         - Returns: The url of the new item. If no new file system object is required, the same url as the current is returned. However, if a new file system object is required, the url may be different. For example, replacing an `RTF` document with an `RTFD` document requires the creation of a new file.
         
         - Throws: Throws an error if the item couldn't be replaced..
         */
        @discardableResult
        public func replace(with replacement: URL, backupItemName: String? = nil, options: FileManager.ItemReplacementOptions = []) throws -> URL? {
            try fileManager.replaceItemAt(url, withItemAt: replacement, backupItemName: backupItemName, options: options)
        }
        
        /**
         Removes the item.
         
         - Throws: Throws an error if the item couldn't be removed.
         */
        public func remove() throws {
            try fileManager.removeItem(at: url)
        }
        
        /**
         Moves the item to the trash.
         
         The actual name of the item may be changed when moving it to the trash.
         
         - Throws: Throws an error if the item couldn't be moved to the trash.
         - Returns: Returns the url of the trashed item.
         */
        @discardableResult
        public func trash() throws -> URL {
            try fileManager.trashItem(at: url)
        }
        
        /**
         Reads the file as the specified `Decodable` type.
         
         - Parameter type: The `Decodable` type.
         - Throws: If the file doesn't exist, can't be accessed or isn't compatible.
         */
        public func read<T: Decodable>(_ type : T.Type) throws -> T {
            return try JSONDecoder().decode(T.self, from: try read())
        }
        
        /**
         Reads the file as data.
         
         - Parameter options: Options for reading the data.
         - Throws: If the file doesn't exist or couldn't be read.
         */
        public func read(options: Data.ReadingOptions = []) throws -> Data {
            try Data(contentsOf: url, options: options)
        }
    
        /**
         Reads the file as string.
         
         - Parameter encoding: The string encoding.
         - Throws: If the file doesn't exist or couldn't be read.
         */
        public func readAsString(_ encoding: String.Encoding = .utf8) throws -> String {
             try String(contentsOf: url, encoding: encoding)
        }
        
        /**
         A Boolean value that indicates whether the files or directories between the item and the specified url have the same contents.
         
         - Parameter url: The url of a file or directory to compare with the contents of item.
         - Returns: `true` if file or directory of the item has the same contents as that specified in `url`, otherwise `false`.
         
         If they are both directories, the contents are the list of files and subdirectories each contains—contents of subdirectories are also compared. For files, this method checks to see if they’re the same file, then compares their size, and finally compares their contents. This method does not traverse symbolic links, but compares the links themselves.
         */
        public func contentIsEqual(to url: URL) -> Bool {
            fileManager.contentsEqual(at: self.url, and: url)
        }
        
        #if os(macOS)
        /**
         Opens the item.
         
         - Parameters:
            - applicationURL: A URL specifying the location of the application to open the item.
            - configuration: The options that indicate how to open the item.
         
         - Throws: Throws an error if the item couldn't be opened.
         */
        func open(withApplicationAt applicationURL: URL? = nil, configuration: NSWorkspace.OpenConfiguration? = nil) throws {
            guard fileManager.fileExists(at: url) else {
                throw FileManager.Errors.failedToMoveToTrash
            }
            let semaphore = DispatchSemaphore(value: 0)
            var error: Error?

            if let applicationURL = applicationURL {
                NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration ?? .init()) { _, err in
                    error = err
                    semaphore.signal()
                }
            } else {
                NSWorkspace.shared.open(url, configuration: configuration ?? .init()) { _, err in
                    error = err
                    semaphore.signal()
                }
            }
            semaphore.wait()
            if let error = error {
                throw error
            }
        }
        
        /**
         Opens the item asynchronous.
         
         - Parameters:
            - applicationURL: A URL specifying the location of the application to open the item.
            - configuration: The options that indicate how to open the item.
            - completionHandler: The completion handler block to call asynchronously with the results. AppKit executes the completion handler on a concurrent queue. The handler block has no return value and takes the following parameters:
                - app: On success, this parameter contains a reference to the app that opened the URLs. If the app didn't open the URLs successfully, this parameter is nil.
                - error: On failure, this parameter contains an NSError object indicating the reason for the failure. If the method opened the URLs successfully, this parameter is nil.
         */
        public func open(withApplicationAt applicationURL: URL? = nil, configuration: NSWorkspace.OpenConfiguration, completionHandler: ((_ app: NSRunningApplication?, _ error: (any Error)?) -> Void)?) {
            guard fileManager.fileExists(at: url) else {
                completionHandler?(nil, FileManager.Errors.failedToMoveToTrash)
                return
            }
            if let applicationURL = applicationURL {
                NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration, completionHandler: completionHandler)
            } else {
                NSWorkspace.shared.open(url, configuration: configuration, completionHandler: completionHandler)
            }
        }
        
        /**
         Returns an the urls to all available applications that can open the file.
         
         The array is sorted by the best match.
         */
        @available(macOS 12.0, *)
        public func urlsForApplicationsToOpen() -> [URL] {
            NSWorkspace.shared.urlsForApplications(toOpen: url)
        }
        
        /**
         Returns an image containing the icon for the item.
         
         The returned image has an initial size of 32x32 pixels.
         */
        public func iconForFile() -> NSImage {
            NSWorkspace.shared.icon(forFile: url.path)
        }
        
        /**
         Opens a window in `Finder` selecting the item.
         
         - Returns: `true` if the file was successfully selected; otherwise, `false.
         */
        @discardableResult
        public func selectInFinder() -> Bool {
            // NSWorkspace.shared.activateFileViewerSelecting([url])
            NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
        }
        
        /**
         Duplicates the item asynchronously in the same manner as the `Finder`.
         
         - Parameters:
            - completionHandler: The completion handler that is called when the operation completes. The handler takes two parameters:
                - url: The location of the duplicated file.
                - error:  An error if the duplcation failed.
         */
        public func duplicate(completionHandler: ((_ url: URL?, _ error: (any Error)?) -> Void)? = nil)  {
            NSWorkspace.shared.duplicate([url], completionHandler: { urls, error in
                completionHandler?(urls[url], error)
            })
        }
        
        /**
         Duplicates the item in the same manner as the `Finder` and returns the location of the duplicated file.
         
         - Throws: Throws an error if the duplication failed.
         */
        public func duplicate() throws -> URL {
            let semaphore = DispatchSemaphore(value: 0)
            var error: Error?
            var duplicateURL: URL?
            duplicate { url, err in
                duplicateURL = url
                error = err
                semaphore.signal()
            }
            semaphore.wait()
            if let error = error {
                throw error
            }
            guard let duplicateURL = duplicateURL else {
                throw Errors.duplicateFailed
            }
            return duplicateURL
        }
        
        public enum Errors: Error {
            case duplicateFailed
        }
    #endif
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.url == rhs.url
        }
    }
}
