//
//  Interpose+ObjectHook+Optional.swift
//
//
//  Created by Florian Zand on 14.02.25.
//

import Foundation

extension NSObject {
    /**
     Adds an unimplemented protocol method to the object.
     
     Use this method to add an unimplemented protocol method to the object. To replace an existing method use ``hook(_:closure:)``.
     
     Example usage:
     
     ```swift
     let tableView = NSTableView()
     
     try tableView.addMethod(selector, closure: { session, point in
          // Method called
      } as @convention(block) (NSDraggingSession, NSPoint) -> Void)
     ```
                    
     - Returns: The token for resetting.
     */
    @discardableResult
    public func addMethod(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook(addMethod: self, selector: selector, hookClosure: closure as AnyObject).apply(true)
    }
    
    @discardableResult
    public func addMethod(_ selector: String, closure: Any) throws -> Hook {
        try addMethod(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Adds an unimplemented protocol method to all instances of the class.
     
     Use this method to add an unimplemented protocol method to the object. To replace an existing method use ``hook(_:closure:)``.
     
     Example usage:
     
     ```swift
     try NSTableView.addMethod(selector, closure: { session, point in
          // Method called
      } as @convention(block) (NSDraggingSession, NSPoint) -> Void)
     ```
                    
     - Returns: The token for resetting.
     */
    @discardableResult
    public static func addMethod(all selector: Selector, closure: Any) throws -> Hook {
        try Hook(addMethod: self, selector: selector, hookClosure: closure as AnyObject).apply(true)
    }
    
    @discardableResult
    public static func addMethod(all selector: String, closure: Any) throws -> Hook {
        try addMethod(all: NSSelectorFromString(selector), closure: closure)
    }
}

class AddMethodHook: AnyHook {
    let typeEncoding: String
    weak var object: AnyObject?
    var didSubclass = false
    
    var interposeSubclass: InterposeSubclass?
    
    let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
    
    var dynamicSubclass: AnyClass {
        interposeSubclass!.dynamicClass
    }
    
    #if os(macOS) || os(iOS)
    override func replaceImplementation() throws {
        guard let object = object else { return }
        var hooks: [Hook] = []
        defer { hooks.forEach({ try? $0.apply() }) }
        if !didSubclass {
            didSubclass = true
            if !InterposeSubclass.isSubclass(object: object) {
                hooks = _AnyObject(object).allHooks
                try hooks.forEach({ try $0.revert(remove: false) })
            }
            interposeSubclass = try InterposeSubclass(object: object)
        }
        _ = typeEncoding.withCString { typeEncodingPtr in
            class_replaceMethod(dynamicSubclass, selector, replacementIMP, typeEncodingPtr)
        }
        _AnyObject(object).addedMethods.insert(selector)
    }
    #else
    override func replaceImplementation() throws {
        guard let object = object else { return }
        if !didSubclass {
            didSubclass = true
            interposeSubclass = try InterposeSubclass(object: object)
        }
        _ = typeEncoding.withCString { typeEncodingPtr in
            class_replaceMethod(dynamicSubclass, selector, replacementIMP, typeEncodingPtr)
        }
        (object as? NSObject)?.addedMethods.insert(selector)
    }
    #endif
    
    override func resetImplementation() throws {
        guard let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        let noop: @convention(block) (AnyObject) -> Void = { _ in }
        let noopIMP = imp_implementationWithBlock(noop)
        method_setImplementation(method, noopIMP)
        guard let object = object else { return }
        #if os(macOS) || os(iOS)
        _AnyObject(object).addedMethods.remove(selector)
        #else
        (object as? NSObject)?.addedMethods.remove(selector)
        #endif
    }
    
    init(object: AnyObject, selector: Selector, hookClosure: Any) throws {
        guard !object.responds(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: type(of: object), optionalOnly: true) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(type(of: object)) failed")
        }
        #if os(macOS) || os(iOS)
        try Hook.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure as AnyObject)
        #endif
        self.typeEncoding = String(cString: typeEncoding)
        self.object = object
        try super.init(class: type(of: object), selector: selector, shouldValidate: false)
        let block = hookClosure as AnyObject
        replacementIMP = imp_implementationWithBlock(hookClosure as AnyObject)
        guard replacementIMP != nil else {
            throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
        }
        // Weakly store reference to hook inside the block of the IMP.
        Interpose.storeHook(hook: self, to: block)
    }
}

