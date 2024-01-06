//
//  URL+Resource.swift
//  
//
//  Created by Florian Zand on 25.12.21.
//

import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if os(macOS)
import AppKit
#elseif canImport(MobileCoreServices)
import MobileCoreServices
#endif

public extension URL {
    ///  The properties of a file system resource.
    var resources: URLResources {
        return URLResources(url: self)
    }
}

/**
 The properties of a file system resource.
 
 Some of the properties can be modified. Not all properties exist for all files. For example, if a file is located on a volume that doesn’t support creation dates, the creationDate property will return nil.
 */
public class URLResources {
    /// The url to the resource
    public private(set) var url: URL
    
    /**
     Creates an object for accessing and modifying properties of the resource at the specified url.
     
     - Parameter url: The url to the resource.
     - Returns: `URLResources` for the specified resource.
     */
    public init(url: URL) {
        self.url = url
    }

    internal func value<V>(for keyPath: KeyPath<URLResourceValues, V?>) throws -> V? {
        guard let resourceKey = keyPath.resourceKey else { return nil }
        return try url.resourceValues(for: resourceKey)[keyPath: keyPath]
    }

    internal func setValue<V>(_ newValue: V?, for keyPath: WritableKeyPath<URLResourceValues, V?>) throws {
        var urlResouceValues = URLResourceValues()
        urlResouceValues[keyPath: keyPath] = newValue
        try url.setResourceValues(urlResouceValues)
    }

    /// Name of the resource in the file system.
    public var name: String? {
        get { return try? value(for: \.name) }
        set { try? setValue(newValue, for: \.name) }
    }

    /// Localized or extension-hidden name  as displayed to users.
    public var localizedName: String? { return try? value(for: \.localizedName) }

    /// A Boolean value indicating whether the resource is a regular file rather than a directory or a symbolic link.
    public var isRegularFile: Bool { return (try? value(for: \.isRegularFile)) ?? false }

    /// A Boolean value indicating if the resource is a directory.
    public var isDirectory: Bool { return (try? value(for: \.isDirectory)) ?? false }

    /// A Boolean value indicating if the resource is a isymbolic link.
    public var isSymbolicLink: Bool { return (try? value(for: \.isSymbolicLink)) ?? false }

    /// A Boolean value indicating if the resource is a volume.
    public var isVolume: Bool { return (try? value(for: \.isVolume)) ?? false }

    /// A Boolean value indicating if the resource is a packaged directory.
    public var isPackage: Bool {
        get { (try? value(for: \.isPackage)) ?? false }
        set { try? setValue(newValue, for: \.isPackage) }
    }

    @available(macOS 10.11, iOS 9.0, *)
    /// A Boolean value indicating if the resource is an application.
    public var isApplication: Bool { (try? value(for: \.isApplication)) ?? false }

    /// A Boolean value indicating if the resource is system-immutable.
    public var isSystemImmutable: Bool { (try? value(for: \.isSystemImmutable)) ?? false }

    /// A Boolean value indicating if the resource is user-immutable.
    public var isUserImmutable: Bool {
        get { (try? value(for: \.isUserImmutable)) ?? false }
        set { try? setValue(newValue, for: \.isUserImmutable) }
    }

    /// A Boolean value indicating if the resource is normally not displayed to users.
    public var isHidden: Bool {
        get { (try? value(for: \.isHidden)) ?? false }
        set { try? setValue(newValue, for: \.isHidden) }
    }

    /// A Boolean value indicating if the resources filename extension is removed from the localizedName property.
    public var hasHiddenExtension: Bool {
        get { (try? value(for: \.hasHiddenExtension)) ?? false }
        set { try? setValue(newValue, for: \.hasHiddenExtension) }
    }

    /// Creation date of the resource.
    public var creationDate: Date? {
        get { try? value(for: \.creationDate) }
        set { try? setValue(newValue, for: \.creationDate) }
    }
    /// Date the resource was created, or renamed into or within its parent directory.
    public var addedToDirectoryDate: Date? { try? value(for: \.addedToDirectoryDate) }

    /// Date the resource content was last accessed.
    public var contentAccessDate: Date? {
        get { try? value(for: \.contentAccessDate) }
        set { try? setValue(newValue, for: \.contentAccessDate) }
    }

    /// Date the resource content was last modified.
    public var contentModificationDate: Date? {
        get { try? value(for: \.contentModificationDate) }
        set { try? setValue(newValue, for: \.contentModificationDate) }
    }

