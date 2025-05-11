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
        try Hook(addedMethod: self, selector: selector, hookClosure: closure as AnyObject).apply(true)
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
    public static func addMethod(_ selector: Selector, closure: Any) throws -> Hook {
        try Hook(addedMethod: self, selector: selector, hookClosure: closure as AnyObject).apply(true)
    }
    
    @discardableResult
    public static func addMethod(_ selector: String, closure: Any) throws -> Hook {
        try addMethod(NSSelectorFromString(selector), closure: closure)
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
    
    override func resetImplementation() throws {
        guard let method = class_getInstanceMethod(dynamicSubclass, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        let noop: @convention(block) (AnyObject) -> Void = { _ in }
        let noopIMP = imp_implementationWithBlock(noop)
        method_setImplementation(method, noopIMP)
        guard let object = object else { return }
        _AnyObject(object).addedMethods.remove(selector)
    }
    
    init(object: AnyObject, selector: Selector, hookClosure: Any) throws {
        guard !object.responds(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: type(of: object)) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(type(of: object)) failed")
        }
        try Hook.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure as AnyObject)
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
        var hooks: [Hook] = []
        defer { hooks.forEach({ try? $0.apply() }) }
        _ = typeEncoding.withCString { typeEncodingPtr in
            class_replaceMethod(class_, selector, replacementIMP, typeEncodingPtr)
        }
        _AnyClass(class_).addedMethods.insert(selector)
    }
    
    override func resetImplementation() throws {
        guard let method = class_getInstanceMethod(class_, selector) else { throw NSObject.SwizzleError.resetUnsupported("Couldn't reset the added method \(selector)") }
        let noop: @convention(block) (AnyObject) -> Void = { _ in }
        let noopIMP = imp_implementationWithBlock(noop)
        method_setImplementation(method, noopIMP)
        _AnyClass(class_).addedMethods.remove(selector)
    }
    
    init<T: NSObject>(class_: T.Type, selector: Selector, hookClosure: Any) throws {
        guard !class_.instancesRespond(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: class_) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(class_) failed")
        }
        try Hook.parametersCheck(typeEncoding: typeEncoding, closure: hookClosure as AnyObject)
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
 
/*
class AddedMethodHookAlt: AnyHook {
    weak var object: AnyObject?
    let token: Hook
    var didSubclass = false
    let typeEncoding: String
    
    var interposeSubclass: InterposeSubclass?
    
    let generatesSuperIMP = InterposeSubclass.supportsSuperTrampolines
    
    var dynamicSubclass: AnyClass {
        interposeSubclass!.dynamicClass
    }
        
    override func replaceImplementation() throws {
        guard let object = object else { return }
        var hooks: [Hook] = []
        defer { hooks.forEach({ try? $0.apply() }) }
        
        if !didSubclass {
            if !InterposeSubclass.isSubclass(object: object) {
                hooks = _AnyObject(object).allHooks
                try hooks.forEach({ try $0.revert(remove: false) })
            }
            interposeSubclass = try InterposeSubclass(object: object)
            didSubclass = true
            let noop: @convention(block) (AnyObject) -> Void = { _ in }
            let newIMP = imp_implementationWithBlock(noop)
            _ = typeEncoding.withCString { typeEncodingPtr in
                class_replaceMethod(dynamicSubclass, selector, newIMP, typeEncoding)
            }
        }
        try token.apply()
        _AnyObject(object).addedMethods.insert(selector)
    }
    
    override func resetImplementation() throws {
        try token.revert()
        guard let object = object else { return }
        _AnyObject(object).addedMethods.remove(selector)
    }
    
    init(object: AnyObject, selector: Selector, hookClosure: AnyObject) throws {
        guard !object.responds(to: selector) else {
            throw NSObject.SwizzleError.unableToAddMethod(type(of: self), selector)
        }
        guard let typeEncoding = FZSwiftUtils.typeEncoding(for: selector, _class: type(of: object)) else {
            throw NSObject.SwizzleError.unknownError("typeEncoding for \(selector) of \(type(of: object)) failed")
        }
        self.typeEncoding = String(cString: typeEncoding)
        self.object = object
        self.token = try Hook(for: object, selector: selector, mode: .instead, hookClosure: hookClosure, check: false)
        try super.init(class: type(of: object), selector: selector, shouldValidate: false)
    }
}
 */