class AddInstanceMethodHook: AnyHook {
    let typeEncoding: String
    let class_: AnyClass
    
    override func replaceImplementation() throws {
        _ = typeEncoding.withCString { typeEncodingPtr in
            class_replaceMethod(class_, selector, replacementIMP, typeEncodingPtr)
        }
        #if os(macOS) || os(iOS)
        _AnyClass(class_).addedMethods.insert(selector)
        #else
        (class_ as? NSObject.Type)?.addedMethods.insert(selector)
        #endif
    }
    
    override func resetImplementation() throws {
        guard let method = class_getInstanceMethod(class_, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        let noop: @convention(block) (AnyObject) -> Void = { _ in }
        let noopIMP = imp_implementationWithBlock(noop)
        method_setImplementation(method, noopIMP)
        #if os(macOS) || os(iOS)
        _AnyClass(class_).addedMethods.remove(selector)
        #else
        (class_ as? NSObject.Type)?.addedMethods.remove(selector)
        #endif
    }
    
    init<T: NSObject>(class_: T.Type, selector: Selector, hookClosure: Any) throws {
        guard !class_.instancesRespond(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: class_, optionalOnly: true) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(class_) failed")
        }
        #if os(macOS) || os(iOS)
        try Hook.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure as AnyObject)
        #endif
        self.typeEncoding = String(cString: typeEncoding)
        self.class_ = class_
        try super.init(class: class_, selector: selector, shouldValidate: false)
        let block = hookClosure as AnyObject
        replacementIMP = imp_implementationWithBlock(hookClosure as AnyObject)
        guard replacementIMP != nil else {
            throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
        }
        // Weakly store reference to hook inside the block of the IMP.
        Interpose.storeHook(hook: self, to: block)
    }
}

#if os(watchOS) || os(tvOS)
extension NSObject {
    var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            if newValue.count == 1 {
                do {
                    try hook(#selector(ByteCountFormatter.string(for:)),
                         methodSignature: (@convention(c)  (AnyObject, Selector, Selector?) -> (Bool)).self,
                         hookSignature: (@convention(block)  (AnyObject, Selector?) -> (Bool)).self) { store in {
                             object, selector in
                        if let selector = selector, (object as? NSObject)?.addedMethods.contains(selector) == true {
                            return true
                        }
                        return store.original(object, store.selector, selector)
                         } }
                } catch {
                    Swift.print(error)
                }
            } else if newValue.isEmpty {
                revertHooks(for: #selector(NSObject.responds(to:)))
            }
        }
    }
    
    static var addedMethods: Set<Selector> {
        get { getAssociatedValue("addedMethods") ?? [] }
        set {
            setAssociatedValue(newValue, key: "addedMethods")
            if newValue.count == 1 {
                do {
                    try hook(#selector(ByteCountFormatter.string(for:)),
                         methodSignature: (@convention(c)  (AnyObject, Selector, Selector?) -> (Bool)).self,
                         hookSignature: (@convention(block)  (AnyObject, Selector?) -> (Bool)).self) { store in {
                             object, selector in
                        if let selector = selector, (object as? NSObject.Type)?.addedMethods.contains(selector) == true {
                            return true
                        }
                        return store.original(object, store.selector, selector)
                         } }
                } catch {
                    Swift.print(error)
                }
            } else if newValue.isEmpty {
                revertHooks(for: #selector(NSObject.responds(to:)))
            }
        }
    }
}
#endif
