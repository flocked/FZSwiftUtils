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
 
 Not all properties exist for all files. For example, if a file is located on a volume that doesn’t support creation dates, the creationDate property will return nil.

 Some of the properties can be modified. Changing them attempts  to modify the represented file or folder.
 */
public class URLResources {
    /// The url to the resource
    public private(set) var url: URL
    private var iteratorKey: String?
    static var iteratorKeys: SynchronizedDictionary<String, Set<URLResourceKey>> = [:]

    /// Creates an object for accessing and modifying properties of the resource at the specified url.
    public init(url: URL) {
        self.url = url
        guard url.path.hasPrefix("/_prefetchCheck_") else { return }
        iteratorKey = url.path.removingPrefix("/_prefetchCheck_")
    }
    
    private func value<V>(for resourceKey: URLResourceKey, _ keyPath: KeyPath<URLResourceValues, V?>) -> V? {
        if let iteratorKey = iteratorKey {
            let keys = Self.iteratorKeys[iteratorKey] ?? [] + resourceKey
            Self.iteratorKeys[iteratorKey] = keys
            return nil
        }
        do {
            return try url.resourceValues(forKeys: [resourceKey])[keyPath: keyPath]
        } catch {
            Swift.print(error)
            return nil
        }
    }

    private func setValue<V>(_ newValue: V?, for keyPath: WritableKeyPath<URLResourceValues, V?>) {
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
        get { value(for: .nameKey, \.name) }
        set { setValue(newValue, for: \.name) }
    }

    /// Localized or extension-hidden name  as displayed to users.
    public var localizedName: String? { value(for: .localizedNameKey, \.localizedName) }

    /// A Boolean value indicating whether the resource is a regular file rather than a directory or a symbolic link.
    public var isRegularFile: Bool { value(for: .isRegularFileKey, \.isRegularFile) ?? false }

    /// A Boolean value indicating if the resource is a directory.
    public var isDirectory: Bool { value(for: .isDirectoryKey, \.isDirectory) ?? false }

    /**
     The count of file system objects in the directory.

     This value is a count of objects that are actually in the file system, so it excludes virtual items like “.” and “..”. This property is useful for quickly identifying an empty directory for backup and syncing. If the URL isn’t a directory, or the file system can’t cheaply compute the value, the value is `nil`.
     */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    public var directoryEntryCount: Int? {
        try? url.resourceValues(forKeys: [.directoryEntryCountKey]).directoryEntryCount        
    }

    /// A Boolean value indicating if the resource is a isymbolic link.
    public var isSymbolicLink: Bool { value(for: .isSymbolicLinkKey, \.isSymbolicLink) ?? false }

    /// A Boolean value indicating if the resource is a volume.
    public var isVolume: Bool { value(for: .isVolumeKey, \.isVolume) ?? false }

    /**
     A Boolean value indicating if the resource is a packaged directory.

     - Note: You can only set or clear this property on directories; if you try to set this property on non-directory objects, the property is ignored. If the directory is a package for some other reason (extension type, etc), setting this property to false will have no effect.
     */
    public var isPackage: Bool {
        get { value(for: .isPackageKey, \.isPackage) ?? false }
        set { setValue(newValue, for: \.isPackage) }
    }

    /// A Boolean value indicating if the resource is an application.
    public var isApplication: Bool { value(for: .isApplicationKey, \.isApplication) ?? false }

    /// A Boolean value indicating if the resource is system-immutable.
    public var isSystemImmutable: Bool { value(for: .isSystemImmutableKey, \.isSystemImmutable) ?? false }

    /// A Boolean value indicating if the resource is user-immutable.
    public var isUserImmutable: Bool {
        get { value(for: .isUserImmutableKey, \.isUserImmutable) ?? false }
        set { setValue(newValue, for: \.isUserImmutable) }
    }

