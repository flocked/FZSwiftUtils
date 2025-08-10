//
//  ParametersCheck.swift
//
//
//  Created by Yanni Wang on 17/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation

extension Hook {
    private static let blacklistSelectors = [NSSelectorFromString("retain"), NSSelectorFromString("release"), NSSelectorFromString("autorelease")]
    private static let taggedPointerStringClass: AnyClass? = NSClassFromString("NSTaggedPointerString")
    
    static func parametersCheck(for object: AnyObject, selector: Selector, mode: HookMode, closure: AnyObject) throws {
        guard !(object is AnyClass) else {
            throw HookError.hookClassWithObjectAPI
        }
        guard let baseClass = object_getClass(object) else {
            throw HookError.internalError(file: #file, line: #line)
        }
        guard baseClass != taggedPointerStringClass else {
            throw HookError.hookInstanceOfNSTaggedPointerString
        }
        try parametersCheck(for: baseClass, selector: selector, mode: mode, closure: closure)
    }
    
    static func parametersCheck(for targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
        guard !blacklistSelectors.contains(selector) else {
            throw HookError.blacklist
        }
        let isHookingDeallocSelector = selector == .dealloc
        if isHookingDeallocSelector {
            guard targetClass is NSObject.Type else {
                throw HookError.pureSwiftObjectDealloc
            }
        }
        
        guard let method = class_getInstanceMethod(targetClass, selector) else {
            throw HookError.noRespondSelector
        }
        
        let methodSignature = try Signature(method: method)
        
        let closureSignature = try Signature(closure: closure)
        
        guard closureSignature.signatureType == .closure else {
            throw HookError.internalError(file: #file, line: #line)
        }
        guard methodSignature.signatureType == .method else {
            throw HookError.internalError(file: #file, line: #line)
        }
        
        let closureReturnType = closureSignature.returnType
        var closureArgumentTypes = closureSignature.argumentTypes
        let methodReturnType = methodSignature.returnType
        let methodArgumentTypes = methodSignature.argumentTypes
        
        guard methodArgumentTypes.count >= 2, closureArgumentTypes.count >= 1 else {
            throw HookError.internalError(file: #file, line: #line)
        }
        closureArgumentTypes.removeFirst()
        if isHookingDeallocSelector {
            switch mode {
            case .before:
                guard closureReturnType == .voidTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `before`, the hook closure must return `void`. Found `\(closureReturnType.code)`.")
                }
                guard closureArgumentTypes.isEmpty ||
                        (closureArgumentTypes.count == 1 && closureArgumentTypes.first == .objectTypeValue) else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `before`, the hook closure must have no parameters or a single parameter of type `AnyObject`. Found: `\(closureArgumentTypes.toSignatureString())`.")
                }
            case .after:
                guard closureReturnType == .voidTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `after`, the hook closure must return `void`. Found `\(closureReturnType.code)`.")
                }
                guard closureArgumentTypes.isEmpty else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `after`, the hook closure must have no parameters. Found: `\(closureArgumentTypes.toSignatureString())`.")
                }
            case .instead:
                // Original closure (first parameter)
                guard closureArgumentTypes.count == 1 else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the hook closure must have exactly one parameter: the original `dealloc` closure. Found \(closureArgumentTypes.count) parameters.")
                }
                let originalClosureType = closureArgumentTypes[0]
                guard originalClosureType == .closureTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the single parameter of the hook closure must be a closure (that represents the original `dealloc` implementation). Found: `\(originalClosureType.code)`.")
                }
                guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                    throw HookError.internalError(file: #file, line: #line)
                }
                closureArgumentTypes.removeFirst()
                
                let originalClosureReturnType = originalClosureSignature.returnType
                var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
                
                guard originalClosureReturnType == .voidTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the original closure (the hook closure`s parameter) must return `void`. Found: `\(originalClosureReturnType.code)`.")
                }
                guard originalClosureArgumentTypes.count >= 1 else {
                    throw HookError.internalError(file: #file, line: #line)
                }
                originalClosureArgumentTypes.removeFirst()
                guard originalClosureArgumentTypes.isEmpty else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the original closure (the hook closure`s parameter) must have no parameters (besides `self`). Found: `\(originalClosureArgumentTypes.toSignatureString())`.")
                }
                
