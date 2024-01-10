//
//  NSError+.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension NSError {
    /**
     Creates an `NSError` object for the specified POSIX error code.

     - Parameter errorCode: The POSIX error code.
     - Returns: An `NSError` object representing the POSIX error.
     */
    static func posix(_ errorCode: Int32) -> NSError {
        NSError(domain: NSPOSIXErrorDomain, code: Int(errorCode),
                userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(errorCode))])
    }
}
