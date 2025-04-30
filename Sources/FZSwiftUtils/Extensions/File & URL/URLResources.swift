//
//  URLResources.swift
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
        URLResources(url: self)
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

    func value<V>(for keyPath: KeyPath<URLResourceValues, V?>) -> V? {
        guard let resourceKey = keyPath.resourceKey else { return nil }
        do {
            return try url.resourceValues(for: resourceKey)[keyPath: keyPath]
        } catch {
            Swift.print(error)
            return nil
        }
    }

    func setValue<V>(_ newValue: V?, for keyPath: WritableKeyPath<URLResourceValues, V?>) {
        var urlResouceValues = URLResourceValues()
        urlResouceValues[keyPath: keyPath] = newValue
        do {
            try url.setResourceValues(urlResouceValues)
        } catch {
            Swift.print(error)
        }
    }

    /// Name of the resource in the file system.
    public var name: String? {
        get { value(for: \.name) }
        set { setValue(newValue, for: \.name) }
    }

    /// Localized or extension-hidden name  as displayed to users.
    public var localizedName: String? { value(for: \.localizedName) }

    /// A Boolean value indicating whether the resource is a regular file rather than a directory or a symbolic link.
    public var isRegularFile: Bool { value(for: \.isRegularFile) ?? false }

    /// A Boolean value indicating if the resource is a directory.
    public var isDirectory: Bool { value(for: \.isDirectory) ?? false }
    
    /**
     The count of file system objects in the directory.
     
     This value is a count of objects that are actually in the file system, so it excludes virtual items like “.” and “..”. This property is useful for quickly identifying an empty directory for backup and syncing. If the URL isn’t a directory, or the file system can’t cheaply compute the value, the value is `nil`.
     */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    public var directoryEntryCount: Int? {
        try? url.resourceValues(forKeys: [.directoryEntryCountKey]).directoryEntryCount        
    }

    /// A Boolean value indicating if the resource is a isymbolic link.
    public var isSymbolicLink: Bool { value(for: \.isSymbolicLink) ?? false }

    /// A Boolean value indicating if the resource is a volume.
    public var isVolume: Bool { value(for: \.isVolume) ?? false }

    /**
     A Boolean value indicating if the resource is a packaged directory.
     
     - Note: You can only set or clear this property on directories; if you try to set this property on non-directory objects, the property is ignored. If the directory is a package for some other reason (extension type, etc), setting this property to false will have no effect.
     */
    public var isPackage: Bool {
        get { value(for: \.isPackage) ?? false }
        set { setValue(newValue, for: \.isPackage) }
    }

    /// A Boolean value indicating if the resource is an application.
    @available(macOS 10.11, iOS 9.0, watchOS 2.0, tvOS 9.0, *)
    public var isApplication: Bool { value(for: \.isApplication) ?? false }

    /// A Boolean value indicating if the resource is system-immutable.
    public var isSystemImmutable: Bool { value(for: \.isSystemImmutable) ?? false }

    /// A Boolean value indicating if the resource is user-immutable.
    public var isUserImmutable: Bool {
        get { value(for: \.isUserImmutable) ?? false }
        set { setValue(newValue, for: \.isUserImmutable) }
    }

    /**
     A Boolean value indicating if the resource is normally not displayed to users.
     
     - Note: If the resource is a hidden because its name starts with a period, setting this property to false will not change the property.
     */
    public var isHidden: Bool {
        get { value(for: \.isHidden) ?? false }
        set { setValue(newValue, for: \.isHidden) }
    }

    /// A Boolean value indicating if the resources filename extension is removed from the localizedName property.
    public var hasHiddenExtension: Bool {
        get { value(for: \.hasHiddenExtension) ?? false }
        set { setValue(newValue, for: \.hasHiddenExtension) }
    }

    /// Creation date of the resource.
    public var creationDate: Date? {
        get { value(for: \.creationDate) }
        set { setValue(newValue, for: \.creationDate) }
    }

    /// Date the resource was created, or renamed into or within its parent directory.
    public var addedToDirectoryDate: Date? { value(for: \.addedToDirectoryDate) }

    /// Date the resource content was last accessed.
    public var contentAccessDate: Date? {
        get { value(for: \.contentAccessDate) }
        set { setValue(newValue, for: \.contentAccessDate) }
    }

    /// Date the resource content was last modified.
    public var contentModificationDate: Date? {
        get { value(for: \.contentModificationDate) }
        set { setValue(newValue, for: \.contentModificationDate) }
    }

    /// Date the resource’s attributes were last modified.
    public var attributeModificationDate: Date? { value(for: \.attributeModificationDate) }

    /// Number of hard links to the resource.
    public var linkCount: Int? { value(for: \.linkCount) }

    /// The resource’s parent directory, if any.
    public var parentDirectory: URL? { value(for: \.parentDirectory) }

    /// User-visible type or “kind” description of the resource.
    public var localizedTypeDescription: String? { value(for: \.localizedTypeDescription) }

    /// The label number assigned to the resource.
    public var labelNumber: Int? {
        get { value(for: \.labelNumber) }
        set { setValue(newValue, for: \.labelNumber) }
    }

    /// The user-visible label text of the resource.
    public var labelLocalizedName: String? { value(for: \.localizedLabel) }

    /// A value APFS assigns that identifies a file’s content data stream.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var fileContentIdentifier: Int64? { value(for: \.fileContentIdentifier) }

    /// The optimal block size when reading or writing this file’s data, or `nil` if not available.
    public var preferredIOBlockSize: Int? { value(for: \.preferredIOBlockSize) }

    /// A Boolean value indicating if the resource is readable.
    public var isReadable: Bool? { value(for: \.isReadable) }

    /// A Boolean value indicating if the resource is writable.
    public var isWritable: Bool? { value(for: \.isWritable) }

    /// A Boolean value indicating if the resource is executable.
    public var isExecutable: Bool? { value(for: \.isExecutable) }

    public var fileSecurity: NSFileSecurity? {
        get { value(for: \.fileSecurity) }
        set { setValue(newValue, for: \.fileSecurity) }
    }

    /// A Boolean value indicating whether the resource is excluded from backups.
    public var isExcludedFromBackup: Bool? {
        get { value(for: \.isExcludedFromBackup) }
        set { setValue(newValue, for: \.isExcludedFromBackup) }
    }

    /// File system path to the resource.
    public var path: String? { value(for: \.path) }

    /// The resource’s path as a canonical absolute file system path.
    public var canonicalPath: String? { value(for: \.canonicalPath) }

    /// A Boolean value indicating whether the resource is a file system trigger directory.
    public var isMountTrigger: Bool? { value(for: \.isMountTrigger) }

    /**
     An opaque generation identifier which can be compared using == to determine if the data in a document has been modified.

     For resources which refer to the same file inode, the generation identifier will change when the data in the file’s data fork is changed (changes to extended attributes or other file system metadata do not change the generation identifier). For resources which refer to the same directory inode, the generation identifier will change when direct children of that directory are added, removed or renamed (changes to the data of the direct children of that directory will not change the generation identifier). The generation identifier is persistent across system restarts. The generation identifier is tied to a specific document on a specific volume and is not transferred when the document is copied to another volume. This property is not supported by all volumes.
     */
    public var generationIdentifier: (NSCopying & NSSecureCoding & NSObjectProtocol)? { value(for: \.generationIdentifier) }

    /// A value that the kernel assigns to identify a document.
    public var documentIdentifier: Int? { value(for: \.documentIdentifier) }

    /// A Boolean value indicating whether the file may have extended attributes.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var mayHaveExtendedAttributes: Bool { value(for: \.mayHaveExtendedAttributes) ?? false }

    /// A Boolean value indicating whether the file system can delete the file when the system needs to free space.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var isPurgeable: Bool { value(for: \.isPurgeable) ?? false }

    /// A Boolean value indicating whether the file has sparse regions.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var isSparse: Bool { value(for: \.isSparse) ?? false }

    /// A Boolean value that indicates whether the cloned files and their original files may share data blocks.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var mayShareFileContent: Bool { value(for: \.mayShareFileContent) ?? false }

    /// The type of the fresource.
    public var fileResourceType: URLFileResourceType? { value(for: \.fileResourceType) }

    /// A Boolean value indicating whether the resource is in the iCloud storage.
    public var isUbiquitousItem: Bool { value(for: \.isUbiquitousItem) ?? false }

    /// A Boolean value indicating whether the resource has outstanding conflicts.
    public var ubiquitousItemHasUnresolvedConflicts: Bool { value(for: \.ubiquitousItemHasUnresolvedConflicts) ?? false }

    /// A Boolean value indicating whether the system is downloading the resource.
    public var ubiquitousItemIsDownloading: Bool { value(for: \.ubiquitousItemIsDownloading) ?? false }

    /// A Boolean value indicating whether data is present in the cloud for the resource.
    public var ubiquitousItemIsUploaded: Bool { value(for: \.ubiquitousItemIsUploaded) ?? false }

    /// A Boolean value indicating whether the system is uploading the resource.
    public var ubiquitousItemIsUploading: Bool { value(for: \.ubiquitousItemIsUploading) ?? false }

    /// The download status of the resource.
    public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus? { value(for: \.ubiquitousItemDownloadingStatus) }

    /// The protection level for the resource.
    @available(macOS 11.0, iOS 9.0, *)
    public var fileProtection: URLFileProtection? { value(for: \.fileProtection) }

    /// The total file size.
    public var fileSize: DataSize? { value(for: \.fileSize)?.dataSize }

    /// The total allocated size on-disk for the file.
    public var fileAllocatedSize: DataSize? { value(for: \.fileAllocatedSize)?.dataSize }

    /// The total displayable size of the file.
    public var totalFileSize: DataSize? { value(for: \.totalFileSize)?.dataSize }

    /// The total allocated size of the file.
    public var totalFileAllocatedSize: DataSize? { value(for: \.totalFileAllocatedSize)?.dataSize }

    /// A Boolean value indicating whether the resource is a Finder alias file or a symlink.
    public var isAliasFile: Bool { value(for: \.isAliasFile) ?? false }

    #if canImport(UniformTypeIdentifiers)
    /// The content type of the resource.
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var contentType: UTType? { value(for: \.contentType) }
    #endif
    
    #if os(macOS)
    /// The Finder tags of the resource.
    public var finderTags: [String] {
        get { value(for: \.tagNames) ?? [] }
        set {
            do {
                try (url as NSURL).setResourceValue(newValue.uniqued() as NSArray, forKey: .tagNamesKey)
            } catch {
                debugPrint(error)
                let newTags = newValue.compactMap({ (String($0.suffix(3)) != "\n6") ? ($0 + "\n6") : $0 }).uniqued()
                url.extendedAttributes["com.apple.metadata:kMDItemUserTags"] = newTags.uniqued()
            }
        }
    }
    #else
    /// The macOS Finder tags of the resource.
    public var finderTags: [String] {
        get {
            let tags: [String] = url.extendedAttributes["com.apple.metadata:kMDItemUserTags"] ?? []
            return tags.compactMap { $0.replacingOccurrences(of: "\n6", with: "") }
        }
        set { url.extendedAttributes["com.apple.metadata:kMDItemUserTags"] = newValue.compactMap({ (String($0.suffix(3)) != "\n6") ? ($0 + "\n6") : $0 }).uniqued() }
    }
    #endif
}

