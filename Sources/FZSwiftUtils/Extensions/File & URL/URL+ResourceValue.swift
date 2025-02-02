//
//  URL+ResourceValue.swift
//
//
//  Created by Florian Zand on 24.03.23.
//

import Foundation

#if os(macOS) || os(iOS)
    extension PartialKeyPath where Root == URLResourceValues {
        var resourceKey: URLResourceKey? {
            switch self {
            case \.documentIdentifier: return .documentIdentifierKey
            case \.fileResourceIdentifier: return .fileResourceIdentifierKey
            case \.fileAllocatedSize: return .fileAllocatedSizeKey
            case \.fileResourceType: return .fileResourceTypeKey
            case \.fileSecurity: return .fileSecurityKey
            case \.fileSize: return .fileSizeKey
            case \.isExecutable: return .isExecutableKey
            case \.isRegularFile: return .isRegularFileKey
            case \.isDirectory: return .isDirectoryKey
            case \.totalFileAllocatedSize: return .totalFileAllocatedSizeKey
            case \.totalFileSize: return .totalFileSizeKey
            case \.volumeAvailableCapacity: return .volumeAvailableCapacityKey
            case \.volumeAvailableCapacityForImportantUsage: return .volumeAvailableCapacityForImportantUsageKey
            case \.volumeAvailableCapacityForOpportunisticUsage: return .volumeAvailableCapacityForOpportunisticUsageKey
            case \.volumeTotalCapacity: return .volumeTotalCapacityKey
            case \.volumeIsAutomounted: return .volumeIsAutomountedKey
            case \.volumeIsBrowsable: return .volumeIsBrowsableKey
            case \.volumeIsEjectable: return .volumeIsEjectableKey
            case \.volumeIsEncrypted: return .volumeIsEncryptedKey
            case \.volumeIsInternal: return .volumeIsInternalKey
            case \.volumeIsJournaling: return .volumeIsJournalingKey
            case \.volumeIsLocal: return .volumeIsLocalKey
            case \.volumeIsReadOnly: return .volumeIsReadOnlyKey
            case \.volumeIsRemovable: return .volumeIsRemovableKey
            case \.volumeIsRootFileSystem: return .volumeIsRootFileSystemKey
            case \.isMountTrigger: return .isMountTriggerKey
            case \.isVolume: return .isVolumeKey
            case \.volume: return .volumeURLKey
            case \.volumeCreationDate: return .volumeCreationDateKey
            case \.volumeIdentifier: return .volumeIdentifierKey
            case \.volumeLocalizedFormatDescription: return .volumeLocalizedFormatDescriptionKey
            case \.volumeLocalizedName: return .volumeLocalizedNameKey
            case \.volumeMaximumFileSize: return .volumeMaximumFileSizeKey
            case \.volumeName: return .volumeNameKey
            case \.volumeResourceCount: return .volumeResourceCountKey
            case \.volumeSupportsAccessPermissions: return .volumeSupportsAccessPermissionsKey
            case \.volumeSupportsAdvisoryFileLocking: return .volumeSupportsAdvisoryFileLockingKey
            case \.volumeSupportsCasePreservedNames: return .volumeSupportsCasePreservedNamesKey
            case \.volumeSupportsCaseSensitiveNames: return .volumeSupportsCaseSensitiveNamesKey
            case \.volumeSupportsCompression: return .volumeSupportsCompressionKey
            case \.volumeSupportsExclusiveRenaming: return .volumeSupportsExclusiveRenamingKey
            case \.volumeSupportsExtendedSecurity: return .volumeSupportsExtendedSecurityKey
            case \.volumeSupportsFileCloning: return .volumeSupportsFileCloningKey
            case \.volumeSupportsHardLinks: return .volumeSupportsHardLinksKey
            case \.volumeSupportsImmutableFiles: return .volumeSupportsImmutableFilesKey
            case \.volumeSupportsJournaling: return .volumeSupportsJournalingKey
            case \.volumeSupportsPersistentIDs: return .volumeSupportsPersistentIDsKey
            case \.volumeSupportsRenaming: return .volumeSupportsRenamingKey
            case \.volumeSupportsRootDirectoryDates: return .volumeSupportsRootDirectoryDatesKey
            case \.volumeSupportsSparseFiles: return .volumeSupportsSparseFilesKey
            case \.volumeSupportsSwapRenaming: return .volumeSupportsSwapRenamingKey
            case \.volumeSupportsSymbolicLinks: return .volumeSupportsSymbolicLinksKey
            case \.volumeSupportsVolumeSizes: return .volumeSupportsVolumeSizesKey
            case \.volumeSupportsZeroRuns: return .volumeSupportsZeroRunsKey
            case \.volumeURLForRemounting: return .volumeURLForRemountingKey
            case \.volumeUUIDString: return .volumeUUIDStringKey
            case \.isUbiquitousItem: return .isUbiquitousItemKey
            case \.ubiquitousItemIsShared: return .ubiquitousItemIsSharedKey
            case \.ubiquitousSharedItemCurrentUserPermissions: return .ubiquitousSharedItemCurrentUserPermissionsKey
            case \.ubiquitousSharedItemCurrentUserRole: return .ubiquitousSharedItemCurrentUserRoleKey
            case \.ubiquitousSharedItemMostRecentEditorNameComponents: return .ubiquitousSharedItemMostRecentEditorNameComponentsKey
            case \.ubiquitousSharedItemOwnerNameComponents: return .ubiquitousSharedItemOwnerNameComponentsKey
            case \.ubiquitousItemContainerDisplayName: return .ubiquitousItemContainerDisplayNameKey
            case \.ubiquitousItemDownloadRequested: return .ubiquitousItemDownloadRequestedKey
            case \.ubiquitousItemDownloadingError: return .ubiquitousItemDownloadingErrorKey
            case \.ubiquitousItemDownloadingStatus: return .ubiquitousItemDownloadingStatusKey
            case \.ubiquitousItemHasUnresolvedConflicts: return .ubiquitousItemHasUnresolvedConflictsKey
            case \.ubiquitousItemIsDownloading: return .ubiquitousItemIsDownloadingKey
            case \.ubiquitousItemIsUploaded: return .ubiquitousItemIsUploadedKey
            case \.ubiquitousItemIsUploading: return .ubiquitousItemIsUploadingKey
            case \.ubiquitousItemUploadingError: return .ubiquitousItemUploadingErrorKey
            case \.thumbnailDictionary: return .thumbnailDictionaryKey
            case \.thumbnailDictionary: return .thumbnailDictionaryKey
            case \.addedToDirectoryDate: return .addedToDirectoryDateKey
            case \.attributeModificationDate: return .attributeModificationDateKey
            case \.canonicalPath: return .canonicalPathKey
            case \.contentAccessDate: return .contentAccessDateKey
            case \.contentModificationDate: return .contentModificationDateKey
            case \.creationDate: return .creationDateKey
            case \.generationIdentifier: return .generationIdentifierKey
            case \.hasHiddenExtension: return .hasHiddenExtensionKey
            case \.isAliasFile: return .isAliasFileKey
            case \.isExcludedFromBackup: return .isExcludedFromBackupKey
            case \.isHidden: return .isHiddenKey
            case \.isPackage: return .isPackageKey
            case \.isReadable: return .isReadableKey
            case \.isSymbolicLink: return .isSymbolicLinkKey
            case \.isSystemImmutable: return .isSystemImmutableKey
            case \.isUserImmutable: return .isUserImmutableKey
            case \.isWritable: return .isWritableKey
            case \.labelNumber: return .labelNumberKey
            case \.linkCount: return .linkCountKey
            case \.localizedLabel: return .localizedLabelKey
            case \.localizedName: return .localizedNameKey
            case \.localizedTypeDescription: return .localizedTypeDescriptionKey
            case \.name: return .nameKey
            case \.parentDirectory: return .parentDirectoryURLKey
            case \.path: return .pathKey
            case \.preferredIOBlockSize: return .preferredIOBlockSizeKey
            case \.typeIdentifier: return .typeIdentifierKey
            default: break
            }

            #if os(macOS)
                switch self {
                case \.thumbnail: return .thumbnailKey
                case \.customIcon: return .customIconKey
                case \.effectiveIcon: return .effectiveIconKey
                case \.labelColor: return .labelColorKey
                case \.quarantineProperties: return .quarantinePropertiesKey
                case \.tagNames: return .tagNamesKey
                default: break
                }
            #endif

            if #available(macOS 11.3, iOS 14.5, *) {
                switch self {
                case \.ubiquitousItemIsExcludedFromSync: return .ubiquitousItemIsExcludedFromSyncKey
                default: break
                }
            }

            if #available(macOS 11.0, iOS 14.0, *) {
                switch self {
                case \.mayShareFileContent: return .mayShareFileContentKey
                case \.mayHaveExtendedAttributes: return .mayHaveExtendedAttributesKey
                case \.isPurgeable: return .isPurgeableKey
                case \.isSparse: return .isSparseKey
                case \.fileContentIdentifier: return .fileContentIdentifierKey
                case \.fileProtection: return .fileProtectionKey
                case \.contentType: return .contentTypeKey
                default: break
                }
            }
            return nil
        }
    }

