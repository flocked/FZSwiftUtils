//
//  FileAttributes.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

/// The attributes of a file.
public struct FileAttributes {
    // MARK: Init

    /**
     Creates an object for accessing and modifying the attributes of the specified file.

     - Parameter url: The url of the file.
     - Returns: `FileAttribute` for the file.
     */
    public init(url: URL) throws {
        self.url = url
        fileManager = .default
        attributes = try fileManager.attributesOfItem(atPath: url.path)
    }

    /**
     Creates an object for accessing and modifying the attributes of the specified file.

     - Parameters:
        - url: The url of the file.
        - fileManager: The file manager.

     - Returns: `FileAttribute` for the file.
     */
    init(url: URL, fileManager: FileManager) throws {
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

    /// The file size.
    public var fileSize: DataSize { DataSize(Int(_attributes.fileSize())) }

    /// The creation date of the file.
    public var creationDate: Date? {
        get { _attributes.fileCreationDate() }
        set { self[.creationDate] = newValue }
    }

    /// The modification date of the file.
    public var modificationDate: Date? {
        get { _attributes.fileModificationDate() }
        set { self[.modificationDate] = newValue }
    }

    public var directoryFilesCount: Int? { self[.referenceCount] }

    /// The identifier for the device on which the file resides.
    public var deviceIdentifier: Double? { self[.deviceIdentifier] }

    /// The name of the file’s owner.
    public var fileOwnerAccountName: String? {
        get { _attributes.fileOwnerAccountName() }
        set { self[.ownerAccountName] = newValue }
    }

    /// The file’s group owner account name.
    public var fileGroupOwnerAccountName: String? {
        get { _attributes.fileGroupOwnerAccountName() }
        set { self[.groupOwnerAccountName] = newValue }
    }

    /// The file’s Posix permissions.
    public var filePosixPermissions: Int {
        get { _attributes.filePosixPermissions() }
        set { self[.posixPermissions] = newValue }
    }

    /// The filesystem number.
    public var fileSystemNumber: Int { _attributes.fileSystemNumber() }

    /// The filesystem file number.
    public var fileSystemFileNumber: Int { _attributes.fileSystemFileNumber() }

    /// A Boolean value indicating whether the file’s extension is hidden.
    public var fileExtensionIsHidden: Bool {
        get { _attributes.fileExtensionHidden() }
        set { self[.extensionHidden] = newValue }
    }

    /// The file’s HFS creator code.
    public var hfsCreatorCode: OSType {
        get { _attributes.fileHFSCreatorCode() }
        set { self[.hfsCreatorCode] = newValue }
    }

    /// The file’s HFS type code.
    public var hfsTypeCode: OSType? {
        get { _attributes.fileHFSTypeCode() }
        set { self[.hfsTypeCode] = newValue }
    }

    /// A Boolean value indicating whether the file is immutable.
    public var isImmutable: Bool {
        get { _attributes.fileIsImmutable() }
        set { self[.immutable] = newValue }
    }

    /// A Boolean value indicating whether the file is readonly.
    public var isReadOnly: Bool? { _attributes.fileIsAppendOnly() }

    /// The file’s owner's account ID.
    public var ownerAccountID: Double? {
        get { self[.ownerAccountID] }
        set { self[.ownerAccountID] = newValue }
    }

    /// The file’s group ID.
    public var groupOwnerAccountID: Double? {
        get { self[.groupOwnerAccountID] }
        set { self[.groupOwnerAccountID] = newValue }
    }

    /// A Boolean value indicating whether the file is busy.
    public var isBusy: Bool? {
        get { self[.busy] }
        set { self[.busy] = newValue }
    }

    /// The protection level for the file.
    public var fileProtection: FileProtectionType? { if let rawValue: String = self[.protectionKey] {
        return FileProtectionType(rawValue: rawValue)
    }
    return nil
    }

    /// The size of the file system.
    public var systemSize: DataSize? {
        if let size: UInt64 = self[.systemSize] {
            return DataSize(Int(size))
        }
        return nil
    }

    /// The amount of free space on the file system.
    public var systemFreeSize: DataSize? {
        if let size: UInt64 = self[.systemFreeSize] {
            return DataSize(Int(size))
        }
        return nil
    }

    /// The number of nodes in the file system.
    public var systemNodes: Int? { self[.systemNodes] }

    /// The number of free nodes in the file system.
    public var systemFreeNodes: Int? { self[.systemFreeNodes] }

    /// The file’s extended attributes.
    public var extendedAttributes: [String: Data]? {
        self[.extendedAttributes]
    }

    // MARK: Internal

    /// The url of the file.
    public let url: URL
    /// The file mananger.
    let fileManager: FileManager
    var attributes: [FileAttributeKey: Any]
    var _attributes: NSDictionary {
        attributes as NSDictionary
    }

    mutating func updateAttributes() throws {
        attributes = try fileManager.attributesOfItem(atPath: url.path)
    }

    func getAttribute<T>(_ attribute: FileAttributeKey) -> T? {
        attributes[attribute] as? T
    }

    public subscript<T>(attribute: FileAttributeKey) -> T? {
        get { attributes[attribute] as? T }
        set {
            var attributes = attributes
            attributes[attribute] = newValue
            try? fileManager.setAttributes(attributes, ofItemAtPath: url.path)
            self.attributes = attributes
        }
    }

    mutating func setAttribute(_ attribute: FileAttributeKey, to value: Any?) throws {
        var attributes = attributes
        attributes[attribute] = value
        try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
        self.attributes = attributes
    }
}

extension FileManager {
    /**
     Sets the attributes of the specified file or directory.
     
     Returns the attributes for the item at the specific url.

     - Throws: If the attributes couldn't be loaded.
     */
    public func attributes(for url: URL) throws -> FileAttributes {
        try FileAttributes(url: url, fileManager: self)
    }
    
    /**
     Sets the attributes of the specified file or directory.
     
     - Parameters:
        - attributes: The attributes to write.
        - url: The file resource URL.

     */
    func setAttributes(_ attributes: FileAttributes, ofItemAt url: URL) throws {
        try setAttributes(attributes.attributes, ofItemAtPath: url.path)
    }
}

extension FileAttributeKey {
    /// The key in a file attribute dictionary whose value indicates the file’s extended attributes.
    public static let extendedAttributes = FileAttributeKey("NSFileExtendedAttributes")
}
