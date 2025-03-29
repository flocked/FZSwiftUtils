//
//  OSHash.swift
//
//
//  Created by Florian Zand on 04.04.2023
//

import Foundation

/**
 An implementation of the OpenSubtitle hash.
 
 The OSHash is calculated via the provided file size + the checksum of the first and last 64k bytes (even if they overlap because the file/data is smaller than 128k bytes).
 
 To access the hash value, use `hashValue`.
 */
public struct OSHash: Hashable {
    
    /// The number of bytes that represents the hash function’s internal state.
    static let blockByteCount: Int = 65536
    
    /// The number of bytes in a OSHash digest.
    static let byteCount = 8
    
    let digest: UInt64
    
    init(digest: UInt64) {
        self.digest = digest
    }
    
    /**
     Computes the `OSHash` digest for the specified file.
     
     - Throws: Throws if the file isn't available, can't be accessed or is to small.
     */
    public init(url: URL) throws {
        let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as! UInt64
        guard fileSize >= UInt64(Self.blockByteCount) else {
            self = Self(digest: fileSize)
            return
        }
        
        let fileHandler = try FileHandle(forReadingFrom: url)
        defer { fileHandler.closeFile() }
        
        let startData = fileHandler.readData(ofLength: Self.blockByteCount)
        fileHandler.seek(toFileOffset: fileSize - UInt64(Self.blockByteCount))
        let endData = fileHandler.readData(ofLength: Self.blockByteCount)
        
        self = Self.hash(size: fileSize, startData: startData, endData: endData)
    }
    
    /// Computes the `OSHash` digest for the specified data.
    public init<D: DataProtocol>(data: D) {
        let size = UInt64(data.count)
        guard size >= UInt64(Self.blockByteCount) else {
            self = Self(digest: size)
            return
        }
        
        let startData = data.prefix(Self.blockByteCount)
        let endData = data.suffix(Self.blockByteCount)
        
        self = Self.hash(size: size, startData: Data(startData), endData: Data(endData))
    }
    
    private static func hash(size: UInt64, startData: Data, endData: Data) -> Self {
        var hash = size
        hash = startData.withUnsafeBytes { buffer in
            buffer.bindMemory(to: UInt64.self).reduce(hash, &+)
        }
        hash = endData.withUnsafeBytes { buffer in
            buffer.bindMemory(to: UInt64.self).reduce(hash, &+)
        }
        return Self(digest: hash)
    }
}
