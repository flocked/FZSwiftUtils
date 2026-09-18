//
//  URL+Attributes.swift
//
//
//  Created by Florian Zand on 18.09.26.
//

import Foundation

public extension URL {
    /**
     Returns the value of the specified file system attribute.

     - Parameters:
       - attribute: The attribute identifier.
       - type: The type of the attribute value.
     - Returns: The value of the attribute.
     - Throws: A POSIX error if the attribute couldn't be retrieved.
     */
    func getAttribute<V: BitwiseCopyable>(_ attribute: Int32, as type: V.Type = V.self) throws -> V {
        var attributes = attrlist()
        attributes.bitmapcount = UInt16(ATTR_BIT_MAP_COUNT)
        attributes.commonattr = attrgroup_t(attribute)
        let offset = MemoryLayout<UInt32>.size
        var buffer = [UInt8](repeating: 0, count: offset + MemoryLayout<V>.size)
        try buffer.withUnsafeMutableBytes { buffer in
            guard withUnsafeFileSystemRepresentation({
                getattrlist($0!, &attributes, buffer.baseAddress, buffer.count, 0)
            }) == 0 else {
                throw POSIXError.current ?? NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }
        return buffer.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: V.self) }
    }

    /**
     Sets the value of the specified file system attribute.

     - Parameters:
       - attribute: The attribute identifier.
       - value: The value to set.
     - Throws: A POSIX error if the attribute couldn't be set.
     */
    func setAttribute<V: BitwiseCopyable>(_ attribute: Int32, to value: V) throws {
        var value = value
        try withUnsafeMutableBytes(of: &value) { buffer in
            var attributes = attrlist()
            attributes.bitmapcount = UInt16(ATTR_BIT_MAP_COUNT)
            attributes.commonattr = attrgroup_t(attribute)
            guard withUnsafeFileSystemRepresentation({
                setattrlist($0!, &attributes, buffer.baseAddress, buffer.count, 0)
            }) == 0 else {
                throw POSIXError.current ?? NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }
    }

    /// The value of the specified file system attribute.
    subscript<V: BitwiseCopyable>(attribute attribute: Int32) -> V? {
        get { try? getAttribute(attribute) }
        set {
            guard let newValue else { return }
            try? setAttribute(attribute, to: newValue)
        }
    }
    
    /**
     Returns the value of the specified file system attribute.

     - Parameters:
       - attribute: The attribute identifier.
       - type: The type of the attribute value.
     - Returns: The value of the attribute.
     - Throws: A POSIX error if the attribute couldn't be retrieved.
     */
    func getAttribute<V: RawRepresentable>(_ attribute: Int32, as type: V.Type = V.self) throws -> V where V.RawValue: BitwiseCopyable {
        guard let value = try V(rawValue: getAttribute(attribute)) else {
            throw URLError(.cannotDecodeRawData, failingURL: self)
        }
        return value
    }
    
    /**
     Sets the value of the specified file system attribute.

     - Parameters:
       - attribute: The attribute identifier.
       - value: The value to set.
     - Throws: A POSIX error if the attribute couldn't be set.
     */
    func setAttribute<V: RawRepresentable>(_ attribute: Int32, to value: V) throws where V.RawValue: BitwiseCopyable {
        try setAttribute(attribute, to: value.rawValue)
    }
    
    /// The value of the specified file system attribute.
    subscript<V: RawRepresentable>(attribute attribute: Int32) -> V? where V.RawValue: BitwiseCopyable {
        get { try? getAttribute(attribute) }
        set {
            guard let newValue else { return }
            try? setAttribute(attribute, to: newValue)
        }
    }
}

public extension URL {
    /// A file system attribute that can be read from a URL.
    struct Attribute<Value>: URLAttribute, _URLAttribute {
        /// The identifier of the attribute.
        public let identifier: Int32
        fileprivate let get: (URL) throws -> Value

        fileprivate func getValue(_ url: URL) throws -> Any? { try get(url) }

        /// Creates an attribute with the specified identifier.
        public init(_ identifier: Int32) where Value: BitwiseCopyable {
            self.identifier = identifier
            self.get = { try $0.getAttribute(identifier) }
        }

        /**
         Creates an attribute that decodes its raw file system value.

         - Parameters:
           - identifier: The identifier of the attribute.
           - type: The type of the raw attribute value.
           - decode: A closure that converts the raw value to the attribute value.
         */
        public init<RawValue: BitwiseCopyable>(_ identifier: Int32, as type: RawValue.Type = RawValue.self, decode: @escaping (RawValue) -> Value) {
            self.identifier = identifier
            self.get = { try decode($0.getAttribute(identifier)) }
        }
    }

    /// A file system attribute that can be read from and written to a URL.
    struct SettableAttribute<Value>: URLAttribute, _URLAttribute {
        /// The readable representation of the attribute.
        public let attribute: Attribute<Value>
        fileprivate let set: (URL, Value) throws -> Void

        fileprivate func getValue(_ url: URL) throws -> Any? { try attribute.getValue(url) }

        /// The identifier of the attribute.
        public var identifier: Int32 { attribute.identifier }

        /// Creates a settable attribute with the specified identifier.
        public init(_ identifier: Int32) where Value: BitwiseCopyable {
            self.attribute = Attribute(identifier)
            self.set = { try $0.setAttribute(identifier, to: $1) }
        }

