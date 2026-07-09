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
        public let url: URL
        
        /**
         Creates an extended attributes object from the specified url.
         
         - Parameter url: The url of the file.
         - Returns: An object for reading and writing extended attributes of the file.
         */
        public init(_ url: URL) {
            self.url = url
        }
        
        /// Returns the value for the specified extended attribute.
        public subscript<T>(key: String, flags: Flags = []) -> T? {
            get { try? get(key) }
            set { try? set(newValue, for: key, flags: flags) }
        }
        
        /// Returns the value for the specified extended attribute.
        public subscript<T>(key: String, strategy: CodingStrategy = .json, flags: Flags = []) -> T? where T: Codable {
            get { try? get(key, using: strategy) }
            set { try? set(newValue, for: key, using: strategy, flags: flags) }
        }
        
        /// Returns the data for the specified extended attribute.
        @_disfavoredOverload
        public subscript(key: String, flags: Flags = []) -> Data? {
            get { try? getData(for: key) }
            set { try? setData(newValue, for: key, flags: flags) }
        }
        
        /// The strategy how to encode and decode extended attributes.
        public enum CodingStrategy {
            /// Property list.
            case propertyList
            /// JSON (only for `Codable` types)
            case json
        }
        
        /**
         Returns the decoded value of the specified extended attribute.
         
         The attribute is decoded using the supplied coding strategy.
         
         - Parameter key: The name of the extended attribute.
         - Returns: The decoded value.
         - Throws: An error if the file doesn't exist or the attribute cannot be read or decoded.
         */
        public func get<T>(_ key: String) throws -> T? {
            try getPropertyList(key)
        }
        
        /**
         Returns the decoded value of the specified extended attribute.
         
         The attribute is decoded using the supplied coding strategy.
         
         - Parameters:
         - key: The name of the extended attribute.
         - strategy: The strategy used to decode the stored value.
         - Returns: The decoded value.
         - Throws: An error if the file doesn't exist or the attribute cannot be read or decoded.
         */
        public func get<T: Codable>(_ key: String, using strategy: CodingStrategy = .json) throws -> T {
            strategy == .json ? try getJSON(key) : try getPropertyList(key)
        }
        
        private func getPropertyList<T>(_ key: String) throws -> T {
            let propertyListValue = try PropertyListSerialization.propertyList(from: getData(for: key), format: nil)
            guard let value = propertyListValue as? T else {
                throw Errors.propertyListTypeMismatch(key: key, expected: T.self, actual: type(of: propertyListValue))
            }
            return value
        }
        
        private func getJSON<T: Codable>(_ key: String) throws -> T {
            try JSONDecoder().decode(T.self, from: getData(for: key))
        }
        
        /**
         Encodes and stores the specified value as an extended attribute.
         
         - Parameters:
         - value: The value to encode and store, or `nil` to remove the attribute.
         - key: The name of the attribute.
         - flags: The flags describing how the attribute should be handled by the file system.
         
         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func set<T>(_ value: T?, for key: String, flags: Flags = []) throws {
            try setPropertyList(value, for: key, flags: flags)
        }
        
        /**
         Encodes and stores the specified value as an extended attribute.
         
         - Parameters:
         - value: The value to encode and store, or `nil` to remove the attribute.
         - key: The name of the attribute.
         - strategy: The strategy used to encode the value.
         - flags: The flags describing how the attribute should be handled by the file system.
         
         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func set<T: Codable>(_ value: T?, for key: String, using strategy: CodingStrategy = .json, flags: Flags = []) throws {
            if strategy == .json {
                try setJSON(value, for: key, flags: flags)
            } else {
                try setPropertyList(value, for: key, flags: flags)
            }
        }
        
        private func setPropertyList<T>(_ value: T?, for key: String, flags: Flags) throws {
            if let value = value {
                guard PropertyListSerialization.propertyList(value, isValidFor: .binary) else {
                    throw Errors.valueNotPropertyListSerializable(key: key, type: type(of: value))
                }
                try setData(PropertyListSerialization.data(fromPropertyList: value, format: .binary), for: key, flags: flags)
            } else {
                try remove(key)
            }
        }
        
        private func setJSON<T: Codable>(_ value: T?, for key: String, flags: Flags) throws {
            if let value = value {
                try setData(JSONEncoder().encode(value), for: key, flags: flags)
            } else {
                try remove(key)
            }
        }
        
        /**
         Removes the specified extended attribute.
         
         - Parameter key: The name of the extended attribute to remove.
         - Throws: An error if the file doesn't exist or if the value couldn't be removed.
         */
        public func remove(_ key: String) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = removexattr(fileSystemPath, key, 0)
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }
        
        /**
         Returns the raw data of the specified extended attribute.
         
         - Parameter key: The name of the extended attribute.
         - Returns: The attribute data.
         - Throws: An error if the file doesn't exist or the attribute cannot be read.
         */
        public func getData(for key: String) throws -> Data {
            return try url.withUnsafeFileSystemRepresentation {
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
        }
        
        /**
         Stores the specified raw data as an extended attribute.
         
         - Parameters:
         - data: The data to store, or `nil` to remove the attribute.
         - key: The name of the extended attribute.
         - flags: The attribute flags describing how the attribute should be handled by the file system.
         - Throws: An error if the file doesn't exist or the attribute cannot be written or removed.
         */
        public func setData(_ data: Data?, for key: String, flags: Flags = []) throws {
            if let data = data {
                let key = try flags.nameWithFlags(key)
                try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                    let result = data.withUnsafeBytes {
                        setxattr(fileSystemPath, key, $0.baseAddress, $0.count, 0, 0)
                    }
                    guard result >= 0 else { throw NSError.posix(errno) }
                }
            } else {
                try remove(key)
            }
        }
        
        /**
         A Boolean value indicating whether the attribute with an name exists.
         
         - Parameter key: The name of the extended attribute.
         - Returns: `true` if the attribute exists; otherwise `false`.
         - Throws: An error if the file doesn't exist.
         */
        public func has(_ key: String) throws -> Bool {
            return try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Bool in
                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                if length >= 0 {
                    return true
                } else if errno == 93 {
                    return false
                }
                throw NSError.posix(errno)
            }
        }
        
        /**
         An array of all attribute names and their flags.
         
         - Throws: An error if the file doesn't exists or the attribute names couldn't be read.
         */
        public func attributes() throws -> [(name: String, flags: Flags)] {
            try rawNames().map { try (Flags.nameWithoutFlags($0), .fromName($0)) }.sorted(by: \.name)
        }
        
        /**
         An array of all attribute names.
         
         - Throws: An error if the file doesn't exists or the attribute names couldn't be read.
         */
        public func names() throws -> [String] {
            try rawNames().map { try Flags.nameWithoutFlags($0) }.sorted()
        }
        
        private func rawNames() throws -> [String] {
            try url.withUnsafeFileSystemRepresentation {
                fileSystemPath in
                let length = listxattr(fileSystemPath, nil, 0, 0)
                guard length >= 0 else { throw NSError.posix(errno) }
                var data = Data(count: length)
                let count = data.count
                try data.withUnsafeMutableBytes {
                    let bytes = $0.baseAddress?.bindMemory(to: CChar.self, capacity: count)
                    let result = listxattr(fileSystemPath, bytes, count, 0)
                    if result < 0 { throw NSError.posix(errno) }
                }
                return data.split(separator: 0).compactMap { String(data: Data($0), encoding: .utf8) }
            }
        }
        
        public struct Flags: OptionSet, CustomStringConvertible {
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
             Declares that the attribute should never be copied.
             
             Attributes marked with this flag are not preserved, regardless of the operation's preservation intent.
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
            
            public var description: String {
                var strings: [String] = []
                for element in elements() {
                    if element == .noExport { strings += ".noExport" }
                    else if element == .contentDependent { strings += ".contentDependent" }
                    else if element == .neverPreserve { strings += ".neverPreserve" }
                    else if element == .onlyBackup { strings += ".onlyBackup" }
                    else if element == .syncable { strings += ".syncable" }
                    else { strings += ".init(rawValue: \(element.rawValue))" }
                }
                return "[\(strings.sorted().joined(separator: ", "))]"
            }
            
            static func fromName(_ name: String) -> Self {
                .init(rawValue: xattr_flags_from_name(name))
            }
            
            static func nameWithoutFlags(_ name: String) throws -> String {
                guard let newName = xattr_name_without_flags(name) else {
                    throw NSError.posix(errno)
                }
                defer { newName.deallocate() }
                return String(cString: newName)
            }
            
            func nameWithFlags(_ name: String) throws -> String {
                if isEmpty { return name }
                guard let newName = xattr_name_with_flags(name, rawValue) else {
                    throw NSError.posix(errno)
                }
                defer { newName.deallocate() }
                return String(cString: newName)
            }
            
            public init(rawValue: xattr_flags_t) {
                self.rawValue = rawValue
            }
        }
        
        private enum Errors: LocalizedError {
            case propertyListTypeMismatch(key: String, expected: Any.Type, actual: Any.Type)
            case valueNotPropertyListSerializable(key: String, type: Any.Type)

            var errorDescription: String? {
                switch self {
                case let .propertyListTypeMismatch(key, expected, actual):
                    """
                    The value of extended attribute "\(key)" is of type \
                    \(String(reflecting: actual)), but a value of type \
                    \(String(reflecting: expected)) was expected.
                    """
                case let .valueNotPropertyListSerializable(key, type):
                    """
                    The value of type \(String(reflecting: type)) for extended attribute \
                    "\(key)" cannot be serialized as a property list.
                    """
                }
            }
            var failureReason: String? {
                switch self {
                case .propertyListTypeMismatch:
                    "The stored property list value does not match the expected type."
                case .valueNotPropertyListSerializable:
                    "The value is not a supported property list type."
                }
            }
        }
    }
}
