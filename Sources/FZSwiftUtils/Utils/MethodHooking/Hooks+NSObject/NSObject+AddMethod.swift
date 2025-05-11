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
     
     try! tableView.addMethod(#selector(NSTableView.draggingSession(_:movedTo:)),
     methodSignature: (@convention(block) (NSDraggingSession, NSPoint) -> Void).self) {
        session, point in
        // method called
     }
     ```
                    
     - Returns: The token for resetting.
     */
    @discardableResult
    public func addMethod<MethodSignature> (_ selector: Selector, methodSignature: MethodSignature.Type = MethodSignature.self, _ implementation: MethodSignature) throws -> HookToken {
        try HookToken(addedMethod: self, selector: selector, implementation: implementation).apply(true)
    }
    
    @discardableResult
    public func addMethod<MethodSignature> (_ selector: String, methodSignature: MethodSignature.Type = MethodSignature.self,_ implementation: MethodSignature) throws -> HookToken {
        try addMethod(NSSelectorFromString(selector), methodSignature: methodSignature, implementation)
    }
}

class AddedMethodHook<MethodSignature>: AnyHook {
    let typeEncoding: String
    weak var object: AnyObject?
    
    var interposeSubclass: InterposeSubclass?
    
    let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
    
    var dynamicSubclass: AnyClass {
        interposeSubclass!.dynamicClass
    }
    
    override func replaceImplementation() throws {
        guard let object = object else { return }
        var hooks: [HookToken] = []
        defer { hooks.forEach({ try? $0.apply() }) }
        if !InterposeSubclass.isSubclass(object: object) {
            hooks = _AnyObject(object).allHooks
            try hooks.forEach({ try $0.revert(remove: false) })
        }
        interposeSubclass = try InterposeSubclass(object: object)
        _ = typeEncoding.withCString { typeEncodingPtr in
            class_replaceMethod(dynamicSubclass, selector, replacementIMP, typeEncodingPtr)
        }
        _AnyObject(object).addedMethods.insert(selector)
    }
    
    override func resetImplementation() throws {
        guard let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        let noop: @convention(block) (AnyObject) -> Void = { _ in }
        let noopIMP = imp_implementationWithBlock(noop)
        method_setImplementation(method, noopIMP)
        guard let object = object else { return }
        _AnyObject(object).addedMethods.remove(selector)
    }
    
    init(object: AnyObject, selector: Selector, implementation: MethodSignature) throws {
        guard !object.responds(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: type(of: object)) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(type(of: object)) failed")
        }
        self.typeEncoding = String(cString: typeEncoding)
        self.object = object
        try super.init(class: type(of: object), selector: selector, shouldValidate: false)
        let block = implementation as AnyObject
        replacementIMP = imp_implementationWithBlock(implementation as AnyObject)
        guard replacementIMP != nil else {
            throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
        }
        // Weakly store reference to hook inside the block of the IMP.
        Interpose.storeHook(hook: self, to: block)
    }
}

/*
 @discardableResult
 public func addMethodAlt(_ selector: Selector, closure: Any) throws -> Hooker {
     let hooker = try AddedMethodHookAlt(object: self, selector: selector, hookClosure: closure as AnyObject)
     try hooker.apply()
     return Hooker(hooker)
 }
 
 public struct Hooker {
     public let hook: AnyHook
     init(_ hook: AnyHook) {
         self.hook = hook
     }
 }
 
class AddedMethodHookAlt: AnyHook {
    let object: AnyObject
    
    var interposeSubclass: InterposeSubclass?
    
    let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
    
    var dynamicSubclass: AnyClass {
        interposeSubclass!.dynamicClass
    }
    
    let hookClosure: AnyObject
    
    override func replaceImplementation() throws {
        guard let typeEncoding = typeEncoding(for: selector, _class: `class`) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding failed")
        }
        var hooks: [HookToken] = []
        defer { hooks.forEach({ try? $0.apply() }) }
        if !InterposeSubclass.isSubclass(object: object) {
            hooks = _AnyObject(object).allHooks
            try hooks.forEach({ try $0.revert(remove: false) })
        }
        
        interposeSubclass = try InterposeSubclass(object: object)
        
        if token == nil {
            guard let newIMP = class_getMethodImplementation(dynamicSubclass, NSSelectorFromString(NSStringFromSelector(selector)+"_add")) else {
                throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)")
            }
            
            class_replaceMethod(dynamicSubclass, selector, newIMP, typeEncoding)
            
            token = try HookToken(for: object, selector: selector, mode: .instead, hookClosure: hookClosure).apply(true)
        }
        
        (object as? NSObject)?.addedMethods.insert(selector)
    }
    
    var token: HookToken?
    
    override func resetImplementation() throws {
        guard let deleteIMP = class_getMethodImplementation(dynamicSubclass, NSSelectorFromString(NSStringFromSelector(selector)+"_Remove")), let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        method_setImplementation(method, deleteIMP)
        _AnyObject(object).addedMethods.remove(selector)
    }
    
    init(object: AnyObject, selector: Selector, hookClosure: AnyObject) throws {
        guard !object.responds(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        self.object = object
        self.hookClosure = hookClosure
        try super.init(class: type(of: object), selector: selector, shouldValidate: false)
        /*
        let block = implementation as AnyObject
        replacementIMP = imp_implementationWithBlock(block)
        guard replacementIMP != nil else {
            throw NSObject.SwizzleError.unknownError("imp_implementationWithBlock failed for \(block) - slots exceeded?")
        }
        // Weakly store reference to hook inside the block of the IMP.
        Interpose.storeHook(hook: self, to: block)
         */
    }
}

/*
 guard let newIMP = class_getMethodImplementation(dynamicSubclass, NSSelectorFromString(NSStringFromSelector(selector)+"_add")) else {
     throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)")
 }
 
 class_replaceMethod(dynamicSubclass, selector, newIMP, typeEncoding)
 */
*/
