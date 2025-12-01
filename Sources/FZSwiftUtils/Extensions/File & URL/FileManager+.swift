//
//  FileManager+.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation
import Accessibility

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
        let folderURL = temporaryDirectoryURL.appendingPathComponent(folderName, isDirectory: true)
        try createDirectory(at: folderURL, withIntermediateDirectories: true)
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
        guard let trashedFileURL = trashedFileURL as? URL else {
            throw Errors.trashItemFailed(url: url)
        }
        return trashedFileURL
    }
    
    fileprivate enum Errors: LocalizedError {
        case trashItemFailed(url: URL)
            
        var errorDescription: String? {
            switch self {
            case .trashItemFailed: return "Tashing Failed."
            }
        }
            
        var failureReason: String? {
            switch self {
            case .trashItemFailed(let url): return "Failed to trash item \(url)."
            }
        }
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
        - type: The type of application support directory (either `identifier` or `name`).
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
        let directoryURL = appSupportURL.appendingPathComponent(name, isDirectory: true)
        if directoryExists(at: directoryURL) {
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
     Returns a Boolean value indicating whether a file or directory exists at a specified url.

     - Parameter url: The url of a file or directory. If the url's path begins with a tilde (`~`), it must first be expanded with [expandingTildeInPath](https://developer.apple.com/documentation/foundation/nsstring/expandingtildeinpath), or this method will return `false`.
     - Returns: `true` if a file or directory at the specified url exists, or `false` if the file or directory does not exist or its existence could not be determined.
     */
    func fileExists(at url: URL) -> Bool {
        fileExists(atPath: url.path)
    }
    
    /**
     Returns a Boolean value indicating whether a file or directory exists at a specified url.

     - Parameters:
        - url: The url of a file or directory. If the url's path begins with a tilde (`~`), it must first be expanded with [expandingTildeInPath](https://developer.apple.com/documentation/foundation/nsstring/expandingtildeinpath), or this method will return `false`.
        - isDirectory: Upon return, contains `true` if path is a directory or if the final path element is a symbolic link that points to a directory; otherwise, contains `false`. If path doesn’t exist, this value is undefined upon return.
     - Returns: `true` if a file or directory at the specified url exists, or `false` if the file or directory does not exist or its existence could not be determined.
     */
    func fileExists(at url: URL, isDirectory: inout Bool) -> Bool {
        var isDir: ObjCBool = false
        let fileExists = fileExists(atPath: url.path, isDirectory: &isDir)
        isDirectory = isDir.boolValue
        return fileExists
    }

    /**
     Returns a Boolean value indicating whether a directory exists at a specified path.

     - Parameter path: The path of  directory. If path begins with a tilde (`~`), it must first be expanded with [expandingTildeInPath](https://developer.apple.com/documentation/foundation/nsstring/expandingtildeinpath), or this method will return false.
     - Returns:`true` if a directory at the specified path exists, or `false` if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    /**
     Returns a Boolean value indicating whether a directory exists at a specified url.

     - Parameter url: The url of a directory. If the url's path begins with a tilde (`~`), it must first be expanded with [expandingTildeInPath](https://developer.apple.com/documentation/foundation/nsstring/expandingtildeinpath), or this method will return false.
     - Returns: `true` if a directory at the specified url exists, or `false` if the directory does not exist or its existence could not be determined.
     */
    func directoryExists(at url: URL) -> Bool {
        directoryExists(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether the invoking object appears able to read a specified file.
     
     If the file at `url` is inaccessible to your app, perhaps because it does not have search privileges for one or more parent directories, this method returns false. This method traverses symbolic links in the `url`. This method also uses the real user ID and group ID, as opposed to the effective user and group IDs, to determine if the file is readable.
     
     - Parameter url: A file url.
     - Returns: `true` if the current process has read privileges for the file at `url`; otherwise `false` if the process does not have read privileges or the existence of the file could not be determined.
     - Note: Attempting to predicate behavior based on the current state of the file system or a particular file on the file system is not recommended. Doing so can cause odd behavior or race conditions. It’s far better to attempt an operation (such as loading a file or creating a directory), check for errors, and handle those errors gracefully than it is to try to figure out ahead of time whether the operation will succeed. For more information on file system race conditions, see [Race Conditions and Secure File Operations in Secure Coding Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/RaceConditions.html#//apple_ref/doc/uid/TP40002585).
     */
    func isReadableFile(at url: URL) -> Bool {
        isReadableFile(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether the invoking object appears able to write to a specified file.
     
     If the file at `url` is inaccessible to your app, perhaps because it does not have search privileges for one or more parent directories, this method returns false. This method traverses symbolic links in the `url`. This method also uses the real user ID and group ID, as opposed to the effective user and group IDs, to determine if the file is writable.
     
     - Parameter url: A file url.
     - Returns: `true` if the current process has write privileges for the file at `url`; otherwise `false` if the process does not have write privileges or the existence of the file could not be determined.
     - Note: Attempting to predicate behavior based on the current state of the file system or a particular file on the file system is not recommended. Doing so can cause odd behavior or race conditions. It’s far better to attempt an operation (such as loading a file or creating a directory), check for errors, and handle those errors gracefully than it is to try to figure out ahead of time whether the operation will succeed. For more information on file system race conditions, see [Race Conditions and Secure File Operations in Secure Coding Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/RaceConditions.html#//apple_ref/doc/uid/TP40002585).
     */
    func isWritableFile(at url: URL) -> Bool {
        isWritableFile(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether the operating system appears able to execute a specified file.
     
     If the file at `url` is inaccessible to your app, perhaps because it does not have search privileges for one or more parent directories, this method returns false. This method traverses symbolic links in the `url`. This method also uses the real user ID and group ID, as opposed to the effective user and group IDs, to determine if the file is executable.
     
     - Parameter url: A file url.
     - Returns: `true` if the current process has execute privileges for the file at `url`; otherwise `false` if the process does not have execute privileges or the existence of the file could not be determined.
     - Note: Attempting to predicate behavior based on the current state of the file system or a particular file on the file system is not recommended. Doing so can cause odd behavior or race conditions. It’s far better to attempt an operation (such as loading a file or creating a directory), check for errors, and handle those errors gracefully than it is to try to figure out ahead of time whether the operation will succeed. For more information on file system race conditions, see [Race Conditions and Secure File Operations in Secure Coding Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/RaceConditions.html#//apple_ref/doc/uid/TP40002585).
     */
    func isExecutableFile(at url: URL) -> Bool {
        isExecutableFile(atPath: url.path)
    }
    
    /**
     Returns a Boolean value that indicates whether the invoking object appears able to delete a specified file.
     
     For a directory or file to be deletable, the current process must either be able to write to the parent directory of `url` or it must have the same owner as the item at `url`. If `url` is a directory, every item contained in `url` must be deletable by the current process.
     
     If the file at `url` is inaccessible to your app, perhaps because it does not have search privileges for one or more parent directories, this method returns `false`. If the item at `url` is a symbolic link, it is not traversed.
     
     - Parameter url: A file url.
     - Returns: `true` if the current process has delete privileges for the file at `url`; otherwise `false` if the process does not have delete privileges or the existence of the file could not be determined.
     - Note: Attempting to predicate behavior based on the current state of the file system or a particular file on the file system is not recommended. Doing so can cause odd behavior or race conditions. It’s far better to attempt an operation (such as loading a file or creating a directory), check for errors, and handle those errors gracefully than it is to try to figure out ahead of time whether the operation will succeed. For more information on file system race conditions, see [Race Conditions and Secure File Operations in Secure Coding Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/RaceConditions.html#//apple_ref/doc/uid/TP40002585).
     */
    func isDeletableFile(at url: URL) -> Bool {
        isDeletableFile(atPath: url.path)
    }

    
    /**
     Returns a Boolean value indicating whether the files or directories in specified paths have the same contents.
     
     - Parameters:
        - url1: The url of a file or directory to compare with the contents of `url2`.
        - url2: The url of a file or directory to compare with the contents of `url1`.
     - Returns: `true` if file or directory specified in `url1` has the same contents as that specified in `url2`, otherwise `false`.
     
     If `url1` and `url2` are directories, the contents are the list of files and subdirectories each contains—contents of subdirectories are also compared. For files, this method checks to see if they’re the same file, then compares their size, and finally compares their contents. This method does not traverse symbolic links, but compares the links themselves.
     */
    func contentsEqual(at url1: URL, and url2: URL) -> Bool {
        contentsEqual(atPath: url1.path, andPath: url2.path)
    }
    
    /**
     Creates a file with the specified content and attributes at the specified url.
     
     - Parameters:
        - url: The url of a file or directory to compare with the contents of `url2`.
        - contents: A data containing the contents of the new file.
        - attributes: A dictionary containing the attributes to associate with the new file. You can use these attributes to set the owner and group numbers, file permissions, and modification date.
     - Returns: `true` if the operation was successful or if the item already exists, otherwise `false`.
     
     If you specify `nil` for the attributes parameter, this method uses a default set of values for the owner, group, and permissions of any newly created directories in the path. Similarly, if you omit a specific attribute, the default value is used. The default values for newly created files are as follows:
     - Permissions are set according to the umask of the current process. For more information, see umask.
     - The owner ID is set to the effective user ID of the process.
     - The group ID is set to that of the parent directory.
     
     If a file already exists at the url, this method overwrites the contents of that file if the current process has the appropriate privileges to do so.
     */
    @discardableResult
    func createFile(at url: URL, contents: Data? = nil, attributes: [FileAttributeKey:Any]? = nil) -> Bool {
        createFile(atPath: url.path, contents: contents, attributes: attributes)
    }
    
    /**
     Creates an alias file for the item at the specific url.
     
     - Parameters:
        - srcURL: The url of the item to create an alias to.
        - dstURL: The destination url for the alias file.
     - Throws: If the alias file couldn't be created.
     */
    func createAlias(at srcURL: URL, to dstURL: URL) throws {
        let bookmarkData = try srcURL.bookmarkData(options: [.suitableForBookmarkFile], includingResourceValuesForKeys: nil, relativeTo: nil)
        try URL.writeBookmarkData(bookmarkData, to: dstURL)
    }
    
    /**
     Returns the attributes of the item at a given URL.
     
     - Parameter url: The URL of a file or directory.
     - Returns: A dictionary object that describes the attributes (file, directory, symlink, and so on) of the file specified by `url`.
     */
    func attributesOfItem(at url: URL) throws -> [FileAttributeKey : Any] {
        try attributesOfItem(atPath: url.path)
    }
    
    /**
     Sets the attributes of the specified file or directory.
     
     - Parameters:
        - attributes: A dictionary containing as keys the attributes to set for path and as values the corresponding value for the attribute.
        - url: The URL of a file or directory.
     */
    func setAttributes(_ attributes: [FileAttributeKey : Any], ofItemAt url: URL) throws {
        try setAttributes(attributes, ofItemAtPath: url.path)
    }
    
    /**
     Copies the attributes of the specified file or directory to the other item.
     
     - Parameters:
        - url: The URL of a file or directory for the attributes.
        - destionationURL: The destionation item for the attributes.
     */
    func copyAttributes(of sourceURL: URL, to destionationURL: URL, strategy: AttributesMergeStrategy = .overwrite) throws {
        let sourceAttr = try attributesOfItem(at: sourceURL)
        if strategy == .replace {
            try setAttributes(sourceAttr, ofItemAt: destionationURL)
        } else {
            var destAttr = try attributesOfItem(at: destionationURL)
            destAttr.merge(with: sourceAttr, strategy: strategy == .keepOriginal ? .keepOriginal : .overwrite)
            try setAttributes(destAttr, ofItemAt: destionationURL)
        }
    }
    
    enum AttributesMergeStrategy {
        /// Keeps the original attributes, only adding new attributes.
        case keepOriginal
        /// Overwrites the original attributes with the new attributes.
        case overwrite
        /// Replaces all attributes with source attributes.
        case replace
    }
    
    /**
     Performs a deep enumeration of the specified directory and returns the paths of all of the contained subdirectories.
     
     This method recurses the specified directory and its subdirectories. The method skips the `“.”` and `“..”` directories at each level of the recursion.
     
     Because this method recurses the directory’s contents, you might not want to use it in performance-critical code. Instead, consider using the [enumerator(at:includingPropertiesForKeys:options:errorHandler:)](https://developer.apple.com/documentation/foundation/filemanager/enumerator(at:includingpropertiesforkeys:options:errorhandler:)) method to enumerate the directory contents yourself. Doing so gives you more control over the retrieval of items and more opportunities to complete the enumeration or perform other tasks at the same time.
     
     - Parameter url: The url of the directory to list.
     - Returns: An array of strings, each containing the path of an item in the directory specified by path.
     */
    func subpathsOfDirectory(at url: URL) throws -> [String] {
        try subpathsOfDirectory(atPath: url.path)
    }
    
    /**
     Performs a shallow search of the specified directory and returns URLs for the contained items.
     
     This method performs a shallow search of the directory and therefore does not traverse symbolic links or return the contents of any subdirectories. This method also does not return URLs for the current directory (`”.”`), parent directory (`”..”`), or resource forks (files that begin with `“._”`) but it does return other hidden files. If you need to perform a deep enumeration, use the [enumerator(at:includingPropertiesForKeys:options:errorHandler:)](https://developer.apple.com/documentation/foundation/filemanager/enumerator(at:includingpropertiesforkeys:options:errorhandler:)) method instead.
     
     The order of the files in the returned array is undefined.
     
     - Parameters:
     - url: The URL for the directory whose contents you want to enumerate.
     - mask: Options for the enumeration. Because this method performs only shallow enumerations, options that prevent descending into subdirectories or packages are not allowed; the only supported option is [skipsHiddenFiles](https://developer.apple.com/documentation/foundation/filemanager/directoryenumerationoptions/skipshiddenfiles).
     - Returns: An array of URLs, each of which identifies a file, directory, or symbolic link contained in url. If the directory contains no entries, this method returns an empty array.
     */
    func contentsOfDirectory(at url: URL, options mask: DirectoryEnumerationOptions = []) throws -> [URL] {
        try contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }
    
    /**
     Returns a directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
     
     Because the enumeration is deep—that is, it lists the contents of all subdirectories—this enumerator object is useful for performing actions that involve large file-system subtrees. If the method is passed a directory on which another file system is mounted (a mount point), it traverses the mount point. This method does not resolve symbolic links or mount points encountered in the enumeration process, nor does it recurse through them if they point to a directory.
     
     For example, if you pass a URL that points to `/Volumes/MyMountedFileSystem`, the returned enumerator will include the entire directory structure for the file system mounted at that location. If, on the other hand, you pass `/Volumes`, the returned enumerator will include `/Volumes/MyMountedFileSystem` as one of its results, but will not traverse into the file system mounted there.
     
     The [FileManager.DirectoryEnumerator](https://developer.apple.com/documentation/foundation/filemanager/directoryenumerator) class has methods for skipping descendants of the existing path and for returning the number of levels deep the current object is in the directory hierarchy being enumerated (where the directory passed to the method is considered to be level `0`).

     - Parameters:
        - url: The location of the directory for which you want an enumeration. This URL must not be a symbolic link that points to the desired directory. You can use the [resolvingSymlinksInPath()](https://developer.apple.com/documentation/foundation/url/resolvingsymlinksinpath()) method to resolve any symlinks in the URL.
        - mask: Options for the enumeration.
        - handler: An optional error handler block for the file manager to call when an error occurs. The handler block should return `true` if you want the enumeration to continue or `false` if you want the enumeration to stop.  If you specify `nil` for this parameter, the enumerator object continues to enumerate items as if you had specified a block that returned `true`. The block takes the following parameters:
            - url: A URL that identifies the item for which the error occurred.
            - error: The error:
     - Returns: An directory enumerator object that enumerates the contents of the directory at `url`. If `url` is a filename, the method returns an enumerator object that enumerates no files—the first call to [nextObject()](https://developer.apple.com/documentation/foundation/nsenumerator/nextobject()) returns `nil`.
     */
    func enumerator(at url: URL, options mask: DirectoryEnumerationOptions = [], errorHandler handler: ((URL, any Error) -> Bool)? = nil) -> DirectoryEnumerator? {
        enumerator(at: url, includingPropertiesForKeys: nil, options: mask, errorHandler: handler)
    }
    
    /**
     The url to the program’s current directory.
     
     The current directory url is the starting point for any relative paths you specify. For example, if the current directory is `/tmp` and you specify a relative pathname of `reports/info.txt`, the resulting full path for the item is `/tmp/reports/info.txt`.
     
     When an app is launched, this property is initially set to the app’s current working directory. If the current working directory is not accessible for any reason, the value of this property is `nil`. You can change the value of this property by calling the ``Foundation/FileManager/changeCurrentDirectory(_:)`` method.
     
     - Warning: This property reports the current working directory for the current process, not just the receiver.
     */
    var currentDirectoryURL: URL {
        .file(currentDirectoryPath)
    }
    
    /**
     Changes the url of the current working directory to the specified url.
     
     All relative pathnames refer implicitly to the current working directory.
          
     - Parameter url: The url of the directory to which to change.
     - Returns: `true` if successful, otherwise `false`.
     - Warning: This method changes the current working directory for the current process, not just the receiver.
     */
    @discardableResult
    func changeCurrentDirectory(_ url: URL) -> Bool {
        changeCurrentDirectoryPath(url.path)
    }
    
    /**
     Returns an array of URLs that identify the mounted volumes available on the device.
          
     - Parameter options: Option flags for the enumeration.
     - Returns: An array of urls identifying the mounted volumes.
     - Important: This method returns `nil` on platforms other than macOS.
     */
    func mountedVolumeURLs(options: FileManager.VolumeEnumerationOptions = []) -> [URL]? {
        mountedVolumeURLs(includingResourceValuesForKeys: nil, options: options)
    }
    
    /**
     Returns the `URL` of the item pointed to by a symbolic link.
     - Parameter url: The url of a file or directory.
     - Returns: The `URL` of the directory or file to which the symbolic link path refers.
     */
    func destinationOfSymbolicLink(at url: URL) throws -> URL {
        .file(try destinationOfSymbolicLink(atPath: url.path))
    }
    
    /// The handlers for the file manager.
    var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            handlerDelegate = newValue.needsDelegate ? Delegate(for: self) : nil
        }
    }
    
    /// Handlers for a file manager.
    struct Handlers {
        /// The handler that determinates whether a file should should move an item to the new url.
        public var shouldMove: ((_ from: URL, _ to: URL)->Bool)?
        /// The handler that determinates whether a file should should copy an item to the new url.
        public var shouldCopy: ((_ from: URL, _ to: URL)->Bool)?
        /// The handler that determinates whether a file should should remove an item.
        public var shouldRemove: ((_ url: URL)->Bool)?
        /// The handler that determinates whether a hard link should be created between the items at the two urls.
        public var shouldLink: ((_ url: URL, _ to: URL)->Bool)?
        /// The handler that determinates whether the file manager should continue after an error occurs while moving an item.
        public var shouldProceedAfterMovingError: ((_ from: URL, _ to: URL, _ error: any Error)->Bool)?
        /// The handler that determinates whether the file manager should continue after an error occurs while copying an item.
        public var shouldProceedAfterCopyingError: ((_ from: URL, _ to: URL, _ error: any Error)->Bool)?
        /// The handler that determinates whether the file manager should continue after an error occurs while removing an item.
        public var shouldProceedAfterRemovingError: ((_ url: URL, _ error: any Error)->Bool)?
        /// The handler that determinates whether the file manager should continue after an error occurs while linking an item.
        public var shouldProceedAfterLinkingError: ((_ url: URL, _ to: URL, _ error: any Error)->Bool)?
        
        var needsDelegate: Bool {
            shouldMove != nil || shouldCopy != nil || shouldRemove != nil || shouldLink != nil || shouldProceedAfterMovingError != nil || shouldProceedAfterCopyingError != nil || shouldProceedAfterRemovingError != nil || shouldProceedAfterLinkingError != nil
        }
    }
    
    private var handlerDelegate: Delegate? {
        get { getAssociatedValue("handlerDelegate") }
        set { setAssociatedValue(newValue, key: "handlerDelegate")  }
    }
    
    private class Delegate: NSObject, FileManagerDelegate {
        var observation: KeyValueObservation?
        var delegate: FileManagerDelegate?
        weak var fileManager: FileManager?
        
        func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldMove?(srcURL, dstURL) ?? delegate?.fileManager?(fileManager, shouldMoveItemAt: srcURL, to: dstURL) ?? true
        }
        
        func fileManager(_ fileManager: FileManager, shouldCopyItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldCopy?(srcURL, dstURL) ?? delegate?.fileManager?(fileManager, shouldCopyItemAt: srcURL, to: dstURL) ?? true
        }
        
        func fileManager(_ fileManager: FileManager, shouldLinkItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldLink?(srcURL, dstURL) ?? delegate?.fileManager?(fileManager, shouldLinkItemAt: srcURL, to: dstURL) ?? true
        }
        
        func fileManager(_ fileManager: FileManager, shouldRemoveItemAt url: URL) -> Bool {
            fileManager.handlers.shouldRemove?(url) ?? delegate?.fileManager?(fileManager, shouldRemoveItemAt: url) ?? true
        }
        
        func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, movingItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldProceedAfterMovingError?(srcURL, dstURL, error) ?? false
        }
        
        func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldProceedAfterCopyingError?(srcURL, dstURL, error) ?? false
        }
        
        func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, removingItemAt url: URL) -> Bool {
            fileManager.handlers.shouldProceedAfterRemovingError?(url, error) ?? false
        }
        
        func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, linkingItemAt srcURL: URL, to dstURL: URL) -> Bool {
            fileManager.handlers.shouldProceedAfterLinkingError?(srcURL, dstURL, error) ?? false
        }
        
        init(for fileManager: FileManager) {
            super.init()
            delegate = fileManager.delegate
            fileManager.delegate = self
            observation = fileManager.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, !(new is Delegate) else { return }
                self.delegate = new
                self.fileManager?.delegate = self
            }
        }
        
        deinit {
            fileManager?.delegate = delegate
        }
    }
}
