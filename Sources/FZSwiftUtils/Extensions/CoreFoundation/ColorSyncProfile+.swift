//
//  ColorSyncProfile+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

#if os(macOS)
import Foundation
import ColorSync



public extension CFType where Self == ColorSyncProfile {
    /// Creates a color sync profile with the specified data.
    init?(data: Data) {
        guard let profile = ColorSyncProfileCreate(data as CFData, nil)?.takeRetainedValue(), let colorProfile = ColorSyncProfile(profile) else { return nil}
        self = colorProfile
    }
    
    /// Creates a color sync profile with the specified name.
    init?(name: String) {
        guard let profile = ColorSyncProfileCreateWithName(name as CFString)?.takeRetainedValue(), let colorProfile = ColorSyncProfile(profile) else { return nil }
        self = colorProfile
    }
    
    /// Creates a color sync profile with the specified url.
    init?(url: URL) {
        guard let profile = ColorSyncProfileCreateWithURL(url as CFURL, nil)?.takeRetainedValue(), let colorProfile = ColorSyncProfile(profile) else { return nil }
        self = colorProfile
    }
    
    /// Creates a color sync profile with the specified display identifier.
    init?(displayID: UInt32) {
        guard let profile = ColorSyncProfileCreateWithDisplayID(displayID)?.takeRetainedValue(), let colorProfile = ColorSyncProfile(profile) else { return nil }
        self = colorProfile
    }
}
#endif
