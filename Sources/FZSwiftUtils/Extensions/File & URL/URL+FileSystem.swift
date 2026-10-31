//
//  URL+FileSystem.swift
//
//
//  Created by Florian Zand on 30.10.26.
//

import Foundation

public extension URL {
    /// Provides file system operations for this URL.
    var fileSystem: FileSystem {
        .init(self)
    }
    
    /// Provides file system operations for a specific URL.
    struct FileSystem: Sendable {
        private let url: URL
        
        init(_ url: URL) {
            self.url = url
        }
        
        // MARK: - File Information
        
        /// A Boolean value indicating whether a file system item exists at the URL.
        public var exists: Bool {
            FileManager.default.fileExists(at: url)
        }
        
        /// A Boolean value indicating whether the file system item is readable by the current process.
        public var isReadable: Bool {
            FileManager.default.isReadableFile(at: url)
        }
        
        /// A Boolean value indicating whether the file system item is writable by the current process.
        public var isWritable: Bool {
            FileManager.default.isWritableFile(at: url)
        }
        
        /// A Boolean value indicating whether the file system item is executable by the current process.
        public var isExecutable: Bool {
            FileManager.default.isExecutableFile(at: url)
        }
        
        /// A Boolean value indicating whether the file system item can be deleted by the current process.
        public var isDeletable: Bool {
            FileManager.default.isDeletableFile(at: url)
        }
        
        /**
         A Boolean value indicating whether a directory exists at the URL.
         
         Returns `false` if the URL does not exist or refers to an item that is not a directory.
         */
        public var directoryExists: Bool {
            FileManager.default.directoryExists(at: url)
        }
        
        /**
         Determines whether the contents of the file system item are equal to those of another item.
         
         - Parameter url: The URL of the item to compare.
         - Returns: `true` if the contents are equal; otherwise, `false`.
         */
        public func contentsEqual(to url: URL) -> Bool {
            FileManager.default.contentsEqual(at: self.url, and: url)
        }
        
        // MARK: - Directory Operations
        
        /// Returns the relative paths of all items contained in the directory, including items in subdirectories.
        public func subpaths() throws -> [String] {
            try FileManager.default.subpathsOfDirectory(at: url)
        }
        
        /**
         Returns the URLs of the items directly contained in the directory.
         
         Unlike ``subpaths()``, this method does not recursively enumerate subdirectories.
         
         - Parameters:
            - keys: The resource property keys to prefetch for each returned URL, or `nil` to use the default behavior.
            - options: Options that control directory enumeration.
         - Returns: An array of URLs representing the directory's immediate contents.
         */
        public func contents(includingPropertiesForKeys keys: [URLResourceKey]? = nil, options: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
            try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: options)
        }
        
