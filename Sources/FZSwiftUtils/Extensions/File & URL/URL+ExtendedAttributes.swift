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
        return ExtendedAttributes(self)
    }

    /// An object for reading and writing extended attributes of a file system resource.
    class ExtendedAttributes {
        public typealias Key = String

        /// The url of the file system resource.
        public private(set) var url: URL
        
        /**
         Creates an extended attributes object from the specified url.
         - Parameters url: The url of the file.
         - Returns: An object for reading and writing extended attributes of the file.
         */
        public init(_ url: URL) {
            self.url = url
        }

        public subscript<T>(key: Key, initalValue: T? = nil) -> T? {
            get {
                if let value: T = extendedAttribute(for: key) {
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
            set { try? setExtendedAttribute(newValue, for: key) }
        }

        /**
         Sets an attribute to a value.
         
         - Parameters value: The value, or nil if the attribute should be removed.
         - Parameters key: The name of the attribute.
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
         
         - Parameters key: The name of the attribute.
         
         - Returns: The value of the key, or nil if there isn't an attribute with the key.
         */
        public func extendedAttribute<T>(for key: Key) -> T? {
            if let data = extendedAttributeData(for: key),
               let any = try? PropertyListSerialization.propertyList(from: data, format: nil),
               let value = any as? T
            {
                return value
            }

            return nil
        }

        /**
         Removes an attribute.
         
         - Parameters key: The name of the attribute.
         
         - Throws: Throws if the value couldn't be removed.
         */
        public func removeExtendedAttribute(_ key: Key) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = removexattr(fileSystemPath, key, 0)
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }

        /**
         A bool indicating whether the attribute with an name exists.
         
         - Parameters key: The name of the attribute.
         
         - Returns: True if the attribute exists, or false if it isn't.
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
                if let data = extendedAttributeData(for: key),
                   let value = try? PropertyListSerialization.propertyList(from: data, format: nil)
                {
                    values[key] = value
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
        
        private func extendedAttributeData(for key: Key) -> Data? {
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

        private func setExtendedAttributeData(_ data: Data, for key: Key) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = data.withUnsafeBytes {
                    setxattr(fileSystemPath, key, $0.baseAddress, $0.count, 0, 0)
                }
                guard result >= 0 else { throw NSError.posix(errno) }
            }
        }
    }
}
