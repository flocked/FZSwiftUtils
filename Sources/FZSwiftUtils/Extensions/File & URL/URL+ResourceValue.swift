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
            case \Root.documentIdentifier: return .documentIdentifierKey
            case \Root.fileResourceIdentifier: return .fileResourceIdentifierKey
            case \Root.fileAllocatedSize: return .fileAllocatedSizeKey
            case \Root.fileResourceType: return .fileResourceTypeKey
            case \Root.fileSecurity: return .fileSecurityKey
            case \Root.fileSize: return .fileSizeKey
            case \Root.isExecutable: return .isExecutableKey
            case \Root.isRegularFile: return .isRegularFileKey
            case \Root.isDirectory: return .isDirectoryKey
            case \Root.totalFileAllocatedSize: return .totalFileAllocatedSizeKey
            case \Root.totalFileSize: return .totalFileSizeKey
            case \Root.volumeAvailableCapacity: return .volumeAvailableCapacityKey
            case \Root.volumeAvailableCapacityForImportantUsage: return .volumeAvailableCapacityForImportantUsageKey
            case \Root.volumeAvailableCapacityForOpportunisticUsage: return .volumeAvailableCapacityForOpportunisticUsageKey
            case \Root.volumeTotalCapacity: return .volumeTotalCapacityKey
            case \Root.volumeIsAutomounted: return .volumeIsAutomountedKey
            case \Root.volumeIsBrowsable: return .volumeIsBrowsableKey
            case \Root.volumeIsEjectable: return .volumeIsEjectableKey
            case \Root.volumeIsEncrypted: return .volumeIsEncryptedKey
            case \Root.volumeIsInternal: return .volumeIsInternalKey
            case \Root.volumeIsJournaling: return .volumeIsJournalingKey
            case \Root.volumeIsLocal: return .volumeIsLocalKey
            case \Root.volumeIsReadOnly: return .volumeIsReadOnlyKey
            case \Root.volumeIsRemovable: return .volumeIsRemovableKey
            case \Root.volumeIsRootFileSystem: return .volumeIsRootFileSystemKey
            case \Root.isMountTrigger: return .isMountTriggerKey
            case \Root.isVolume: return .isVolumeKey
            case \Root.volume: return .volumeURLKey
            case \Root.volumeCreationDate: return .volumeCreationDateKey
            case \Root.volumeIdentifier: return .volumeIdentifierKey
            case \Root.volumeLocalizedFormatDescription: return .volumeLocalizedFormatDescriptionKey
            case \Root.volumeLocalizedName: return .volumeLocalizedNameKey
            case \Root.volumeMaximumFileSize: return .volumeMaximumFileSizeKey
            case \Root.volumeName: return .volumeNameKey
            case \Root.volumeResourceCount: return .volumeResourceCountKey
            case \Root.volumeSupportsAccessPermissions: return .volumeSupportsAccessPermissionsKey
            case \Root.volumeSupportsAdvisoryFileLocking: return .volumeSupportsAdvisoryFileLockingKey
            case \Root.volumeSupportsCasePreservedNames: return .volumeSupportsCasePreservedNamesKey
            case \Root.volumeSupportsCaseSensitiveNames: return .volumeSupportsCaseSensitiveNamesKey
            case \Root.volumeSupportsCompression: return .volumeSupportsCompressionKey
            case \Root.volumeSupportsExclusiveRenaming: return .volumeSupportsExclusiveRenamingKey
            case \Root.volumeSupportsExtendedSecurity: return .volumeSupportsExtendedSecurityKey
            case \Root.volumeSupportsFileCloning: return .volumeSupportsFileCloningKey
            case \Root.volumeSupportsHardLinks: return .volumeSupportsHardLinksKey
            case \Root.volumeSupportsImmutableFiles: return .volumeSupportsImmutableFilesKey
            case \Root.volumeSupportsJournaling: return .volumeSupportsJournalingKey
            case \Root.volumeSupportsPersistentIDs: return .volumeSupportsPersistentIDsKey
            case \Root.volumeSupportsRenaming: return .volumeSupportsRenamingKey
            case \Root.volumeSupportsRootDirectoryDates: return .volumeSupportsRootDirectoryDatesKey
            case \Root.volumeSupportsSparseFiles: return .volumeSupportsSparseFilesKey
            case \Root.volumeSupportsSwapRenaming: return .volumeSupportsSwapRenamingKey
            case \Root.volumeSupportsSymbolicLinks: return .volumeSupportsSymbolicLinksKey
            case \Root.volumeSupportsVolumeSizes: return .volumeSupportsVolumeSizesKey
            case \Root.volumeSupportsZeroRuns: return .volumeSupportsZeroRunsKey
            case \Root.volumeURLForRemounting: return .volumeURLForRemountingKey
            case \Root.volumeUUIDString: return .volumeUUIDStringKey
            case \Root.isUbiquitousItem: return .isUbiquitousItemKey
            case \Root.ubiquitousItemIsShared: return .ubiquitousItemIsSharedKey
            case \Root.ubiquitousSharedItemCurrentUserPermissions: return .ubiquitousSharedItemCurrentUserPermissionsKey
            case \Root.ubiquitousSharedItemCurrentUserRole: return .ubiquitousSharedItemCurrentUserRoleKey
            case \Root.ubiquitousSharedItemMostRecentEditorNameComponents: return .ubiquitousSharedItemMostRecentEditorNameComponentsKey
            case \Root.ubiquitousSharedItemOwnerNameComponents: return .ubiquitousSharedItemOwnerNameComponentsKey
            case \Root.ubiquitousItemContainerDisplayName: return .ubiquitousItemContainerDisplayNameKey
            case \Root.ubiquitousItemDownloadRequested: return .ubiquitousItemDownloadRequestedKey
            case \Root.ubiquitousItemDownloadingError: return .ubiquitousItemDownloadingErrorKey
            case \Root.ubiquitousItemDownloadingStatus: return .ubiquitousItemDownloadingStatusKey
            case \Root.ubiquitousItemHasUnresolvedConflicts: return .ubiquitousItemHasUnresolvedConflictsKey
            case \Root.ubiquitousItemIsDownloading: return .ubiquitousItemIsDownloadingKey
            case \Root.ubiquitousItemIsUploaded: return .ubiquitousItemIsUploadedKey
            case \Root.ubiquitousItemIsUploading: return .ubiquitousItemIsUploadingKey
            case \Root.ubiquitousItemUploadingError: return .ubiquitousItemUploadingErrorKey
            case \Root.thumbnailDictionary: return .thumbnailDictionaryKey
            case \Root.thumbnailDictionary: return .thumbnailDictionaryKey
            case \Root.addedToDirectoryDate: return .addedToDirectoryDateKey
            case \Root.attributeModificationDate: return .attributeModificationDateKey
            case \Root.canonicalPath: return .canonicalPathKey
            case \Root.contentAccessDate: return .contentAccessDateKey
            case \Root.contentModificationDate: return .contentModificationDateKey
            case \Root.creationDate: return .creationDateKey
            case \Root.generationIdentifier: return .generationIdentifierKey
            case \Root.hasHiddenExtension: return .hasHiddenExtensionKey
            case \Root.isAliasFile: return .isAliasFileKey
            case \Root.isExcludedFromBackup: return .isExcludedFromBackupKey
            case \Root.isHidden: return .isHiddenKey
            case \Root.isPackage: return .isPackageKey
            case \Root.isReadable: return .isReadableKey
            case \Root.isSymbolicLink: return .isSymbolicLinkKey
            case \Root.isSystemImmutable: return .isSystemImmutableKey
            case \Root.isUserImmutable: return .isUserImmutableKey
            case \Root.isWritable: return .isWritableKey
            case \Root.labelNumber: return .labelNumberKey
            case \Root.linkCount: return .linkCountKey
            case \Root.localizedLabel: return .localizedLabelKey
            case \Root.localizedName: return .localizedNameKey
            case \Root.localizedTypeDescription: return .localizedTypeDescriptionKey
            case \Root.name: return .nameKey
            case \Root.parentDirectory: return .parentDirectoryURLKey
            case \Root.path: return .pathKey
            case \Root.preferredIOBlockSize: return .preferredIOBlockSizeKey
            case \Root.typeIdentifier: return .typeIdentifierKey
            default: break
            }

            #if os(macOS)
                switch self {
                case \Root.thumbnail: return .thumbnailKey
                case \Root.customIcon: return .customIconKey
                case \Root.effectiveIcon: return .effectiveIconKey
                case \Root.labelColor: return .labelColorKey
                case \Root.quarantineProperties: return .quarantinePropertiesKey
                case \Root.tagNames: return .tagNamesKey
                default: break
                }
            #endif

            if #available(macOS 11.3, iOS 14.5, *) {
                switch self {
                case \Root.ubiquitousItemIsExcludedFromSync: return .ubiquitousItemIsExcludedFromSyncKey
                default: break
                }
            }

            if #available(macOS 11.0, iOS 14.0, *) {
                switch self {
                case \Root.mayShareFileContent: return .mayShareFileContentKey
                case \Root.mayHaveExtendedAttributes: return .mayHaveExtendedAttributesKey
                case \Root.isPurgeable: return .isPurgeableKey
                case \Root.isSparse: return .isSparseKey
                case \Root.fileContentIdentifier: return .fileContentIdentifierKey
                case \Root.fileProtection: return .fileProtectionKey
                case \Root.contentType: return .contentTypeKey
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
            case \Root.documentIdentifier: return .documentIdentifierKey
            case \Root.fileResourceIdentifier: return .fileResourceIdentifierKey
            case \Root.fileAllocatedSize: return .fileAllocatedSizeKey
            case \Root.fileResourceType: return .fileResourceTypeKey
            case \Root.fileSecurity: return .fileSecurityKey
            case \Root.fileSize: return .fileSizeKey
            case \Root.isExecutable: return .isExecutableKey
            case \Root.isRegularFile: return .isRegularFileKey
            case \Root.isDirectory: return .isDirectoryKey
            case \Root.totalFileAllocatedSize: return .totalFileAllocatedSizeKey
            case \Root.totalFileSize: return .totalFileSizeKey
            case \Root.volumeAvailableCapacity: return .volumeAvailableCapacityKey
            case \Root.volumeTotalCapacity: return .volumeTotalCapacityKey
            case \Root.volumeIsAutomounted: return .volumeIsAutomountedKey
            case \Root.volumeIsBrowsable: return .volumeIsBrowsableKey
            case \Root.volumeIsEjectable: return .volumeIsEjectableKey
            case \Root.volumeIsEncrypted: return .volumeIsEncryptedKey
            case \Root.volumeIsInternal: return .volumeIsInternalKey
            case \Root.volumeIsJournaling: return .volumeIsJournalingKey
            case \Root.volumeIsLocal: return .volumeIsLocalKey
            case \Root.volumeIsReadOnly: return .volumeIsReadOnlyKey
            case \Root.volumeIsRemovable: return .volumeIsRemovableKey
            case \Root.volumeIsRootFileSystem: return .volumeIsRootFileSystemKey
            case \Root.isMountTrigger: return .isMountTriggerKey
            case \Root.isVolume: return .isVolumeKey
            case \Root.volume: return .volumeURLKey
            case \Root.volumeCreationDate: return .volumeCreationDateKey
            case \Root.volumeIdentifier: return .volumeIdentifierKey
            case \Root.volumeLocalizedFormatDescription: return .volumeLocalizedFormatDescriptionKey
            case \Root.volumeLocalizedName: return .volumeLocalizedNameKey
            case \Root.volumeMaximumFileSize: return .volumeMaximumFileSizeKey
            case \Root.volumeName: return .volumeNameKey
            case \Root.volumeResourceCount: return .volumeResourceCountKey
            case \Root.volumeSupportsAccessPermissions: return .volumeSupportsAccessPermissionsKey
            case \Root.volumeSupportsAdvisoryFileLocking: return .volumeSupportsAdvisoryFileLockingKey
            case \Root.volumeSupportsCasePreservedNames: return .volumeSupportsCasePreservedNamesKey
            case \Root.volumeSupportsCaseSensitiveNames: return .volumeSupportsCaseSensitiveNamesKey
            case \Root.volumeSupportsCompression: return .volumeSupportsCompressionKey
            case \Root.volumeSupportsExclusiveRenaming: return .volumeSupportsExclusiveRenamingKey
            case \Root.volumeSupportsExtendedSecurity: return .volumeSupportsExtendedSecurityKey
            case \Root.volumeSupportsFileCloning: return .volumeSupportsFileCloningKey
            case \Root.volumeSupportsHardLinks: return .volumeSupportsHardLinksKey
            case \Root.volumeSupportsImmutableFiles: return .volumeSupportsImmutableFilesKey
            case \Root.volumeSupportsJournaling: return .volumeSupportsJournalingKey
            case \Root.volumeSupportsPersistentIDs: return .volumeSupportsPersistentIDsKey
            case \Root.volumeSupportsRenaming: return .volumeSupportsRenamingKey
            case \Root.volumeSupportsRootDirectoryDates: return .volumeSupportsRootDirectoryDatesKey
            case \Root.volumeSupportsSparseFiles: return .volumeSupportsSparseFilesKey
            case \Root.volumeSupportsSwapRenaming: return .volumeSupportsSwapRenamingKey
            case \Root.volumeSupportsSymbolicLinks: return .volumeSupportsSymbolicLinksKey
            case \Root.volumeSupportsVolumeSizes: return .volumeSupportsVolumeSizesKey
            case \Root.volumeSupportsZeroRuns: return .volumeSupportsZeroRunsKey
            case \Root.volumeURLForRemounting: return .volumeURLForRemountingKey
            case \Root.volumeUUIDString: return .volumeUUIDStringKey
            case \Root.isUbiquitousItem: return .isUbiquitousItemKey
            case \Root.ubiquitousItemContainerDisplayName: return .ubiquitousItemContainerDisplayNameKey
            case \Root.ubiquitousItemDownloadRequested: return .ubiquitousItemDownloadRequestedKey
            case \Root.ubiquitousItemDownloadingError: return .ubiquitousItemDownloadingErrorKey
            case \Root.ubiquitousItemDownloadingStatus: return .ubiquitousItemDownloadingStatusKey
            case \Root.ubiquitousItemHasUnresolvedConflicts: return .ubiquitousItemHasUnresolvedConflictsKey
            case \Root.ubiquitousItemIsDownloading: return .ubiquitousItemIsDownloadingKey
            case \Root.ubiquitousItemIsUploaded: return .ubiquitousItemIsUploadedKey
            case \Root.ubiquitousItemIsUploading: return .ubiquitousItemIsUploadingKey
            case \Root.ubiquitousItemUploadingError: return .ubiquitousItemUploadingErrorKey
            case \Root.thumbnailDictionary: return .thumbnailDictionaryKey
            case \Root.thumbnailDictionary: return .thumbnailDictionaryKey
            case \Root.addedToDirectoryDate: return .addedToDirectoryDateKey
            case \Root.attributeModificationDate: return .attributeModificationDateKey
            case \Root.canonicalPath: return .canonicalPathKey
            case \Root.contentAccessDate: return .contentAccessDateKey
            case \Root.contentModificationDate: return .contentModificationDateKey
            case \Root.creationDate: return .creationDateKey
            case \Root.generationIdentifier: return .generationIdentifierKey
            case \Root.hasHiddenExtension: return .hasHiddenExtensionKey
            case \Root.isAliasFile: return .isAliasFileKey
            case \Root.isExcludedFromBackup: return .isExcludedFromBackupKey
            case \Root.isHidden: return .isHiddenKey
            case \Root.isPackage: return .isPackageKey
            case \Root.isReadable: return .isReadableKey
            case \Root.isSymbolicLink: return .isSymbolicLinkKey
            case \Root.isSystemImmutable: return .isSystemImmutableKey
            case \Root.isUserImmutable: return .isUserImmutableKey
            case \Root.isWritable: return .isWritableKey
            case \Root.labelNumber: return .labelNumberKey
            case \Root.linkCount: return .linkCountKey
            case \Root.localizedLabel: return .localizedLabelKey
            case \Root.localizedName: return .localizedNameKey
            case \Root.localizedTypeDescription: return .localizedTypeDescriptionKey
            case \Root.name: return .nameKey
            case \Root.parentDirectory: return .parentDirectoryURLKey
            case \Root.path: return .pathKey
            case \Root.preferredIOBlockSize: return .preferredIOBlockSizeKey
            case \Root.typeIdentifier: return .typeIdentifierKey
            case \Root.fileProtection: return .fileProtectionKey
            default: break
            }
            if #available(watchOS 7.0, *) {
                switch self {
                case \Root.mayShareFileContent: return .mayShareFileContentKey
                case \Root.mayHaveExtendedAttributes: return .mayHaveExtendedAttributesKey
                case \Root.isPurgeable: return .isPurgeableKey
                case \Root.isSparse: return .isSparseKey
                case \Root.fileContentIdentifier: return .fileContentIdentifierKey
                case \Root.contentType: return .contentTypeKey
                default: break
                }
            }
            return nil
        }
    }
#endif