    /**
     A Boolean value indicating if the resource is normally not displayed to users.

     - Note: If the resource is a hidden because its name starts with a period, setting this property to false will not change the property.
     */
    public var isHidden: Bool {
        get { value(for: .isHiddenKey, \.isHidden) ?? false }
        set { setValue(newValue, for: \.isHidden) }
    }

    /// A Boolean value indicating if the resources filename extension is removed from the localizedName property.
    public var hasHiddenExtension: Bool {
        get { value(for: .hasHiddenExtensionKey, \.hasHiddenExtension) ?? false }
        set { setValue(newValue, for: \.hasHiddenExtension) }
    }

    /// Creation date of the resource.
    public var creationDate: Date? {
        get { value(for:  .creationDateKey, \.creationDate) }
        set { setValue(newValue, for: \.creationDate) }
    }

    /// Date the resource was created, or renamed into or within its parent directory.
    public var addedToDirectoryDate: Date? { value(for: .addedToDirectoryDateKey, \.addedToDirectoryDate) }

    /// Date the resource content was last accessed.
    public var contentAccessDate: Date? {
        get { value(for: .contentAccessDateKey, \.contentAccessDate) }
        set { setValue(newValue, for: \.contentAccessDate) }
    }

    /// Date the resource content was last modified.
    public var contentModificationDate: Date? {
        get { value(for: .contentModificationDateKey, \.contentModificationDate) }
        set { setValue(newValue, for: \.contentModificationDate) }
    }

    /// Date the resource’s attributes were last modified.
    public var attributeModificationDate: Date? { value(for: .attributeModificationDateKey, \.attributeModificationDate) }

    /// Number of hard links to the resource.
    public var linkCount: Int? { value(for: .linkCountKey, \.linkCount) }

    /// The resource’s parent directory, if any.
    public var parentDirectory: URL? { value(for: .parentDirectoryURLKey, \.parentDirectory) }

    /// User-visible type or “kind” description of the resource.
    public var localizedTypeDescription: String? { value(for: .localizedTypeDescriptionKey, \.localizedTypeDescription) }

    /// The label number assigned to the resource.
    public var labelNumber: Int? {
        get { value(for: .labelNumberKey, \.labelNumber) }
        set { setValue(newValue, for: \.labelNumber) }
    }

    /// The user-visible label text of the resource.
    public var labelLocalizedName: String? { value(for: .localizedLabelKey, \.localizedLabel) }

    /// A value APFS assigns that identifies a file’s content data stream.
    public var fileContentIdentifier: Int64? { value(for: .fileContentIdentifierKey, \.fileContentIdentifier) }

    /// The optimal block size when reading or writing this file’s data, or `nil` if not available.
    public var preferredIOBlockSize: Int? { value(for: .preferredIOBlockSizeKey, \.preferredIOBlockSize) }

    /// A Boolean value indicating if the resource is readable.
    public var isReadable: Bool? { value(for: .isReadableKey, \.isReadable) }

    /// A Boolean value indicating if the resource is writable.
    public var isWritable: Bool? { value(for: .isWritableKey, \.isWritable) }

    /// A Boolean value indicating if the resource is executable.
    public var isExecutable: Bool? { value(for: .isExecutableKey, \.isExecutable) }

    public var fileSecurity: NSFileSecurity? {
        get { value(for: .fileSecurityKey, \.fileSecurity) }
        set { setValue(newValue, for: \.fileSecurity) }
    }

    /// A Boolean value indicating whether the resource is excluded from backups.
    public var isExcludedFromBackup: Bool? {
        get { value(for: .isExcludedFromBackupKey, \.isExcludedFromBackup) }
        set { setValue(newValue, for: \.isExcludedFromBackup) }
    }

    /// File system path to the resource.
    public var path: String? { value(for: .pathKey, \.path) }

    /// The resource’s path as a canonical absolute file system path.
    public var canonicalPath: String? { value(for: .canonicalPathKey, \.canonicalPath) }

    /// A Boolean value indicating whether the resource is a file system trigger directory.
    public var isMountTrigger: Bool? { value(for: .isMountTriggerKey, \.isMountTrigger) }

