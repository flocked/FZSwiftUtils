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
        public typealias Key = String

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

        /*
         public subscript<T>(key: Key, initalValue: T? = nil) -> T? where T: Codable {
             get {
                 if let value: T = getExtendedAttribute(for: key) {
                     return value
                 } else if let initalValue = initalValue {
                     do {
                         try setExtendedAttribute(initalValue, for: key)
                         return initalValue
                     } catch {
                         return nil
                     }
                 }
                 return nil
             }
             set { try? setExtendedAttributeExplicit(newValue, for: key) }
         }
         */

        public subscript<T>(key: Key, initalValue: T? = nil) -> T? {
            get {
                if let value: T = getExtendedAttribute(for: key) {
                    return value
                } else if let initalValue = initalValue {
                    do {
                        try setExtendedAttributeExplicit(initalValue, for: key)
                        return initalValue
                    } catch {
                        return nil
                    }
                }
                return nil
            }
            set { try? setExtendedAttributeExplicit(newValue, for: key) }
        }

        /**
         Sets an attribute to a value.

         - Parameters:
            - value: The value, or `nil` if the attribute should be removed.
            - key: The name of the attribute.

         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func setExtendedAttribute<T>(_ value: T?, for key: Key) throws where T: Codable {
            if let value = value {
                let data = try JSONEncoder().encode(value)
                try setExtendedAttributeData(data, for: key)
            } else {
                try removeExtendedAttribute(key)
            }
        }

        /**
         Sets an attribute to a value.

         - Parameters:
            - value: The value, or `nil` if the attribute should be removed.
            - key: The name of the attribute.

         - Throws: Throws if the file doesn't exist or the attribute couldn't written.
         */
        public func setExtendedAttribute<T>(_ value: T?, for key: Key) throws {
            if let value = value {
                let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
                try setExtendedAttributeData(data, for: key)
            } else {
                try removeExtendedAttribute(key)
            }
        }

        /**
         The value of an key.

         - Parameter key: The name of the attribute.
         - Returns: The value of the key, or `nil` if there isn't an attribute with the key.
         */
        public func extendedAttribute<T>(for key: Key) -> T? where T: Codable {
            guard let data = extendedAttributeData(for: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }

        /**
         The value of an key.

         - Parameter key: The name of the attribute.
         - Returns: The value of the key, or `nil` if there isn't an attribute with the key.
         */
        public func extendedAttribute<T>(for key: Key) -> T? {
            guard let data = extendedAttributeData(for: key), let any = try? PropertyListSerialization.propertyList(from: data, format: nil),
                  let value = any as? T else { return nil }
            return value
        }

        func getExtendedAttribute<T>(for key: Key) -> T? {
            guard let data = extendedAttributeData(for: key) else { return nil }

            if let codableType = T.self as? Decodable.Type, let value = try? JSONDecoder().decode(codableType.self, from: data) {
                    return value as? T
            }
            if let value = try? PropertyListSerialization.propertyList(from: data, format: nil) as? T {
                return value
            }
            return nil
        }

        func setExtendedAttributeExplicit<T>(_ value: T?, for key: Key) throws {
            if isCodable(for: value, key: key) {
                if let codable = value as? Codable {
                    try setExtendedAttribute(codable, for: key)
                }
            } else if isNonCodable(for: value, key: key) {
                try setExtendedAttribute(value, for: key)
            } else {
                if let codable = value as? Codable {
                    try setExtendedAttribute(codable, for: key)
                } else {
                    try setExtendedAttribute(value, for: key)
                }
            }
        }

        func isNonCodable<T>(for _: T, key: Key) -> Bool {
            if let data = extendedAttributeData(for: key) {
                return ((try? PropertyListSerialization.propertyList(from: data, format: nil)) is T) == true
            }
            return false
        }

        func isCodable<T>(for _: T, key: Key) -> Bool {
            if let type = T.self as? Codable.Type, let data = extendedAttributeData(for: key) {
                return (try? JSONDecoder().decode(type.self, from: data)) != nil
            }
            return false
        }

        /**
         Removes an attribute.

         - Parameter key: The name of the attribute.
         - Throws: Throws if the value couldn't be removed.
         */
        public func removeExtendedAttribute(_ key: Key) throws {
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
        public func hasExtendedAttribute(_ key: Key) -> Bool {
            let result = url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Bool in
                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                return length >= 0
            }

            return result
        }

        /// A dictionary of all attributes.
        public func allExtendedAttributes() throws -> [Key: Any] {
            let keys = try listExtendedAttributes()
            var values: [String: Any] = [:]
            for key in keys {
                if let data = extendedAttributeData(for: key) {
                   if let value = try? PropertyListSerialization.propertyList(from: data, format: nil) {
                     values[key] = value
                   } else {
                    values[key] = data
                   }
                }
            }
            return values
        }

        /// An array of all attribute names.
        public func listExtendedAttributes() throws -> [Key] {
            let list = try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> [String] in

                let length = listxattr(fileSystemPath, nil, 0, 0)
                guard length >= 0 else { throw NSError.posix(errno) }

                // Create buffer with required size

                var data = Data(count: length)
                let count = data.count

                // Retrieve attribute list

                try data.withUnsafeMutableBytes {
                    let bytes = $0.baseAddress?.bindMemory(to: CChar.self, capacity: count)
                    let result = listxattr(fileSystemPath, bytes, count, 0)
                    if result < 0 { throw NSError.posix(errno) }
                }

                let list = data.split(separator: 0).compactMap {
                    String(data: Data($0), encoding: .utf8)
                }

                return list
            }

            return list
        }

        public func extendedAttributeData(for key: Key) -> Data? {
            let data = try? url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Data in

                // Determine attribute size

                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                guard length >= 0 else { throw NSError.posix(errno) }

                // Create buffer with required size

                var data = Data(count: length)

                // Retrieve attribute

                let count = data.count
                let result = data.withUnsafeMutableBytes {
                    getxattr(fileSystemPath, key, $0.baseAddress, count, 0, 0)
                }

                guard result >= 0 else { throw NSError.posix(errno) }
                return data
            }

            return data
        }

        public func setExtendedAttributeData(_ data: Data, for key: Key) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = data.withUnsafeBytes {
                    setxattr(fileSystemPath, key, $0.baseAddress, $0.count, 0, 0)
                }
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }
    }
}