@available(macOS, obsoleted: 11.0, message: "Use contentType instead")
@available(iOS, obsoleted: 14.0, message: "Use contentType instead")
@available(macCatalyst, obsoleted: 14.0, message: "Use contentType instead")
@available(tvOS, obsoleted: 14.0, message: "Use contentType instead")
@available(watchOS, obsoleted: 7.0, message: "Use contentType instead")
extension URLResources {
    /// The content type identifier of the resource.
    public var contentTypeIdentifier: String? { value(for: \.typeIdentifier) }

    /// The content type identifier tree of the resource.
    public var contentTypeIdentifierTree: [String] {
        guard let identifier = contentTypeIdentifier else { return [] }
        return identifier + getSupertypes(for: identifier)
    }

    private func getSupertypes(for identifier: String) -> [String] {
        guard let params = UTTypeCopyDeclaration(identifier as CFString)?.takeRetainedValue() as? [String: Any], let supertypes = params[String(kUTTypeConformsToKey)] as? [String] else {
            return []
        }
        return supertypes.flatMap { getSupertypes(for: $0) + [$0] }
    }
}

#if os(macOS)
    public extension URLResources {
        /// A Boolean value indicating whether the resource is scriptable. Only applies to applications.
        var applicationIsScriptable: Bool { value(for: \.applicationIsScriptable) ?? false }

        /// URLs to applications that support opening the file.
        @available(macOS 12.0, *)
        var supportedApplicationURLs: [URL]? {
            contentType?.supportedApplicationURLs
        }

        /// The quarantine properties of the resource.
        var quarantineProperties: QurantineProperties? {
            get { QurantineProperties(value(for: \.quarantineProperties)) }
            set { setValue(newValue?.rawValue, for: \.quarantineProperties) }
        }

        /// The icon stored with the resource.
        var customIcon: NSUIImage? { value(for: \.customIcon) }

        /// The normal icon for the resource.
        var effectiveIcon: NSUIImage? { value(for: \.effectiveIcon) as? NSUIImage }

        /// The label color of the resource.
        var labelColor: NSUIColor? { value(for: \.labelColor) }
    }
