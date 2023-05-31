//
//  URL+Resource.swift
//  FinalImageCollectionView
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
    var resources: URLResources {
        return URLResources(url: self)
    }
}

/**
 The properties that the file system resources support.

 Not all property values exist for all file system URLs. For example, if a file is located on a volume that doesn’t support creation dates, you can request the creation date property, but the request returns nil and doesn’t generate an error.
 Only the fields requested by the keys you pass into the URL function to receive this value will be populated. The other fields return nil regardless of the underlying property on the file system.

 As a convenience, you can request volume resource values from any file system URL by using the volume property. The value returned reflects the property values for the volume that the resource is located on.
 */
public class URLResources {
    private(set) var url: URL
    init(url: URL) {
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

    public var name: String? {
        get { return try? value(for: \.name) }
        set { try? setValue(newValue, for: \.name) }
    }

    public var localizedName: String? { return try? value(for: \.localizedName) }

    public var isRegularFile: Bool { return (try? value(for: \.isRegularFile)) ?? false }

    public var isDirectory: Bool { return (try? value(for: \.isDirectory)) ?? false }

    public var isSymbolicLink: Bool { return (try? value(for: \.isSymbolicLink)) ?? false }

    public var isVolume: Bool { return (try? value(for: \.isVolume)) ?? false }

    public var isPackage: Bool {
        get { (try? value(for: \.isPackage)) ?? false }
        set { try? setValue(newValue, for: \.isPackage) }
    }

    @available(macOS 10.11, iOS 9.0, *)
    public var isApplication: Bool { (try? value(for: \.isApplication)) ?? false }

    public var isSystemImmutable: Bool { (try? value(for: \.isSystemImmutable)) ?? false }

    public var isUserImmutable: Bool {
        get { (try? value(for: \.isUserImmutable)) ?? false }
        set { try? setValue(newValue, for: \.isUserImmutable) }
    }

    public var isHidden: Bool {
        get { (try? value(for: \.isHidden)) ?? false }
        set { try? setValue(newValue, for: \.isHidden) }
    }

    public var hasHiddenExtension: Bool {
        get { (try? value(for: \.hasHiddenExtension)) ?? false }
        set { try? setValue(newValue, for: \.hasHiddenExtension) }
    }

    public var creationDate: Date? {
        get { try? value(for: \.creationDate) }
        set { try? setValue(newValue, for: \.creationDate) }
    }

    public var addedToDirectoryDate: Date? { try? value(for: \.addedToDirectoryDate) }

    public var contentAccessDate: Date? {
        get { try? value(for: \.contentAccessDate) }
        set { try? setValue(newValue, for: \.contentAccessDate) }
    }

    public var contentModificationDate: Date? {
        get { try? value(for: \.contentModificationDate) }
        set { try? setValue(newValue, for: \.contentModificationDate) }
    }

    public var attributeModificationDate: Date? { try? value(for: \.attributeModificationDate) }

    public var linkCount: Int? { try? value(for: \.linkCount) }

    public var parentDirectory: URL? {
        get { try? value(for: \.parentDirectory) }
        set {
            if var newParentDirectory = newValue {
                newParentDirectory.appendPathComponent(url.lastPathComponent)
                try? FileManager.default.moveItem(at: url, to: newParentDirectory)
            }
        }
    }

    public var localizedTypeDescription: String? { try? value(for: \.localizedTypeDescription) }

    public var labelNumber: Int? {
        get { try? value(for: \.labelNumber) }
        set { try? setValue(newValue, for: \.labelNumber) }
    }

    public var localizedLabel: String? { try? value(for: \.localizedLabel) }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var fileContentIdentifier: Int64? { try? value(for: \.fileContentIdentifier) }

    public var preferredIOBlockSize: Int? { try? value(for: \.preferredIOBlockSize) }

    public var isReadable: Bool? { try? value(for: \.isReadable) }

    public var isWritable: Bool? { try? value(for: \.isWritable) }

    public var isExecutable: Bool? { try? value(for: \.isExecutable) }

    public var fileSecurity: NSFileSecurity? {
        get { try? value(for: \.fileSecurity) }
        set { try? setValue(newValue, for: \.fileSecurity) }
    }

    public var isExcludedFromBackup: Bool? {
        get { try? value(for: \.isExcludedFromBackup) }
        set { try? setValue(newValue, for: \.isExcludedFromBackup) }
    }

    public var path: String? { try? value(for: \.path) }

    @available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    public var canonicalPath: String? { try? value(for: \.canonicalPath) }

    public var isMountTrigger: Bool? { try? value(for: \.isMountTrigger) }

    @available(macOS 10.10, iOS 8.0, *)
    public var generationIdentifier: (NSCopying & NSSecureCoding & NSObjectProtocol)? { try? value(for: \.generationIdentifier) }

    @available(macOS 10.10, iOS 8.0, *)
    public var documentIdentifier: Int? { try? value(for: \.documentIdentifier) }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var mayHaveExtendedAttributes: Bool { (try? value(for: \.mayHaveExtendedAttributes)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var isPurgeable: Bool { (try? value(for: \.isPurgeable)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var isSparse: Bool { (try? value(for: \.isSparse)) ?? false }

    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public var mayShareFileContent: Bool { (try? value(for: \.mayShareFileContent)) ?? false }

    public var fileResourceType: URLFileResourceType? { try? value(for: \.fileResourceType) }

    public var isUbiquitousItem: Bool { (try? value(for: \.isUbiquitousItem)) ?? false }

    public var ubiquitousItemHasUnresolvedConflicts: Bool { (try? value(for: \.ubiquitousItemHasUnresolvedConflicts)) ?? false }

    public var ubiquitousItemIsDownloading: Bool { (try? value(for: \.ubiquitousItemIsDownloading)) ?? false }

    public var ubiquitousItemIsUploaded: Bool { (try? value(for: \.ubiquitousItemIsUploaded)) ?? false }

    public var ubiquitousItemIsUploading: Bool { (try? value(for: \.ubiquitousItemIsUploading)) ?? false }

    public var ubiquitousItemDownloadingStatus: URLUbiquitousItemDownloadingStatus? { try? value(for: \.ubiquitousItemDownloadingStatus) }

    @available(macOS 11.0, iOS 9.0, *)
    public var fileProtection: URLFileProtection? { try? value(for: \.fileProtection) }

    public var fileSize: DataSize? { guard let bytes = fileSizeBytes else { return nil }
        return DataSize(bytes)
    }

    public var fileAllocatedSize: DataSize? { guard let bytes = fileAllocatedSizeBytes else { return nil }
        return DataSize(bytes)
    }

    public var totalFileSize: DataSize? { guard let bytes = totalFileSizeBytes else { return nil }
        return DataSize(bytes)
    }

    public var totalFileAllocatedSize: DataSize? { guard let bytes = totalFileAllocatedSizeBytes else { return nil }
        return DataSize(bytes)
    }

    internal var fileSizeBytes: Int? { try? value(for: \.fileSize) }

    internal var fileAllocatedSizeBytes: Int? { try? value(for: \.fileAllocatedSize) }

    internal var totalFileSizeBytes: Int? { try? value(for: \.totalFileSize) }

    internal var totalFileAllocatedSizeBytes: Int? { try? value(for: \.totalFileAllocatedSize) }

    public var isAliasFile: Bool { (try? value(for: \.isAliasFile)) ?? false }

    #if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public var contentType: UTType? { try? value(for: \.contentType) }
    #endif
}

@available(macOS, deprecated: 11.0, message: "Use contentType instead")
@available(iOS, deprecated: 14.0, message: "Use contentType instead")
@available(macCatalyst, deprecated: 14.0, message: "Use contentType instead")
@available(tvOS, deprecated: 14.0, message: "Use contentType instead")
@available(watchOS, deprecated: 7.0, message: "Use contentType instead")
extension URLResources {
    public var contentTypeIdentifier: String? { try? value(for: \.typeIdentifier) }

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
    /// True if the resource is scriptable. Only applies to applications.
    @available(macOS 10.11, *)
    var applicationIsScriptable: Bool { (try? value(for: \.applicationIsScriptable)) ?? false }

    @available(macOS 12.0, *)
    var supportedApplicationURLs: [URL]? {
        return contentType?.supportedApplicationURLs
    }

    @available(macOS 10.10, *)
    var quarantineProperties: [String: Any]? {
        get { try? value(for: \.quarantineProperties) }
        set { try? setValue(newValue, for: \.quarantineProperties) }
    }

    @available(macOS 10.9, *)
    var tags: [String] {
        get { (try? value(for: \.tagNames)) ?? [] }
        set {
            let newTags = newValue.compactMap { (String($0.suffix(3)) != "\n6") ? ($0 + "\n6") : $0 }
            url.extendedAttributes["com.apple.metadata:kMDItemUserTags"] = newTags.uniqued()
        }
    }

    var whereFroms: [String]? {
        get { return url.extendedAttributes["com.apple.metadata:kMDItemWhereFroms"] }
        set { url.extendedAttributes["com.apple.metadata:kMDItemWhereFroms"] = newValue }
    }

    var downloadDate: Date? {
        get { return url.extendedAttributes["com.apple.metadata:kMDItemDownloadedDate"] }
        set { url.extendedAttributes["com.apple.metadata:kMDItemDownloadedDate"] = newValue }
    }

    var customIcon: NSUIImage? { try? value(for: \.customIcon) }

    var effectiveIcon: NSUIImage? { (try? value(for: \.effectiveIcon)) as? NSUIImage }

    var labelColor: NSUIColor? { try? value(for: \.labelColor) }
}
#endif

public extension URLResources {
    var volume: VolumeURLResources {
        return VolumeURLResources(url)
    }

    struct VolumeURLResources {
        internal let _url: URL
        public init(_ _url: URL) {
            self._url = _url
        }

        public var url: URL? {
            return try? _url.resourceValues(for: .volumeURLKey).volume
        }

        public var name: String? { return try? _url.resourceValues(for: .volumeNameKey).volumeName
        }

        public var localizedName: String? { return try? _url.resourceValues(for: .volumeLocalizedNameKey).volumeLocalizedName
        }

        public var uuid: String? { return try? _url.resourceValues(for: .volumeUUIDStringKey).volumeUUIDString
        }

        public var resourceCount: Int? { return try? _url.resourceValues(for: .volumeResourceCountKey).volumeResourceCount
        }

        public var creationDate: Date? { return try? _url.resourceValues(for: .volumeCreationDateKey).volumeCreationDate
        }

        public var isReadOnly: Bool { return (try? _url.resourceValues(for: .volumeIsReadOnlyKey).volumeIsReadOnly) ?? true
        }

        public var supportsAccessPermissions: Bool { return (try? _url.resourceValues(for: .volumeSupportsAccessPermissionsKey).volumeSupportsAccessPermissions) ?? false
        }

        public var supportsRenaming: Bool { return (try? _url.resourceValues(for: .volumeSupportsRenamingKey).volumeSupportsRenaming) ?? false
        }

        public var supportsSymbolicLinks: Bool { return (try? _url.resourceValues(for: .volumeSupportsSymbolicLinksKey).volumeSupportsSymbolicLinks) ?? false
        }

        public var isRemovable: Bool { return (try? _url.resourceValues(for: .volumeIsRemovableKey).volumeIsRemovable) ?? false
        }

        public var isEjectable: Bool { return (try? _url.resourceValues(for: .volumeIsEjectableKey).volumeIsEjectable) ?? false
        }

        public var isRootFileSystem: Bool { return (try? _url.resourceValues(for: .volumeIsRootFileSystemKey).volumeIsRootFileSystem) ?? false
        }

        public var availableCapacity: DataSize? {
            if let bytes = try? _url.resourceValues(for: .volumeAvailableCapacityKey).volumeAvailableCapacity {
                return DataSize(bytes)
            }
            return nil
        }

        public var totalCapacity: DataSize? {
            if let bytes = try? _url.resourceValues(for: .volumeTotalCapacityKey).volumeTotalCapacity {
                return DataSize(bytes)
            }
            return nil
        }
    }
}