        /**
         Creates a directory at the URL.
         
         - Parameters:
            - createIntermediates: If `true`, creates any missing intermediate directories.
            -  attributes: The file attributes to apply to the newly created directory, or `nil` for the default attributes.
         */
        public func createDirectory(withIntermediateDirectories createIntermediates: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
        
        // MARK: - File Operations
        
        /**
         Creates a file with the specified content and attributes at the url.
         
         - Parameters:
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
        public func createFile(contents: Data? = nil, attributes: [FileAttributeKey: Any]? = nil) -> Bool {
            FileManager.default.createFile(at: url, contents: contents, attributes: attributes)
        }
                
        /**
         Removes the file system item at the URL.
         
         If the item is a directory, its contents are also removed.
         */
        public func remove() throws {
            try FileManager.default.removeItem(at: url)
        }
        
        #if os(macOS) || os(iOS) || os(visionOS)
        /**
         Moves the file system item to the Trash.
         
         - Returns: The URL of the item at its new location in the Trash.
         */
        @discardableResult
        public func trash() throws -> URL {
            try FileManager.default.trashItem(at: url)
        }
        #endif
        /**
         Copies the file system item to the specified destination.
         
         If the item is a directory, its contents are also copied.
         
         - Parameter url: The destination URL.
         */
        public func copy(to url: URL) throws {
            try FileManager.default.copyItem(at: self.url, to: url)
        }
        
        /**
         Copies the file system item into the specified directory, preserving its name.

         - Parameter directory: The destination directory.
         */
        public func copy(toDirectory directory: URL) throws {
            try copy(to: directory.appendingPathComponent(url.lastPathComponent))
        }
        
        /**
         Moves the file system item to the specified destination.
         
         - Parameter url: The destination URL.
         */
        public func move(to url: URL) throws {
            try FileManager.default.moveItem(at: self.url, to: url)
        }
        
        /**
         Moves the file system item into the specified directory, preserving its name.

         - Parameter directory: The destination directory.
         */
        public func move(toDirectory directory: URL) throws {
            try move(to: directory.appendingPathComponent(url.lastPathComponent))
        }
        
        /**
         Replaces the file system item with another item.
         
         - Parameters:
            - replacementURL: The URL of the replacement item.
            - backupItemName: An optional name for a backup of the original item.
            - options: Options controlling the replacement operation.
         - Returns: The URL of the resulting item, or `nil` if no URL is available.
         */
        @discardableResult
        public func replace(with replacementURL: URL, backupItemName: String? = nil, options: FileManager.ItemReplacementOptions = []) throws -> URL? {
            try FileManager.default.replaceItemAt(url, withItemAt: replacementURL, backupItemName: backupItemName, options: options)
        }
        
        // MARK: - Aliases & Symbolic Links
        
        /**
         Creates an alias at the specified URL that refers to the file system item.

         - Parameter url: The URL at which to create the alias.
         */
        public func createAlias(at url: URL) throws {
            try FileManager.default.createAlias(at: url, to: self.url)
        }

        /**
         Creates a hard link to the file system item at the specified URL.

         - Parameter url: The URL at which to create the hard link.
         */
        public func createHardLink(at url: URL) throws {
            try FileManager.default.linkItem(at: self.url, to: url)
        }

        /**
         Creates a symbolic link to the file system item at the specified URL.

         - Parameter url: The URL at which to create the symbolic link.
         */
        public func createSymbolicLink(at url: URL) throws {
            try FileManager.default.createSymbolicLink(at: url, withDestinationURL: self.url)
        }
        
        /**
         Returns the destination URL of the symbolic link.

         Relative symbolic link destinations are resolved against the symbolic link's parent directory.
         
         The returned URL is absolute and standardized.

         - Parameter resolvingSymlinks: Whether to resolve additional symbolic links in the destination path.
         - Returns: The destination URL of the symbolic link.
         */
        public func symbolicLinkDestination(resolvingSymlinks: Bool = false) throws -> URL {
            try FileManager.default.destinationOfSymbolicLink(at: url, resolvingSymlinks: resolvingSymlinks)
        }
        
        // MARK: - File Attributes
        
        /**
         Returns the attributes of the file system item.
         
         - Returns: A dictionary containing the item's file attributes.
         */
        public func attributes() throws -> [FileAttributeKey: Any] {
            try FileManager.default.attributesOfItem(at: url)
        }
        
        /**
         Sets the attributes of the file system item.
         
         - Parameter attributes: A dictionary containing the attributes to set.
         */
        public func setAttributes(_ attributes: [FileAttributeKey: Any]) throws {
            try FileManager.default.setAttributes(attributes, ofItemAt: url)
        }
        
        /**
         Copies the attributes of the file system item to the other item.
         
         - Parameters:
            - url: The URL of a file or directory for the attributes.
            - destionationURL: The destionation item for the attributes.
         */
        public func copyAttributes(to url: URL, strategy: FileManager.AttributesMergeStrategy = .overwrite) throws {
            try FileManager.default.copyAttributes(of: self.url, to: url, strategy: strategy)
        }
        
        // MARK: - File Provider
        
        /**
         Retrieves the file provider services available for the file system item.
         
         - Parameter completionHandler: A closure called with a `Result` containing the available services or an error.
         */
        public func fileProviderServices(completionHandler: @escaping (_ result: Result<[NSFileProviderServiceName: NSFileProviderService], Error>) -> ()) {
            FileManager.default.getFileProviderServicesForItem(at: url) { services, error in
                completionHandler(Result {
                    guard let services else { throw error ?? CocoaError(.fileReadUnknown) }
                    return services
                })
            }
        }
        
        /**
         Asynchronously retrieves the file provider services available for the file system item.
         
         - Returns: A dictionary mapping service names to their corresponding file provider services.
         */
        public func fileProviderServices() async throws -> [NSFileProviderServiceName: NSFileProviderService] {
            try await FileManager.default.fileProviderServicesForItem(at: url)
        }
        
        // MARK: - File System Relationships
        
        /**
         Determines the relationship between the file system item and a system directory.
         
         - Parameters:
            - directory: The system directory to compare against.
            - domainMask: The domain in which to locate the system directory.
         - Returns: The relationship between the system directory and the item.
         */
        public func relationship(to directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) throws -> FileManager.URLRelationship {
            var relationship = FileManager.URLRelationship.same
            try FileManager.default.getRelationship(&relationship, of: directory, in: domainMask, toItemAt: url)
            return relationship
        }
        
        // MARK: - Ubiquitous Items
        
        /**
         A Boolean value indicating whether the file system item is managed by iCloud.

         Returns `true` if the item is an ubiquitous item; otherwise, `false`.
         */
        public var isUbiquitous: Bool {
            FileManager.default.isUbiquitousItem(at: url)
        }
        
        /**
         Evicts the local contents of an ubiquitous item.
         
         The item remains available in iCloud and can be downloaded again when needed.
         */
        public func evictUbiquitousItem() throws {
            try FileManager.default.evictUbiquitousItem(at: url)
        }
        
        /**
         Requests that the contents of an ubiquitous item be downloaded from iCloud.
         
         This method initiates the download but does not wait for it to finish.
         */
        public func startDownloadingUbiquitousItem() throws {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
        }
        
        /**
         Creates a URL that can be used to publish an ubiquitous item.
         
         - Returns: A tuple containing the publishing URL and its expiration date.
         */
        public func publishingURL() throws -> (url: URL, expirationDate: Date) {
            var date: NSDate?
            let url = try FileManager.default.url(forPublishingUbiquitousItemAt: url, expiration: &date)
            return (url, date! as Date)
        }
        
        /**
         Uploads the local version of an ubiquitous item to iCloud using the specified conflict resolution policy.
         
         - Parameters:
            - policy: The policy used to resolve conflicts between the local and cloud versions.
            - completionHandler: A closure called with a `Result` containing the uploaded file version or an error.
         */
        @available(macOS 26.0, iOS 26.0, tvOS 26.0, visionOS 26.0, *)
        public func uploadLocalVersion(withConflictResolutionPolicy policy: NSFileManagerUploadLocalVersionConflictPolicy = .conflictPolicyDefault, completionHandler: @escaping (_ result: Result<NSFileVersion, Error>) -> ()) {
            FileManager.default.uploadLocalVersionOfUbiquitousItem(at: url, withConflictResolutionPolicy: policy) { version, error in
                completionHandler(Result {
                    guard let version else { throw error ?? CocoaError(.fileReadUnknown) }
                    return version
                })
            }
        }
        
        /**
         Asynchronously uploads the local version of an ubiquitous item to iCloud.
         
         - Parameter policy: The policy used to resolve conflicts between the local and cloud versions.
         - Returns: The uploaded file version.
         */
        @available(macOS 26.0, iOS 26.0, tvOS 26.0, visionOS 26.0, *)
        public func uploadLocalVersion(withConflictResolutionPolicy policy: NSFileManagerUploadLocalVersionConflictPolicy = .conflictPolicyDefault) async throws -> NSFileVersion {
            try await FileManager.default.uploadLocalVersionOfUbiquitousItem(at: url, withConflictResolutionPolicy: policy)
        }
        
        /**
         Requests that synchronization of an ubiquitous item with iCloud be paused.
         
         - Parameter completionHandler: A closure called with an error if the request fails, or `nil` on success.
         */
        @available(macOS 26.0, iOS 26.0, tvOS 26.0, visionOS 26.0, *)
        public func pauseUbiquitousSync(completionHandler: @escaping (_ error: Error?) -> ()) {
            FileManager.default.pauseSyncForUbiquitousItem(at: url, completionHandler: completionHandler)
        }
        
        /// Asynchronously requests that synchronization of an ubiquitous item with iCloud be paused.
        @available(macOS 26.0, iOS 26.0, tvOS 26.0, visionOS 26.0, *)
        public func pauseUbiquitousSync() async throws {
            try await FileManager.default.pauseSyncForUbiquitousItem(at: url)
        }
        
        /**
         Moves an item into or out of iCloud storage.
         
         - Parameters:
            - isUbiquitous: `true` to move the item into iCloud storage, or `false` to move it out.
            - destinationURL: The destination URL for the item.
         */
        public func setUbiquitous(_ isUbiquitous: Bool, destinationURL: URL) throws {
            try FileManager.default.setUbiquitous(isUbiquitous, itemAt: url, destinationURL: destinationURL)
        }
    }
}
