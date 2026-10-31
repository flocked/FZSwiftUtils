//
//  FileAttributes.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

import Foundation

/// The attributes of a file system item.
public struct FileAttributes: CustomStringConvertible, CustomDebugStringConvertible, Sequence {
    
    /// All attributes of the file system item.
    public private(set) var attributes: [FileAttributeKey: Any]

    /**
     Creates an instance representing the attributes of the specified file or folder.

     You can modify some of the attributes of a file or folder by assigning new values to this instance and use it with `FileManager` ``Foundation/FileManager/setAttributes(_:ofItemAt:)``.
     
     - Parameter url: The url of the file.
     - Returns: `FileAttribute` for the file.
     */
    public init(url: URL) throws {
        attributes = try FileManager.default.attributesOfItem(at: url)
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

    /// The number of hard links referencing the file.
    public var referenceCount: Int? { self[.referenceCount] }

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
    public var fileSystemNumber: Int? { self[.systemNumber] }

    /// The filesystem file number.
    public var fileSystemFileNumber: Int? { self[.systemFileNumber] }

    /// A Boolean value indicating whether the file’s extension is hidden.
    public var fileExtensionIsHidden: Bool {
        get { self[.extensionHidden] ?? false }
        set { self[.extensionHidden] = newValue }
    }

    /// The file’s HFS creator code.
    public var hfsCreatorCode: OSType? {
        get { self[.hfsCreatorCode] }
        set { self[.hfsCreatorCode] = newValue }
    }

    /// The file’s HFS type code.
    public var hfsTypeCode: HFSType? {
        get { self[.hfsTypeCode] }
        set { self[.hfsTypeCode] = newValue }
    }

    /// A Boolean value indicating whether the file is immutable.
    public var isImmutable: Bool {
        get { self[.immutable] ?? false }
        set { self[.immutable] = newValue }
    }

    /// A Boolean value indicating whether the file is append-only.
    public var isAppendOnly: Bool {
        self[.appendOnly] ?? false
    }

    /// The file’s owner's account ID.
    public var ownerAccountID: Int? {
        get { self[.ownerAccountID] }
        set { self[.ownerAccountID] = newValue }
    }

    /// The file’s group owner account ID.
    public var groupOwnerAccountID: Int? {
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
    
    var writableAttributes: [FileAttributeKey: Any] {
        attributes.filter { Self.writableAttributes.contains($0.key) }
    }

    /// The attribute for the specified attribute key.
    public subscript<T>(attributeKey: FileAttributeKey) -> T? {
        get { attributes[attributeKey] as? T }
        set {
            guard Self.writableAttributes.contains(attributeKey) else { return }
            attributes[attributeKey] = newValue
        }
    }
    
    /// The attribute for the specified attribute key.
    public subscript<T: RawRepresentable>(attributeKey: FileAttributeKey) -> T? {
        get {
            guard let rawValue = attributes[attributeKey] as? T.RawValue else { return nil }
            return T(rawValue: rawValue)
        }
        set { self[attributeKey] = newValue?.rawValue }
    }
    
    private static let writableAttributes: Set<FileAttributeKey> = [
        .creationDate,
        .modificationDate,
        .ownerAccountName,
        .groupOwnerAccountName,
        .posixPermissions,
        .extensionHidden,
        .busy,
        .groupOwnerAccountID,
        .ownerAccountID,
        .immutable,
        .hfsTypeCode,
        .hfsCreatorCode
    ]
    
    public var description: String { attributes.description }
    public var debugDescription: String { attributes.debugDescription }
    public func makeIterator() -> [FileAttributeKey: Any].Iterator { attributes.makeIterator() }
}

public extension FileAttributes {
    /// A classic Macintosh four-character file type code.
    struct HFSType: RawRepresentable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
        /// The underlying four-character type code.
        public let rawValue: OSType

        /// Creates an HFS type from its raw value.
        public init(rawValue: OSType) {
            self.rawValue = rawValue
        }

        /// Creates an HFS type from a four-character string.
        public init(_ code: String) {
            guard let bytes = code.data(using: .macOSRoman), bytes.count == 4 else {
                preconditionFailure("HFS type codes must contain exactly four Mac OS Roman bytes.")
            }
            self.rawValue = bytes.reduce(0) { ($0 << 8) | OSType($1) }
        }

        // MARK: - Text
        /// A plain text file.
        public static let text = Self("TEXT")
        /// A read-only text file.
        public static let readOnlyText = Self("ttro")

        // MARK: - Images
        /// A Macintosh PICT image.
        public static let pict = Self("PICT")
        /// A JPEG image.
        public static let jpeg = Self("JPEG")
        /// A GIF image.
        public static let gif = Self("GIFf")
        /// A TIFF image.
        public static let tiff = Self("TIFF")
        /// A PNG image.
        public static let png = Self("PNGf")

        // MARK: - Documents
        /// A PDF document.
        public static let pdf = Self("PDF ")

        // MARK: - Audio
        /// An AIFF audio file.
        public static let aiff = Self("AIFF")
        /// A WAV audio file.
        public static let wave = Self("WAVE")
        /// An MP3 audio file.
        public static let mp3 = Self("MPG3")

        // MARK: - Video
        /// A QuickTime movie.
        public static let quickTimeMovie = Self("MooV")
        /// An MPEG video file.
        public static let mpeg = Self("MPEG")

        // MARK: - Other
        /// A Macintosh application.
        public static let application = Self("APPL")
        /// A binary file.
        public static let binary = Self("BINA")
        /// An unknown or unspecified file type.
        public static let unknown = Self("????")
        
        /// The four-character string representation of the HFS type code.
        public var stringValue: String {
           return String(bytes: [
                UInt8(truncatingIfNeeded: rawValue >> 24),
                UInt8(truncatingIfNeeded: rawValue >> 16),
                UInt8(truncatingIfNeeded: rawValue >> 8),
                UInt8(truncatingIfNeeded: rawValue)
            ], encoding: .macOSRoman) ?? "????"
        }
        
        private static let descriptions: [Self: String] = [
            .text: ".txt",
            .readOnlyText: "Read-only text file",
            .pict: ".pict",
            .jpeg: ".jpg",
            .gif: ".gif",
            .tiff: ".tiff",
            .png: ".png",
            .pdf: ".pdf",
            .aiff: ".aiff",
            .wave: ".wav",
            .mp3: ".mp3",
            .quickTimeMovie: ".mov",
            .mpeg: ".mpeg",
            .application: "Application",
            .binary: "Binary file",
            .unknown: "Unknown file type"
        ]

        public var description: String { Self.descriptions[self] ?? stringValue }
        
        public var debugDescription: String { stringValue }
    }
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
    public func setAttributes(_ attributes: FileAttributes, ofItemAt url: URL) throws {
        let writable = attributes.writableAttributes
        guard !writable.isEmpty else { return }
        try setAttributes(writable, ofItemAt: url )
    }
}

extension FileAttributeKey {
    /// The key in a file attribute dictionary whose value indicates the file’s extended attributes.
    public static let extendedAttributes = FileAttributeKey("NSFileExtendedAttributes")
}
