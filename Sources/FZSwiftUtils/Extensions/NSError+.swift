//
//  File.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import Foundation

public extension NSError {
    static func posix(_ err: Int32) -> NSError {
        NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
