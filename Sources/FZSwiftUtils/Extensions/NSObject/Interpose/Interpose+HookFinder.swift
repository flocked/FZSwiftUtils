import Foundation

extension Interpose {
    static func storeHook<HookType: AnyHook>(hook: HookType, to block: AnyObject) {
        // Weakly store reference to hook inside the block of the IMP.
        setAssociatedValue(weak: hook, key: "hookForBlock", object: block)
    }

    // Finds the hook to a given implementation.
    static func hookForIMP<HookType: AnyHook>(_ imp: IMP) -> HookType? {
        // Get the block that backs our IMP replacement
        guard let block = imp_getBlock(imp) else { return nil }
        return getAssociatedValue("hookForBlock", object: block as AnyObject)
    }

    // Find the hook above us (not necessarily topmost)
    static func findNextHook<HookType: AnyHook>(selfHook: HookType, topmostIMP: IMP) -> HookType? {
        // We are not topmost hook, so find the hook above us!
        var impl: IMP? = topmostIMP
        var currentHook: HookType?
        repeat {
            // get topmost hook
            let hook: HookType? = hookForIMP(impl!)
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
