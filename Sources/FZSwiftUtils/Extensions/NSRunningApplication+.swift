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
}
#endif
