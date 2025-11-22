//
//  URL+ExtendedAttributes.swift
//
//
//  Created by Florian Zand on 02.08.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

import Foundation

public extension URL {
    /**
     The extended attributes of a file.

     An object for reading and writing the extended attributes of a file.
     */
    var extendedAttributes: ExtendedAttributes {
        ExtendedAttributes(self)
    }

    /// An object for reading and writing extended attributes of a file system resource.
    class ExtendedAttributes {
        
        /// The url of the file system resource.
        public private(set) var url: URL
        
        /**
         Creates an extended attributes object from the specified url.
         
         - Parameter url: The url of the file.
         - Returns: An object for reading and writing extended attributes of the file.
         */
        public init(_ url: URL) {
            self.url = url
        }
        
        public subscript<T>(key: String) -> T? {
            get { try? get(key) }
            set { try? set(newValue, for: key) }
        }
        
        public subscript<T>(key: String, strategy: CodingStrategy = .json) -> T? where T: Codable {
            get { try? get(key, using: strategy) }
            set { try? set(newValue, for: key, using: strategy) }
        }
        
        /// The strategy how to encode and decode extended attributes.
        public enum CodingStrategy {
            /// Property list.
            case propertyList
            /// JSON (only for `Codable` types)
            case json
        }
        
        /**
         The value of an key.
         
         - Parameter key: The name of the attribute.
         - Returns: The value of the key, or `nil` if there isn't an attribute with the key.
         */
        public func get<T>(_ key: String) throws -> T?{
            try getPropertyListt(key)
        }
        
        /**
         The value of an key.

         - Parameter key: The name of the attribute.
         - Returns: The value of the key, or `nil` if there isn't an attribute with the key.
         */
        public func get<T>(_ key: String, using strategy: CodingStrategy = .json) throws -> T where T: Codable {
            strategy == .json ? try getJSON(key) : try getPropertyListt(key)
        }
        
        private func getPropertyListt<T>(_ key: String) throws -> T {
            guard let value = try PropertyListSerialization.propertyList(from: try getData(for: key), format: nil) as? T else {
                throw CocoaError(.coderInvalidValue)
            }
            return value
        }
        
        private func getJSON<T>(_ key: String) throws -> T where T: Codable {
            try JSONDecoder().decode(T.self, from: try getData(for: key))
        }

        /**
         Sets an attribute to a value.

         - Parameters:
            - value: The value, or `nil` if the attribute should be removed.
            - key: The name of the attribute.

         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func set<T>(_ value: T?, for key: String, flags: Flags? = nil) throws {
           try setPropertyList(value, for: key, flags: flags)
        }
        
        /**
         Sets an attribute to a value.

         - Parameters:
            - value: The value, or `nil` if the attribute should be removed.
            - key: The name of the attribute.

         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func set<T>(_ value: T?, for key: String, using strategy: CodingStrategy = .json, flags: Flags? = nil) throws where T: Codable {
            if strategy == .json {
                try setJSON(value, for: key, flags: flags)
            } else {
                try setPropertyList(value, for: key, flags: flags)
            }
        }
        
        private func setPropertyList<T>(_ value: T?, for key: String, flags: Flags? = nil) throws {
            if let value = value {
                guard PropertyListSerialization.propertyList(value, isValidFor: .binary) else {
                    throw CocoaError(.propertyListWriteInvalid)
                }
                let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
                try setData(data, for: key)
            } else {
                try remove(key)
            }
        }
        
        private func setJSON<T: Codable>(_ value: T?, for key: String, flags: Flags? = nil) throws {
            if let value = value {
                let data = try JSONEncoder().encode(value)
                try setData(data, for: key)
            } else {
                try remove(key)
            }
        }

        /**
         Removes an attribute.

         - Parameter key: The name of the attribute.
         - Throws: Throws if the value couldn't be removed.
         */
        public func remove(_ key: String) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = removexattr(fileSystemPath, key, 0)
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }

        /**
         A Boolean value indicating whether the attribute with an name exists.

         - Parameter key: The name of the attribute.
         - Returns: `true` if the attribute exists, or `false if it isn't.
         */
        public func has(_ key: String) throws -> Bool {
            let result = try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Bool in
                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                if length >= 0 {
                    return true
                } else if errno == 93 {
                    return false
                }
                throw NSError.posix(errno)
            }
            return result
        }

        /// An array of all attribute names.
        public func allNames(withFlags: Bool = false) throws -> [String] {
            let list = try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> [String] in
                let length = listxattr(fileSystemPath, nil, 0, 0)
                guard length >= 0 else { throw NSError.posix(errno) }
                var data = Data(count: length)
                let count = data.count
                try data.withUnsafeMutableBytes {
                    let bytes = $0.baseAddress?.bindMemory(to: CChar.self, capacity: count)
                    let result = listxattr(fileSystemPath, bytes, count, 0)
                    if result < 0 { throw NSError.posix(errno) }
                }
                var list = data.split(separator: 0).compactMap {
                    String(data: Data($0), encoding: .utf8)
                }
                if !withFlags {
                    list = try list.map { try Self.nameWithoutFlags($0) }
                }
                return list
            }
            return list
        }

        public func getData(for key: String) throws -> Data {
            let data = try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Data in
                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                guard length >= 0 else { throw NSError.posix(errno) }
                var data = Data(count: length)
                let result = data.withUnsafeMutableBytes {
                    getxattr(fileSystemPath, key, $0.baseAddress, length, 0, 0)
                }
                guard result >= 0 else { throw NSError.posix(errno) }
                return data
            }
            return data
        }

        public func setData(_ data: Data, for key: String, flags: Flags? = nil) throws {
            let key = if let flags { try Self.nameWithFlags(key, flags: flags) } else { key }
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = data.withUnsafeBytes {
                    setxattr(fileSystemPath, key, $0.baseAddress, $0.count, 0, 0)
                }
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }
    }
}

extension URL.ExtendedAttributes {
    public struct Flags: OptionSet {
        /**
        Declare that the attribute should not be exported. This is deliberately a bit vague, but this is used by `XATTR_OPERATION_INTENT_SHARE` to indicate not to preserve the attribute.
        */
        public static let noExport = Self(rawValue: XATTR_FLAG_NO_EXPORT)

        /**
        Declares the  attribute to be tied to the contents of the file (or vice versa), such that it should be re-created when the contents of the file change. Examples might include cryptographic keys, checksums, saved position or search information, and text encoding.

        This property causes the attribute to be preserved for copy and share, but not for safe save. In a safe save, the attriubte exists on the original, and will not be copied to the new version.
        */
        public static let contentDependent = Self(rawValue: XATTR_FLAG_CONTENT_DEPENDENT)

        /**
        Declares that the attribute is never to be copied, for any intention type.
        */
        public static let neverPreserve = Self(rawValue: XATTR_FLAG_NEVER_PRESERVE)

        /**
        Declares that the attribute is to be synced, used by the `XATTR_OPERATION_ITENT_SYNC` intention. Syncing tends to want to minimize the amount of metadata synced around, hence the default behavior is for the attribute NOT to be synced, even if it would else be preserved for the `XATTR_OPERATION_ITENT_COPY` intention.
        */
        public static let syncable = Self(rawValue: XATTR_FLAG_SYNCABLE)

        /**
        Declares that the attribute should only be copied if the intention is `XATTR_OPERATION_INTENT_BACKUP`. That intention is distinct from the `XATTR_OPERATION_INTENT_SYNC` intention in that there is no desire to minimize the amount of metadata being moved.
        */
        public static let onlyBackup = Self(rawValue: XATTR_FLAG_ONLY_BACKUP)

        public var rawValue: xattr_flags_t

        public init(rawValue: xattr_flags_t) {
            self.rawValue = rawValue
        }
    }
    
    static func flagsFromName(_ name: String) -> Flags {
        Flags(rawValue: xattr_flags_from_name(name))
    }

    static func nameWithoutFlags(_ name: String) throws -> String {
        guard let newName = xattr_name_without_flags(name) else {
            throw NSError.posix(errno)
        }
        defer { newName.deallocate() }
        return String(cString: newName)
    }

    static func nameWithFlags(_ name: String, flags: Flags) throws -> String {
        guard let newName = xattr_name_with_flags(name, flags.rawValue) else {
            throw NSError.posix(errno)
        }
        defer { newName.deallocate() }
        return String(cString: newName)
    }
}
