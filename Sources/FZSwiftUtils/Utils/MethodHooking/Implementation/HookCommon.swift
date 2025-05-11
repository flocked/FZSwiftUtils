//
//  HookCommon.swift
//
//
//  Created by Yanni Wang on 24/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#if os(macOS) || os(iOS)
import Foundation

let hookSerialQueue = HookSerialQueue(label: "com.florianzand.FZSwiftUtils.HookSerialQueue")


final class HookSerialQueue {
    private let queue: DispatchQueue
    private let key = DispatchSpecificKey<Void>()

    init(label: String) {
        self.queue = DispatchQueue(label: label)
        self.queue.setSpecific(key: key, value: ())
    }

    func sync(_ block: () -> Void) {
        if DispatchQueue.getSpecific(key: key) != nil {
            block()
        } else {
            queue.sync(execute: block)
        }
    }

    func sync<T>(_ block: () -> T) -> T {
        if DispatchQueue.getSpecific(key: key) != nil {
            return block()
        } else {
            return queue.sync(execute: block)
        }
    }

    func async(_ block: @escaping () -> Void) {
        queue.async(execute: block)
    }
    
    
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        if DispatchQueue.getSpecific(key: key) != nil {
            return try block()
        } else {
            return try queue.sync(execute: block)
        }
    }
}

extension Selector {
    static let dealloc = NSSelectorFromString("dealloc")
}

enum HookError: Error {
    case hookClassWithObjectAPI // Can't hook class with object hooking API. Please use "hookClassMethod" instead.
    case blacklist // Unsupport to hook current method. Search "blacklistSelectors" to see all methods unsupport.
    case pureSwiftObjectDealloc // Technologically can't hook dealloc method for pure Swift Object with swizzling. Please use "hookDeInitAfterByTail" to hook pure swift object's dealloc method.
    case noRespondSelector // Can't find the method by the selector from the class.
    case emptyStruct // The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method.
    case wrongTypeForHookClosure // Please check the hook clousre. Is it a standard closure? Does it have keyword @convention(block)?
    case incompatibleClosureSignature(_ description: String) // Please check the hook closure if it match to the method.
    case duplicateHookClosure // This closure has been hooked with current mode already.
    case ffiError // The error from FFI. Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
    case internalError(file: String, line: Int) // Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
    case hookInstanceOfNSTaggedPointerString // Unsupport to hook instance of NSTaggedPointerString.
    case hookKVOUnsupportedInstance // Unable to hook a instance which is not support KVO.
    case nonObjcProperty // The partial keyPath isn't KVO / @objc.
}
#endif
