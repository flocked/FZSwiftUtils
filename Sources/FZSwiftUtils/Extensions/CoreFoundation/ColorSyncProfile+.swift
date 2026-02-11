//
//  ColorSyncProfile+.swift
//
//
//  Created by Florian Zand on 05.12.25.
//

#if os(macOS)
import Foundation
import ColorSync
import AppKit

public extension CFType where Self == ColorSyncProfile {
    /// Creates a color sync profile with the specified data.
    init?(data: Data) {
        guard let profile = ColorSyncProfileCreate(data as CFData, nil)?.takeRetainedValue() else { return nil}
        self.init(profile)
    }
    
    /// Creates a color sync profile with the specified name.
    init?(name: String) {
        guard let profile = ColorSyncProfileCreateWithName(name as CFString)?.takeRetainedValue() else { return nil }
        self.init(profile)
    }
    
    /// Creates a color sync profile with the specified url.
    init?(url: URL) {
        guard let profile = ColorSyncProfileCreateWithURL(url as CFURL, nil)?.takeRetainedValue() else { return nil }
        self.init(profile)
    }
    
    /// Creates a color sync profile with the specified display identifier.
    init?(displayID: UInt32) {
        guard let profile = ColorSyncProfileCreateWithDisplayID(displayID)?.takeRetainedValue() else { return nil }
        self.init(profile)
    }
    
    /// Creates a color sync profile with the specified screen.
    init?(screen: NSScreen) {
        guard let displayID = screen.displayID else { return nil }
        self.init(displayID: displayID)
    }
}

fileprivate extension NSScreen {
    var displayID: CGDirectDisplayID? {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
}
#endif
