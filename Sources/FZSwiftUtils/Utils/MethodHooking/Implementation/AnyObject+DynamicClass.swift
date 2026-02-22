//
//  DynamicClass.swift
//
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

func wrapDynamicClassIfNeeded(object: AnyObject) throws -> AnyClass {
    guard let baseClass = object_getClass(object) else {
        throw HookError.internalError(file: #file, line: #line)
    }

    guard DynamicClassContext[dynamic: baseClass] == nil else {
        return baseClass
    }
    
    let existingContext = DynamicClassContext[base: baseClass]
    let context: DynamicClassContext
    if let existingContext {
        context = existingContext
    } else {
        context = try DynamicClassContext(baseClass: baseClass)
    }
    object_setClass(object, context.dynamicClass)
    return context.dynamicClass
}

func unwrapDynamicClass(object: AnyObject) throws {
    guard let dynamicClass = object_getClass(object) else {
        throw HookError.internalError(file: #file, line: #line)
    }
    guard let context = DynamicClassContext[dynamic: dynamicClass] else {
        throw HookError.internalError(file: #file, line: #line)
    }
    object_setClass(object, context.baseClass)
}

fileprivate class DynamicClassContext {
    private static var byDynamicClass: [ObjectIdentifier: DynamicClassContext] = [:]
    private static var byClass: [ObjectIdentifier: DynamicClassContext] = [:]
    
    fileprivate let baseClass: AnyClass
    fileprivate let dynamicClass: AnyClass
    private let getClassHookContext: HookContext
    
    fileprivate init(baseClass: AnyClass) throws {
        self.baseClass = baseClass
        // Can't use `let dynamicClassName = "SwiftHook_" + "\(baseClass)"` here because the "\(baseClass)" doesn't contain namespace. There maybe some different class with the same className.
        let dynamicClassName = "SwiftHook_" + NSStringFromClass(baseClass)
        guard let dynamicClass = objc_allocateClassPair(baseClass, dynamicClassName, 0) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        objc_registerClassPair(dynamicClass)
        var deallocateHelper: AnyClass? = dynamicClass
        defer {
            if let deallocateHelper = deallocateHelper {
                objc_disposeClassPair(deallocateHelper)
            }
        }
        // Hook "Get Class"
        let selector = NSSelectorFromString("class")
        try overrideSuperMethodIfNeeded(selector, of: dynamicClass)
        getClassHookContext = try HookContext(targetClass: dynamicClass, selector: selector, isSpecifiedInstance: true)
        try getClassHookContext.append(hookClosure: {_, _, _ in
            return baseClass
        } as @convention(block) ((AnyObject, Selector) -> AnyClass, AnyObject, Selector) -> AnyClass as AnyObject, mode: .instead)
        self.dynamicClass = dynamicClass
        deallocateHelper = nil
        Self.byDynamicClass[dynamicClass] = self
        Self.byClass[baseClass] = self
    }
    
    deinit {
        objc_disposeClassPair(dynamicClass)
    }
    
    static subscript(base baseClass: AnyClass) -> DynamicClassContext? {
        byClass[baseClass]
    }
    
    static subscript(dynamic dynamicClass: AnyClass) -> DynamicClassContext? {
        byDynamicClass[dynamicClass]
    }
}