    /**
     An opaque generation identifier which can be compared using == to determine if the data in a document has been modified.

     For files the generation identifier will change when the data in the file’s data fork is changed. Changes to extended attributes or other file system metadata do not change the generation identifier.

     For directories the generation identifier will change when direct children of that directory are added, removed or renamed. Changes to the data of the direct children will not change the generation identifier.

     The generation identifier is persistent across system restarts. The generation identifier is tied to a specific document on a specific volume and is not transferred when the document is copied to another volume. This property is not supported by all volumes.
     */
    public var generationIdentifier: (NSCopying & NSSecureCoding & NSObjectProtocol)? {
        value(for: .generationIdentifierKey, \.generationIdentifier) }

    /**
     The identifier of the resource.

     The value is assigned by the kernel to identify the resource regardless of where it moves on a volume.

     The identifier survives safe-save operation, and is sticky to the path the kernel assigns. [replaceItemAt(_:withItemAt:backupItemName:options:)](https://developer.apple.com/documentation/foundation/filemanager/replaceitemat(_:withitemat:backupitemname:options:)-4210g) is the preferred safe-save API.
     
     The identifier is persistent across system restarts, and doesn’t transfer when you copy the resource. The identifier is only unique within a single volume and not all volumes support this property.
     */
    public var identifier: Int? { value(for: .documentIdentifierKey, \.documentIdentifier) }

    /// A Boolean value indicating whether the file may have extended attributes.
    public var mayHaveExtendedAttributes: Bool { value(for: .mayHaveExtendedAttributesKey, \.mayHaveExtendedAttributes) ?? false }

    /// A Boolean value indicating whether the file system can delete the file when the system needs to free space.
    public var isPurgeable: Bool { value(for: .isPurgeableKey, \.isPurgeable) ?? false }

    /// A Boolean value indicating whether the file has sparse regions.
    public var isSparse: Bool { value(for: .isSparseKey, \.isSparse) ?? false }

    /// A Boolean value indicating whether the cloned files and their original files may share data blocks.
    public var mayShareFileContent: Bool { value(for: .mayShareFileContentKey, \.mayShareFileContent) ?? false }

    /// The type of the fresource.
    public var fileResourceType: URLFileResourceType? { value(for: .fileResourceTypeKey, \.fileResourceType) }

    /// A Boolean value indicating whether the resource is in the iCloud storage.
    public var isUbiquitousItem: Bool { value(for: .isUbiquitousItemKey, \.isUbiquitousItem) ?? false }

    /// A Boolean value indicating whether the resource has outstanding conflicts.
    public var ubiquitousItemHasUnresolvedConflicts: Bool { value(for: .ubiquitousItemHasUnresolvedConflictsKey, \.ubiquitousItemHasUnresolvedConflicts) ?? false }

    /// A Boolean value indicating whether the system is downloading the resource.
    public var ubiquitousItemIsDownloading: Bool { value(for: .ubiquitousItemIsUploadingKey, \.ubiquitousItemIsDownloading) ?? false }

    /// A Boolean value indicating whether data is present in the cloud for the resource.
    public var ubiquitousItemIsUploaded: Bool { value(for: .ubiquitousItemIsUploadedKey, \.ubiquitousItemIsUploaded) ?? false }

    /// A Boolean value indicating whether the system is uploading the resource.
    public var ubiquitousItemIsUploading: Bool { value(for: .ubiquitousItemIsUploadingKey, \.ubiquitousItemIsUploading) ?? false }

    /// The download status of the resource.
    public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus? { value(for: .ubiquitousItemDownloadingStatusKey, \.ubiquitousItemDownloadingStatus) }

    /// The protection level for the resource.
    public var fileProtection: URLFileProtection? { value(for: .fileProtectionKey, \.fileProtection) }

    /// The total file size.
    public var fileSize: DataSize? { value(for: .fileSizeKey, \.fileSize)?.dataSize }

