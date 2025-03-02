//
//  Interpose+ObjectHook+Optional.swift
//
//
//  Created by Florian Zand on 14.02.25.
//

import Foundation

extension Interpose {
    /// A hook that adds an unimplemented optional instance method from a protocol to a single object.
    final public class OptionalObjectHook<MethodSignature, HookSignature>: TypedHook<MethodSignature, HookSignature> {
        /// The object that is being hooked.
        public let object: AnyObject

        /// Subclass that we create on the fly
        var interposeSubclass: InterposeSubclass?

        // Logic switch to use super builder
        let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
        
        var dynamicSubclass: AnyClass {
            interposeSubclass!.dynamicClass
        }
        
        override func replaceImplementation() throws {
            interposeSubclass = try InterposeSubclass(object: object)
            guard let typeEncoding = typeEncoding(for: selector, _class: `class`) else {
                throw NSObject.SwizzleError.unknownError("typeEncoding failed")
            }
            class_replaceMethod(dynamicSubclass, selector, replacementIMP, typeEncoding)
            (object as? NSObject)?.addedMethods.insert(selector)
        }
        
        override func resetImplementation() throws {
            guard let deleteIMP = class_getMethodImplementation(dynamicSubclass, NSSelectorFromString(NSStringFromSelector(selector)+"_Remove")), let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
           method_setImplementation(method, deleteIMP)
            (object as? NSObject)?.addedMethods.remove(selector)
        }
        
        /// Initialize a new hook to add an unimplemented instance method from a conforming protocol.
        public init(object: AnyObject, selector: Selector,
                    implementation: (OptionalObjectHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
            guard !object.responds(to: selector) else {
                throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
            }
            self.object = object
            try super.init(class: type(of: object), selector: selector, shouldValidate: false)
            let block = implementation(self) as AnyObject
            replacementIMP = imp_implementationWithBlock(block)
            guard replacementIMP != nil else {
                throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
            }

            // Weakly store reference to hook inside the block of the IMP.
            Interpose.storeHook(hook: self, to: block)
        }
    }
}
