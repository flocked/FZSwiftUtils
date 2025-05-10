//
//  OverrideSuperMethodContext.swift
//
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation
import _Libffi

func overrideSuperMethodIfNeeded(_ selector: Selector, of targetClass: AnyClass) throws {
    guard getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil else { return }
    let overrideMethodContext = try OverrideMethodContext(targetClass: targetClass, selector: selector)
    OverrideMethodContext.pool.insert(overrideMethodContext)
}

fileprivate class OverrideMethodContext: Hashable {
    static var pool = Set<OverrideMethodContext>()
    
    fileprivate let targetClass: AnyClass
    fileprivate let selector: Selector
    
    fileprivate let methodCifContext: FFICIFContext
    fileprivate var methodClosureContext: FFIClosureContext!
    
    init(targetClass: AnyClass, selector: Selector) throws {
        self.targetClass = targetClass
        self.selector = selector
        
        // superMethod
        guard let superMethod = class_getInstanceMethod(self.targetClass, self.selector) else {
            // Tests: OverrideSuperMethodTests: testCanNotGetMethod
            throw HookError.internalError(file: #file, line: #line)
        }
        
        // Signature
        let methodSignature = try Signature(method: superMethod)
        
        // FFICIFContext
        self.methodCifContext = try FFICIFContext.init(signature: methodSignature)
        
        // FFIClosureContext
        self.methodClosureContext = try FFIClosureContext.init(cif: self.methodCifContext.cif, userData: Unmanaged.passUnretained(self).toOpaque(), fun: overrideMethodCalled)
        
        // add Method
        guard class_addMethod(self.targetClass, self.selector, self.methodClosureContext.targetIMP, method_getTypeEncoding(superMethod)) else {
            throw HookError.internalError(file: #file, line: #line)
        }
    }
        
    static func == (lhs: OverrideMethodContext, rhs: OverrideMethodContext) -> Bool {
        lhs.targetClass == rhs.targetClass && lhs.selector == rhs.selector
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(targetClass))
        hasher.combine(selector)
    }
}

fileprivate func overrideMethodCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                                  ret: UnsafeMutableRawPointer?,
                                  args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                                  userdata: UnsafeMutableRawPointer?) {
    guard let userdata = userdata else {
        assert(false)
        return
    }
    let overrideMethodContext = Unmanaged<OverrideMethodContext>.fromOpaque(userdata).takeUnretainedValue()
    guard let sueprClass = class_getSuperclass(overrideMethodContext.targetClass) else {
        assert(false)
        return
    }
    guard let methodIMP = class_getMethodImplementation(sueprClass, overrideMethodContext.selector) else {
        assert(false)
        return
    }
    ffi_call(overrideMethodContext.methodCifContext.cif, unsafeBitCast(methodIMP, to: (@convention(c) () -> Void).self), ret, args)
}
#endif