    /// Date the resource’s attributes were last modified.
    public var attributeModificationDate: Date? { try? value(for: \.attributeModificationDate) }

    /// Number of hard links to the resource.
    public var linkCount: Int? { try? value(for: \.linkCount) }

    /// The resource’s parent directory, if any.
    public var parentDirectory: URL? {
        get { try? value(for: \.parentDirectory) }
    }

    /// User-visible type or “kind” description of the resource.
    public var localizedTypeDescription: String? { try? value(for: \.localizedTypeDescription) }

    /// The label number assigned to the resource.
    public var labelNumber: Int? {
        get { try? value(for: \.labelNumber) }
        set { try? setValue(newValue, for: \.labelNumber) }
    }

    /// The user-visible label text of the resource.
    public var labelLocalizedName: String? { try? value(for: \.localizedLabel) }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// A value APFS assigns that identifies a file’s content data stream.
    public var fileContentIdentifier: Int64? { try? value(for: \.fileContentIdentifier) }

    /// The optimal block size when reading or writing this file’s data, or nil if not available.
    public var preferredIOBlockSize: Int? { try? value(for: \.preferredIOBlockSize) }

    /// A Boolean value indicating if the resource is readable.
    public var isReadable: Bool? { try? value(for: \.isReadable) }

    /// A Boolean value indicating if the resource is writable.
    public var isWritable: Bool? { try? value(for: \.isWritable) }

    /// A Boolean value indicating if the resource is executable.
    public var isExecutable: Bool? { try? value(for: \.isExecutable) }

    public var fileSecurity: NSFileSecurity? {
        get { try? value(for: \.fileSecurity) }
        set { try? setValue(newValue, for: \.fileSecurity) }
    }

    /// A Boolean value indicating whether the resource is excluded from backups.
    public var isExcludedFromBackup: Bool? {
        get { try? value(for: \.isExcludedFromBackup) }
        set { try? setValue(newValue, for: \.isExcludedFromBackup) }
    }

    /// File system path to the resource.
    public var path: String? { try? value(for: \.path) }

    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    /// The resource’s path as a canonical absolute file system path.
    public var canonicalPath: String? { try? value(for: \.canonicalPath) }

    /// A Boolean value indicating whether the resource is a file system trigger directory.
    public var isMountTrigger: Bool? { try? value(for: \.isMountTrigger) }

    @available(macOS 10.10, iOS 8.0, *)
    /**
     An opaque generation identifier which can be compared using == to determine if the data in a document has been modified.
     
     For resources which refer to the same file inode, the generation identifier will change when the data in the file’s data fork is changed (changes to extended attributes or other file system metadata do not change the generation identifier). For resources which refer to the same directory inode, the generation identifier will change when direct children of that directory are added, removed or renamed (changes to the data of the direct children of that directory will not change the generation identifier). The generation identifier is persistent across system restarts. The generation identifier is tied to a specific document on a specific volume and is not transferred when the document is copied to another volume. This property is not supported by all volumes.
     */
    public var generationIdentifier: (NSCopying & NSSecureCoding & NSObjectProtocol)? { try? value(for: \.generationIdentifier) }