#endif

public extension URLResources {
    /// The volume properties of the resource.
    var volume: VolumeURLResources {
        VolumeURLResources(self)
    }

    ///  The volume properties of a file system resource.
    struct VolumeURLResources {
        private let resources: URLResources
        
        public init(_ resources: URLResources) {
            self.resources = resources
        }

        /// The url of the volume.
        public var url: URL? { resources.value(for: \.volume) }

        /// The name of the volume.
        public var name: String? { resources.value(for: \.volumeName) }

        /// The name of the volume as it should be displayed in the user interface.
        public var localizedName: String? { resources.value(for: \.volumeLocalizedName) }

        /// The persistent UUID of the volume.
        public var uuid: String? { resources.value(for: \.volumeUUIDString) }

        /// The total number of resources on the volume.
        public var resourceCount: Int? { resources.value(for: \.volumeResourceCount) }

        /// The creation date of the volume.
        public var creationDate: Date? { resources.value(for: \.volumeCreationDate) }

        /// A Boolean value indicating whether the volume is read-only.
        public var isReadOnly: Bool { resources.value(for: \.volumeIsReadOnly) ?? true }

        /// A Boolean value indicating whether the volume supports setting standard access permissions.
        public var supportsAccessPermissions: Bool { resources.value(for: \.volumeSupportsAccessPermissions) ?? false }

