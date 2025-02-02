//
//  Enum+Name.swift
//
//
//  Created by Florian Zand on 05.07.23.
//

import Foundation

@_silgen_name("swift_EnumCaseName")
func _getEnumCaseName<T>(_ value: T) -> UnsafePointer<CChar>?

/// Returns the name of an enum case.
public func getEnumCaseName<T>(for value: T) -> String? {
    if let stringPtr = _getEnumCaseName(value) {
        return String(validatingUTF8: stringPtr)
    }
    return nil
}
