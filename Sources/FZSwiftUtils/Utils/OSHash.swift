//
//  OSHash.swift
//
//
//  Created by Florian Zand on 04.04.2023
//

import Foundation
import CryptoKit

/**
 An implementation of the OpenSuptitle hash.

 The OSHash is calculated via the provided file size + the checksum of the first and last 64k bytes (even if they overlap because the file/data is smaller than 128k bytes).

 - Note: The file has to be at least 65536 bytes large.
 */
public struct OSHash: HashFunction {
    
    /// The number of bytes that represents the hash function’s internal state.
    public static let blockByteCount: Int = 65536
  
    /// The number of bytes in a OSHash digest.
    public static let byteCount = 8
    
    /// The digest type for a OSHash hash function.
    public typealias Digest = OSHashDigest
    
    let digest: Data = Data()
    
    /// Creates a OSHash hash function.
    public init() {
        
    }
    
    /**
     Computes the OSHash digest for the specified file.
     
     - Throws: Throws if the file isn't available, can't be accessed or is to small.
     */
    public static func hash(url: URL) throws -> OSHashDigest {
        let fileHandler = try FileHandle(forReadingFrom: url)
        let startData: Data = fileHandler.readData(ofLength: Self.blockByteCount) as Data

        fileHandler.seekToEndOfFile()
        let fileSize: UInt64 = fileHandler.offsetInFile
        
        guard UInt64(Self.blockByteCount) <= fileSize else {
            fileHandler.closeFile()
            return OSHashDigest(digest: fileSize)
        }
        
        fileHandler.seek(toFileOffset: max(0, fileSize - UInt64(Self.blockByteCount)))
        let endData: Data = fileHandler.readData(ofLength: Self.blockByteCount)
        return hash(size: fileSize, startData: startData, endData: endData)
    }
    
    /// Computes the OSHash digest for the specified data.
    public static func hash<D>(data: D) -> OSHashDigest where D : DataProtocol {
        let data = Data(data)
        let size = UInt64(data.count)
        let startData = data[0 ..< Self.blockByteCount]
        let endData = data[(data.count - 1 - Self.blockByteCount) ... data.count - 1]
        return hash(size: size, startData: startData, endData: endData)
    }
    
    static func hash(size: UInt64, startData: Data, endData: Data) -> OSHashDigest {
        var hash = size
        guard UInt64(Self.blockByteCount) <= size else {
            return OSHashDigest(digest: hash)
        }
        
        startData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: startData.count / MemoryLayout<UInt64>.size
            )
            hash = data_bytes.reduce(hash,&+)
        }
        endData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: endData.count / MemoryLayout<UInt64>.size
            )
            hash = data_bytes.reduce(hash,&+)
        }
        return OSHashDigest(digest: hash)
    }
    
    /// Not implemented. Use either ``hash(data:)`` or ``hash(url:)``.
    public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
        
    }
    
    /// Not implemented. Use either ``hash(data:)`` or ``hash(url:)``.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try digest.withUnsafeBytes(body)
    }
    
    /// Not implemented. Use either ``hash(data:)`` or ``hash(url:)``.
    public func finalize() -> OSHashDigest {
        OSHashDigest(digest: digest)
    }
}

/// The output of a OpenSuptitle hash.
public struct OSHashDigest: Digest {
    
    private let digest: Data

    public static var byteCount: Int = 8

    init(digest: Data) {
        self.digest = digest
    }
    
    init(digest: UInt64) {
        let byteArray = Swift.withUnsafeBytes(of: digest.bigEndian) {
            Array($0)
        }
        self.digest = Data(byteArray)
    }
    
    
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try digest.withUnsafeBytes(body)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(digest)
    }
    
    public var description: String {
        hexString
    }
    
    public func makeIterator() -> Data.Iterator {
        digest.makeIterator()
    }
}
