//
//  ColorSyncProfile+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

import Foundation
import ColorSync

public extension CFType where Self: ColorSyncProfile {
    /// Creates a color sync profile with the specified data.
    init?(data: Data) {
        guard let profile = ColorSyncProfileCreate(data as CFData, nil)?.takeRetainedValue() as? Self else { return nil}
        self = profile
    }
    
    /// Creates a color sync profile with the specified name.
    init?(name: String) {
        guard let profile = ColorSyncProfileCreateWithName(name as CFString)?.takeRetainedValue() as? Self else { return nil }
        self = profile
    }
    
    /// Creates a color sync profile with the specified url.
    init?(url: URL) {
        guard let profile = ColorSyncProfileCreateWithURL(url as CFURL, nil)?.takeRetainedValue() as? Self else { return nil }
        self = profile
    }
    
    /// Creates a color sync profile with the specified display identifier.
    init?(displayID: UInt32) {
        guard let profile = ColorSyncProfileCreateWithDisplayID(displayID)?.takeRetainedValue() as? Self else { return nil }
        self = profile
    }
}
