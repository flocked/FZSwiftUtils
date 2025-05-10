import Foundation

/// A hook to an instance method and stores both the original and new implementation.
class ClassHook<MethodSignature, HookSignature>: TypedHook<MethodSignature, HookSignature> {
    /* HookSignature?: This must be optional or swift runtime will crash.
     Or swiftc may segfault. Compiler bug? */
    /// Initialize a new hook to interpose an instance method.
    public init(`class`: AnyClass, selector: Selector,
                implementation: (ClassHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
        try super.init(class: `class`, selector: selector)
        replacementIMP = imp_implementationWithBlock(implementation(self) as Any)
    }
    
    override func replaceImplementation() throws {
        let method = try validate()
        origIMP = class_replaceMethod(`class`, selector, replacementIMP, method_getTypeEncoding(method))
        guard origIMP != nil else { throw NSObject.SwizzleError.nonExistingImplementation(`class`, selector) }
        Interpose.log("Swizzled -[\(`class`).\(selector)] IMP: \(origIMP!) -> \(replacementIMP!)")
    }
    
    override func resetImplementation() throws {
        let method = try validate(expectedState: .interposed)
        precondition(origIMP != nil)
        let previousIMP = class_replaceMethod(`class`, selector, origIMP!, method_getTypeEncoding(method))
        guard previousIMP == replacementIMP else {
            throw NSObject.SwizzleError.unexpectedImplementation(`class`, selector, previousIMP)
        }
        Interpose.log("Restored -[\(`class`).\(selector)] IMP: \(origIMP!)")
    }
    
    /// The original implementation is cached at hook time.
    public override var original: MethodSignature {
        unsafeBitCast(origIMP, to: MethodSignature.self)
    }
}
