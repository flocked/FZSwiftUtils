//
//  NSRunningApplication+.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

#if os(macOS)
import AppKit

public extension NSRunningApplication {
    /// The application bundle.
    var bundle: Bundle? {
        guard let url = bundleURL else { return nil }
        return Bundle(url: url)
    }
    
    /// Returns the frontmost app, which is the app that receives key events.
    static var frontMost: NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }
    
    /// Returns the app that owns the currently displayed menu bar.
    static var menuBarOwning: NSRunningApplication? {
        NSWorkspace.shared.menuBarOwningApplication
    }
}
#endif