        /// A Boolean value indicating whether the volume can be renamed.
        public var supportsRenaming: Bool { resources.value(for: \.volumeSupportsRenaming) ?? false }

        /// A Boolean value indicating whether the volume supports symbolic links.
        public var supportsSymbolicLinks: Bool { resources.value(for: \.volumeSupportsSymbolicLinks) ?? false }

        /// A Boolean value indicating whether the volume is removable.
        public var isRemovable: Bool { resources.value(for: \.volumeIsRemovable) ?? false }
        
        /// A Boolean value indicating whether the volume is stored on a local device.
        public var isLocal: Bool { resources.value(for: \.volumeIsLocal) ?? false }
        
        /// A Boolean value that indicates whether the volume’s device is connected to an internal bus, or nil if not available.
        public var isInternal: Bool { resources.value(for: \.volumeIsInternal) ?? false }

        /// A Boolean value indicating whether the volume is ejectable.
        public var isEjectable: Bool { resources.value(for: \.volumeIsEjectable) ?? false }

        /// A Boolean value indicating whether the volume is the root filesystem.
        public var isRootFileSystem: Bool { resources.value(for: \.volumeIsRootFileSystem) ?? false }

        /// The available capacity of the volume.
        public var availableCapacity: DataSize? {
            resources.value(for: \.volumeAvailableCapacity)?.dataSize
        }
        
        #if os(macOS) || os(iOS)
        /// The volume’s available capacity for storing nonessential resources, in bytes.
        public var availableCapacityForImportantUisage: DataSize? {
            resources.value(for: \.volumeAvailableCapacityForImportantUsage)?.dataSize
        }
        
        /// The available capacity of the volume.
        public var volumeAvailableCapacityForOpportunisticUsage: DataSize? {
            resources.value(for: \.volumeAvailableCapacityForOpportunisticUsage)?.dataSize
        }
        #endif

        /// The total capacity of the volume.
        public var totalCapacity: DataSize? {
            resources.value(for: \.volumeTotalCapacity)?.dataSize
        }
    }
}