    /// The total allocated size on-disk for the file.
    public var fileAllocatedSize: DataSize? { value(for: .fileAllocatedSizeKey, \.fileAllocatedSize)?.dataSize }

    /// The total displayable size of the file.
    public var totalFileSize: DataSize? { value(for: .totalFileSizeKey, \.totalFileSize)?.dataSize }

    /// The total allocated size of the file.
    public var totalFileAllocatedSize: DataSize? { value(for: .totalFileAllocatedSizeKey, \.totalFileAllocatedSize)?.dataSize }

    /// A Boolean value indicating whether the resource is a Finder alias file or a symlink.
    public var isAliasFile: Bool { value(for: .isAliasFileKey, \.isAliasFile) ?? false }

    /// The content type of the resource.
    public var contentType: UTType? { value(for: .contentTypeKey, \.contentType) }

    #if os(macOS)
    /// The Finder tags of the resource.
    public var finderTags: [String] {
        get { value(for: .tagNamesKey, \.tagNames) ?? [] }
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

#if os(macOS)
public extension URLResources {
    /// A Boolean value indicating whether the resource is scriptable. Only applies to applications.
    var applicationIsScriptable: Bool { value(for: .applicationIsScriptableKey, \.applicationIsScriptable) ?? false }

    /// URLs to applications that support opening the file.
    var supportedApplicationURLs: [URL]? {
        contentType?.supportedApplicationURLs
    }

    /// The quarantine properties of the resource.
    var quarantineProperties: QurantineProperties? {
        get { QurantineProperties(value(for: .quarantinePropertiesKey, \.quarantineProperties)) }
        set { setValue(newValue?.rawValue, for: \.quarantineProperties) }
    }

    /// The icon stored with the resource.
    var customIcon: NSUIImage? { value(for: .customIconKey, \.customIcon) }

    /// The normal icon for the resource.
    var effectiveIcon: NSUIImage? { value(for: .effectiveIconKey, \.effectiveIcon) as? NSUIImage }

    /// The label color of the resource.
    var labelColor: NSUIColor? { value(for: .labelColorKey, \.labelColor) }
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
        public var url: URL? { resources.value(for: .volumeURLKey, \.volume) }

        /// The name of the volume.
        public var name: String? { resources.value(for: .volumeNameKey, \.volumeName) }

        /// The name of the volume as it should be displayed in the user interface.
        public var localizedName: String? { resources.value(for: .volumeLocalizedNameKey, \.volumeLocalizedName) }

        /// The persistent UUID of the volume.
        public var uuid: String? { resources.value(for: .volumeUUIDStringKey, \.volumeUUIDString) }

        /// The total number of resources on the volume.
        public var resourceCount: Int? { resources.value(for: .volumeResourceCountKey, \.volumeResourceCount) }

        /// The creation date of the volume.
        public var creationDate: Date? { resources.value(for: .volumeCreationDateKey, \.volumeCreationDate) }

        /// A Boolean value indicating whether the volume is read-only.
        public var isReadOnly: Bool { resources.value(for: .volumeIsReadOnlyKey, \.volumeIsReadOnly) ?? true }

        /// A Boolean value indicating whether the volume supports setting standard access permissions.
        public var supportsAccessPermissions: Bool { resources.value(for: .volumeSupportsAccessPermissionsKey, \.volumeSupportsAccessPermissions) ?? false }

        /// A Boolean value indicating whether the volume can be renamed.
        public var supportsRenaming: Bool { resources.value(for: .volumeSupportsRenamingKey, \.volumeSupportsRenaming) ?? false }

        /// A Boolean value indicating whether the volume supports symbolic links.
        public var supportsSymbolicLinks: Bool { resources.value(for: .volumeSupportsSymbolicLinksKey,  \.volumeSupportsSymbolicLinks) ?? false }

        /// A Boolean value indicating whether the volume is removable.
        public var isRemovable: Bool { resources.value(for: .volumeIsRemovableKey, \.volumeIsRemovable) ?? false }

        /// A Boolean value indicating whether the volume is stored on a local device.
        public var isLocal: Bool { resources.value(for: .volumeIsLocalKey, \.volumeIsLocal) ?? false }

        /// A Boolean value indicating whether the volume’s device is connected to an internal bus, or nil if not available.
        public var isInternal: Bool { resources.value(for: .volumeIsInternalKey, \.volumeIsInternal) ?? false }

        /// A Boolean value indicating whether the volume is ejectable.
        public var isEjectable: Bool { resources.value(for: .volumeIsEjectableKey, \.volumeIsEjectable) ?? false }

        /// A Boolean value indicating whether the volume is the root filesystem.
        public var isRootFileSystem: Bool { resources.value(for: .volumeIsRootFileSystemKey, \.volumeIsRootFileSystem) ?? false }

        /// The available capacity of the volume.
        public var availableCapacity: DataSize? {
            resources.value(for: .volumeAvailableCapacityKey, \.volumeAvailableCapacity)?.dataSize
        }

        #if os(macOS) || os(iOS)
        /// The volume’s available capacity for storing nonessential resources, in bytes.
        public var availableCapacityForImportantUisage: DataSize? {
            resources.value(for: .volumeAvailableCapacityForImportantUsageKey,  \.volumeAvailableCapacityForImportantUsage)?.dataSize
        }

        /// The available capacity of the volume.
        public var volumeAvailableCapacityForOpportunisticUsage: DataSize? {
            resources.value(for: .volumeAvailableCapacityForOpportunisticUsageKey,  \.volumeAvailableCapacityForOpportunisticUsage)?.dataSize
        }
        #endif

        /// The total capacity of the volume.
        public var totalCapacity: DataSize? {
            resources.value(for: .volumeTotalCapacityKey, \.volumeTotalCapacity)?.dataSize
        }
    }
}

#if os(macOS)
public extension URLResources {
    /// The quarantine properties of a resource.
    struct QurantineProperties: CustomStringConvertible, CustomDebugStringConvertible {
        /**
         The URL of the resource originally hosting the quarantined item.

         For web downloads, this property is the URL of the web page on which the user initiated the download. For attachments, this property is the URL of the resource to which the quarantined item was attached (e.g. the email message, calendar event, etc.).

         The origin URL may be a file URL for local resources, or a custom URL to which the quarantining app will respond when asked to open it. The quarantining app should respond by displaying the resource to the user.

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

         When applying the quarantine properties to an item and this value is `nil`, the value is set automatically to the main bundle identifier of the current process.
         */
        public var agentBundleIdentifier: String? {
            get { rawValue[kLSQuarantineAgentBundleIdentifierKey as String] as? String }
            set { rawValue[kLSQuarantineAgentBundleIdentifierKey as String] = newValue }
        }

