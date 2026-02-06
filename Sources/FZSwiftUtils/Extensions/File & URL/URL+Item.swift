//
//  URL+Item.swift
//
//
//  Created by Florian Zand on 07.09.24.
//

import Foundation

extension URL {
    /// The file system item of the url.
    public var item: Item {
        Item(self)
    }
    
    /// The file system item of an url.
    public struct Item {
        /// The url of the item.
        public let url: URL
        
        init(_ url: URL) {
            self.url = url
        }
        
        /// A Boolean value indicating whether the item exists.
        public var exists: Bool {
            FileManager.default.fileExists(at: url)
        }
        
        /// Copies the item to the specified url.
        public func copy(to url: URL) throws {
            try FileManager.default.copyItem(at: self.url, to: url)
        }
        
        /// Copies the item to the specified folder.
        public func copy(toFolder folder: URL) throws {
            try copy(to: folder.appendingPathComponent(url.lastPathComponent))
        }
        
        /// Moves the item to the specified url.
        public func move(to url: URL) throws {
            try FileManager.default.moveItem(at: self.url, to: url)
        }
        
        /// Moves the item to the specified folder.
        public func move(toFolder folder: URL) throws {
            try move(to: folder.appendingPathComponent(url.lastPathComponent))
        }
        
        /// Deletes the item.
        public func delete() throws {
            try FileManager.default.removeItem(at: url)
        }
        
        #if os(macOS) || os(iOS)
        /// Moves the item to the trash.
        @discardableResult
        public func moveToTrash() throws -> URL {
            try FileManager.default.trashItem(at: url)
        }
        #endif
        
        /// Creates a subfolder with the specified name.
        @discardableResult
        public func createSubfolder(named name: String) throws -> URL {
            guard url.isDirectory else { throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteInvalidFileNameError, userInfo: [NSLocalizedDescriptionKey: "Cannot create subfolder inside a non-directory item"]) }
            try FileManager.default.createDirectory(at: url.appendingPathComponent(name), withIntermediateDirectories: true)
            return url.appendingPathComponent(name)
        }
        
        /// Creates a symbolic link at the specified URL pointing to this item.
        public func createSymbolicLink(at url: URL) throws {
            try FileManager.default.createSymbolicLink(at: url, withDestinationURL: self.url)
        }
        
        /// Creates a hard link at the specified URL pointing to this item.
        public func createHardLink(at url: URL) throws {
            try FileManager.default.linkItem(at: self.url, to: url)
        }
        
        /// Creates a Finder alias at the specified URL pointing to this item.
        public func createAlias(at url: URL) throws {
            try FileManager.default.createAlias(at: self.url, to: url)
        }
        
        /// Reads the data of the file.
        public func read() throws -> Data {
            try Data(contentsOf: url)
        }
        
        /// Reads the file as a string.
        public func readAsString(encoding: String.Encoding = .utf8) throws -> String {
            try String(contentsOf: url, encoding: encoding)
        }
        
        /// Reads the file as the specified decodable type.
        public func read<V: Decodable>(as type: V.Type) throws -> V {
            try JSONDecoder().decode(type, from: read())
        }
        
        /// Reads the file as the specified decodable type.
        public func read<V: Decodable>(as type: V.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> V {
            try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(type, from: read())
        }
        
        /// Writes the specified data to the url.
        public func write(_ data: Data) throws {
            try data.write(to: url)
        }
        
        /// Writes the specified data to the url.
        public func write(_ data: Data, options: Data.WritingOptions) throws {
            try data.write(to: url, options: options)
        }
        
        /// The attributes off the item.
        public var attributes: FileAttributes? {
            get { try? FileManager.default.attributes(for: url) }
            set {
                guard let newValue = newValue else { return }
                try? FileManager.default.setAttributes(newValue, ofItemAt: url)
            }
        }
    }
}
