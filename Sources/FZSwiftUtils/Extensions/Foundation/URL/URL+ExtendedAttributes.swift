import Foundation

private extension URL {
    /// Wrap the xattr functions's POSIX error codes in `NSError` instances.
    ///
    /// - note: Originally written by Martin R on StackOverflow: <https://stackoverflow.com/a/38343753/1460929>
    /// - parameter err: POSIX error code.
    /// - returns: NSError in the `NSPOSIXErrorDomain` with the code `err` and `userInfo` with a default localized description for the error code.
    static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}

public extension URL {
    var extendedAttributes: ExtendedAttributes {
        return ExtendedAttributes(self)
    }

    class ExtendedAttributes {
        public typealias Key = String

        private var url: URL
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

        public func setExtendedAttribute<T>(_ value: T?, for key: Key) throws {
            if let value = value {
                let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
                try setExtendedAttributeData(data, for: key)
            } else {
                try removeExtendedAttribute(key)
            }
        }

        /// Get extended attribute

        public func extendedAttribute<T>(for key: Key) -> T? {
            if let data = extendedAttributeData(for: key),
               let any = try? PropertyListSerialization.propertyList(from: data, format: nil),
               let value = any as? T
            {
                return value
            }

            return nil
        }

        /// Extended attribute data.
        ///
        /// - note: Originally written by Martin R on StackOverflow: <https://stackoverflow.com/a/38343753/1460929>
        /// - parameter name: Attribute name
        /// - throws: `NSError` in the `NSPOSIXErrorDomain` when no attribute of `name` was found.
        /// - returns: Data representation of the attribute's value.
        private func extendedAttributeData(for key: Key) -> Data? {
            let data = try? url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Data in

                // Determine attribute size

                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                guard length >= 0 else { throw URL.posixError(errno) }

                // Create buffer with required size

                var data = Data(count: length)

                // Retrieve attribute

                let count = data.count
                let result = data.withUnsafeMutableBytes {
                    getxattr(fileSystemPath, key, $0.baseAddress, count, 0, 0)
                }

                guard result >= 0 else { throw URL.posixError(errno) }
                return data
            }

            return data
        }

        /// Set or overwrite an extended attribute.
        ///
        /// - note: Originally written by Martin R on StackOverflow: <https://stackoverflow.com/a/38343753/1460929>
        /// - parameter data: Data representation of any value to be stored in the xattrs.
        /// - parameter name: Attribute name
        /// - throws: `NSError` in the `NSPOSIXErrorDomain` when writing the attribute failed.
        private func setExtendedAttributeData(_ data: Data, for key: Key) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = data.withUnsafeBytes {
                    setxattr(fileSystemPath, key, $0.baseAddress, $0.count, 0, 0)
                }
                guard result >= 0 else { throw URL.posixError(errno) }
            }
        }

        /// Removed the extended attribute of `name`.
        ///
        /// - note: Originally written by Martin R on StackOverflow: <https://stackoverflow.com/a/38343753/1460929>
        /// - parameter name: Attribute name to remove.
        /// - throws: `NSError` in the `NSPOSIXErrorDomain`.
        public func removeExtendedAttribute(_ key: Key) throws {
            try url.withUnsafeFileSystemRepresentation { fileSystemPath in
                let result = removexattr(fileSystemPath, key, 0)
                guard result >= 0 else { throw URL.posixError(errno) }
            }
        }

        public func hasExtendedAttribute(_ key: Key) -> Bool {
            let result = url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> Bool in
                let length = getxattr(fileSystemPath, key, nil, 0, 0, 0)
                return length >= 0
            }

            return result
        }

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

        public func listExtendedAttributes() throws -> [Key] {
            let list = try url.withUnsafeFileSystemRepresentation {
                fileSystemPath -> [String] in

                let length = listxattr(fileSystemPath, nil, 0, 0)
                guard length >= 0 else { throw URL.posixError(errno) }

                // Create buffer with required size

                var data = Data(count: length)
                let count = data.count

                // Retrieve attribute list

                try data.withUnsafeMutableBytes {
                    let bytes = $0.baseAddress?.bindMemory(to: CChar.self, capacity: count)
                    let result = listxattr(fileSystemPath, bytes, count, 0)
                    if result < 0 { throw URL.posixError(errno) }
                }

                // Extract attribute names

                let list = data.split(separator: 0).compactMap {
                    String(data: Data($0), encoding: .utf8)
                }

                return list
            }

            return list
        }
    }
}