        /**
         The app name of the quarantining agent.

         When applying the quarantine properties to an item and this value is `nil`, the value is set automatically to the current process name.
         */
        public var agentName: String? {
            get { rawValue[kLSQuarantineAgentNameKey as String] as? String }
            set { rawValue[kLSQuarantineAgentNameKey as String] = newValue }
        }

        /**
         The date and time of the item’s quarantine.

         When applying the quarantine properties to an item and this value is `nil`, the value is set automaticallyto the current date and time.
         */
        public var timestamp: Date? {
            get { rawValue[kLSQuarantineTimeStampKey as String] as? Date }
            set { rawValue[kLSQuarantineTimeStampKey as String] = newValue }
        }

        /// The reason for the item's quarantine, such as a web download or email attachment.
        public var type: QuarantineType? {
            get {
                guard let rawValue = rawValue[kLSQuarantineTypeKey as String] as? String else { return nil }
                return QuarantineType(rawValue)
            }
            set { rawValue[kLSQuarantineTypeKey as String] = newValue?.rawValue }
        }

        /// A Boolean value indicating whether the quarantined item was created by the current user.
        public var isOwnedByCurrentUser: Bool? {
            get { rawValue["LSQuarantineIsOwnedByCurrentUser"] as? Bool }
        }

        /// The identifier for the quarantine event.
        public var eventIdentifier: String? {
            get { rawValue["LSQuarantineEventIdentifier"] as? String }
        }

