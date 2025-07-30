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
    
        /// An enumeration of file manager errors.
        internal enum Errors: LocalizedError {
            /// The file couldn't be moved to the trash.
            case trashItemFailed(url: URL)
            
            var errorDescription: String? {
                switch self {
                case .trashItemFailed(let url): return "Tashing Failed."
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
        var isDirectory: ObjCBool = false
        return fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
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
        if strategy == .overwrite {
            try setAttributes(sourceAttr, ofItemAt: destionationURL)
        } else {
            var destAttr = try attributesOfItem(at: destionationURL)
            destAttr.merge(with: sourceAttr, strategy: strategy == .keepSource ? .keepOld : .keepNew)
            try setAttributes(destAttr, ofItemAt: destionationURL)
        }
    }
    
    enum AttributesMergeStrategy {
        case keepSource
        case keepDestionation
        /// Overwrite the value in the first dictionary with the value in the second dictionary.
        case overwrite
    }
    
    /// The handlers for the file manager.
    var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            _delegate = newValue.needsDelegate ? Delegate(for: self) : nil
        }
    }
    
    /// Handlers for a file manager.
    struct Handlers {
        /// The handler that determinates if a file should should move an item to the new url.
        public var shouldMove: ((_ from: URL, _ to: URL)->Bool)?
        /// The handler that determinates if a file should should copy an item to the new url.
        public var shouldCopy: ((_ from: URL, _ to: URL)->Bool)?
        /// The handler that determinates if a file should should remove an item.
        public var shouldRemove: ((_ url: URL)->Bool)?
        /// The handler that determinates if a hard link should be created between the items at the two urls.
        public var shouldLink: ((_ url: URL, _ to: URL)->Bool)?
        
        var needsDelegate: Bool {
            shouldMove != nil || shouldCopy != nil || shouldRemove != nil || shouldLink != nil
        }
    }
    
    private var _delegate: Delegate? {
        get { getAssociatedValue("_delegate") }
        set { setAssociatedValue(newValue, key: "handlers")  }
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
            fileManager?.delegate = self
        }
    }
}
