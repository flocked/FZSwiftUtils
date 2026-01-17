//
//  ObjCIvarInfo.swift
//
//
//  Created by p-x9 on 2024/06/23
//  
//

import Foundation

/// Represents information about an Objective-C instance variable.
public struct ObjCIvarInfo: Sendable, Equatable, Codable {
    /// Name of the Ivar.
    public let name: String
    /// Encoded type of the Ivar.
    public let typeEncoding: String
    /// Offset of the Ivar.
    public let offset: Int
    
    /// Type of Ivar.
    public var type: ObjCType? {
        ObjCType(typeEncoding)
    }
    
    /// The size of the ivat.
    public var size: Int {
        var alignment = 0
        var size: Int = 0
        NSGetSizeAndAlignment(typeEncoding, &size, &alignment)
        return size
    }
    
    /**
     Initializes a new instance of `ObjCIvarInfo`.

     - Parameters:
       - name: Name of the ivar.
       - typeEncoding: Encoded type of the ivar.
       - offset: Offset of the ivar.
     */
    public init(name: String, typeEncoding: String, offset: Int) {
        self.name = name
        self.typeEncoding = typeEncoding
        self.offset = offset
    }

    /**
     Initializes a new instance of `ObjCIvarInfo` for the specified ivar.

     - Parameter ivar: The ivar of the target for which information is to be obtained.
     */
    public init?(_ ivar: Ivar) {
        guard let name = ivar_getName(ivar), let typeEncoding = ivar_getTypeEncoding(ivar) else {  return nil }
        self.init(
            name: String(cString: name),
            typeEncoding: String(cString: typeEncoding),
            offset: ivar_getOffset(ivar)
        )
    }
}

extension ObjCIvarInfo: CustomStringConvertible {
    /// Returns a string representing the ivar in a Objective-C header.
    public var headerString: String {
        if let type, case let .bitField(width) = type {
            let field = ObjCField(type: .int, name: name, bitWidth: width)
            return field.decodedForHeader(fallbackName: name)
        } else {
            if [.char, .uchar].contains(type) {
                return "BOOL \(name)"
            }
            let type = type?.decoded()
            if let type, type.last == "*" {
                return "\(type)\(name);"
            }
            return "\(type ?? "unknown") \(name);"
        }
    }
    
    public var description: String { headerString }
}
