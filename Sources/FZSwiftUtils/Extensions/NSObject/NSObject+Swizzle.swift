//
//  NSObject+Swizzle.swift
//
//  Created by Florian Zand on 05.10.23.
//
//  Adopted from:
//  InterposeKit - https://github.com/steipete/InterposeKit/
//  Copyright (c) 2020 Peter Steinberger

import Foundation

public extension NSObject {
    /**
     Replace an `@objc dynamic` instance method via selector on the current object.

     Example usage that replaces the `mouseDown`method of a view:

     ```swift
     let view = NSView()
     do {
         try view.replaceMethod(
             #selector(NSView.mouseDown(with:)),
             methodSignature: (@convention(c)  (AnyObject, Selector, NSEvent) -> ()).self,
             hookSignature: (@convention(block)  (AnyObject, NSEvent) -> ()).self) { store in {
                object, event in
                let view = (object as! NSView)
                // handle replaced `mouseDown`

                // calls `super.mouseDown`
                store.original(object, #selector(NSView.mouseDown(with:)), event)
             }
        }
     } catch {
     // handle error
     }
     ```
     */
    func replaceMethod<MethodSignature, HookSignature>(
        _ selector: Selector,
        methodSignature _: MethodSignature.Type = MethodSignature.self,
        hookSignature _: HookSignature.Type = HookSignature.self,
        _ implementation: (Hook<MethodSignature>) -> HookSignature?
    ) throws {
        let subclass: AnyClass = try subclass()
        let hook = Hook<MethodSignature>(selector: selector, class: type(of: self))
        let block = implementation(hook) as AnyObject
        let replacementIMP = imp_implementationWithBlock(block)
        guard let viewClass = object_getClass(self) else { return }
        guard let method = class_getInstanceMethod(viewClass, selector) else { return }
        let encoding = method_getTypeEncoding(method)

        let hasExistingMethod = hasExistingMethod(subclass, selector)
        if hasExistingMethod {
            class_replaceMethod(subclass, selector, replacementIMP, encoding)
        } else {
            class_addMethod(subclass, selector, replacementIMP, encoding)
        }
    }

    /// Resets an `@objc dynamic` instance method on the current object to it's original state.
    func resetMethod(_ selector: Selector) {
        guard let subclass = getExistingSubclass() else { return }
        guard let viewClass = object_getClass(self) else { return }
        guard let method = class_getInstanceMethod(viewClass, selector) else { return }
        let encoding = method_getTypeEncoding(method)
        let hasExistingMethod = hasExistingMethod(subclass, selector)
        if hasExistingMethod {
            if let originalIMP = originalIMP(for: selector) {
                class_replaceMethod(subclass, selector, originalIMP, encoding)
            }
        }
    }
}

extension NSObject {
    enum ObjCMethodEncoding {
        static let getClass = extract("#@:")

        private static func extract(_ string: StaticString) -> UnsafePointer<CChar> {
            UnsafeRawPointer(string.utf8Start).assumingMemoryBound(to: CChar.self)
        }
    }

    func subclass() throws -> AnyClass {
        try getExistingSubclass() ?? createSubclass()
    }

    func replaceMethod<MethodSignature>(for selector: Selector, replacement: MethodSignature) throws {
        let dynamicSubclass: AnyClass = try subclass()
        let replacementIMP = imp_implementationWithBlock(replacement)

        guard let viewClass = object_getClass(self) else { return }
        guard let method = class_getInstanceMethod(viewClass, selector) else { return }
        let encoding = method_getTypeEncoding(method)

        class_addMethod(dynamicSubclass, selector, replacementIMP, encoding)
    }

    func originalMethod<MethodSignature>(for selector: Selector) -> MethodSignature? {
        var currentClass: AnyClass? = type(of: self)
        repeat {
            if let currentClass = currentClass,
               let method = class_getInstanceMethod(currentClass, selector)
            {
                let origIMP = method_getImplementation(method)

                return unsafeBitCast(origIMP, to: MethodSignature.self)
            }
            currentClass = class_getSuperclass(currentClass)
        } while currentClass != nil
        return nil
    }

