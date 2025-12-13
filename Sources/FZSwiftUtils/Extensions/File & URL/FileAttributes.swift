//
//  FileAttributes.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

/// The attributes of a file system item.
public struct FileAttributes {

    /**
     Creates an instance representing the attributes of the specified file or folder.

     You can modify the attributes of a file or folder by assigning new values to this instance and use it with `FileManager` ``Foundation/FileManager/setAttributes(_:ofItemAt:)``.
     
     - Parameter url: The url of the file.
     - Returns: `FileAttribute` for the file.
     */
    public init(url: URL) throws {
        self = try FileManager.default.attributes(for: url)
    }
    
    /**
     Creates an empty  instance.

     Assign values to the properties you want to provide or change for and use it  with `FileManager` ``Foundation/FileManager/setAttributes(_:ofItemAt:)``.

     Example usage:
     
     ```swift
     var attrs = FileAttributes()
     attrs.creationDate = Date()
     attrs.isHidden = true
     try FileManager.default.setAttributes(attrs, ofItemAt: url)
     */
    public init() {
        attributes = [:]
    }
    
    init(_ attributes: [FileAttributeKey: Any]) {
        self.attributes = attributes
    }

    // MARK: Attributes

    /// The tfile type.
    public var fileType: FileAttributeType? { self[.type] }

    /// The file size.
    public var fileSize: DataSize { DataSize(self[.size] ?? 0) }

    /// The creation date of the file.
    public var creationDate: Date? {
        get { self[.creationDate] }
        set { self[.creationDate] = newValue }
    }

    /// The modification date of the file.
    public var modificationDate: Date? {
        get { self[.modificationDate] }
        set { self[.modificationDate] = newValue }
    }

    public var directoryFilesCount: Int? { self[.referenceCount] }

    /// The identifier for the device on which the file resides.
    public var deviceIdentifier: Int? { self[.deviceIdentifier] }

    /// The name of the file’s owner.
    public var fileOwnerAccountName: String? {
        get { self[.ownerAccountName] }
        set { self[.ownerAccountName] = newValue }
    }

    /// The file’s group owner account name.
    public var fileGroupOwnerAccountName: String? {
        get { self[.groupOwnerAccountName] }
        set { self[.groupOwnerAccountName] = newValue }
    }

    /// The file’s Posix permissions.
    public var filePosixPermissions: Int {
        get { self[.posixPermissions] ?? 0 }
        set { self[.posixPermissions] = newValue }
    }

    /// The filesystem number.
    public var fileSystemNumber: Int { self[.systemNumber] ?? 0 }

    /// The filesystem file number.
    public var fileSystemFileNumber: Int { self[.systemFileNumber] ?? 0 }

    /// A Boolean value indicating whether the file’s extension is hidden.
    public var fileExtensionIsHidden: Bool {
        get { self[.extensionHidden] ?? false }
        set { self[.extensionHidden] = newValue }
    }

    /// The file’s HFS creator code.
    public var hfsCreatorCode: OSType {
        get { self[.hfsCreatorCode]! }
        set { self[.hfsCreatorCode] = newValue }
    }

    /// The file’s HFS type code.
    public var hfsTypeCode: OSType {
        get { self[.hfsTypeCode] ?? 0 }
        set { self[.hfsTypeCode] = newValue }
    }

    /// A Boolean value indicating whether the file is immutable.
    public var isImmutable: Bool {
        get { self[.immutable] ?? false }
        set { self[.immutable] = newValue }
    }

    /// A Boolean value indicating whether the file is readonly.
    public var isReadOnly: Bool? { self[.appendOnly] ?? false }

    /// The file’s owner's account ID.
    public var ownerAccountID: Int? {
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
    public var fileProtection: FileProtectionType? { self[.protectionKey] }

    /// The size of the file system.
    public var systemSize: DataSize? { self[.systemSize] }

    /// The amount of free space on the file system.
    public var systemFreeSize: DataSize? { self[.systemFreeSize] }

    /// The number of nodes in the file system.
    public var systemNodes: Int? { self[.systemNodes] }

    /// The number of free nodes in the file system.
    public var systemFreeNodes: Int? { self[.systemFreeNodes] }

    /// The file’s extended attributes.
    public var extendedAttributes: [String: Data]? { self[.extendedAttributes]  }

    // MARK: Internal

    var attributes: [FileAttributeKey: Any]

    /// The attribute for the specified attribute key.
    public subscript<T>(attributeKey: FileAttributeKey) -> T? {
        get { attributes[attributeKey] as? T }
        set { setAttribute(attributeKey, to: newValue) }
    }
    
    /// The attribute for the specified attribute key.
    public subscript<T: RawRepresentable>(attributeKey: FileAttributeKey) -> T? {
        get { attributes[attributeKey] as? T }
        set { setAttribute(attributeKey, to: newValue) }
    }
        
    func attribute<T>(for attributeKey: FileAttributeKey) -> T? {
        attributes[attributeKey] as? T
    }
    
    func attribute<T: RawRepresentable>(for attributeKey: FileAttributeKey) -> T? {
        guard let rawValue = attributes[attributeKey] as? T.RawValue else { return nil }
        return T(rawValue: rawValue)
    }
    
    mutating func setAttribute<T: RawRepresentable>(_ attributeKey: FileAttributeKey, to value: T?) {
        setAttribute(attributeKey, to: value?.rawValue)
    }

    mutating func setAttribute<T>(_ attributeKey: FileAttributeKey, to value: T?) {
        guard let value = value, Self.writableAttributes.contains(attributeKey) else { return }
        attributes[attributeKey] = value
    }
    
    static let writableAttributes: Set<FileAttributeKey> = [.creationDate, .modificationDate, .ownerAccountName, .groupOwnerAccountName, .posixPermissions, .extensionHidden, .busy, .groupOwnerAccountID, .ownerAccountID, .immutable, .hfsTypeCode, .hfsCreatorCode]
}

extension FileManager {
    /**
     Sets the attributes of the specified file or directory.
     
     Returns the attributes for the item at the specific url.

     - Throws: If the attributes couldn't be loaded.
     */
    public func attributes(for url: URL) throws -> FileAttributes {
        FileAttributes(try attributesOfItem(at: url))
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