                // Hook closure
                guard closureReturnType == .voidTypeValue else {
                    throw HookError.incompatibleClosureSignature("In `instead` mode for `dealloc`, the hook closure must return `void`. Found: `\(closureReturnType.code)`.")
                }
                guard closureArgumentTypes.isEmpty else {
                    throw HookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the hook closure must have no parameters besides the `original` closure parameter. Found: `\(closureArgumentTypes.toSignatureString())`.")
                }
            }
            
        } else {
            switch mode {
            case .before, .after:
                guard closureReturnType == .voidTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking using `\(mode.rawValue)`, the hook closure must return `void`. Found: `\(closureReturnType.code)`.")
                }
                guard closureArgumentTypes.isEmpty ||
                        closureArgumentTypes == Array.init(methodArgumentTypes[0..<2]) ||
                        closureArgumentTypes == methodArgumentTypes  else {
                    throw HookError.incompatibleClosureSignature("When hooking using `\(mode.rawValue)`, the hook closure parameters must be either empty, `(AnyObject, Selector)`, or match the method's parameters. Closure: `\(closureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
                }
            case .instead:
                // Original closure (first parameter)
                guard closureArgumentTypes.count == methodArgumentTypes.count + 1 else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure must have the same number of parameters as the method + one extra parameter: The first parameter is the `original` closure, followed by the parameters of the method. Found \(closureArgumentTypes.count) parameters, expected \(methodArgumentTypes.count + 1).")
                }
                let originalClosureType = closureArgumentTypes[0]
                guard originalClosureType == .closureTypeValue else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the first parameter of the hook closure must be a closure (the `original` closure). Found `\(originalClosureType.code)`.")
                }
                guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                    throw HookError.internalError(file: #file, line: #line)
                }
                closureArgumentTypes.removeFirst()
                
                let originalClosureReturnType = originalClosureSignature.returnType
                var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
                
                guard originalClosureReturnType == methodReturnType else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the `original` closure (the hook closure`s first parameter) must return the same type as the method. Original: `\(originalClosureReturnType.code)`, Method: `\(methodReturnType.code)`.")
                }
                guard originalClosureArgumentTypes.count >= 1 else {
                    throw HookError.internalError(file: #file, line: #line)
                }
                originalClosureArgumentTypes.removeFirst()
                guard originalClosureArgumentTypes == methodArgumentTypes else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the parameters of the `original` closure (the hook closure`s first parameter) must match the method parameters. Original: `\(originalClosureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
                }
                
                // Hook closure
                guard closureReturnType == methodReturnType else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure must return the same type as the method. Closure: `\(closureReturnType.code)`, Method: `\(methodReturnType.code)`.")
                }
                guard closureArgumentTypes == methodArgumentTypes else {
                    throw HookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure’s parameters (after the first `original` closure) must match the method’s parameters. Closure: `\(closureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
                }
            }
        }
    }
    
    static func parametersCheck(typeEncoding: UnsafePointer<CChar>, closure: AnyObject) throws {
        let closureSignature = try Signature(closure: closure)
        let methodSignature = try Signature(typeEncoding: typeEncoding)
        
        // let closureArguments = Array(closureSignature.argumentTypes.dropFirst(2))
        // let methodArguments = Array(methodSignature.argumentTypes.dropFirst(2))
        
        let methodEncoding = "@" + methodSignature.argumentTypes.toSignatureString().dropFirst(2)
        let closureEncoding = closureSignature.argumentTypes.toSignatureString().dropFirst(2)
        guard methodEncoding == closureEncoding else {
            throw HookError.incompatibleClosureSignature("When adding a method, the closure needs to have the same parameters as the original protocol method. Closure: \(closureSignature.argumentTypes.toSignatureString()), original: \(methodSignature.argumentTypes.toSignatureString())")
        }
        guard closureSignature.returnType == methodSignature.returnType else {
            throw HookError.incompatibleClosureSignature("When adding a method, The return type of the closure needs to have the same return type as the original protocol method. Closure: \(closureSignature.returnType.code), original: \(methodSignature.returnType.code)")
        }
    }
}


#endif
