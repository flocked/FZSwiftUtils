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
        
        let url: URL
        
        init(_ url: URL) {
            self.url = url
        }
        
        /// A Boolean value that indicates whether the item exists.
        public var exists: Bool {
            FileManager.default.fileExists(at: url)
        }
        
        /// Copies the item to the specified folder.
        public func copy(to folder: URL) throws {
            try FileManager.default.copyItem(at: url, to: folder.appendingPathComponent(url.lastPathComponent))
        }
        
        /// Moves the item to the specified folder.
        public func move(to folder: URL) throws {
            try FileManager.default.moveItem(at: url, to: folder.appendingPathComponent(url.lastPathComponent))
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
        
        /// Reads the data of the file.
        public func read() throws -> Data {
            try Data(contentsOf: url)
        }
        
        /// Reads the file as a string.
        public func readAsString(encodedAs encoding: String.Encoding = .utf8) throws -> String {
            guard let string = try String(data: read(), encoding: encoding) else {
                throw Errors.stringDecodingFailed
            }
            return string
        }
        
        /// Reads the file as the specified decodable type.
        public func read<V: Decodable>(as type: V.Type) throws -> V {
            return try JSONDecoder().decode(type, from: try read())
        }
        
        /// Reads the file as the specified decodable type.
        public func read<V: Decodable>(as type: V.Type, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) throws -> V {
            return try JSONDecoder(dateDecodingStrategy: dateDecodingStrategy, keyDecodingStrategy: keyDecodingStrategy, dataDecodingStrategy: dataDecodingStrategy).decode(type, from: try read())
        }
        
        /// Writes the specified data to the url.
        public func write(_ data: Data) throws {
            try data.write(to: url)
        }
        
        /// Writes the specified data to the url.
        public func write(_ data: Data, options: Data.WritingOptions) throws {
            try data.write(to: url, options: options)
        }
        
        /// Creates a subfolder with the specified name.
        public func createSubfolder(named name: String) throws {
            try FileManager.default.createDirectory(at: url.appendingPathComponent(name), withIntermediateDirectories: true)
        }
        
        enum Errors: Error {
            case stringDecodingFailed
        }
    }
}
