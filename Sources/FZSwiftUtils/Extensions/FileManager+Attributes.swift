//
//  File.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

public extension FileManager {
    /**
     The attributes of an file.
     */
    struct Attributes {
        // MARK: Init

        public init(url: URL) throws {
            self.url = url
            fileManager = .default
            attributes = try fileManager.attributesOfItem(atPath: url.path)
        }

        public init(url: URL, fileManager: FileManager) throws {
            self.url = url
            self.fileManager = fileManager
            attributes = try fileManager.attributesOfItem(atPath: url.path)
        }

        // MARK: Attributes

        public var fileType: FileAttributeType? { if let rawValue: String = _attributes.fileType() {
            return FileAttributeType(rawValue: rawValue)
        }
        return nil
        }

        public var fileSize: DataSize { DataSize(Int(_attributes.fileSize())) }

        public var creationDate: Date? {
            get { _attributes.fileCreationDate() }
            set { self[.creationDate] = newValue }
        }

        public var modificationDate: Date? {
            get { _attributes.fileModificationDate() }
            set { self[.modificationDate] = newValue }
        }

        public var directoryFilesCount: Int? { self[.referenceCount] }

        public var deviceIdentifier: Double? { self[.deviceIdentifier] }

        public var fileOwnerAccountName: String? {
            get { _attributes.fileOwnerAccountName() }
            set { self[.ownerAccountName] = newValue }
        }

        public var fileGroupOwnerAccountName: String? {
            get { _attributes.fileGroupOwnerAccountName() }
            set { self[.groupOwnerAccountName] = newValue }
        }

        public var filePosixPermissions: Int {
            get { _attributes.filePosixPermissions() }
            set { self[.posixPermissions] = newValue }
        }

        public var fileSystemNumber: Int { _attributes.fileSystemNumber() }

        public var fileSystemFileNumber: Int { _attributes.fileSystemFileNumber() }

        public var fileExtensionIsHidden: Bool {
            get { _attributes.fileExtensionHidden() }
            set { self[.extensionHidden] = newValue }
        }

        public var hfsCreatorCode: OSType {
            get { _attributes.fileHFSCreatorCode() }
            set { self[.hfsCreatorCode] = newValue }
        }

        public var hfsTypeCode: OSType? {
            get { _attributes.fileHFSTypeCode() }
            set { self[.hfsTypeCode] = newValue }
        }

        public var isImmutable: Bool {
            get { _attributes.fileIsImmutable() }
            set { self[.immutable] = newValue }
        }

        public var isReadOnly: Bool? { _attributes.fileIsAppendOnly() }

        public var ownerAccountID: Double? {
            get { self[.ownerAccountID] }
            set { self[.ownerAccountID] = newValue }
        }

        public var groupOwnerAccountID: Double? {
            get { self[.groupOwnerAccountID] }
            set { self[.groupOwnerAccountID] = newValue }
        }

        public var isBusy: Bool? {
            get { self[.busy] }
            set { self[.busy] = newValue }
        }

        public var fileProtection: FileProtectionType? { if let rawValue: String = self[.protectionKey] {
            return FileProtectionType(rawValue: rawValue)
        }
        return nil
        }

        public var systemSize: DataSize? {
            if let size: UInt64 = self[.systemSize] {
                return DataSize(Int(size))
            }
            return nil
        }

        public var systemFreeSize: DataSize? {
            if let size: UInt64 = self[.systemFreeSize] {
                return DataSize(Int(size))
            }
            return nil
        }

        public var systemNodes: Int? { self[.systemNodes] }

        public var systemFreeNodes: Int? { self[.systemFreeNodes] }

        // MARK: Internal

        let url: URL
        let fileManager: FileManager
        internal var attributes: [FileAttributeKey: Any]
        internal var _attributes: NSDictionary {
            attributes as NSDictionary
        }

        internal mutating func updateAttributes() throws {
            attributes = try fileManager.attributesOfItem(atPath: url.path)
        }

        internal func getAttribute<T>(_ attribute: FileAttributeKey) -> T? {
            attributes[attribute] as? T
        }

        public subscript<T>(attribute: FileAttributeKey) -> T? {
            get { attributes[attribute] as? T }
            set {
                var attributes = self.attributes
                attributes[attribute] = newValue
                try? fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                self.attributes = attributes
            }
        }

        internal mutating func setAttribute(_ attribute: FileAttributeKey, to value: Any?) throws {
            var attributes = self.attributes
            attributes[attribute] = value
            try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
            self.attributes = attributes
        }
    }
}
