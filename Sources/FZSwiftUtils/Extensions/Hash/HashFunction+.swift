//
//  HashFunction+.swift
//
//
//  Created by Florian Zand on 22.09.22.
//

import Foundation
import CryptoKit

public extension HashFunction {
    
    /// Computes the hash digest of the string and returns the computed digest.
    static func hash(string: String) -> Digest? {
        if let data = string.data(using: .utf16) {
            return hash(data: data)
        }
        return nil
    }
    
    /// Computes the hash digest from a file without loading all the data into memory. Defaults to a 10 MB buffer.
    static func hash(fileStream input: URL, bufferSizeBytes: Int = 1024 * 1024 * 10) throws -> Digest {
        let stream = try InputStream(url: input).unwrap()
        return try hash(stream: stream, bufferSizeBytes: bufferSizeBytes)
    }

    /// Computes the hash digest from a stream without loading all the data into memory. Defaults to a 10 MB buffer.
    static func hash(stream input: InputStream, bufferSizeBytes: Int = 1024 * 1024 * 10) throws -> Digest {
        var hasher = Self.init()
        
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: bufferSizeBytes)
        guard let pointer = buffer.baseAddress else { throw NSError(domain: "Error allocating buffer", code: -2) }
        input.open()
        while input.hasBytesAvailable {
            let bytesRead = input.read(pointer, maxLength: bufferSizeBytes)
            let bufferrr = UnsafeRawBufferPointer(start: pointer, count: bytesRead)
            hasher.update(bufferPointer: bufferrr)
        }
        input.close()

        return hasher.finalize()
    }
}