        /**
         Creates a settable attribute that converts between its raw and exposed values.

         - Parameters:
           - identifier: The identifier of the attribute.
           - type: The type of the raw attribute value.
           - decode: A closure that converts the raw value to the attribute value.
           - encode: A closure that converts the attribute value to its raw value.
         */
        public init<RawValue: BitwiseCopyable>(_ identifier: Int32, as type: RawValue.Type = RawValue.self, decode: @escaping (RawValue) -> Value, encode: @escaping (Value) -> RawValue) {
            self.attribute = Attribute(identifier, as: type, decode: decode)
            self.set = { try $0.setAttribute(identifier, to: encode($1)) }
        }
    }

    /// The value of the specified attribute, or `nil` if it couldn't be retrieved.
    subscript<Value>(attribute attribute: Attribute<Value>) -> Value? { try? attribute.get(self) }

    /// The value of the specified settable attribute.
    subscript<Value>(attribute attribute: SettableAttribute<Value>) -> Value? {
        get { try? attribute.attribute.get(self) }
        set {
            guard let newValue else { return }
            try? attribute.set(self, newValue)
        }
    }

    /**
     Returns the value of the specified attribute.

     - Parameter attribute: The attribute to retrieve.
     - Returns: The value of the attribute.
     - Throws: An error if the attribute couldn't be retrieved.
     */
    func getAttribute<Value>(_ attribute: Attribute<Value>) throws -> Value { try attribute.get(self) }

    /**
     Returns the value of the specified settable attribute.

     - Parameter attribute: The attribute to retrieve.
     - Returns: The value of the attribute.
     - Throws: An error if the attribute couldn't be retrieved.
     */
    func getAttribute<Value>(_ attribute: SettableAttribute<Value>) throws -> Value { try getAttribute(attribute.attribute) }

    /**
     Sets the value of the specified attribute.

     - Parameters:
       - attribute: The attribute to set.
       - value: The value to set.
     - Throws: An error if the attribute couldn't be set.
     */
    func setAttribute<Value>(_ attribute: SettableAttribute<Value>, to value: Value) throws { try attribute.set(self, value) }

    /**
     Returns the values of the specified attributes.

     Attributes that can't be retrieved are omitted from the returned dictionary.

     - Parameter attributes: The attributes to retrieve.
     - Returns: A dictionary keyed by attribute identifier.
     */
    func getAttributes<S: Sequence<any URLAttribute>>(_ attributes: S) -> [Int32: Any] {
        Dictionary(uniqueKeysWithValues: attributes.uniqued(by: \.identifier).compactMap {
            guard let attribute = $0 as? _URLAttribute, let value = try? attribute.getValue(self) else { return nil }
            return ($0.identifier, value)
        })
    }
    
    /**
     Returns the values of the specified attributes.

     Attributes that can't be retrieved are omitted from the returned dictionary.

     - Parameter attributes: The attributes to retrieve.
     - Returns: A dictionary keyed by attribute identifier.
     */
    func getAttributes(_ attributes: (any URLAttribute)...)-> [Int32: Any] {
        getAttributes(attributes)
    }
}

/// A file system attribute that can be accessed using a URL.
public protocol URLAttribute {
    /// The value type of the attribute.
    associatedtype Value
    /// The identifier of the attribute.
    var identifier: Int32 { get }
}

fileprivate protocol _URLAttribute {
    func getValue(_ url: URL) throws -> Any?
}

public extension URL.SettableAttribute<Date> {
    /// The date the item was added to its containing directory.
    static var addedToDirectoryDate: Self { .init(ATTR_CMN_ADDEDTIME, as: Darwin.timespec.self, decode: Date.init(timespec:), encode: \.timespec) }
    /// The date the item's attributes were last modified.
    static var attributeModificationDate: Self { .init(ATTR_CMN_CHGTIME, as: Darwin.timespec.self, decode: Date.init(timespec:), encode: \.timespec) }
}

public extension URL.SettableAttribute<URL.FileFlags> {
    /// The file system flags of the item.
    static var flags: Self { .init(ATTR_CMN_FLAGS, as: UInt32.self, decode: URL.FileFlags.init(rawValue:), encode: \.rawValue) }
}

public extension URL {
    /// The file system flags of an item.
    struct FileFlags: OptionSet, Hashable, Sendable {
        /// The item isn't included in file system dumps.
        public static let noDump = Self(UF_NODUMP)
        /// The item can't be changed by its owner.
        public static let immutable = Self(UF_IMMUTABLE)
        /// The item can only be appended to.
        public static let append = Self(UF_APPEND)
        /// The directory is opaque when viewed through a union mount.
        public static let opaque = Self(UF_OPAQUE)
        /// The item is stored in compressed form.
        public static let compressed = Self(UF_COMPRESSED)
        /// The item is tracked for rename and delete operations.
        public static let tracked = Self(UF_TRACKED)
        /// The item is protected by a data vault.
        public static let dataVault = Self(UF_DATAVAULT)
        /// The item is hidden.
        public static let hidden = Self(UF_HIDDEN)
        /// The item is archived.
        public static let archived = Self(SF_ARCHIVED)
        /// The item can't be changed except by the system.
        public static let systemImmutable = Self(SF_IMMUTABLE)
        /// The item can only be appended to except by the system.
        public static let systemAppend = Self(SF_APPEND)
        /// The item is restricted by the system.
        public static let restricted = Self(SF_RESTRICTED)
        /// The item can't be unlinked by ordinary operations.
        public static let noUnlink = Self(SF_NOUNLINK)
        /// The item is a firmlink.
        public static let firmLink = Self(SF_FIRMLINK)
        /// The item's data isn't stored locally.
        public static let dataLess = Self(SF_DATALESS)
        
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        init(_ rawValue: Int32) {
            self.rawValue = UInt32(rawValue)
        }
    }
}
