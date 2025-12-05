//
//  ObjC.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation

/// Objective-C utilities.
public struct ObjC {
    /// Returns the type string of an instance variable.
    public static func typeEncoding(for ivar: Ivar) -> String? {
        ivar_getTypeEncoding(ivar).map { String(cString: $0) }
    }
}