        /// The raw representation of the qurantine properties.
        public var rawValue: [String: Any] = [:]

        public var description: String {
            var strings: [String] = []
            if let originURL = originURL { strings += "originURL: \(originURL)" }
            if let dataURL = dataURL { strings += "dataURL: \(dataURL)" }
            if let agent = agentName, let bundleID = agentBundleIdentifier { strings += "agent: \(agent), \(bundleID)" } else if let agentName = agentName { strings += "agent: \(agentName)" } else if let agentBundleID = agentBundleIdentifier { strings += "agentBundleID: \(agentBundleID)" }
            if let type = type { strings += "type: \(type)" }
            if let isOwned = isOwnedByCurrentUser { strings += "isOwnedByUser: \(isOwned)" }
            if let timestamp = timestamp { strings += "timestamp: \(timestamp)" }
            return "QurantineProperties(\(strings.joined(separator: ", ")))"
        }

        public var debugDescription: String {
            "\(rawValue)"
        }

        init?(_ dictionary: [String: Any]?) {
            guard let dictionary = dictionary else { return nil }
            self.rawValue = dictionary
        }

        /// The reason for an item's quarantine.
        public struct QuarantineType: RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {

            /// The item is from a website download.
            public static let webDownload = Self(kLSQuarantineTypeWebDownload as String)

            /// The item is from a download.
            public static let otherDownload = Self(kLSQuarantineTypeOtherDownload as String)

            /// The item is an attachment from an email message.
            public static let emailAttachment = Self(kLSQuarantineTypeEmailAttachment as String)

            /// The item is an attachment from a message.
            public static let instantMessageAttachment = Self(kLSQuarantineTypeInstantMessageAttachment as String)

            /// The item is an attachment from a calendar event.
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
                rawValue.replacingOccurrences(of: "LSQuarantineType", with: "").lowercasedFirst()
            }
        }
    }
}
#endif

#if os(macOS)
@available(macOS 26.0, *)
extension URLResources {
    /// The icon of a folder.
    enum FolderIcon: Hashable, CustomStringConvertible {
        /// Emoji.
        case emoji(String)
        /// System symbol image.
        case symbolImage(String)

        var description: String {
            switch self {
            case .emoji(let string):
                return "Emoji: \(string)"
            case .symbolImage(let string):
                return "SymbolImage: \(string)"
            }
        }

        var dict: [String: String]? {
            switch self {
            case .emoji(let string):
                guard string.allSatisfy({$0.isEmoji}) else { return nil }
                return ["emoji": string]
            case .symbolImage(let string):
                // guard NSImage(systemSymbolName: string) != nil else { return nil}
                return ["sym": string]
            }
        }
    }

    /// The icon of the folder.
    var folderIcon: FolderIcon? {
        get {
            do {
                let data = try url.extendedAttributes.getData(for: "com.apple.icon.folder#S")
                guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
                if let symbolName = dict["sym"] as? String {
                    return .symbolImage(symbolName)
                } else if let emoji = dict["emoji"] as? String {
                    return .emoji(emoji)
                }
            } catch {
                Swift.print(error)
            }
            return nil
        }
        set {
            do {
                if let newValue = newValue {
                    guard let dict = newValue.dict else { return }
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                    guard let data = String(data: jsonData, encoding: .utf8)?.data(using: .utf8) else { return }
                    try url.extendedAttributes.setData(data, for: "com.apple.icon.folder#S")
                } else {
                    try url.extendedAttributes.remove("com.apple.icon.folder#S")
                }
            } catch {
                Swift.print(error)
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
