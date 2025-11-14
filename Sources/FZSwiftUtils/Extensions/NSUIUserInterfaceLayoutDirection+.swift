//
//  NSUIUserInterfaceLayoutDirection+.swift
//
//
//  Created by Florian Zand on 14.11.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension NSUIUserInterfaceLayoutDirection {
    /// The application's layout direction of the user interface.
    static var app: Self {
        #if os(macOS)
        NSApp.userInterfaceLayoutDirection
        #else
        UIApplication.shared.userInterfaceLayoutDirection
        #endif
    }
}

#endif
