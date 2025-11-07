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
    
    /// The running applications.
    class var runningApplications: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
    }
        
    /**
     The running applications with the specified localized name.
         
     - Parameter name: Tha localized application name.
     */
    class func runningApplications(named name: String) -> [NSRunningApplication] {
        runningApplications.filter({ $0.localizedName == name })
    }
}
#endif