#elseif os(tvOS) || os(watchOS)
    extension PartialKeyPath where Root == URLResourceValues {
        var resourceKey: URLResourceKey? {
            switch self {
            case \.documentIdentifier: return .documentIdentifierKey
            case \.fileResourceIdentifier: return .fileResourceIdentifierKey
            case \.fileAllocatedSize: return .fileAllocatedSizeKey
            case \.fileResourceType: return .fileResourceTypeKey
            case \.fileSecurity: return .fileSecurityKey
            case \.fileSize: return .fileSizeKey
            case \.isExecutable: return .isExecutableKey
            case \.isRegularFile: return .isRegularFileKey
            case \.isDirectory: return .isDirectoryKey
            case \.totalFileAllocatedSize: return .totalFileAllocatedSizeKey
            case \.totalFileSize: return .totalFileSizeKey
            case \.volumeAvailableCapacity: return .volumeAvailableCapacityKey
            case \.volumeTotalCapacity: return .volumeTotalCapacityKey
            case \.volumeIsAutomounted: return .volumeIsAutomountedKey
            case \.volumeIsBrowsable: return .volumeIsBrowsableKey
            case \.volumeIsEjectable: return .volumeIsEjectableKey
            case \.volumeIsEncrypted: return .volumeIsEncryptedKey
            case \.volumeIsInternal: return .volumeIsInternalKey
            case \.volumeIsJournaling: return .volumeIsJournalingKey
            case \.volumeIsLocal: return .volumeIsLocalKey
            case \.volumeIsReadOnly: return .volumeIsReadOnlyKey
            case \.volumeIsRemovable: return .volumeIsRemovableKey
            case \.volumeIsRootFileSystem: return .volumeIsRootFileSystemKey
            case \.isMountTrigger: return .isMountTriggerKey
            case \.isVolume: return .isVolumeKey
            case \.volume: return .volumeURLKey
            case \.volumeCreationDate: return .volumeCreationDateKey
            case \.volumeIdentifier: return .volumeIdentifierKey
            case \.volumeLocalizedFormatDescription: return .volumeLocalizedFormatDescriptionKey
            case \.volumeLocalizedName: return .volumeLocalizedNameKey
            case \.volumeMaximumFileSize: return .volumeMaximumFileSizeKey
            case \.volumeName: return .volumeNameKey
            case \.volumeResourceCount: return .volumeResourceCountKey
            case \.volumeSupportsAccessPermissions: return .volumeSupportsAccessPermissionsKey
            case \.volumeSupportsAdvisoryFileLocking: return .volumeSupportsAdvisoryFileLockingKey
            case \.volumeSupportsCasePreservedNames: return .volumeSupportsCasePreservedNamesKey
            case \.volumeSupportsCaseSensitiveNames: return .volumeSupportsCaseSensitiveNamesKey
            case \.volumeSupportsCompression: return .volumeSupportsCompressionKey
            case \.volumeSupportsExclusiveRenaming: return .volumeSupportsExclusiveRenamingKey
            case \.volumeSupportsExtendedSecurity: return .volumeSupportsExtendedSecurityKey
            case \.volumeSupportsFileCloning: return .volumeSupportsFileCloningKey
            case \.volumeSupportsHardLinks: return .volumeSupportsHardLinksKey
            case \.volumeSupportsImmutableFiles: return .volumeSupportsImmutableFilesKey
            case \.volumeSupportsJournaling: return .volumeSupportsJournalingKey
            case \.volumeSupportsPersistentIDs: return .volumeSupportsPersistentIDsKey
            case \.volumeSupportsRenaming: return .volumeSupportsRenamingKey
            case \.volumeSupportsRootDirectoryDates: return .volumeSupportsRootDirectoryDatesKey
            case \.volumeSupportsSparseFiles: return .volumeSupportsSparseFilesKey
            case \.volumeSupportsSwapRenaming: return .volumeSupportsSwapRenamingKey
            case \.volumeSupportsSymbolicLinks: return .volumeSupportsSymbolicLinksKey
            case \.volumeSupportsVolumeSizes: return .volumeSupportsVolumeSizesKey
            case \.volumeSupportsZeroRuns: return .volumeSupportsZeroRunsKey
            case \.volumeURLForRemounting: return .volumeURLForRemountingKey
            case \.volumeUUIDString: return .volumeUUIDStringKey
            case \.isUbiquitousItem: return .isUbiquitousItemKey
            case \.ubiquitousItemContainerDisplayName: return .ubiquitousItemContainerDisplayNameKey
            case \.ubiquitousItemDownloadRequested: return .ubiquitousItemDownloadRequestedKey
            case \.ubiquitousItemDownloadingError: return .ubiquitousItemDownloadingErrorKey
            case \.ubiquitousItemDownloadingStatus: return .ubiquitousItemDownloadingStatusKey
            case \.ubiquitousItemHasUnresolvedConflicts: return .ubiquitousItemHasUnresolvedConflictsKey
            case \.ubiquitousItemIsDownloading: return .ubiquitousItemIsDownloadingKey
            case \.ubiquitousItemIsUploaded: return .ubiquitousItemIsUploadedKey
            case \.ubiquitousItemIsUploading: return .ubiquitousItemIsUploadingKey
            case \.ubiquitousItemUploadingError: return .ubiquitousItemUploadingErrorKey
            case \.thumbnailDictionary: return .thumbnailDictionaryKey
            case \.thumbnailDictionary: return .thumbnailDictionaryKey
            case \.addedToDirectoryDate: return .addedToDirectoryDateKey
            case \.attributeModificationDate: return .attributeModificationDateKey
            case \.canonicalPath: return .canonicalPathKey
            case \.contentAccessDate: return .contentAccessDateKey
            case \.contentModificationDate: return .contentModificationDateKey
            case \.creationDate: return .creationDateKey
            case \.generationIdentifier: return .generationIdentifierKey
            case \.hasHiddenExtension: return .hasHiddenExtensionKey
            case \.isAliasFile: return .isAliasFileKey
            case \.isExcludedFromBackup: return .isExcludedFromBackupKey
            case \.isHidden: return .isHiddenKey
            case \.isPackage: return .isPackageKey
            case \.isReadable: return .isReadableKey
            case \.isSymbolicLink: return .isSymbolicLinkKey
            case \.isSystemImmutable: return .isSystemImmutableKey
            case \.isUserImmutable: return .isUserImmutableKey
            case \.isWritable: return .isWritableKey
            case \.labelNumber: return .labelNumberKey
            case \.linkCount: return .linkCountKey
            case \.localizedLabel: return .localizedLabelKey
            case \.localizedName: return .localizedNameKey
            case \.localizedTypeDescription: return .localizedTypeDescriptionKey
            case \.name: return .nameKey
            case \.parentDirectory: return .parentDirectoryURLKey
            case \.path: return .pathKey
            case \.preferredIOBlockSize: return .preferredIOBlockSizeKey
            case \.typeIdentifier: return .typeIdentifierKey
            case \.fileProtection: return .fileProtectionKey
            default: break
            }
            if #available(watchOS 7.0, *) {
                switch self {
                case \.mayShareFileContent: return .mayShareFileContentKey
                case \.mayHaveExtendedAttributes: return .mayHaveExtendedAttributesKey
                case \.isPurgeable: return .isPurgeableKey
                case \.isSparse: return .isSparseKey
                case \.fileContentIdentifier: return .fileContentIdentifierKey
                case \.contentType: return .contentTypeKey
                default: break
                }
            }
            return nil
        }
    }
#endif
