//
//  Interpose.swift
//
//  Copyright (c) 2020 Peter Steinberger
//  InterposeKit - https://github.com/steipete/InterposeKit/
//

import Foundation

final class Interpose {
    /// A Boolean value indicating whether logging is enabled.
     static var isLoggingEnabled = false

    /// Simple log wrapper for print.
    class func log(_ object: Any) {
        if isLoggingEnabled {
            print("[Interposer] \(object)")
        }
    }
}


extension Interpose {
    static func storeHook<HookType: AnyHook>(hook: HookType, to block: AnyObject) {
        setAssociatedValue(weak: hook, key: "_hook", object: block)
    }

    // Finds the hook to a given implementation.
    static func hookForIMP<HookType: AnyHook>(_ imp: IMP) -> HookType? {
        // Get the block that backs our IMP replacement
        guard let block = imp_getBlock(imp) as? AnyObject else { return nil }
        return getAssociatedValue("_hook", object: block)
    }

    // Find the hook above us (not necessarily topmost)
    static func findNextHook<HookType: AnyHook>(selfHook: HookType, topmostIMP: IMP) -> HookType? {
        // We are not topmost hook, so find the hook above us!
        var impl: IMP? = topmostIMP
        var currentHook: HookType?
        repeat {
            // get topmost hook
            let hook: HookType? = Interpose.hookForIMP(impl!)
            if hook === selfHook {
                // return parent
                return currentHook
            }
            // crawl down the chain until we find ourselves
            currentHook = hook
            impl = hook?.origIMP
        } while impl != nil
        return nil
    }
}
