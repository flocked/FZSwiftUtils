//
//  OSHash.swift
//  OSHash
//
//  Created by Florian Zand on 04.04.2023
//

import Foundation

public class OSHash {
   public enum HashError: Error {
        case invalidFile
        case toSmall
    }
    
    private static let chunkSize: Int = 65536
    private static let UInt64Size = 8
    
    public static func stringValue(for fileURL: URL) throws -> String  {
        let hash = try self.value(for: fileURL)
        return String(format:"%qx", arguments: [hash])
    }
    
    public static func stringValue(for filePath: String) throws -> String  {
        let hash = try self.value(for: filePath)
        return String(format:"%qx", arguments: [hash])
    }
    
    public static func stringValue(from data: Data) throws -> String  {
        let hash = try self.value(from: data)
        return String(format:"%qx", arguments: [hash])
    }
    
    public static func value(from data: Data) throws -> UInt64 {
        guard (UInt64(OSHash.chunkSize) <= data.count) else {
            throw HashError.toSmall
        }
        let dataBegin = data[0..<OSHash.chunkSize]
        let dataEnd = data[(data.count-1-OSHash.chunkSize)...data.count-1]
        return try value(startData: dataBegin, endData: dataEnd)
    }
    
    public static func value(for fileURL: URL) throws -> UInt64  {
        try self.value(for: fileURL.path)
    }
    
    public static func value(for filePath: String) throws -> UInt64  {
        guard let fileHandler = FileHandle(forReadingAtPath: filePath) else {
            throw HashError.invalidFile
        }
        let fileDataBegin: Data = fileHandler.readData(ofLength: OSHash.chunkSize) as Data
        fileHandler.seekToEndOfFile()
        
        let fileSize: UInt64 = fileHandler.offsetInFile
        guard (UInt64(OSHash.chunkSize) <= fileSize) else {
            fileHandler.closeFile()
            throw HashError.toSmall
        }
        
        fileHandler.seek(toFileOffset: max(0, fileSize - UInt64(OSHash.chunkSize)))
        let fileDataEnd: Data = fileHandler.readData(ofLength: OSHash.chunkSize)
        
        let hashValue = try value(startData: fileDataBegin, endData: fileDataEnd)
        fileHandler.closeFile()
        return hashValue
    }
    
    internal static func value(startData: Data, endData: Data)  throws -> UInt64 {
        guard (UInt64(OSHash.chunkSize) <= startData.count) else {
            throw HashError.toSmall
        }
        var hash: UInt64 = UInt64(startData.count)
        startData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: startData.count/OSHash.UInt64Size)
            hash = data_bytes.reduce(into: hash,  { hash = $0 &+ $1 })
        }
        
        endData.withUnsafeBytes { buffer in
            let binded = buffer.bindMemory(to: UInt64.self)
            let data_bytes = UnsafeBufferPointer<UInt64>(
                start: binded.baseAddress,
                count: endData.count/OSHash.UInt64Size)
            hash = data_bytes.reduce(into: hash,  { hash = $0 &+ $1 })
        }
        return hash
    }
}