#if os(macOS)
public extension URLResources {
    /// The quarantine properties of a resource.
    struct QurantineProperties {
        /**
         The URL of the resource originally hosting the quarantined item.
         
         For web downloads, this property is the URL of the web page on which the user initiated the download. For attachments, this property is the URL of the resource to which the quarantined item was attached (e.g. the email message, calendar event, etc.). The origin URL may be a file URL for local resources, or a custom URL to which the quarantining app will respond when asked to open it. The quarantining app should respond by displaying the resource to the user.
         
         - Note: The origin URL should not be set to the data URL, or the quarantining app may start downloading the file again if the user choses to view the origin URL while resolving a quarantine warning.
         */
        public var originURL: URL? {
            get { rawValue[kLSQuarantineOriginURLKey as String] as? URL }
            set { rawValue[kLSQuarantineOriginURLKey as String] = newValue }
        }
        
        /// The actual URL of the quarantined item.
        public var dataURL: URL? {
            get { rawValue[kLSQuarantineDataURLKey as String] as? URL }
            set { rawValue[kLSQuarantineDataURLKey as String] = newValue }
        }
        
        /**
         The bundle identifier of the quarantining agent.
         
         When setting quarantine properties, the bundle identifier is set automatically to the main bundle identifier of the current process if the key is not present.
         */
        public var agentBundleIdentifier: String? {
            get { rawValue[kLSQuarantineAgentBundleIdentifierKey as String] as? String }
            set { rawValue[kLSQuarantineAgentBundleIdentifierKey as String] = newValue }
        }
        
        /**
         The app name of the quarantining agent.
         
         When setting quarantine properties, this agent name is set automatically to the current process name if this key is not present.
         */
        public var agentName: String? {
            get { rawValue[kLSQuarantineAgentNameKey as String] as? String }
            set { rawValue[kLSQuarantineAgentNameKey as String] = newValue }
        }
        
        /**
         The date and time of the item’s quarantine.
         
         When setting quarantine properties, this property is set automatically to the current date and time if this value is not present.
         */
        public var timestamp: Date? {
            get { rawValue[kLSQuarantineTimeStampKey as String] as? Date }
            set { rawValue[kLSQuarantineTimeStampKey as String] = newValue }
        }
        
        /// The reason for the quarantine.
        public var type: QuarantineType? {
            get {
                guard let rawValue = rawValue["LSQuarantineEventIdentifier"] as? String else { return nil }
                return QuarantineType(rawValue)
            }
            set { rawValue["LSQuarantineEventIdentifier"] = newValue?.rawValue }
        }
        
        /// A Boolean value indicating whether the quarantined item was created by the current user.
        public var isOwnedByCurrentUser: Bool? {
            get { rawValue["LSQuarantineIsOwnedByCurrentUser"] as? Bool }
            set { rawValue["LSQuarantineIsOwnedByCurrentUser"] = newValue }
        }
        
        /// The identifier for the quarantine event.
        public var eventIdentifier: String? {
            get { rawValue["LSQuarantineEventIdentifier"] as? String }
            set { rawValue["LSQuarantineEventIdentifier"] = newValue }
        }
        
        /// The raw value of the qurantine properties.
        public var rawValue: [String: Any] = [:]
        
        init?(_ dictionary: [String: Any]?) {
            guard let dictionary = dictionary else { return nil }
            self.rawValue = dictionary
        }
        
        /// The reason for the quarantine.
        public struct QuarantineType: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
            
            /// The data is from a website download.
            public static let webDownload = Self(kLSQuarantineTypeWebDownload as String)
            
            /// The data is from a download.
            public static let otherDownload = Self(kLSQuarantineTypeOtherDownload as String)
            
            /// The data is an attachment from an email message.
            public static let emailAttachment = Self(kLSQuarantineTypeEmailAttachment as String)
            
            /// The data is an attachment from a message.
            public static let instantMessageAttachment = Self(kLSQuarantineTypeInstantMessageAttachment as String)
            
            public static let calendarEventAttachment = Self(kLSQuarantineTypeCalendarEventAttachment as String)
            
            /// The data is an attachment from a generic source.
            public static let otherAttachment = Self(kLSQuarantineTypeOtherAttachment as String)
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(stringLiteral value: String) {
                self.rawValue = value
            }
            
            public let rawValue: String
            
            public var description: String {
                rawValue.replacingOccurrences(of: "kLSQuarantineType", with: "").lowercasedFirst()
            }
        }
    }
}
#endif

fileprivate extension BinaryInteger {
    var dataSize: DataSize {
        DataSize(self)
    }
}