    @available(macOS 10.10, iOS 8.0, *)
    /// A value that the kernel assigns to identify a document.
    public var documentIdentifier: Int? { try? value(for: \.documentIdentifier) }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// A Boolean value indicating whether the file may have extended attributes.
    public var mayHaveExtendedAttributes: Bool { (try? value(for: \.mayHaveExtendedAttributes)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// A Boolean value indicating whether the file system can delete the file when the system needs to free space.
    public var isPurgeable: Bool { (try? value(for: \.isPurgeable)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// A Boolean value indicating whether the file has sparse regions.
    public var isSparse: Bool { (try? value(for: \.isSparse)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    /// A Boolean value that indicates whether the cloned files and their original files may share data blocks.
    public var mayShareFileContent: Bool { (try? value(for: \.mayShareFileContent)) ?? false }

    /// The type of the fresource.
    public var fileResourceType: URLFileResourceType? { try? value(for: \.fileResourceType) }

    /// A Boolean value indicating whether the resource is in the iCloud storage.
    public var isUbiquitousItem: Bool { (try? value(for: \.isUbiquitousItem)) ?? false }

    /// A Boolean value indicating whether the resource has outstanding conflicts.
    public var ubiquitousItemHasUnresolvedConflicts: Bool { (try? value(for: \.ubiquitousItemHasUnresolvedConflicts)) ?? false }

    /// A Boolean value indicating whether the system is downloading the resource.
    public var ubiquitousItemIsDownloading: Bool { (try? value(for: \.ubiquitousItemIsDownloading)) ?? false }

    /// A Boolean value indicating whether data is present in the cloud for the resource.
    public var ubiquitousItemIsUploaded: Bool { (try? value(for: \.ubiquitousItemIsUploaded)) ?? false }

    /// A Boolean value indicating whether the system is uploading the resource.
    public var ubiquitousItemIsUploading: Bool { (try? value(for: \.ubiquitousItemIsUploading)) ?? false }

    /// The download status of the resource.
    public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus? { try? value(for: \.ubiquitousItemDownloadingStatus) }

    @available(macOS 11.0, iOS 9.0, *)
    /// The protection level for the resource.
    public var fileProtection: URLFileProtection? { try? value(for: \.fileProtection) }

    /// The total file size.
    public var fileSize: DataSize? { guard let bytes = fileSizeBytes else { return nil }
        return DataSize(bytes)
    }

    /// The total allocated size on-disk for the file.
    public var fileAllocatedSize: DataSize? { guard let bytes = fileAllocatedSizeBytes else { return nil }
        return DataSize(bytes)
    }

    /// The total displayable size of the file.
    public var totalFileSize: DataSize? { guard let bytes = totalFileSizeBytes else { return nil }
        return DataSize(bytes)
    }

    /// The total allocated size of the file.
    public var totalFileAllocatedSize: DataSize? { guard let bytes = totalFileAllocatedSizeBytes else { return nil }
        return DataSize(bytes)
    }

    internal var fileSizeBytes: Int? { try? value(for: \.fileSize) }

    internal var fileAllocatedSizeBytes: Int? { try? value(for: \.fileAllocatedSize) }

    internal var totalFileSizeBytes: Int? { try? value(for: \.totalFileSize) }

    internal var totalFileAllocatedSizeBytes: Int? { try? value(for: \.totalFileAllocatedSize) }

    /// A Boolean value indicating whether the resource is a Finder alias file or a symlink.
    public var isAliasFile: Bool { (try? value(for: \.isAliasFile)) ?? false }

    #if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    /// A content type of the resource.
    public var contentType: UTType? { try? value(for: \.contentType) }
    #endif
}

@available(macOS, deprecated: 11.0, message: "Use contentType instead")
@available(iOS, deprecated: 14.0, message: "Use contentType instead")
@available(macCatalyst, deprecated: 14.0, message: "Use contentType instead")
@available(tvOS, deprecated: 14.0, message: "Use contentType instead")
@available(watchOS, deprecated: 7.0, message: "Use contentType instead")
extension URLResources {
    /// A content type identifier of the resource.
    public var contentTypeIdentifier: String? { try? value(for: \.typeIdentifier) }

    /// A content type identifier tree of the resource.
    public var contentTypeIdentifierTree: [String] { if let identifier = contentTypeIdentifier {
        return [identifier] + getSupertypes(for: identifier)
    }
    return []
    }

    internal func getSupertypes(for identifier: String) -> [String] {
        let params = UTTypeCopyDeclaration(identifier as CFString)?.takeRetainedValue() as? [String: Any]
        var supertypes = params?[String(kUTTypeConformsToKey)] as? [String] ?? []
        for supertype in supertypes {
            supertypes = getSupertypes(for: supertype) + supertypes
        }
        return supertypes.reversed()
    }
}

#if os(macOS)
public extension URLResources {
    /// A Boolean value indicating whether the resource is scriptable. Only applies to applications.
    @available(macOS 10.11, *)
    var applicationIsScriptable: Bool { (try? value(for: \.applicationIsScriptable)) ?? false }

    @available(macOS 12.0, *)
    /// URLs to applications that support opening the file.
    var supportedApplicationURLs: [URL]? {
        return contentType?.supportedApplicationURLs
    }

    @available(macOS 10.10, *)
    /// The quarantine properties of the resource.
    var quarantineProperties: [String: Any]? {
        get { try? value(for: \.quarantineProperties) }
        set { try? setValue(newValue, for: \.quarantineProperties) }
    }

    @available(macOS 10.9, *)
    /// The finder tags of the resource.
    var tags: [String] {
        get { (try? value(for: \.tagNames)) ?? [] }
        set {
            do {
                try (url as NSURL).setResourceValue(newValue.uniqued() as NSArray, forKey: .tagNamesKey)
            } catch {
                debugPrint(error)
                let newTags = newValue.compactMap { (String($0.suffix(3)) != "\n6") ? ($0 + "\n6") : $0 }
                url.extendedAttributes["com.apple.metadata:kMDItemUserTags"] = newTags.uniqued()
            }
        }
    }

    /// The icon stored with the resource.
    var customIcon: NSUIImage? { try? value(for: \.customIcon) }

    /// The normal icon for the resource.
    var effectiveIcon: NSUIImage? { (try? value(for: \.effectiveIcon)) as? NSUIImage }

    /// The label color of the resource.
    var labelColor: NSUIColor? { try? value(for: \.labelColor) }
}
#endif

public extension URLResources {
    /// The volume properties of the resource.
    var volume: VolumeURLResources {
        return VolumeURLResources(url)
    }

    ///  The volume properties of a file system resource.
    struct VolumeURLResources {
        internal let _url: URL
        public init(_ _url: URL) {
            self._url = _url
        }

        /// The url of the volume.
        public var url: URL? {
            return try? _url.resourceValues(for: .volumeURLKey).volume
        }

        /// The name of the volume.
        public var name: String? { return try? _url.resourceValues(for: .volumeNameKey).volumeName
        }

        /// The name of the volume as it should be displayed in the user interface.
        public var localizedName: String? { return try? _url.resourceValues(for: .volumeLocalizedNameKey).volumeLocalizedName
        }

        /// The persistent UUID of the volume.
        public var uuid: String? { return try? _url.resourceValues(for: .volumeUUIDStringKey).volumeUUIDString
        }

        /// The total number of resources on the volume.
        public var resourceCount: Int? { return try? _url.resourceValues(for: .volumeResourceCountKey).volumeResourceCount
        }

        /// The creation date of the volume.
        public var creationDate: Date? { return try? _url.resourceValues(for: .volumeCreationDateKey).volumeCreationDate
        }

        /// A Boolean value indicating whether the volume is read-only.
        public var isReadOnly: Bool { return (try? _url.resourceValues(for: .volumeIsReadOnlyKey).volumeIsReadOnly) ?? true
        }

        /// A Boolean value indicating whether the volume supports setting standard access permissions.
        public var supportsAccessPermissions: Bool { return (try? _url.resourceValues(for: .volumeSupportsAccessPermissionsKey).volumeSupportsAccessPermissions) ?? false
        }

        /// A Boolean value indicating whether the volume can be renamed.
        public var supportsRenaming: Bool { return (try? _url.resourceValues(for: .volumeSupportsRenamingKey).volumeSupportsRenaming) ?? false
        }

        /// A Boolean value indicating whether the volume supports symbolic links.
        public var supportsSymbolicLinks: Bool { return (try? _url.resourceValues(for: .volumeSupportsSymbolicLinksKey).volumeSupportsSymbolicLinks) ?? false
        }

        /// A Boolean value indicating whether the volume is removable.
        public var isRemovable: Bool { return (try? _url.resourceValues(for: .volumeIsRemovableKey).volumeIsRemovable) ?? false
        }

        /// A Boolean value indicating whether the volume is ejectable.
        public var isEjectable: Bool { return (try? _url.resourceValues(for: .volumeIsEjectableKey).volumeIsEjectable) ?? false
        }

        /// A Boolean value indicating whether the volume is the root filesystem.
        public var isRootFileSystem: Bool { return (try? _url.resourceValues(for: .volumeIsRootFileSystemKey).volumeIsRootFileSystem) ?? false
        }

        /// The available capacity of the volume.
        public var availableCapacity: DataSize? {
            if let bytes = try? _url.resourceValues(for: .volumeAvailableCapacityKey).volumeAvailableCapacity {
                return DataSize(bytes)
            }
            return nil
        }

        /// The total capacity of the volume.
        public var totalCapacity: DataSize? {
            if let bytes = try? _url.resourceValues(for: .volumeTotalCapacityKey).volumeTotalCapacity {
                return DataSize(bytes)
            }
            return nil
        }
    }
}
