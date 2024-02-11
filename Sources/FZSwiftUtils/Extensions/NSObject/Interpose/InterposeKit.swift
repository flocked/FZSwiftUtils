import Foundation

final class Interpose {
    /// Logging uses print and is minimal.
    static var isLoggingEnabled = false

    /// Simple log wrapper for print.
    class func log(_ object: Any) {
        if isLoggingEnabled {
            print("[Interposer] \(object)")
        }
    }
}

extension Interpose {

    private struct AssociatedKeys {
        static var hookForBlock: UInt8 = 0
    }

    private class WeakObjectContainer<T: AnyObject>: NSObject {
        private weak var _object: T?

        var object: T? {
            return _object
        }
        init(with object: T?) {
            _object = object
        }
    }

    static func storeHook<HookType: AnyHook>(hook: HookType, to block: AnyObject) {
        set(weakAssociatedValue: hook, key: "_hook", object: block)
    }

    // Finds the hook to a given implementation.
    static func hookForIMP<HookType: AnyHook>(_ imp: IMP) -> HookType? {
        // Get the block that backs our IMP replacement
        guard let block = imp_getBlock(imp) as? AnyObject else { return nil }
        return getAssociatedValue(key: "_hook", object: block)
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
