//
//  OSHash.swift
//
//
//  Created by Florian Zand on 04.04.2023
//

import Foundation

/**
 An implementation of the OpenSuptitle hash.
 
 The OSHash is calculated via the provided file/data size + the checksum of the first and last 64k bytes (even if they overlap because the file/data is smaller than 128k bytes).
 */
public struct OSHash {
    /// OSHash errors.
    public enum Errors: Error {
        /// The file isn't available.
        case invalidFile
        /// The data / gile is too small.
        case toSmall
    }

    /// The number of bytes in an OSHash.
    public static let byteCount: Int = 65536
    /// The number of bytes that represents the hash function’s internal state.
    public static let blockByteCount = 8
    
    /// The hash value.
    let value: UInt64
    
    internal init(value: UInt64) {
        self.value = value
    }
}

public extension OSHash {
    /// The hash value.
    var stringValue: String {
        String(format: "%qx", arguments: [self.value])
    }
    
    /**
     Creates a OpenSubtitle hash for the file path.
     
     - Parameters path: The path to the file for calculating the hash.
     
     - Returns: The OpenSubtitle hash.
     
     - Throws: Throws if the file isn't available or to small.
     */
    init(path: String) throws  {
        try self.init(url: URL(fileURLWithPath: path))
    }
    
    /**
     Creates a OpenSubtitle hash for the file at the url.
     
     - Parameters url: The url to the file for calculating the hash.
     
     - Returns: The OpenSubtitle hash.
     
     - Throws: Throws if the file isn't available or to small.
     */
    init(url: URL) throws  {
        let fileHandler = try FileHandle(forReadingFrom: url)
        let startData: Data = fileHandler.readData(ofLength: Self.byteCount) as Data
        
        fileHandler.seekToEndOfFile()
        let fileSize: UInt64 = fileHandler.offsetInFile
        guard UInt64(Self.byteCount) <= fileSize else {
            fileHandler.closeFile()
            throw Errors.toSmall
        }

        fileHandler.seek(toFileOffset: max(0, fileSize - UInt64(Self.byteCount)))
        let endData: Data = fileHandler.readData(ofLength: Self.byteCount)

        try self.init(size: fileSize, startData: startData, endData: endData)
        fileHandler.closeFile()
    }
    
    /**
     Creates a OpenSubtitle hash for the data.
     
     - Parameters data: The data for calculating the hash.
     
     - Returns: The OpenSubtitle hash.
     
     - Throws: Throws if the data is to small.
     */
    init(data: Data) throws  {
        let size = UInt64(data.count)
        guard UInt64(Self.byteCount) <= size else {
            throw Errors.toSmall
        }
        let startData = data[0 ..< Self.byteCount]
        let endData = data[(data.count - 1 - Self.byteCount) ... data.count - 1]
        try self.init(size: size, startData: startData, endData: endData)
    }
    
    internal init(size: UInt64, startData: Data, endData: Data) throws  {
        guard UInt64(Self.byteCount) <= startData.count else {
            throw Errors.toSmall
        }
        var hash = size
        startData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: startData.count / Self.blockByteCount
            )
            hash = data_bytes.reduce(into: hash) { hash = $0 &+ $1 }
        }

        endData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: endData.count / Self.blockByteCount
            )
            hash = data_bytes.reduce(into: hash) { hash = $0 &+ $1 }
        }
        self.init(value: hash)
    }
}