    func originalIMP(for selector: Selector) -> IMP? {
        var currentClass: AnyClass? = type(of: self)
        repeat {
            if let currentClass = currentClass,
               let method = class_getInstanceMethod(currentClass, selector)
            {
                return method_getImplementation(method)
            }
            currentClass = class_getSuperclass(currentClass)
        } while currentClass != nil
        return nil
    }

    func hasExistingMethod(_ klass: AnyClass, _ selector: Selector) -> Bool {
        var methodCount: CUnsignedInt = 0
        guard let methodsInAClass = class_copyMethodList(klass, &methodCount) else { return false }
        defer { free(methodsInAClass) }
        for index in 0 ..< Int(methodCount) {
            let method = methodsInAClass[index]
            if method_getName(method) == selector {
                return true
            }
        }
        return false
    }

    func createSubclass() throws -> AnyClass {
        let perceivedClass: AnyClass = type(of: self)
        let actualClass: AnyClass = object_getClass(self)!

        let className = NSStringFromClass(perceivedClass)
        // Right now we are wasteful. Might be able to optimize for shared IMP?
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let subclassName = "FZSubclass_" + className + uuid

        let subclass: AnyClass? = subclassName.withCString { cString in
            // swiftlint:disable:next force_cast
            if let existingClass = objc_getClass(cString) as! AnyClass? {
                return existingClass
            } else {
                guard let subclass: AnyClass = objc_allocateClassPair(actualClass, cString, 0) else { return nil }
                replaceGetClass(in: subclass, decoy: perceivedClass)
                objc_registerClassPair(subclass)
                return subclass
            }
        }

        guard let nnSubclass = subclass else {
            throw NSObjectSwizzleError.failedToAllocateClassPair(class: perceivedClass, subclassName: subclassName)
        }

        object_setClass(self, nnSubclass)
        // let oldName = NSStringFromClass(class_getSuperclass(object_getClass(self)!)!)
        // debugPrint("Generated \(NSStringFromClass(nnSubclass)) for object (was: \(oldName))")
        return nnSubclass
    }

    func replaceGetClass(in class: AnyClass, decoy perceivedClass: AnyClass) {
        // crashes on linux
        let getClass: @convention(block) (AnyObject) -> AnyClass = { _ in
            perceivedClass
        }
        let impl = imp_implementationWithBlock(getClass as Any)
        _ = class_replaceMethod(`class`, Selector((("class"))), impl, ObjCMethodEncoding.getClass)
        _ = class_replaceMethod(object_getClass(`class`), Selector((("class"))), impl, ObjCMethodEncoding.getClass)
    }

    /// We need to reuse a dynamic subclass if the object already has one.
    func getExistingSubclass() -> AnyClass? {
        let actualClass: AnyClass = object_getClass(self)!
        if NSStringFromClass(actualClass).hasPrefix("FZSubclass_") {
            return actualClass
        }
        return nil
    }
}

public class Hook<MethodSignature> {
    let selector: Selector
    let `class`: AnyClass
    init(selector: Selector, class: AnyClass) {
        self.selector = selector
        self.class = `class`
    }

    public var original: MethodSignature {
        var currentClass: AnyClass? = `class`
        repeat {
            if let currentClass = currentClass,
               let method = class_getInstanceMethod(currentClass, selector)
            {
                let origIMP = method_getImplementation(method)
                return unsafeBitCast(origIMP, to: MethodSignature.self)
            }
            currentClass = class_getSuperclass(currentClass)
        } while currentClass != nil
        preconditionFailure("IMP must be found for call")
    }
}

public enum NSObjectSwizzleError: LocalizedError {
    /// Unable to register subclass for object-based interposing.
    case failedToAllocateClassPair(class: AnyClass, subclassName: String)

    public var errorDescription: String? {
        switch self {
        case let .failedToAllocateClassPair(klass, subclassName):
            return "Failed to allocate class pair: \(klass), \(subclassName)"
        }
    }
}
